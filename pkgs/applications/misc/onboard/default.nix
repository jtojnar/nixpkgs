{ config
, fetchurl
, atspiSupport ? true, at_spi2_core ? null
, gtk3
, gnome3
, libcanberra_gtk3
, libudev
, hunspell
, isocodes
, pkgconfig
, xorg
, libxkbcommon
, python3
, stdenv
, intltool
, glib
, gobjectIntrospection
, gsettings_desktop_schemas
, wrapGAppsHook
, yelp
, glibcLocales
, psmisc
}:

python3.pkgs.buildPythonApplication rec {
  name = "onboard-${version}";
  majorVersion = "1.4";
  version = "${majorVersion}.1";
  src = fetchurl {
    url = "https://launchpad.net/onboard/${majorVersion}/${version}/+download/${name}.tar.gz";
    sha256 = "01cae1ac5b1ef1ab985bd2d2d79ded6fc99ee04b1535cc1bb191e43a231a3865";
  };

  LC_ALL = "en_US.UTF-8";

  doCheck = false;

  propagatedBuildInputs = with python3.pkgs; [
    pycairo
    dbus-python
    pygobject3
    systemd
    distutils_extra
    pyatspi
  ];

  nativeBuildInputs = [ intltool wrapGAppsHook glibcLocales ];
  buildInputs = [
    python3
    gtk3
    libcanberra_gtk3
    libudev
    hunspell
    isocodes
    pkgconfig
    xorg.libXtst
    xorg.libxkbfile
    libxkbcommon
    glib gsettings_desktop_schemas gnome3.dconf
    psmisc
  ] ++ stdenv.lib.optional atspiSupport at_spi2_core;

  preBuild = ''
    substituteInPlace  ./scripts/sokSettings.py \
    --replace "PYTHON_EXECUTABLE," "\"${python3}/bin/python\"" \

    chmod -x ./scripts/sokSettings.py

    patchShebangs .

    substituteInPlace  ./Onboard/LanguageSupport.py \
    --replace "/usr/share/xml/iso-codes" "${isocodes}/share/xml/iso-codes" \
    --replace "/usr/bin/yelp" "${yelp}/bin/yelp"

    substituteInPlace  ./Onboard/Indicator.py \
    --replace   "/usr/bin/yelp" "${yelp}/bin/yelp"

    substituteInPlace  ./gnome/Onboard_Indicator@onboard.org/extension.js \
    --replace "/usr/bin/yelp" "${yelp}/bin/yelp" \
    --replace "killall" "${psmisc}/bin/yelp"

    substituteInPlace  ./Onboard/SpellChecker.py \
    --replace "/usr/share/hunspell" ${hunspell}/bin/hunspell \
    --replace "/usr/lib" "$out/lib"

    substituteInPlace  ./data/org.onboard.Onboard.service  \
    --replace "/usr/bin" "$out/bin"

    substituteInPlace  ./Onboard/utils.py \
    --replace "/usr/share" "$out/share"
    substituteInPlace  ./onboard-defaults.conf.example \
    --replace "/usr/share" "$out/share"
    substituteInPlace  ./Onboard/Config.py \
    --replace "/usr/share/onboard" "$out/share/onboard"

    substituteInPlace  ./Onboard/WordSuggestions.py \
    --replace "/usr/bin" "$out/bin"
  '';

  postInstall = ''
    ${glib.dev}/bin/glib-compile-schemas $out/share/glib-2.0/schemas/
  '';

  meta = {
    homepage = https://launchpad.net/onboard;
    description = "An onscreen keyboard useful for tablet PC users and for mobility impaired users.";
    longDescription = ''
      An onscreen keyboard useful for tablet PC users and for mobility impaired users.
      In order to save settings, add pkgs.gnome3.dconf to environment.systemPackages.
      Additional settings can be changed with dconf.
      For example, to turn on key labels:
      dconf write /org/onboard/keyboard/show-secondary-labels true
      For word prediction enable atspiSupport
      To get rid of org.a11y.Bus warning enable "services.gnome3.at-spi2-core.enable = true"
    '';
    maintainers = with stdenv.lib.maintainers; [ johnramsden ];
    license = stdenv.lib.licenses.gpl3;
  };
}
