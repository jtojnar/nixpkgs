{ stdenv, lib, fetchFromGitLab
, python3
, meson, ninja, pkg-config
, gobject-introspection
, desktop-file-utils, shared-mime-info
, wrapGAppsHook
, appstream-glib , gtk3, gtk4
, webkitgtk
, genericUpdater
, useGTK3Broadwayd ? false
, useGTK4Broadwayd ? false
}:

python3.pkgs.buildPythonApplication rec {
  pname = "cambalache";
  version = "0.8.0";

  format = "other";
  strictDeps = false; # https://github.com/NixOS/nixpkgs/issues/56943

  src = fetchFromGitLab {
    domain = "gitlab.gnome.org";
    owner = "jpu";
    repo = pname;
    rev = version;
    sha256 = "05hf45v24l73fwv36bf90h6ksf6axvi8f4mddyq24x63w1yndhg9";
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

  propagatedBuildInputs = with python3.pkgs; [
    pygobject3
    lxml
  ];

  buildInputs = [
    appstream-glib
    gtk3
    gtk4
    webkitgtk
  ];

  # Prevent double wrapping.
  dontWrapGApps = true;

  postPatch = ''
    patchShebangs postinstall.py
  '';

  preFixup = ''
    # Let python wrapper use GNOME flags.
    makeWrapperArgs+=(
      # For gtk3 broadwayd
      ${ lib.optionalString useGTK3Broadwayd ''--prefix PATH : "${gtk3}/bin"''}
      # For gtk4-broadwayd
      ${ lib.optionalString useGTK4Broadwayd ''--prefix PATH : "${gtk4.dev}/bin"''}
      "''${gappsWrapperArgs[@]}"
    )
  '';

  postFixup = ''
    mkdir -p $out/bin
    ${ lib.optionalString (!useGTK3Broadwayd) "install ${gtk3}/bin/broadwayd $out/bin/"}
    ${ lib.optionalString (!useGTK4Broadwayd) "install ${gtk4.dev}/bin/gtk4-broadwayd $out/bin/"}
    # Wrap a helper script in an unusual location.
    wrapPythonProgramsIn "$out/${python3.sitePackages}/cambalache/priv/merengue" "$out $pythonPath"
  '';

  passthru = {
    updateScript = genericUpdater {
      url = "${meta.homepage}.git";
    };
  };

  meta = with lib; {
    homepage = "https://gitlab.gnome.org/jpu/cambalache";
    description = "RAD tool for Gtk 4 and 3 with a clear MVC design and data model first philosophy.";
    maintainers = teams.gnome.members;
    license = with licenses; [
      lgpl21Only # Cambalache
      gpl2Only # tools
    ];
    platforms = platforms.unix;
  };
}
