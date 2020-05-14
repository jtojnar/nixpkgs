{ stdenv
, fetchurl
, gettext
, meson
, ninja
, pkgconfig
, gobject-introspection
, python3
, gtk-doc
, docbook_xsl
, docbook_xml_dtd_45
, asciidoc
, libxml2
, glib
, wrapGAppsHook
, vala
, sqlite
, libxslt
, libstemmer
, gnome3
, icu
, libuuid
, libsoup
, json-glib
, systemd
, dbus
}:

let
  testUtilsPath = "${placeholder "dev"}/lib/tracker";
in
stdenv.mkDerivation rec {
  pname = "tracker";
  version = "2.99.1";

  outputs = [ "out" "dev" "devdoc" ];

  src = fetchurl {
    url = "mirror://gnome/sources/${pname}/${stdenv.lib.versions.majorMinor version}/${pname}-${version}.tar.xz";
    sha256 = "mLY0kQfkxDQFkqZGNQAbGh5ivQTS2duSGn4SF8rK6cM=";
  };

  nativeBuildInputs = [
    meson
    ninja
    vala
    pkgconfig
    gettext
    libxslt
    wrapGAppsHook
    gobject-introspection
    gtk-doc
    docbook_xsl
    docbook_xml_dtd_45
    asciidoc
    python3 # for data-generators
    systemd # used for checks to install systemd user service
    dbus # used for checks and pkgconfig to install dbus service/s
  ];

  buildInputs = [
    glib
    libxml2
    sqlite
    icu
    libsoup
    libuuid
    json-glib
    libstemmer
    gobject-introspection # for glib typelibs
  ];

  checkInputs = [
    python3.pkgs.pygobject3
  ];

  mesonFlags = [
    "-Dtest_utils_dir=${testUtilsPath}"
  ];

  doCheck = true;

  postPatch = ''
    patchShebangs utils/data-generators/cc/generate
    patchShebangs tests/functional-tests/test-runner.sh.in
    patchShebangs tests/functional-tests/*.py

    # https://gitlab.gnome.org/GNOME/tracker/issues/207
    substituteInPlace docs/manpages/meson.build --replace "/etc/asciidoc" "${asciidoc}/etc/asciidoc"
  '';

  preCheck = ''
    # (tracker-store:6194): Tracker-CRITICAL **: 09:34:07.722: Cannot initialize database: Could not open sqlite3 database:'/homeless-shelter/.cache/tracker/meta.db': unable to open database file
    export HOME=$(mktemp -d)

    # Our gobject-introspection patches make the shared library paths absolute
    # in the GIR files. When running functional tests, the library is not yet installed,
    # though, so we need to replace the absolute path with a local one during build.
    # We are using a symlink that will be overridden during installation.
    mkdir -p $out/lib
    ln -s $PWD/src/libtracker-sparql-backend/libtracker-sparql-3.0.so $out/lib/libtracker-sparql-3.0.so.0
    ln -s $PWD/src/libtracker-data/libtracker-data.so $out/lib/libtracker-data.so
  '';

  checkPhase = ''
    runHook preCheck

    # Functional tests require dbus session.
    dbus-run-session \
      --config-file=${dbus.daemon}/share/dbus-1/session.conf \
      meson test --print-errorlogs

    runHook postCheck
  '';

  postCheck = ''
    # Clean up out symlinks
    rm -r $out/lib
  '';

  postFixup = ''
    gappsWrapperArgs+=(--set NIX_PYTHONPATH "$PYTHONPATH")
    wrapGApp ${testUtilsPath}/trackertestutils/tracker-sandbox
  '';

  passthru = {
    updateScript = gnome3.updateScript {
      packageName = pname;
      versionPolicy = "none";
    };
  };

  meta = with stdenv.lib; {
    homepage = "https://wiki.gnome.org/Projects/Tracker";
    description = "Desktop-neutral user information store, search tool and indexer";
    maintainers = teams.gnome.members;
    license = licenses.gpl2Plus;
    platforms = platforms.linux;
  };
}
