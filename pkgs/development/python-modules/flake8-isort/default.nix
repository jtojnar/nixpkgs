{
  lib,
  buildPythonPackage,
  pythonOlder,
  fetchFromGitHub,
  hatchling,
  isort,
  flake8,
  pytestCheckHook,
}:

buildPythonPackage rec {
  pname = "flake8-isort";
  version = "6.1.1";

  disabled = pythonOlder "3.8";

  pyproject = true;

  src = fetchFromGitHub {
    owner = "gforcada";
    repo = "flake8-isort";
    rev = version;
    hash = "sha256-2kOUajf+TzGZVRB64wp6Hk4RbzTgerKDUwCoaXwvjaA=";
  };

  nativeBuildInputs = [ hatchling ];

  propagatedBuildInputs = [
    isort
    flake8
  ];

  nativeCheckInputs = [ pytestCheckHook ];

  pytestFlagsArray = [ "run_tests.py" ];

  disabledTests = [
    "test_isortcfg_not_found"
    "test_isort_formatted_output"
  ];

  meta = with lib; {
    description = "flake8 plugin that integrates isort";
    homepage = "https://github.com/gforcada/flake8-isort";
    license = licenses.gpl2Only;
    maintainers = with maintainers; [ ];
    # mainProgram = "flake8-isort";
  };
}
