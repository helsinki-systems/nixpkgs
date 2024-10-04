{
  lib,
  buildPythonPackage,
  fetchFromGitHub,
  setuptools,
  scipy,
  numpy,
  h5py,
  pytestCheckHook,
}:
buildPythonPackage rec {
  pname = "fides";
  version = "0.7.8";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "fides-dev";
    repo = "fides";
    rev = version;
    hash = "sha256-EzaHKuGg+FCd+CklG1fA/TGPgf/VA5OlGlTuJeVIJzE=";
  };

  build-system = [
    setuptools
  ];

  dependencies = [
    scipy
    numpy
    h5py
  ];

  nativeCheckInputs = [ pytestCheckHook ];

  pythonImportsCheck = [ "fides" ];

  meta = {
    homepage = "https://github.com/fides-dev/fides";
    description = "Interior Trust Region Reflective for boundary constrained optimization problems in Python";
    license = lib.licenses.bsd3;
    maintainers = lib.teams.helsinki-systems.members;
  };
}
