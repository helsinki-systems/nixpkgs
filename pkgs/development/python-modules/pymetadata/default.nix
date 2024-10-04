{
  lib,
  buildPythonPackage,
  fetchFromGitHub,
  depinfo,
  lxml,
  rich,
  requests,
  zeep,
  pronto,
  fastobo,
  jinja2,
  xmltodict,
  pydantic,
  pytestCheckHook,
}:
buildPythonPackage rec {
  pname = "pymetadata";
  version = "0.4.4";

  src = fetchFromGitHub {
    owner = "matthiaskoenig";
    repo = "pymetadata";
    rev = version;
    hash = "sha256-N4dUEt6YZeBjOWEqSkYzuz/x0TefjjUiqDnIljp2kKQ=";
  };

  dependencies = [
    depinfo
    lxml
    rich
    requests
    zeep
    pronto
    fastobo
    jinja2
    xmltodict
    pydantic
  ];

  nativeCheckInputs = [ pytestCheckHook ];
  disabledTestPaths = [
    "tests/core/test_annotation.py"
    "tests/test_ols.py"
    "tests/test_registry.py"
  ];
  disabledTests = [
    "test_chebi"
    "test_get_sources"
    "test_get_source_exists"
    "test_get_source_missing"
    "test_query_xref_for_inchikey_no_cache"
    "test_query_xref_for_inchikey_cache"
  ];

  pythonImportsCheck = [ "pymetadata" ];

  meta = {
    homepage = "https://github.com/matthiaskoenig/pymetadata";
    description = "Python utilities for working with metadata and COMBINE archives";
    license = lib.licenses.lgpl3;
    maintainers = lib.teams.helsinki-systems.members;
  };
}
