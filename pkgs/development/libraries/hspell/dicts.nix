{ stdenv, hspell }:

let
  dict = variant: a: hspell.overrideAttrs (orig: a // {
    buildFlags = [ variant ];

    meta = orig.meta // {
      description = "${variant} Hebrew dictionary";
    } // (a.meta or {});
  });
in
{
  recurseForDerivations = true;

  aspell = dict "aspell" {
    name = "aspell-dict-he-${hspell.version}";

    installPhase = ''
      runHook preInstall
      mkdir -p $out/lib/aspell
      cp -v he_affix.dat he.wl $out/lib/aspell
      runHook postInstall
    '';
  };

  myspell = dict "myspell" {
    name = "myspell-dict-he-${hspell.version}";

    installPhase = ''
      runHook preInstall
      mkdir -p $out/lib/myspell
      cp -v he.dic he.aff $out/lib/myspell
      runHook postInstall
    '';
  };

  hunspell = dict "hunspell" {
    name = "hunspell-dict-he-${hspell.version}";

    installPhase = ''
      runHook preInstall
      mkdir -p $out/lib
      cp -rv hunspell $out/lib
      runHook postInstall
    '';
  };
}
