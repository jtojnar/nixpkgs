{ lib
, fetchFromGitHub
, autoreconfHook
, pkgconfig
, wrapGAppsHook
, python3
, gtk3
}:

let
  bibtexparser = python3.pkgs.buildPythonPackage rec {
    pname = "bibtexparser";
    version = "0.6.2-2ce301e";
    name = "${pname}-${version}";

    src = fetchFromGitHub {
      repo = "python-bibtexparser";
      owner = "sciunto";
      rev = "2ce301ecd01f4db0cb355abc36486ab0c5c62331";
      sha256 = "0bjkr6s762si9vg5vyaksdq9bx12pmxdhd0zvjsfh203jka9jvan";
    };

    propagatedBuildInputs = with python3.pkgs; [ pyparsing ];

    meta = {
      description = "Bibtex parser for python 2.7 and 3.3 and newer";
      homepage = https://github.com/sciunto-org/python-bibtexparser;
      license = with lib.licenses; [ gpl3 bsd3 ];
    };
  };
  version = "0.3-dc90d7f";
in python3.pkgs.buildPythonApplication rec {
  name = "mkbib-${version}";
  src = fetchFromGitHub {
    owner = "rudrab";
    repo = "MkBiB";
    rev = "dc90d7fe66749b9ff0a6259efed8bb376c5cc15a";
    sha256 = "0zl04nqqwjk7pnfxf6hfx5q3fawa7wck3zggbyrfxq9l8n07dh9m";
  };
  format = "other";

  nativeBuildInputs = [ autoreconfHook pkgconfig wrapGAppsHook ];
  buildInputs = [
    gtk3
  ];
  propagatedBuildInputs = with python3.pkgs; [
    pygobject3
    pypdf2
    bibtexparser
    requests
  ];

  meta = {
    homepage = https://rudrab.github.io/MkBiB/;
    description = "GTK bibtex manager.";
    maintainers = with lib.maintainers; [ jtojnar ];
    license = lib.licenses.unfree; # No license is specified
  };
}
