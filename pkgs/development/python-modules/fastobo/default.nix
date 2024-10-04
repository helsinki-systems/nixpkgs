{
  lib,
  buildPythonPackage,
  fetchFromGitHub,
  cargo,
  rustPlatform,
  rustc,
  setuptools-rust,
  unittestCheckHook,
}:
buildPythonPackage rec {
  pname = "fastobo";
  version = "0.12.3";
  format = "pyproject";

  src = fetchFromGitHub {
    owner = "fastobo";
    repo = "fastobo-py";
    rev = "v${version}";
    hash = "sha256-UO3hCZA0FoLmrjfS+vp8xe1b8IzxPkfIhwFnG1TSQ9Q=";
  };

  cargoDeps = rustPlatform.fetchCargoTarball {
    inherit src;
    hash = "sha256-rzl8qkr4TY1z9n7cIA/NX0nCb/54D8elCGah7Llg2EE=";
  };

  postPatch = ''
    # remove doctests because it requires internet access
    sed -i -e "s/suite.addTests(loader.loadTestsFromModule(test_doctests))//g" tests/__init__.py
  '';

  nativeBuildInputs = [
    rustPlatform.cargoSetupHook
    setuptools-rust
    cargo
    rustc
  ];

  nativeCheckInputs = [ unittestCheckHook ];
  pythonImportsCheck = [ "fastobo" ];

  meta = {
    description = "Faultless AST for Open Biomedical Ontologies in Python";
    homepage = "https://github.com/fastobo/fastobo-py";
    license = lib.licenses.mit;
    maintainers = lib.teams.helsinki-systems.members;
  };
}
