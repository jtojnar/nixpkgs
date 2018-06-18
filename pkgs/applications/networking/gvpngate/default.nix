{ stdenv
, fetchFromGitHub
, autoreconfHook
, pkgconfig
, libuuid
, glib
, gtk3
, wrapGAppsHook }:

stdenv.mkDerivation rec {
  name = "gvpngate-${version}";
  version = "0.55";

  src = fetchFromGitHub {
    owner = "Gwiz65";
    repo = "gvpngate";
    rev = "v${version}";
    sha256 = "1n6ky4f532mpvc0qdkdp8m3sagnmb6rljz8p7n4rsvvr7qfg1f3y";
  };

  nativeBuildInputs = [ autoreconfHook pkgconfig wrapGAppsHook ];
  buildInputs = [ glib gtk3 libuuid ];

  meta = with stdenv.lib; {
    description = "VPN Gate frontend for GNOME";
    homepage = https://gwiz65.github.io/gvpngate/;
    license = licenses.gpl3Plus;
    maintainers = with maintainers; [ jtojnar ];
    platforms = platforms.linux;
  };
}
