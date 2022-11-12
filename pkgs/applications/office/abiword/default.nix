{ lib
, stdenv
, fetchurl
, fetchpatch
, pkg-config
, gtk3
, fribidi
, libpng
, popt
, libgsf
, enchant
, wv
, librsvg
, bzip2
, libjpeg
, perl
, boost
, libxslt
, goffice
, autoconf
, automake
, libtool
, autoconf-archive
, wrapGAppsHook
}:

stdenv.mkDerivation rec {
  pname = "abiword";
  version = "3.0.5";

  src = fetchurl {
    url = "https://www.abisource.com/downloads/abiword/${version}/source/abiword-${version}.tar.gz";
    hash = "sha256-ElckfplwUI1tFFbT4zDNGQnEtCsl4PChvDJSbW86IbQ=";
  };


  nativeBuildInputs = [
    pkg-config
    autoconf
    automake
    libtool
    autoconf-archive
    wrapGAppsHook
    perl
  ];

  buildInputs = [
    gtk3
    librsvg
    bzip2
    fribidi
    libpng
    popt
    libgsf
    enchant
    wv
    libjpeg
    boost
    libxslt
    goffice
  ];

  configureFlags = [
    "--enable-plugins=auto"
  ];

  enableParallelBuilding = true;

  postPatch = ''
    patchShebangs \
      tools/cdump/xp/cdump.pl \
      po/ui-backport.pl
  '';

  preConfigure = ''
    NOCONFIGURE=1 ./autogen.sh
  '';

  meta = with lib; {
    description = "Word processing program, similar to Microsoft Word";
    homepage = "https://www.abisource.com/";
    license = licenses.gpl3;
    platforms = platforms.linux;
    maintainers = with maintainers; [ pSub ylwghst sna ];
  };
}
