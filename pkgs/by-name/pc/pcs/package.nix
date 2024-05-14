{
  lib,
  python3,
  fetchFromGitHub,
  openssl
}:

python3.pkgs.buildPythonApplication rec {
  pname = "pcs";
  version = "0.10.8";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "ClusterLabs";
    repo = "pcs";
    rev = version;
    hash = "sha256-8bM4uNiVLpAumqa+4PK0AYKYfhKS8GhMVi3xmsOcCNk=";
  };

  nativeBuildInputs = with python3.pkgs; [
    setuptools
    wheel
  ];

  propagatedBuildInputs = with python3.pkgs; [
    openssl
    astroid
    black
    dacite
    mypy
    pylint
    python-dateutil
    tornado
    lxml
    pycurl
    pyparsing
    pyopenssl
  ];

  pythonImportsCheck = [ "pcs" ];

  meta = {
    description = "Pacemaker command line interface and GUI";
    homepage = "https://github.com/ClusterLabs/pcs";
    changelog = "https://github.com/ClusterLabs/pcs/blob/${src.rev}/CHANGELOG.md";
    license = lib.licenses.gpl2Only;
    maintainers = lib.teams.helsinki-systems.members;
    mainProgram = "pcs";
  };
}
