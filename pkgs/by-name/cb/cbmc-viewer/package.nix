{ lib
, python3
, fetchFromGitHub
}:

python3.pkgs.buildPythonApplication rec {
  pname = "cbmc-viewer";
  version = "3.8";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "model-checking";
    repo = "cbmc-viewer";
    rev = "viewer-${version}";
    hash = "sha256-GIpinwjl/v6Dz5HyOsoPfM9fxG0poZ0HPsKLe9js9vM=";
  };

  nativeBuildInputs = with python3.pkgs; [
    setuptools
    wheel
  ];

  propagatedBuildInputs = with python3.pkgs; [
    voluptuous
    jinja2
    setuptools # needs pkg_resources
  ];

  pythonImportsCheck = [ "cbmc_viewer" ];

  # Tests require building stuff.
  doCheck = false;

  meta = with lib; {
    description = "CBMC Viewer scans the output of CBMC and produces a browsable summary of its findings, making it easy to root cause the issues it finds";
    homepage = "https://github.com/model-checking/cbmc-viewer";
    license = licenses.asl20;
    maintainers = with maintainers; [ jtojnar ];
    mainProgram = "cbmc-viewer";
  };
}
