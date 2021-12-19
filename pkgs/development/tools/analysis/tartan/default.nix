{ stdenv
, lib
, fetchFromGitLab
, meson
, ninja
, pkg-config
, llvmPackages
, gobject-introspection
, glib
, unstableGitUpdater
}:

stdenv.mkDerivation rec {
  pname = "tartan";
  version = "unstable-2020-06-18";

  src = fetchFromGitLab {
    domain = "gitlab.freedesktop.org";
    owner = "tartan";
    repo = "tartan";
    rev = "8132f8470fd025987360659f94e07f9d02658810";
    sha256 = "6N/VnFOXajyjNKLdFCHxsCzISlc5hjGUiKre0ipeSvY=";
  };

  nativeBuildInputs = [
    meson
    ninja
    pkg-config
  ];

  buildInputs = [
    gobject-introspection
    glib
    llvmPackages.libclang
    llvmPackages.libllvm
  ];

  postInstall = ''
    # https://gitlab.freedesktop.org/tartan/tartan/-/merge_requests/11
    chmod +x "$out/bin/tartan-build"
  '';

  passthru = {
    updateScript = unstableGitUpdater {
      # The updater tries src.url by default, which does not exist for fetchFromGitLab (fetchurl).
      url = "https://gitlab.freedesktop.org/tartan/tartan.git";
    };
  };

  meta = with lib; {
    description = "Tools and Clang plugins for developing code with GLib";
    homepage = "https://freedesktop.org/wiki/Software/tartan";
    license = licenses.gpl3Plus;
    platforms = platforms.unix;
    maintainers = with maintainers; [ jtojnar ];
  };
}
