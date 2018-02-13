{ mkDerivation
, lib
, fetchFromGitHub
, qtbase
, qmake
}:

mkDerivation rec {
  name = "mpris-tester-unstable-2015-10-14";

  src = fetchFromGitHub {
    owner = "randomguy3";
    repo = "mpristester";
    rev = "a1edbd414b9ee066c007b155852e04ec9409b375";
    sha256 = "19xyfvq1vgj66qj3wfq1mva6jy04ixgahl4cmg6540agacjrjr7h";
  };

  nativeBuildInputs = [ qmake ];

  buildInputs = [ qtbase ];

  installPhase = ''
    install -D -m755 mpristester "$out/bin/mpristester"
  '';

  meta = with lib; {
    description = "A developer tool for testing the MPRIS interface of media players";
    license = licenses.gpl2Plus;
    maintainers = with maintainers; [ jtojnar ];
    platforms = platforms.linux;
  };
}
