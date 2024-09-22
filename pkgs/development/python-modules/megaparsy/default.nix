{ lib
, buildPythonPackage
, fetchFromGitHub
, setuptools
, parsy
, hypothesis
, pytestCheckHook
, wheel
}:

buildPythonPackage rec {
  pname = "megaparsy";
  version = "0.1.4";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "anentropic";
    repo = "megaparsy";
    rev = version;
    hash = "sha256-wWn55oBHo03qUxpndebRSwAw3s5KqHqS6HomzIjCiso=";
  };

  nativeBuildInputs = [
    setuptools
    wheel
  ];

  propagatedBuildInputs = [
    parsy
  ];

  nativeCheckInputs = [ pytestCheckHook ];
  checkInputs = [ hypothesis ];

  pythonImportsCheck = [ "megaparsy" ];

  pytestFlagsArray = [ "tests/" ];

  postPatch = ''
    # Should be fine, the newer versios mostly just drop support for older Python versions.
    # https://parsy.readthedocs.io/en/latest/history.html
    substituteInPlace setup.py --replace-fail "'parsy>=1.2.0,<1.3.0'" "'parsy>=1.2.0,<2.2'"
  '';

  meta = with lib; {
    description = "Library porting many of the combinators from Haskell's Megaparsec for use with Python's Parsy";
    homepage = "https://github.com/anentropic/megaparsy/";
    license = licenses.mit;
    maintainers = with maintainers; [ ];
  };
}
