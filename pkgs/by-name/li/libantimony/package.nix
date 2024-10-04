{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  pkg-config,
  libsbml,
  bzip2,
  libxml2,
  swig,
  zlib,
  python ? null,
  withPython ? false,
}:
let
  sbml = libsbml.override { withCPP = true;  withCOMP = true; };
in
stdenv.mkDerivation rec {
  pname = "antimony";
  version = "2.15.0";

  src = fetchFromGitHub {
    owner = "sys-bio";
    repo = "antimony";
    rev = "v${version}";
    hash = "sha256-Nn3T0aSis8iGWYb+BsPPYoXz01S/by8uQhrP++HpJqQ=";
  };

  prePatch = ''
    sed -i 's/using namespace libsbml;//g' src/typex.cpp
  '';

  nativeBuildInputs = [
    cmake
    pkg-config
  ] ++ lib.optional withPython python.pkgs.pythonImportsCheckHook;
  buildInputs = [
    swig
    sbml
    libxml2
    bzip2
    zlib
  ] ++ lib.optional withPython python;

  cmakeFlags =
    [
      "-DUSE_UNIVERSAL_BINARIES=OFF"
      "-DWITH_SWIG=ON"
      "-DWITH_QTANTIMONY=OFF"
      "-DWITH_STATIC_SBML=OFF"
      "-DWITH_LIBSBML_EXPAT=OFF"
      "-DWITH_LIBSBML_LIBXML=ON"
      "-DSWIG_EXECUTABLE=${lib.getBin swig}/bin/swig"
    ]
    ++ lib.optionals withPython [
      "-DWITH_PYTHON=ON"
      "-DPYTHON_EXECUTABLE=${python}/bin/python"
    ];

  postInstall = ''
    mkdir -pv $out/${python.sitePackages}
    mv $out/bindings/python/antimony/ $out/${python.sitePackages}/
    rm -rf $out/bindings
  '';

  pythonImportsCheck = [ "antimony" ];

  meta = {
    homepage = "https://github.com/sys-bio/antimony";
    description = "Antimony is a human-readable, human-writable modular model definition language.";
    license = lib.licenses.bsd3;
    maintainers = lib.teams.helsinki-systems.members;
  };
}
