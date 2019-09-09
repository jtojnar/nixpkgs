{ stdenv
, lib
, variant ? "libzbar"
, fetchFromGitHub
, imagemagickBig
, pkgconfig
, python2Packages
, perl
, libX11
, libv4l
, qt5
, gtk2
, xmlto
, docbook_xsl
, autoreconfHook
, dbus
, enableVideo ? stdenv.isLinux
, enableDbus ? stdenv.isLinux
}:

let
  inherit (python2Packages) pygtk python;

  variants = {
    libzbar = {
      targets = [
        "zbar/zbar"
      ];
    };

    zbarimg = {
      targets = [
        "zbarimg/zbarimg"
      ];

      deps = [
        imagemagickBig
      ];
    };

    zbarcam = {
      targets = [
        "zbarcam/zbarcam"
      ];

      deps = [
        imagemagickBig
      ];
    };
    python
    zbarcam-gtk
    libzbar-gtk
    zbarcam-qt
    libzbar-qt
  };
in
stdenv.mkDerivation rec {
  pname = "zbar";
  version = "0.23";

  src = fetchFromGitHub {
    owner = "mchehab";
    repo = "zbar";
    rev = version;
    sha256 = "0hlxakpyjg4q9hp7yp3har1n78341b4knwyll28hn48vykg28pza";
  };

  nativeBuildInputs = [
    pkgconfig
    xmlto
    autoreconfHook
    docbook_xsl
  ];

  buildInputs = [
  #   python
  #   pygtk
  #   perl
  #   libX11
  # ] ++ optional enableDbus dbus
  # ++ optionals enableVideo [
  #   libv4l
  #   gtk2
  #   qt5.qtbase
  #   qt5.qtx11extras
  ];

  configureFlags = [
    (lib.withFeature (variant == "zbarimg") "imagemagick")
    (lib.enableFeature (variant == "zbarcam") "video")
    (lib.withFeature (variant == "python") "python")
    (lib.withFeature (variant == "zbarcam-gtk" || variant == "libzbar-gtk") "gtk")
    (lib.withFeature (variant == "zbarcam-qt" || variant == "libzbar-qt") "qt")
  ];
  # (if enableDbus then [
  #   "--with-dbusconfdir=${placeholder "out"}/etc/dbus-1/system.d"
  # ] else [
  #   "--without-dbus"
  # ]) ++ optionals (!enableVideo) [
  #   "--disable-video"
  #   "--without-gtk"
  #   "--without-qt"
  # ];

  meta = with lib; {
    description = "Bar code reader";
    longDescription = ''
      ZBar is an open source software suite for reading bar codes from various
      sources, such as video streams, image files and raw intensity sensors. It
      supports many popular symbologies (types of bar codes) including
      EAN-13/UPC-A, UPC-E, EAN-8, Code 128, Code 39, Interleaved 2 of 5 and QR
      Code.
    '';
    maintainers = with maintainers; [ delroth raskin ];
    platforms = platforms.unix;
    license = licenses.lgpl21;
    homepage = https://github.com/mchehab/zbar;
  };
}
