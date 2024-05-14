{
  lib,
  python3,
  fetchFromGitHub,
}:

python3.pkgs.buildPythonApplication rec {
  pname = "crmsh";
  version = "4.6.0";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "ClusterLabs";
    repo = "crmsh";
    rev = version;
    hash = "sha256-cmXvZSa9vUdC6KkGtjyHc0zHemctXAR0329CTASx4oY=";
  };

  nativeBuildInputs = with python3.pkgs; [
    setuptools
    wheel
  ];

  propagatedBuildInputs = with python3.pkgs; [
    lxml
    python-dateutil
    pyyaml
  ];

  pythonImportsCheck = [ "crmsh" ];

  meta = {
    description = "Command-line interface for High-Availability cluster management on GNU/Linux systems";
    homepage = "https://github.com/ClusterLabs/crmsh";
    changelog = "https://github.com/ClusterLabs/crmsh/blob/${src.rev}/ChangeLog";
    license = lib.licenses.gpl2Only;
    maintainers = lib.teams.helsinki-systems.members;
    mainProgram = "crmsh";
  };
}
