{ stdenv
, lib
, fetchFromGitLab
, python3
, meson
, ninja
, pkg-config
, gobject-introspection
, desktop-file-utils
, shared-mime-info
, wrapGAppsHook
, glib
, gtk3
, gtk4
, webkitgtk
, nix-update-script
}:

python3.pkgs.buildPythonApplication rec {
  pname = "cambalache";
  version = "0.7.4";

  format = "other";

  src = fetchFromGitLab {
    domain = "gitlab.gnome.org";
    owner = "jpu";
    repo = pname;
    rev = version;
    sha256 = "sha256-R/vRn0LzC2/JG8AGcv333hL54OpjH8S3ZDq3XStIh34=";
  };

  nativeBuildInputs = [
    meson
    ninja
    pkg-config
    gobject-introspection # for setup hook
    desktop-file-utils # for update-desktop-database
    shared-mime-info # for update-mime-database
    wrapGAppsHook
  ];

  pythonPath = with python3.pkgs; [
    pygobject3
    lxml
  ];

  buildInputs = [
    glib
    gtk3
    gtk4
    webkitgtk
  ];

  # Not compatible with gobject-introspection setup hooks.
  strictDeps = false;

  # Prevent double wrapping.
  dontWrapGApps = true;

  postPatch = ''
    patchShebangs postinstall.py
  '';

  preFixup = ''
    # Let python wrapper use GNOME flags.
    makeWrapperArgs+=(
      # For gtk4-broadwayd
      --prefix PATH : "${gtk4.dev}/bin"
      "''${gappsWrapperArgs[@]}"
    )
  '';

  postFixup = ''
    # Wrap a helper script in an unusual location.
    wrapPythonProgramsIn "$out/${python3.sitePackages}/cambalache/priv/merengue" "$out $pythonPath"
  '';

  passthru = {
    updateScript = nix-update-script {
      attrPath = pname;
    };
  };

  meta = with lib; {
    homepage = "https://gitlab.gnome.org/jpu/cambalache";
    description = "RAD tool for GTK 4 and 3";
    maintainers = teams.gnome.members;
    license = with licenses; [
      lgpl2Only # Cambalache
      gpl2Only # tools
    ];
    platforms = platforms.unix;
  };
}
