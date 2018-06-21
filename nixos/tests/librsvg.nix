# run installed tests
import ./make-test.nix ({ pkgs, lib, ... }: {
  name = "librsvg";

  meta = {
    maintainers = pkgs.librsvg.meta.maintainers;
  };

  machine = { pkgs, ... }: {
    environment.systemPackages = with pkgs; [
      gnome-desktop-testing
    ];
  };

  testScript = ''
    $machine->succeed("gnome-desktop-testing-runner -d ${pkgs.librsvg.installedTests}/share");
  '';
})
