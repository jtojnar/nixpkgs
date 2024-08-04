{
  lib,
  fetchFromGitHub,
  fetchpatch,
  gtk3,
  gettext,
  json_c,
  lcms2,
  libpng,
  librsvg,
  gobject-introspection,
  libmypaint,
  hicolor-icon-theme,
  mypaint-brushes,
  gdk-pixbuf,
  pkg-config,
  python3,
  swig,
  wrapGAppsHook3,
  dbus,
  xvfb-run,
}:

let
  inherit (python3.pkgs)
    pycairo
    pygobject3
    numpy
    buildPythonApplication
    ;
in
buildPythonApplication rec {
  pname = "mypaint";
  version = "2.0.1";
  format = "other";

  # src = fetchFromGitHub {
  #   owner = "mypaint";
  #   repo = "mypaint";
  #   rev = "c9b9e31c1d969cab6e5275aba47b9bffc0ad6436";
  #   hash = "sha256-g56TFmAmKZGqgpoMl53eNzjNG25IQP4BRsrhrzoIdVo=";
  #   fetchSubmodules = true;
  # };
  src = /home/jtojnar/Projects/mypaint;

  nativeBuildInputs = [
    gettext
    pkg-config
    swig
    wrapGAppsHook3
    gobject-introspection # for setup hook
    hicolor-icon-theme # fór setup hook
    python3.pkgs.setuptools
  ];

  buildInputs = [
    gtk3
    gdk-pixbuf
    libmypaint
    mypaint-brushes
    json_c
    lcms2
    libpng
    librsvg
    pycairo
    pygobject3

    # Mypaint checks for a presence of this theme scaffold and crashes when not present.
    hicolor-icon-theme
  ];

  propagatedBuildInputs = [
    numpy
    pycairo
    pygobject3
  ];

  nativeCheckInputs = [
    gtk3
    python3.pkgs.nose
    python3.pkgs.isort
    python3.pkgs.black
    python3.pkgs.flake8
    python3.pkgs.pytest
    python3.pkgs.flake8-bugbear

    dbus
    xvfb-run
  ];

  buildPhase = ''
    runHook preBuild

    ${python3.interpreter} setup.py build

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    ${python3.interpreter} setup.py managed_install --prefix=$out

    runHook postInstall
  '';

  # tests require unmaintained and removed nose, it should switch to pytest
  # https://github.com/mypaint/mypaint/issues/1191
  doCheck = false;

  checkPhase = ''
    runHook preCheck

    pwd
    PYTHONPATH=$out/lib/mypaint:$PYTHONPATH \
    HOME=$TEMPDIR NO_AT_BRIDGE=1 \
      xvfb-run -s '-screen 0 800x600x24' dbus-run-session \
        --config-file=${dbus}/share/dbus-1/session.conf \
      nosetests --with-doctest --verbosity=2
    HOME=$TEMPDIR ${python3.interpreter} setup.py test

    runHook postCheck
  '';

  meta = {
    description = "Graphics application for digital painters";
    homepage = "http://mypaint.org/";
    license = lib.licenses.gpl2Plus;
    platforms = lib.platforms.linux;
    maintainers = with lib.maintainers; [ jtojnar ];
  };
}
