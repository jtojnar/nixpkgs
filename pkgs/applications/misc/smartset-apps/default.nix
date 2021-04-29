{ stdenv
, lib
, fetchFromGitHub
, lazarus
, fpc
, libX11

# GTK2/3
, pango
, cairo
, glib
, atk
, gtk2
, gtk3
, gdk-pixbuf
, python3

# Qt5
, libqt5pas
, qt5

, widgetset ? "gtk2"
}:

assert builtins.elem widgetset [ "gtk2" "gtk3" "qt5" ];

stdenv.mkDerivation rec {
  pname = "smartset-apps";
  version = "2021-03-24";

  src = /home/jtojnar/Projects/SmartSetApps;

  # src = fetchFromGitHub {
  #   owner = "KinesisCorporation";
  #   repo = "SmartSetApps";
  #   rev = "1f7aed22ef5f247a61cc7d70555237bda8343606";
  #   sha256 = "nUxl4YmNSF6XgxojFK1BExLwypPtI8RCZMYWU3LlI68=";
  # };

  nativeBuildInputs = [ lazarus fpc ]
    ++ lib.optional (widgetset == "qt5") qt5.wrapQtAppsHook;

  buildInputs = [ libX11 ]
    ++ lib.optionals (lib.hasPrefix "gtk" widgetset) [ pango cairo glib atk gdk-pixbuf ]
    ++ lib.optional (widgetset == "gtk2") gtk2
    ++ lib.optional (widgetset == "gtk3") gtk3
    ++ lib.optional (widgetset == "qt5") libqt5pas;

  NIX_LDFLAGS = "--as-needed -rpath ${lib.makeLibraryPath buildInputs}";

  postPatch = let
    tab = "\t";
  in ''
    substituteInPlace Components/bgrabitmap-master/Makefile \
      --replace "${tab}lazbuild" "${tab}lazbuild --lazarusdir=${lazarus}/share/lazarus --pcp=$PWD/lazarus"
  '';

  buildPhase = ''
    runHook preBuild

    for p in Components/bgrabitmap-master/bgrabitmap/bgrabitmappack.lpk \
      Components/bgracontrols-master/bgracontrols.lpk \
      Components/ecc_0-9-6-10_16-06-15/EC_Controls/eccontrols.lpk \
      Components/TGIFViewer-master/TGIFViewer-master/package/gifviewer_pkg.lpk \
      Components/HSButton0.9/HSButton/installpkg.lpk \
      Components/mbColorLib-2.2.1/mbColorLib/mbcolorliblaz.lpk \
      Components/mdsliderbarslaz-2/package/mdsliderbarslaz.lpk \
      Components/richmemo/richmemopackage.lpk \
      Components/ueControls_v6.0/uecontrols.lpk \
      Components/CreoSource/creosource.lpk \
      SmartSetAdv2/SmartSetKeyboard.lpi; do
      echo "STEP $((i++)) *****************"
        lazbuild --lazarusdir=${lazarus}/share/lazarus --pcp=$PWD/lazarus --ws=${widgetset} "$p"
      done

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    install -Dm755 SmartSetAdv2/Adv2\ SmartSet\ App\ \(Mac\) $out/bin/Adv2\ SmartSet\ App\ \(Mac\)

    runHook postInstall
  '';

  meta = with lib; {
    description = "Cross-platform code editor";
    longDescription = ''
      Text/code editor with lite UI. Syntax highlighting for 200+ languages.
      Config system in JSON files. Multi-carets and multi-selections.
      Search and replace with RegEx. Extendable by Python plugins and themes.
    '';
    homepage = "https://cudatext.github.io/";
    changelog = "https://cudatext.github.io/history.txt";
    license = licenses.mpl20;
    maintainers = with maintainers; [ sikmir ];
    platforms = platforms.linux;
  };
}
