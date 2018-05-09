{ stdenv, fetchFromGitHub }:

stdenv.mkDerivation rec {
  name = "deepin-sound-theme-${version}";
  version = "15.10.2";

  src = fetchFromGitHub {
    owner = "linuxdeepin";
    repo = "deepin-sound-theme";
    rev = version;
    sha256 = "1j0mwbfw7948n6hh02ipynfl54w9sqka21l5zqg8s3691gdfmnfp";
  };

  makeFlags = [ "PREFIX=$(out)" ];

  meta = with stdenv.lib; {
    description = "Deepin sound theme";
    homepage = https://github.com/linuxdeepin/deepin-sound-theme;
    license = licenses.gpl3;
    maintainers = with maintainers; [ jtojnar ];
    platforms = platforms.unix;
  };
}
