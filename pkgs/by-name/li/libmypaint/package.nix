{
  lib,
  stdenv,
  autoconf,
  meson,
  doxygen,
  sphinx,
  ninja,
  gobject-introspection,
  automake,
  fetchFromGitHub,
  glib,
  gegl,
  intltool,
  json_c,
  libtool,
  pkg-config,
  python3,
}:

let
  withMeson = true;
in
stdenv.mkDerivation rec {
  pname = "libmypaint";
  version = "1.6.1";

  outputs = [
    "out"
    "dev"
  ];

  src = /home/jtojnar/Projects/libmypaint;

  nativeBuildInputs =
    (
      if withMeson then
        [
          meson
          ninja
        ]
      else
        [
          autoconf
          automake
          glib # AM_GLIB_GNU_GETTEXT
          intltool
          libtool
        ]
    )
    ++ [
      doxygen
      sphinx
      python3.pkgs.breathe
      gobject-introspection
      pkg-config
      python3
    ];

  buildInputs = [
    glib
    gegl
  ];

  # for libmypaint.pc
  propagatedBuildInputs = [
    json_c
  ];

  configureFlags = [
    "--enable-docs"
    "--enable-gegl"
  ];

  doCheck = true;

  preConfigure = if !withMeson then "./autogen.sh" else null;

  meta = with lib; {
    homepage = "http://mypaint.org/";
    description = "Library for making brushstrokes which is used by MyPaint and other projects";
    license = licenses.isc;
    maintainers = with maintainers; [ jtojnar ];
    platforms = platforms.unix;
  };
}
