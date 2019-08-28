{ stdenv
, fetchFromGitLab
, appstream-glib
, desktop-file-utils
, fwupd
, gettext
, glib
, gnome3
, gtk3
, libsoup
, libxmlb
, meson
, ninja
, pkgconfig
, systemd
, wrapGAppsHook
}:

stdenv.mkDerivation rec {
  pname = "gnome-firmware-updater";
  version = "unstable-2019-08-27";

  src = fetchFromGitLab {
    domain = "gitlab.gnome.org";
    owner = "hughsie";
    repo = "gnome-firmware-updater";
    rev = "d5014edb634d41c2878b1e918d3f943570d1dfe2";
    sha256 = "03lk81mv5b4qrv561505wzjpp779v5bxha0iyhzwz0g66r96ycdw";
  };

  nativeBuildInputs = [
    appstream-glib # for ITS rules
    desktop-file-utils
    gettext
    meson
    ninja
    pkgconfig
    wrapGAppsHook
  ];

  buildInputs = [
    fwupd
    glib
    gtk3
    libsoup
    libxmlb
    systemd
  ];

  mesonFlags = [
    "-Dconsolekit=false"
  ];

  meta = with stdenv.lib; {
    description = "Tool for installing firmware on devices";
    license = licenses.gpl2Plus;
    maintainers = gnome3.maintainers;
    platforms = platforms.linux;
  };
}
