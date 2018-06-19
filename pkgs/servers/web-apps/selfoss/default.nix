{ stdenv, fetchurl, unzip }:

stdenv.mkDerivation rec {
  name = "selfoss-${version}";
  version = "2.18";

  src = fetchurl {
    url = https://bintray.com/fossar/selfoss/download_file?file_path=selfoss-2.19-cdd9125.zip;
    sha256 = "11l5nryp6iw1jrkmx7zg77dfcnva85dz1z99fr439rjrcv12k8xn";
  };

  patches = [
    /home/jtojnar/Projects/selfoss/1043.patch
    /home/jtojnar/Projects/selfoss/moo2.patch
  ];

  sourceRoot = ".";
  nativeBuildInputs = [ unzip ];

  installPhase = ''
    mkdir $out
    cp -ra * $out/
  '';

  meta = with stdenv.lib; {
    description = "Web-based news feed (RSS/Atom) aggregator";
    homepage = https://selfoss.aditu.de;
    license = licenses.gpl3;
    maintainers = with maintainers; [ jtojnar regnat ];
    platforms = platforms.all;
  };
}
