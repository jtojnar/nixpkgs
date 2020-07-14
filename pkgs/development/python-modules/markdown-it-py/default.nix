{ stdenv
, buildPythonPackage
, fetchPypi
, attrs
}:

buildPythonPackage rec {
  pname = "markdown-it-py";
  version = "0.4.8";

  src = fetchPypi {
    inherit pname version;
    sha256 = "//UfnRB96zk9zYHkhKQzRFn8J1Kug6dr6ktSM3K+Y5M=";
  };

  propagatedBuildInputs = [
    attrs
  ];

  # Tests not on PyPi.
  doCheck = false;

  meta = with stdenv.lib; {
    description = "Python port of markdown-it. Markdown parsing, done right!";
    homepage = "https://github.com/ExecutableBookProject/markdown-it-py";
    license = licenses.mit;
    maintainers = [ ];
  };
}
