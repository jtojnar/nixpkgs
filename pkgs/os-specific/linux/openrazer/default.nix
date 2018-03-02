{ stdenv
, cmake
, ninja
, fetchFromGitHub
, pkgconfig
, txt2tags
}:

let
  version = "2.2.2";
in stdenv.mkDerivation rec {
  name = "openrazer-${version}";

  src = fetchFromGitHub {
    owner = "openrazer";
    repo = "openrazer";
    rev = "1ae06410180320a5d0e7408a8d1a6ae2aa443c23";
    sha256 = "03yk419gj0767lpk6zvla4jx3nx56zsg4x4adl4nd50xhn409rcc";
  };

  nativeBuildInputs = [
    cmake
    ninja
  ];

  buildInputs = [
  ];

  # cmakeFlags = [
  #   "-DCMAKE_BUILD_TYPE='Release'"
  #   "-DUDEV_BIN_DIR=$out/bin"
  #   "-DUDEV_RULES_DIR=$out/udev"
  # ];

  meta = {
    description = "Thunderbolt(TM) user-space components";
    license = stdenv.lib.licenses.bsd3;
    maintainers = [ stdenv.lib.maintainers.ryantrinkle ];
    homepage = https://01.org/thunderbolt-sw;
    platforms = stdenv.lib.platforms.linux;
  };
}
