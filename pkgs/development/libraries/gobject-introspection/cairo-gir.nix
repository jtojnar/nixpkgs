{
  stdenv,
  lib,
  gobject-introspection,
  meson,
  ninja,
  python3,
  pkg-config,
  glib,
  cairo,
  gnome,
}:

stdenv.mkDerivation rec {
  pname = "gobject-introspection-cairo";
  inherit (gobject-introspection) version;

  outputs = [ "out" "dev" ];

  inherit (gobject-introspection) src;

  patches = [
    # Do not build anything other than girs
    # and use system g-ir-compiler.
    ./only-girs.patch
  ];

  nativeBuildInputs = [
    meson
    ninja
    python3
    pkg-config
    gobject-introspection
  ];

  buildInputs = [
    glib
    cairo
  ];

  mesonFlags = gobject-introspection.mesonFlags ++ [
    # Hardcode the cairo shared library path in the Cairo gir shipped with this package.
    # https://github.com/NixOS/nixpkgs/issues/34080
    "-Dcairo_libname=${lib.getLib cairo}/lib/libcairo-gobject${stdenv.targetPlatform.extensions.sharedLibrary}"
  ];

  ninjaFlags = [
    # Only build the cairo typelib.
    "gir/cairo-1.0.typelib"
  ];

  installPhase = ''
    runHook preInstall

    # Meson currently does not support installing specific targets.
    # https://github.com/mesonbuild/meson/issues/1682
    install -Dt "$dev/share/gir-1.0/" gir/cairo-1.0.gir
    install -Dt "$out/lib/girepository-1.0" gir/cairo-1.0.typelib

    runHook postInstall
  '';

  meta = with lib; {
    description = "GObject introspection annotations for Cairo";
    homepage = "https://gi.readthedocs.io/";
    maintainers = teams.gnome.members;
    platforms = platforms.unix;
    license = cairo.meta.license;
  };
}
