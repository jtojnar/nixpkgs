{ lib
, python3
, fetchFromGitHub
}:

python3.pkgs.buildPythonApplication rec {
  pname = "bump-pydantic";
  version = "0.8.0";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "pydantic";
    repo = "bump-pydantic";
    rev = version;
    hash = "sha256-fO8JniUnMsBn1KcRxI9M0bQY8S8LFRso0sNtuXxQi60=";
  };

  nativeBuildInputs = [
    python3.pkgs.hatchling
  ];

  propagatedBuildInputs = with python3.pkgs; [
    libcst
    rich
    typer
    typing-extensions
  ];

  pythonImportsCheck = [ "bump_pydantic" ];

  meta = with lib; {
    description = "Convert Pydantic from V1 to V2";
    homepage = "https://github.com/pydantic/bump-pydantic";
    license = licenses.mit;
    maintainers = with maintainers; [ ];
    mainProgram = "bump-pydantic";
  };
}
