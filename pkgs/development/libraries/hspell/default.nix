{ stdenv
, fetchurl
, perl
, zlib
}:

stdenv.mkDerivation rec {
  pname = "hspell";
  version = "1.4";

  src = fetchurl {
    url = "${meta.homepage}${pname}-${version}.tar.gz";
    sha256 = "18xymabvwr47gi4w2sw1galpvvq2hrjpj4aw45nivlj0hzaza43k";
  };

  nativeBuildInputs = [
    perl
  ];

  buildInputs = [
    zlib
  ];

  strictDeps = true;

  # Can't locate PrefixBits.pl in @INC […] at ./pmerge line 11.
  PERL_USE_UNSAFE_INC = "1";

  configureFlags = [
    "--enable-shared"
  ];

  postPatch = ''
    patchShebangs --build \
      pmerge \
      wzip
  '';

  meta = with stdenv.lib; {
    description = "Hebrew spell checker";
    homepage = "http://hspell.ivrix.org.il/";
    platforms = platforms.all;
    license = licenses.agpl3Only;
  };
}
