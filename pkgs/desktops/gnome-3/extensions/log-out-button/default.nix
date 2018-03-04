{ stdenv, substituteAll, fetchFromGitLab, glib, gettext }:

let
  version = "1.0.7";
in stdenv.mkDerivation rec {
  name = "gnome-shell-extension-log-out-button-${version}";

  src = fetchFromGitLab {
    owner = "paddatrapper";
    repo = "log-out-button-gnome-extension";
    rev = version;
    sha256 = "0nnj5skcr3g71xj9iqh6kh3m3dnp13s8wkczrjpjlrv1babrpzzc";
  };

  buildInputs = [ glib gettext ];

  uuid = "LogOutButton@kyle.aims.ac.za";

  # See install.sh
  buildPhase = ''
    echo 'Compiling translations...'
    for po in locale/*/LC_MESSAGES/*.po; do
      msgfmt -cv -o ''${po%.po}.mo $po;
    done

    if [ -d src/schemas ]; then
      echo 'Compiling preferences...'
      glib-compile-schemas --targetdir=src/schemas src/schemas
    else
      echo 'No preferences to compile... Skipping'
    fi
  '';

  installPhase = ''
    mkdir -p $out/share/gnome-shell/extensions/${uuid}
    cp -r src/* locale $out/share/gnome-shell/extensions/${uuid}
  '';

  meta = with stdenv.lib; {
    description = "GNOME Shell extension that shows a log out button next to the power-off, lock and settings buttons in the system action list";
    homepage = src.meta.homepage;
    license = licenses.gpl3;
    maintainers = with maintainers; [ jtojnar ];
  };
}
