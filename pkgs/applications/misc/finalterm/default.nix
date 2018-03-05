{ stdenv, fetchFromGitHub, wrapGAppsHook
, pkgconfig, meson, ninja, libxml2, vala, gobjectIntrospection, gettext, gnome3, gtk3, gtk-doc
, keybinder3, libnotify, json-glib, glib, libunity
, libxkbcommon, xorg, udev
, bashInteractive
}:

with stdenv.lib;

stdenv.mkDerivation {
  name = "finalterm-unstable-2018-03-02";

  src = fetchFromGitHub {
    owner = "finalterm";
    repo = "finalterm";
    rev = "64b80a8d1ddbc16972549b8123fe9fdba1b5ecb2";
    sha256 = "0z20qkih6j4d5kvnm3mzrfr3325xpif15mfzdwxgmm0a3zzyc8g7";
  };

  nativeBuildInputs = [ pkgconfig meson ninja glib vala gobjectIntrospection gettext wrapGAppsHook ];
  buildInputs = [
    glib gtk3 gnome3.libgee libunity
    gtk-doc keybinder3 libxml2 libnotify json-glib
  ] ++ optionals stdenv.isLinux [ udev ];

  preConfigure = ''
    patchShebangs meson_post_install.py
    substituteInPlace data/org.gnome.finalterm.gschema.xml \
      --replace "/bin/bash" "${bashInteractive}/bin/bash"
  '';
  mesonFlags = [
    "-Dlibnotify=true"
  ];

  meta = {
    homepage = http://finalterm.org;
    description = "A new breed of terminal emulator";
    longDescription = ''
      Final Term is a new breed of terminal emulator.

      It goes beyond mere emulation and understands what is happening inside the shell it is hosting. This allows it to offer features no other terminal can, including:

      - Semantic text menus
      - Smart command completion
      - GUI terminal controls
    '';
    license = licenses.gpl3Plus;
    maintainers = [ maintainers.cstrahan ];
    platforms = platforms.linux;
  };
}
