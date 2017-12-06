{ stdenv, fetchurl, itstool, python3, intltool, wrapGAppsHook
, libxml2, gobjectIntrospection, gtk3, gnome3, cairo, file
, dbus, xvfb_run }:

let
  minor = "3.18";
  version = "${minor}.0";
  inherit (python3.pkgs) buildPythonApplication pycairo pygobject3 pytest;
in buildPythonApplication rec {
  name = "meld-${version}";

  src = fetchurl {
    url = "mirror://gnome/sources/meld/${minor}/meld-${version}.tar.xz";
    sha256 = "0gi2jzgsrd5q2icyp6wphbn532ddg82nxhfxlffkniy7wnqmi0c4";
  };

  # Tests do not work with 3.18; 3.19-dev is fine.
  doCheck = false;

  nativeBuildInputs = [ intltool wrapGAppsHook itstool libxml2 file ];
  buildInputs = [
    gnome3.gtksourceview gnome3.gsettings_desktop_schemas pycairo cairo
    gnome3.defaultIconTheme gnome3.dconf
  ];
  checkInputs = [ xvfb_run pytest dbus.daemon ];
  propagatedBuildInputs = [ gobjectIntrospection pygobject3 gtk3 ];

  installPhase = ''
    runHook preInstall
    python setup.py install --prefix=$out
    runHook postInstall
  '';

  checkPhase = ''
    runHook preCheck
    # Unable to create user data directory '/homeless-shelter/.local/share' for storing the recently used files list: Permission denied
    mkdir test-home
    export HOME=$(pwd)/test-home

    # GLib.GError: gtk-icon-theme-error-quark: Icon 'meld-change-apply-right' not present in theme Adwaita
    export XDG_DATA_DIRS="$out/share:$XDG_DATA_DIRS"

    # Gtk-CRITICAL **: gtk_icon_theme_get_for_screen: assertion 'GDK_IS_SCREEN (screen)' failed
    xvfb-run -s '-screen 0 800x600x24' dbus-run-session \
      --config-file=${dbus.daemon}/share/dbus-1/session.conf \
      py.test
    runHook postCheck
  '';

  meta = with stdenv.lib; {
    description = "Visual diff and merge tool";
    homepage = http://meldmerge.org/;
    license = licenses.gpl2;
    platforms = platforms.linux ++ platforms.darwin;
    maintainers = with maintainers; [ jtojnar mimadrid ];
  };
}
