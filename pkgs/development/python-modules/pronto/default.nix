{
  lib,
  buildPythonPackage,
  fetchFromGitHub,
  chardet,
  fastobo,
  networkx,
  python-dateutil,
  unittestCheckHook,
}:
buildPythonPackage rec {
  pname = "pronto";
  version = "2.5.8";

  src = fetchFromGitHub {
    owner = "althonos";
    repo = "pronto";
    rev = "v${version}";
    hash = "sha256-5WSES6ZAUiyxjOhj1fZ/FgBzOJD13c4k2smMA+U9zbw=";
  };


  dependencies = [
    chardet
    fastobo
    networkx
    python-dateutil
  ];

  nativeCheckInputs = [ unittestCheckHook ];
  preCheck = ''
    # contains tests which need network access
    rm tests/test_doctest.py
  '';

  pythonImportsCheck = [ "pronto" ];

  meta = {
    description = "A Python frontend to (Open Biomedical) Ontologies.";
    homepage = "https://github.com/althonos/pronto";
    license = lib.licenses.mit;
    maintainers = lib.teams.helsinki-systems.members;
  };
}
