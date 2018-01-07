{ stdenv, fetchFromGitHub, autoreconfHook, zlib, pkgconfig, libuuid, makeWrapper
, withPython ? false, python3, withNode ? false, nodejs, withLmSensors ? false, lm_sensors }:

let
  inherit (stdenv.lib) optional optionalString;
  # https://github.com/firehol/netdata/wiki/Installation#1-prepare-your-system
  python = python3.withPackages (p: with p; [ pyyaml dnspython pymongo pymysql psycopg2 ]);
  binDependencies =
    optional withPython python
    ++ optional withNode nodejs;
  libDependencies =
    optional withLmSensors lm_sensors;
in stdenv.mkDerivation rec{
  version = "1.9.0";
  name = "netdata-${version}";

  src = fetchFromGitHub {
    rev = "v${version}";
    owner = "firehol";
    repo = "netdata";
    sha256 = "1vy0jz5lxw63b830l9jgf1qqhp41gzapyhdr5k1gwg3zghvlg10w";
  };

  nativeBuildInputs = [ autoreconfHook pkgconfig makeWrapper ];
  buildInputs = [ zlib libuuid ];

  # Allow UI to load when running as non-root
  patches = [
    ./web_access.patch
  ];

  # Build will fail trying to create /var/{cache,lib,log}/netdata without this
  postPatch = ''
   sed -i '/dist_.*_DATA = \.keep/d' src/Makefile.am
  '';

  configureFlags = [
    "--localstatedir=/var"
  ];

  # App fails on runtime if the default config file is not detected
  # The upstream installer does prepare an empty file too
  postInstall = ''
    touch $out/etc/netdata/netdata.conf

  '';

  postFixup = ''
    wrapProgram $out/bin/netdata \
      --prefix PATH : "${stdenv.lib.makeBinPath binDependencies}" \
      --prefix LD_LIBRARY_PATH : "${stdenv.lib.makeLibraryPath libDependencies}"
  ''
  # Remove unwanted plugins so that they cannot be accidentally enabled
  + optionalString (!withPython) "rm -rf $out/libexec/netdata/python.d/*"
  + optionalString (!withNode) "rm -rf $out/libexec/netdata/node.d/*"
  + optionalString (!withLmSensors) "rm -f $out/libexec/netdata/python.d/sensors.chart.py";

  meta = with stdenv.lib; {
    description = "Real-time performance monitoring tool";
    homepage = http://netdata.firehol.org;
    license = licenses.gpl3;
    platforms = platforms.linux;
    maintainers = [ maintainers.lethalman ];
  };

}
