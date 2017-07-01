{ stdenv, fetchFromGitHub, pythonPackages, docbook2x, libxslt, gnome_doc_utils
, intltool, dbus_glib, gtk3, dbus, wrapGAppsHook
}:

# TODO: Add optional dependency 'wnck', for "workspace tracking" support. Fixes
# this message:
#
#   WARNING:root:Could not import wnck - workspace tracking will be disabled

pythonPackages.buildPythonApplication rec {
  name = "hamster-time-tracker";
  version = "2.0";

  src = fetchFromGitHub {
    owner = "jtojnar";
    repo = "hamster";
    rev = "fixes";
    sha256 = "1jgwkfdkhhsiqzmmgz8jdpkjpabd0lhxnikvim3xmh3g6a6jhyn5";
  };

  nativeBuildInputs = [ docbook2x libxslt gnome_doc_utils intltool wrapGAppsHook ];

  buildInputs = [
    gtk3 dbus_glib
  ];

  propagatedBuildInputs = with pythonPackages; [ pygobject3 pyxdg dbus-python ];

  configurePhase = ''
    python waf configure --prefix="$out"
  '';
  
  buildPhase = ''
    python waf build
  '';

  installPhase = ''
    python waf install
  '';

  preFixup = ''
    gappsWrapperArgs+=(--prefix PYTHONPATH : $PYTHONPATH)
  '';
 
  # error: invalid command 'test'
  doCheck = false;

  meta = with stdenv.lib; {
    description = "Time tracking application";
    homepage = https://projecthamster.wordpress.com/;
    license = licenses.gpl3;
    platforms = platforms.all;
    maintainers = [ maintainers.bjornfor ];
  };
}
