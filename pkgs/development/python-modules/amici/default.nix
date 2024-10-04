{
  lib,
  buildPythonPackage,
  fetchPypi,
  cmake,
  swig,
  blas,
  hdf5-cpp,
  symlinkJoin,
  setuptools,
  cmake-build-extension,
  sympy,
  numpy,
  libsbml,
  pandas,
  pyarrow,
  toposort,
  mpmath,
  petab,
  h5py,
}:
buildPythonPackage rec {
  pname = "amici";
  version = "0.26.3";
  pyproject = true;

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-x4pt72M5cv1PType8Hd7m+WMxK17lt0DKoUp5ChB9e4=";
  };

  postPatch = ''
    substituteInPlace amici/sbml_import.py \
      --replace-fail "element_name" "getElementName()"
    substituteInPlace pyproject.toml \
      --replace-fail "cmake-build-extension==0.6.0" "cmake-build-extension"
    substituteInPlace pyproject.toml \
      --replace-fail "\"numpy>=2.0\"," ""
  '';

  env = {
    BLAS_CFLAGS = "-I${blas.dev}/include";
    BLAS_LIBS = "-L${blas}/lib -lcblas";
    HDF5_ROOT = "${symlinkJoin {
      name = "hdf5";
      paths = [
        hdf5-cpp.dev
        hdf5-cpp.out
      ];
    }}";
  };

  build-system = [
    setuptools
    numpy
    cmake-build-extension
  ];

  nativeBuildInputs = [
    cmake
    swig
  ];
  buildInputs = [
    blas
    hdf5-cpp
  ];

  dependencies = [
    cmake-build-extension
    sympy
    numpy
    libsbml
    pandas
    pyarrow
    toposort
    mpmath
  ];

  optional-dependencies = {
    petab = [ petab ];
    h5py = [ h5py ];
  };

  pythonImportsCheck = [ "amici" ];
  dontCheckRuntimeDeps = true;
  dontUseCmakeConfigure = true;

  meta = {
    homepage = "https://github.com/AMICI-dev/AMICI";
    description = "Advanced Multilanguage Interface to CVODES and IDAS";
    license = lib.licenses.bsd3;
    maintainers = lib.teams.helsinki-systems.members;
  };
}
