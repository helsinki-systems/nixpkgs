{
  lib,
  buildPythonPackage,
  fetchFromGitHub,
  cmake,
  git,
  setuptools,
  setuptools_scm,
  ninja,
  gitpython,
}:
buildPythonPackage rec {
  pname = "cmake-build-extension";
  version = "0.6.1";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "diegoferigo";
    repo = "cmake-build-extension";
    rev = "v${version}";
    hash = "sha256-Rdp1Ocqh7Axec50glLo4rNW0xlRTsD0M+gtmmiibEho=";
    leaveDotGit = true;
  };

  build-system = [
    setuptools
    setuptools_scm
  ];

  nativeBuildInputs = [
    cmake
    git
  ];

  dependencies = [
    ninja
    gitpython
    setuptools_scm
  ];

  pythonImportsCheck = [ "cmake_build_extension" ];
  dontUseCmakeConfigure = true;

  meta = {
    homepage = "https://github.com/diegoferigo/cmake-build-extension";
    description = "Setuptools extension to build and package CMake projects";
    license = lib.licenses.mit;
    maintainers = lib.teams.helsinki-systems.members;
  };
}
