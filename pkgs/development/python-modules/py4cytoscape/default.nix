{
  lib,
  buildPythonPackage,
  fetchFromGitHub,
  setuptools,
  unittestCheckHook,
  cython,
  numpy,
  pandas,
  networkx,
  requests,
  igraph,
  colorbrewer,
  chardet,
  decorator,
  backoff,
  colour,
}:
buildPythonPackage rec {
  pname = "py4cytoscape";
  version = "1.11.0";
  format = "setuptools";

  src = fetchFromGitHub {
    owner = "cytoscape";
    repo = "py4cytoscape";
    rev = "refs/tags/${version}";
    hash = "sha256-u7nvmOS53/+b0v/v/TN4JSVAvdSW0uYrx3JBIFoPH2s=";
  };

  build-system = [
    cython
  ];

  dependencies = [
    numpy
    pandas
    networkx
    requests
    igraph
    colorbrewer
    chardet
    decorator
    backoff
    colour
    setuptools # needs pkg_resources at runtime
  ];

  nativeCheckInputs = [ unittestCheckHook ];
  unittestFlagsArray = [
    "-s"
    "test"
    "-v"
  ];
  pythonImportsCheck = [ "py4cytoscape" ];

  meta = {
    homepage = "https://github.com/cytoscape/py4cytoscape";
    description = "Python library for calling Cytoscape Automation via CyREST";
    license = lib.licenses.mit;
    maintainers = lib.teams.helsinki-systems.members;
  };
}
