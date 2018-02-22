{ lib, stdenv, fetchFromGitHub, cmake }:

stdenv.mkDerivation rec {
  name = "libstemmer-2017-06-16";

  src = fetchFromGitHub {
    owner = "snowballstem";
    repo = "snowball";
    rev = "78c149a3a6f262a35c7f7351d3f77b725fc646cf";
    sha256 = "06md6n6h1f2zvnjrpfrq7ng46l1x12c14cacbrzmh5n0j98crpq7";
  };

  patches = [
    (fetchurl {
      url = https://git.archlinux.org/svntogit/packages.git/plain/trunk/dynamiclib.patch?h=packages/snowball&id=e806c192ae0259003aba78f00fe7a276d6d05129;
      sha256 = "0000000000000000000000000000000000000000000000000000000000000000";
    })
  ];

  installPhase = ''
    install -Dm644 {.,"$pkgdir"/usr}/include/libstemmer.h
    install -D {.,"$pkgdir"/usr/lib}/libstemmer.so.0.0.0
    ln -s libstemmer.so.0.0.0 "$pkgdir/usr/lib/libstemmer.so.0"
    ln -s libstemmer.so.0 "$pkgdir/usr/lib/libstemmer.so"
  '';

  meta = with lib; {
    description = "Snowball Stemming Algorithms";
    homepage = "http://snowball.tartarus.org/";
    license = licenses.bsd3;
    maintainers = with maintainers; [ fpletz ];
    platforms = platforms.all;
  };
}
