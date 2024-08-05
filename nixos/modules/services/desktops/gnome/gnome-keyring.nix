# GNOME Keyring daemon.

{
  config,
  pkgs,
  lib,
  ...
}:
let
  cfg = config.services.gnome.gnome-keyring;
  package = pkgs.gnome-keyring.override { enableDev = true; };
in
{

  meta = {
    maintainers = lib.teams.gnome.members;
  };

  options = {
    services.gnome.gnome-keyring = {
      enable = lib.mkEnableOption ''
        GNOME Keyring daemon, a service designed to
        take care of the user's security credentials,
        such as user names and passwords
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = [ package ];

    services.dbus.packages = [
      package
      pkgs.gcr
    ];

    xdg.portal.extraPortals = [ package ];

    security.pam.services.login.enableGnomeKeyring = true;

    security.wrappers.gnome-keyring-daemon = {
      owner = "root";
      group = "root";
      capabilities = "cap_ipc_lock=ep";
      source = "${package}/bin/gnome-keyring-daemon";
    };
  };
}
