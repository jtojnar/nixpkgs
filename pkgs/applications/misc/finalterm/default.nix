{ stdenv, fetchFromGitHub, makeWrapper
, pkgconfig, cmake, ninja, libxml2, vala, gobjectIntrospection, intltool, gnome3, gtk3, gtk-doc
, keybinder3, libnotify, json-glib
, libxkbcommon, xorg, udev
, bashInteractive
}:

with stdenv.lib;

stdenv.mkDerivation {
  name = "finalterm-git-2018-03-02";

  src = fetchFromGitHub {
    owner = "RedHatter";
    repo = "finalterm-reborn";
    rev = "274a7ea232317a6cfe4e6a25eb68db38a111eb14";
    sha256 = "1rpzxlja5rgs2g4nk69gkfnd5s5l7sz77r907zw1sixva47fyrnb";
  };

  nativeBuildInputs = [ pkgconfig cmake ninja vala gobjectIntrospection intltool makeWrapper ];
  buildInputs = [
    gtk3 gnome3.libgee
    gtk-doc keybinder3 libxml2 libnotify json-glib
  ] ++ optionals stdenv.isLinux [ udev ];

  preConfigure = ''
    substituteInPlace data/org.gnome.finalterm.gschema.xml \
      --replace "/bin/bash" "${bashInteractive}/bin/bash"

    cmakeFlagsArray=(
      -DMINIMAL_FLAGS=ON
    )
  '';

  postInstall = ''
    mkdir -p $out/share/gsettings-schemas/$name
    mv $out/share/glib-2.0 $out/share/gsettings-schemas/$name/
  '';

  postFixup = ''
    wrapProgram "$out/bin/finalterm" \
      --prefix GI_TYPELIB_PATH : "$GI_TYPELIB_PATH" \
      --prefix GIO_EXTRA_MODULES : "${getLib gnome3.dconf}/lib/gio/modules" \
      --prefix XDG_DATA_DIRS : "${gnome3.defaultIconTheme}/share:${gnome3.gtk.out}/share:$out/share:$GSETTINGS_SCHEMAS_PATH"
  '';

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
