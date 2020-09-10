{ stdenv
, fetchurl
, perl
, zlib
}:

stdenv.mkDerivation rec {
  pname = "hspell";
  version = "1.1";

  src = fetchurl {
    url = "${meta.homepage}${pname}-${version}.tar.gz";
    sha256 = "08x7rigq5pa1pfpl30qp353hbdkpadr1zc49slpczhsn0sg36pd6";
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
