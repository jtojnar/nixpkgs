let
  testApp = {writeShellApplication}:
    writeShellApplication {
      name = "test.sh";
      text = "echo hi";
    };

  packageSet = {callPackage}: {
    test = callPackage testApp {};
  };

  overlaidSet = import ./. {
    overlays = [
      (final: prev: let
        nested = prev.callPackages packageSet {};
        crash = !true;
      in
      if crash then
        prev.lib.trace (builtins.attrNames nested) { test = nested.test; }
      else
        { test = prev.lib.trace (builtins.attrNames nested) nested.test; })
    ];
  };
in {
  fromOverlaySet = overlaidSet.test;
}
