{
  lib,
  buildPythonPackage,
  fetchPypi,
  fetchFromGitHub,
  setuptools,
  numpy,
  pandas,
  pyarrow,
  matplotlib,
  libsbml,
  sympy,
  colorama,
  pyyaml,
  jsonschema,
  antlr4-python3-runtime,
  libcombine,
  seaborn,
  scipy,
  pytestCheckHook,
}:
let
  simplesbml = buildPythonPackage rec {
    pname = "simplesbml";
    version = "2.3.0";

    src = fetchPypi {
      inherit pname version;
      hash = "sha256-P+F8zKWNm5bNe340GWazQxmov7GH3OgFQGUPcwxlvnk=";
    };

    build-system = [ setuptools ];
    dependencies = [
      libsbml
    ];

    meta = {
      homepage = "https://github.com/sys-bio/simplesbml";
      description = "Python package for building SBML models without needing to use libSBML.";
      license = lib.licenses.mit;
      maintainers = lib.teams.helsinki-systems.members;
    };
  };
in
buildPythonPackage rec {
  pname = "petab";
  version = "0.4.1";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "petab-dev";
    repo = "libpetab-python";
    rev = "v${version}";
    hash = "sha256-bXHZLOlZ6hX+qdEOofU3FH+5iAc3JbtGGB6jPGWhUNc=";
  };

  build-system = [ setuptools ];

  dependencies = [
    numpy
    pandas
    pyarrow
    libsbml
    sympy
    colorama
    pyyaml
    jsonschema
    (antlr4-python3-runtime.overridePythonAttrs (_: rec {
      version = "4.13.1";

      source = fetchFromGitHub {
        owner = "antlr";
        repo = "antlr4";
        rev = version;
        hash = "sha256-ky9nTDaS+L9UqyMsGBz5xv+NY1bPavaSfZOeXO1geaA=";
      };
    }))
  ];

  optional-dependencies = {
    combine = [ libcombine ];
    vis = [
      matplotlib
      seaborn
      scipy
    ];
  };

  nativeCheckInputs = [
    pytestCheckHook
    simplesbml
  ] ++ lib.flatten (builtins.attrValues optional-dependencies);

  disabledTestPaths = [
    # requires pysb
    "tests/v1/math/test_math.py"
    "tests/v1/test_model_pysb.py"
  ];

  disabledTests = [
    # require network
    "test_petablint_succeeds"
    "test_load_remote"
    "test_cli"
    "test_data_overview"
    "test_validate_remote"
    "test_petab1to2_remote"
    "test_benchmark_collection"
    "test_load_remote"
    "test_auto_upgrade"
  ];

  pythonImportsCheck = [ "petab" ];
  dontCheckRuntimeDeps = true;

  meta = {
    homepage = "https://github.com/PEtab-dev/libpetab-python";
    description = "PEtab is a data format for specifying parameter estimation problems in systems biology.";
    license = lib.licenses.mit;
    maintainers = lib.teams.helsinki-systems.members;
  };
}
