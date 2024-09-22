{ lib
, python3
, fetchFromGitHub
}:

python3.pkgs.buildPythonApplication rec {
  pname = "waterloo";
  version = "0.7.10";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "anentropic";
    repo = "python-waterloo";
    rev = version;
    hash = "sha256-u0yvzWzBMmcnje4QZjQJOflc2idpsqyCT8lA2T4Pb1U=";
  };

  nativeBuildInputs = [
    python3.pkgs.poetry-core
  ];

  propagatedBuildInputs = with python3.pkgs; [
    attrs
    click
    colorama
    fissix
    inject
    megaparsy
    moreorless
    parso
    prompt-toolkit
    pydantic
    pydantic-settings
    regex
    structlog
    toml
    typesystem
    typing-extensions
  ];

  nativeCheckInputs = [ python3.pkgs.pytestCheckHook ];
  checkInputs = [ python3.pkgs.hypothesis ];

  pythonImportsCheck = [ "waterloo" ];

  pythonRelaxDeps = true;

  # borked
  doCheck = false;

  postPatch = ''
    # substituteInPlace pyproject.toml \
    #   --replace-fail "poetry>=0.12" poetry-core \
    #   --replace-fail "poetry.masonry.api" "poetry.core.masonry.api"
  '';

  preCheck = ''
    export HOME=$(mktemp -d)
  '';

  meta = with lib; {
    description = "A cli tool to convert type annotations found in 'Google-style' docstrings into mypy py2 type comments (and from there into py3 type annotations";
    homepage = "https://github.com/anentropic/python-waterloo";
    license = licenses.mit;
    maintainers = with maintainers; [ ];
    mainProgram = "waterloo";
  };
}
