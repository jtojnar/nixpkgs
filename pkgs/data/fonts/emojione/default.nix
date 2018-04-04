{ stdenv, fetchurl }:

let
  version = "3.1.2";

  src = fetchurl {
    url = "https://github.com/emojione/emojione-assets/releases/download/${version}/emojione-android.ttf";
    sha256 = "0f8i68wnmx40ln1nsidb1fifqxfqz06f4qk58z4vqxiqhx1imyvf";
  };
in stdenv.mkDerivation {
  name = "emojione-${version}";

  phases = [ "installPhase" ];

  installPhase = ''
    install -Dm644 "${src}" "$out/share/fonts/truetype/emojione-android.ttf"
  '';

  meta = with stdenv.lib; {
    description = "Emoji set";
    homepage = https://emojione.com/;
    license = licenses.unfree; # https://www.emojione.com/developers/free-license
    platforms = platforms.all;
    maintainers = with maintainers; [ abbradar ];
  };
}
