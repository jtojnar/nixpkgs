{ stdenv, appimage-run, fetchurl, runtimeShell }:

let
  version = "4.3.2";

  plat = {
    "x86_64-linux" = "x86_64";
  }.${stdenv.hostPlatform.system};

  sha256 = {
    "x86_64-linux" = "0jil1miwk4sh8gpp1b2p9kd3faq3364682dbyf302kj6al2ii7r7";
  }.${stdenv.hostPlatform.system};
in

stdenv.mkDerivation rec {
  name = "pingendo-${version}";

  src = fetchurl {
    url = "https://github.com/Pingendo/pingendo/releases/download/v${version}/Pingendo-${version}-${plat}.AppImage";
    inherit sha256;
  };

  buildInputs = [ appimage-run ];

  unpackPhase = ":";

  installPhase = ''
    mkdir -p $out/{bin,share}
    cp $src $out/share/Pingendo.AppImage
    echo "#!${runtimeShell}" > $out/bin/pingendo
    echo "${appimage-run}/bin/appimage-run $out/share/Pingendo.AppImage" >> $out/bin/pingendo
    chmod +x $out/bin/pingendo $out/share/Pingendo.AppImage
  '';

  meta = with stdenv.lib; {
    description = "WYSIWYG HTML5 editor focused on Bootstrap UI";
    longDescription = ''
      Standard Notes is a private notes app that features unmatched simplicity,
      end-to-end encryption, powerful extensions, and open-source applications.
    '';
    homepage = https://standardnotes.org;
    license = licenses.unfree;
    maintainers = with maintainers; [ mgregoire ];
    platforms = [ "x86_64-linux" ];
  };
}
