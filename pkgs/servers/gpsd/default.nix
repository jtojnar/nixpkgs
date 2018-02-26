{ fetchurl, stdenv, scons, pkgconfig, dbus, dbus-glib
, ncurses, libX11, libXt, libXpm, libXaw, libXext
, libusb1, docbook_xml_dtd_412, docbook_xsl, bc
, libxslt, xmlto, gpsdUser ? "gpsd", gpsdGroup ? "dialout"
, python2Packages
}:

# TODO: put the X11 deps behind a guiSupport parameter for headless support

stdenv.mkDerivation rec {
  name = "gpsd-3.17";

  # outputs = [ "out" "lib" "python" "dev" "man" ];

  # temporarily redirect everything to $out for easier debugging
  preConfigure = ''
    export lib=$out
    export python=$out
    export dev=$out
    export man=$out
  '';

  src = fetchurl {
    url = "http://download-mirror.savannah.gnu.org/releases/gpsd/${name}.tar.gz";
    sha256 = "0yp7hm6wxyb8mch98260v1jv8bl1xn5a8srxidzrjcaqzgndpq38";
  };

  nativeBuildInputs = [
    scons pkgconfig docbook_xml_dtd_412 docbook_xsl xmlto bc
    python2Packages.python
    python2Packages.wrapPython
  ];

  buildInputs = [
    python2Packages.python dbus dbus-glib ncurses libX11 libXt libXpm libXaw libXext
    libxslt libusb1
  ];

  pythonPath = with python2Packages; [
    pygobject3 pycairo
  ];

  patches = [
    ./0001-Import-LD_LIBRARY_PATH-to-allow-running-scons-check-.patch
    ./0002-Import-XML_CATALOG_FILES-to-be-able-to-validate-the-.patch
  ];

  # - leapfetch=no disables going online at build time to fetch leap-seconds
  #   info. See <gpsd-src>/build.txt for more info.
  buildPhase = ''
    patchShebangs .
    sed -e "s|systemd_dir = .*|systemd_dir = '$lib/lib/systemd/system'|" -i SConstruct
    scons prefix="$out" leapfetch=no gpsd_user=${gpsdUser} gpsd_group=${gpsdGroup} \
        systemd=yes udevdir="$lib/lib/udev" libdir="$lib/lib" mandir="$man/share/man" \
        pkgconfig="$dev/lib/pkgconfig" \
        python_libdir="$python/lib/${python2Packages.python.libPrefix}/site-packages"
  '';

  checkPhase = ''
    export LD_LIBRARY_PATH="$PWD"
    scons check
  '';

  # # TODO: the udev rules file and the hotplug script need fixes to work on NixOS
  installPhase = ''
    scons install
  '';

  postFixup = ''
    wrapPythonProgramsIn $out/bin "$python $pythonPath"
  '';

  meta = with stdenv.lib; {
    description = "GPS service daemon";
    longDescription = ''
      gpsd is a service daemon that monitors one or more GPSes or AIS
      receivers attached to a host computer through serial or USB ports,
      making all data on the location/course/velocity of the sensors
      available to be queried on TCP port 2947 of the host computer. With
      gpsd, multiple location-aware client applications (such as navigational
      and wardriving software) can share access to receivers without
      contention or loss of data. Also, gpsd responds to queries with a
      format that is substantially easier to parse than the NMEA 0183 emitted
      by most GPSes. The gpsd distribution includes a linkable C service
      library, a C++ wrapper class, and a Python module that developers of
      gpsd-aware applications can use to encapsulate all communication with
      gpsd. Third-party client bindings for Java and Perl also exist.

      Besides gpsd itself, the project provides auxiliary tools for
      diagnostic monitoring and profiling of receivers and feeding
      location-aware applications GPS/AIS logs for diagnostic purposes.
    '';
    homepage = http://catb.org/gpsd/;
    license = "BSD-style";
    platforms = platforms.linux;
    maintainers = with maintainers; [ bjornfor rasendubi ];
  };
}
