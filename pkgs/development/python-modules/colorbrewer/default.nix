{
  lib,
  buildPythonPackage,
  fetchPypi,
  six,
  unittestCheckHook,
}:
buildPythonPackage rec {
  pname = "colorbrewer";
  version = "0.2.0";
  format = "setuptools";

  src = fetchPypi {
    inherit pname version;
    format = "setuptools";
    hash = "sha256-8STQBRCGiHtS02QyA6dyIlK1AgT4r5PmrmP8ABP0JFY=";
  };

  dependencies = [ six ];

  nativeCheckInputs = [ unittestCheckHook ];
  unittestFlagsArray = [
    "-s"
    "test"
    "-v"
  ];
  pythonImportsCheck = [ "colorbrewer" ];

  meta = {
    homepage = "https://noble.gs.washington.edu/~mmh1/software/colorbrewer/";
    description = "constants from Cynthia Brewer's ColorBrewer";
    license = lib.licenses.unfree; # TODO
    maintainers = lib.teams.helsinki-systems.members;
  };
}
