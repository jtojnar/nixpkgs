{ stdenv
, lib
, fetchFromGitHub
, fetchpatch
, ocamlPackages
, pkg-config
, autoconf
, automake
}:

stdenv.mkDerivation rec {
  pname = "coccinelle";
  version = "1.1.1";

  src = fetchFromGitHub {
    owner = "coccinelle";
    repo = "coccinelle";
    rev = version;
    sha256 = "rS9Ktp/YcXF0xUtT4XZtH5F9huvde0vRztY7vGtyuqY=";
  };

  patches = [
    # Fix data path lookup.
    # https://github.com/coccinelle/coccinelle/pull/270
    (fetchpatch {
      url = "https://github.com/coccinelle/coccinelle/commit/2fb5fd176c3a8b79b6b3648bdffe9c6761f3136c.patch";
      sha256 = "+kGQmAVpQRmnf2LZzVIzJtblaq1UbQ/5u85HFlYcl5E=";
    })
  ];

  nativeBuildInputs = with ocamlPackages; [
    pkg-config
    autoconf
    automake
    ocaml
    findlib
    menhir
  ];

  buildInputs = with ocamlPackages; [
    pyml
    ocaml_pcre
    parmap
    stdcompat
  ];

  doCheck = false;
  strictDeps = true;

  preConfigure = ''
    ./autogen
  '';

  meta = {
    description = "Program to apply semantic patches to C code";
    longDescription = ''
      Coccinelle is a program matching and transformation engine which
      provides the language SmPL (Semantic Patch Language) for
      specifying desired matches and transformations in C code.
      Coccinelle was initially targeted towards performing collateral
      evolutions in Linux.  Such evolutions comprise the changes that
      are needed in client code in response to evolutions in library
      APIs, and may include modifications such as renaming a function,
      adding a function argument whose value is somehow
      context-dependent, and reorganizing a data structure.  Beyond
      collateral evolutions, Coccinelle is successfully used (by us
      and others) for finding and fixing bugs in systems code.
    '';

    homepage = "https://coccinelle.gitlabpages.inria.fr/website/";
    license = lib.licenses.gpl2Only;
    platforms = lib.platforms.unix;
    maintainers = [ lib.maintainers.thoughtpolice ];
  };
}
