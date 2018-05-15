{ stdenv, fetchFromGitHub, meson, ninja, pkgconfig, wrapGAppsHook, glib, gtk3, xdg-desktop-portal }:

stdenv.mkDerivation {
  name = "permission-viewer-unstable-2016-12-10";

  src = fetchFromGitHub {
    owner = "matthiasclasen";
    repo = "permission-viewer";
    rev = "ebb370437773c9410d69d9a4d7a99687828e36ac";
    sha256 = "1ab195jcln55a60yv30d4zxhk3w9jz10nqqawzy3c3n6f76f0awv";
  };

  nativeBuildInputs = [ meson ninja pkgconfig wrapGAppsHook ];
  buildInputs = [ glib gtk3 xdg-desktop-portal ];

  meta = with stdenv.lib; {
    description = "Simple application to display the Flatpak permission store";
    license = licenses.lgpl21;
    maintainers = with maintainers; [ jtojnar ];
    platforms = platforms.linux;
  };
}
