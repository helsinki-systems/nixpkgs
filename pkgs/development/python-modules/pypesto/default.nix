{
  lib,
  buildPythonPackage,
  fetchFromGitHub,
  setuptools,
  numpy,
  scipy,
  pandas,
  cloudpickle,
  matplotlib,
  more-itertools,
  seaborn,
  h5py,
  tqdm,
  tabulate,
  petab,
  fides,
  pytestCheckHook,
}:
buildPythonPackage rec {
  pname = "pypesto";
  version = "0.5.3";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "icb-dcm";
    repo = "pypesto";
    rev = "v${version}";
    hash = "sha256-fxxMXKgVcJ2Q0MXD39TxVzIJqrHXNA1v2BwTJsRghWo=";
  };

  build-system = [ setuptools ];

  dependencies = [
    numpy
    scipy
    pandas
    cloudpickle
    matplotlib
    more-itertools
    seaborn
    h5py
    tqdm
    tabulate
  ];

  optional-dependencies = {
    # amici = [ amici ];
    petab = [ petab ];
    fides = [ fides ];
  };

  nativeCheckInputs = [
    pytestCheckHook
  ] ++ lib.flatten (builtins.attrValues optional-dependencies);

  disabledTestPaths = [
    "test/base/test_aggregated.py"
    "test/base/test_engine.py"
    "test/base/test_ensemble.py"
    "test/base/test_history.py"
    "test/base/test_lazy_result.py"
    "test/base/test_objective.py"
    "test/base/test_roadrunner.py"
    "test/base/test_startpoint.py"
    "test/base/test_store.py"
    "test/base/test_workflow.py"
    "test/base/test_x_fixed.py"
    "test/hierarchical/test_hierarchical.py"
    "test/optimize/test_optimize.py"
    "test/petab/test_amici_objective.py"
    "test/petab/test_amici_predictor.py"
    "test/petab/test_petab_import.py"
    "test/petab/test_petab_suite.py"
    "test/petab/test_sbml_conversion.py"
    "test/profile/test_profile.py"
    "test/select/test_select.py"
    "test/variational/test_variational.py"
    "test/visualize/test_visualize.py"
    "test/hierarchical/test_ordinal.py"
    "test/sample/test_sample.py"
  ];

  disabledTests = [
    "test_dynesty_mcmc_samples"
    "test_dynesty_posterior"
    "test_optimization"
    "test_optimization[inner_options0]"
    "test_optimization[inner_options0]"
    "test_optimization[inner_options10]"
    "test_optimization[inner_options11]"
    "test_optimization[inner_options12]"
    "test_optimization[inner_options13]"
    "test_optimization[inner_options14]"
    "test_optimization[inner_options15]"
    "test_optimization[inner_options1]"
    "test_optimization[inner_options1]"
    "test_optimization[inner_options2]"
    "test_optimization[inner_options3]"
    "test_optimization[inner_options4]"
    "test_optimization[inner_options5]"
    "test_optimization[inner_options6]"
    "test_optimization[inner_options7]"
    "test_optimization[inner_options8]"
    "test_optimization[inner_options9]"
    "test_ordinal_calculator_and_objective"
    "test_ordinal_calculator_and_objective"
    "test_petabJL_from_module"
    "test_petabJL_from_yaml"
    "test_petabJL_interface"
    "test_pyjulia_pipeline"
    "test_save_and_load_spline_knots"
    "test_spline_calculator_and_objective"
  ];

  pythonImportsCheck = [ "pypesto" ];

  meta = {
    homepage = "https://github.com/icb-dcm/pypesto";
    description = "Parameter EStimation TOolbox for python.";
    license = lib.licenses.bsd3;
    maintainers = lib.teams.helsinki-systems.members;
  };
}
