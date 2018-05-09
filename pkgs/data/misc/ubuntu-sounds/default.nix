{ stdenv, fetchurl, intltool }:

stdenv.mkDerivation rec {
  name = "ubuntu-sounds-${version}";
  version = "0.13";

  src = fetchurl {
    url = "https://launchpad.net/ubuntu/+archive/primary/+files/ubuntu-sounds_${version}.tar.gz";
    sha256 = "1gf7bqrwkpnzhm5cidqxq8210gy3rmw98m1chfkghhf967a5ln7y";
  };

  nativeBuildInputs = [ intltool ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out/share/sounds/
    cp -r ubuntu $out/share/sounds/

    runHook postInstall
  '';

  meta = with stdenv.lib; {
    description = "Ubuntu's GNOME audio theme";
    homepage = http://freedesktop.org/wiki/Specifications/sound-theme-spec;
    license = licenses.cc-by-sa-25;
    maintainers = with maintainers; [ jtojnar ];
    platforms = platforms.unix;
  };
}
