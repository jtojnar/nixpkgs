{ stdenv
, fetchFromGitHub
, lib
, autoreconfHook
}:

stdenv.mkDerivation rec {
  name = "libiff";
  version = "0.1";
  src = fetchFromGitHub {
    owner = "svanderburg";
    repo = name;
    rev = "b5f542a83c824f26e0816770c9a17c22bd388606";
    sha256 = "sha256-Arh3Ihd5TWg5tdemodrxz2EDxh/hwz9b2/AvrTONFy8=";
  };
  patches = [
    ./no-binary-builds.patch
  ];
  nativeBuildInputs = [ autoreconfHook ];
  meta = with lib; {
    description  = "Parser for the Interchange File Format (IFF)";
    longDescription = ''
      libiff is a portable, extensible parser library implemented in
      ANSI C, for EA-IFF 85: Electronic Arts' Interchange File Format
      (IFF).
    '';
    homepage    = "https://github.com/svanderburg/libiff";
    maintainers = with maintainers; [ _414owen ];
    platforms   = platforms.all;
    license     = licenses.mit;
  };
}
