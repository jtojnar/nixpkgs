{ fetchzip, stdenv, gnome3 }:

let
  version = "11.0.0";
in fetchzip rec {
  name = "unicode-character-database-${version}";

  url = "http://www.unicode.org/Public/zipped/${version}/UCD.zip";
  sha256 = "051nzfyrkiqm9y0iqzsvzp7dp8v4f6wvz1l2fss1ahsygnz4r90b";

  postFetch = ''
    mkdir -p $out/share/unicode
    unzip $downloadedFile \*.txt -d $out/share/unicode
  '';

  meta = with stdenv.lib; {
    description = "Unicode Character Database";
    homepage = http://www.unicode.org/ucd/;
    license = licenses.mit;
    maintainers = gnome3.maintainers;
    platforms = platforms.all;
  };
}
