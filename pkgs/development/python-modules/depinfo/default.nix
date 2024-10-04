{
  lib,
  buildPythonPackage,
  fetchFromGitHub,
  setuptools,
  versioneer,
  pytestCheckHook,
}:
buildPythonPackage rec {
  pname = "depinfo";
  version = "2.2.0";
  format = "pyproject";

  src = fetchFromGitHub {
    owner = "Midnighter";
    repo = "dependency-info";
    rev = version;
    hash = "sha256-ngcHTbuSxH8O4ndx3dKkgrG4YppmCpnRgpQC8s1koto=";
  };

  postPatch = ''
    # Asked in https://github.com/Project-MONAI/monai-deploy-app-sdk/issues/450
    # if this patch can be incorporated upstream.
    substituteInPlace pyproject.toml \
      --replace-fail 'versioneer-518' 'versioneer'
  '';

  build-system = [ setuptools ];
  dependencies = [ versioneer ];

  nativeCheckInputs = [ pytestCheckHook ];
  disabledTests = [
    "test_simple_format"
    "test_markdown_format"
    "test_print_dependencies"
    "test_show_versions"
  ];

  pythonImportsCheck = [ "depinfo" ];

  meta = {
    homepage = "https://github.com/Midnighter/dependency-info";
    description = "Retrieve and print Python package dependencies.";
    license = lib.licenses.mit;
    maintainers = lib.teams.helsinki-systems.members;
  };
}
