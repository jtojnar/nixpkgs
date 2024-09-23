{ lib
, python3
, fetchFromGitHub
}:

python3.pkgs.buildPythonApplication rec {
  pname = "com2ann";
  version = "0.3.0";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "ilevkivskyi";
    repo = "com2ann";
    rev = "v${version}";
    hash = "sha256-f84IXuA6d9TPBWUyxxr4NYjf7a5MUKbY59ne3K2Yx1s=";
  };

  nativeBuildInputs = [
    python3.pkgs.setuptools
    python3.pkgs.wheel
  ];

  pythonImportsCheck = [ "com2ann" ];

  meta = with lib; {
    description = "Tool for translation type comments to type annotations in Python";
    homepage = "https://github.com/ilevkivskyi/com2ann";
    license = licenses.mit;
    maintainers = with maintainers; [ ];
    mainProgram = "com2ann";
  };
}
