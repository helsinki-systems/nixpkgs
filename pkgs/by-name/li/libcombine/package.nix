{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  pkg-config,
  libsbml,
  libnuml,
  bzip2,
  libxml2,
  swig,
  zlib,
  python ? null,
  withPython ? false,
}:
let
  zipper = stdenv.mkDerivation {
    pname = "zipper";
    version = "unstable-2024-05-22";

    src = fetchFromGitHub {
      owner = "fbergmann";
      repo = "zipper";
      rev = "c56a27fa282b7f353b498d60eee636793342b8bb";
      hash = "sha256-JFTJepAmN1stk1+5ft7KrKQrYpmsJ63nqB1Xi+yFDLA=";
      fetchSubmodules = true;
    };

    nativeBuildInputs = [
      cmake
      pkg-config
    ];
    buildInputs = [
      zlib
    ];
  };
in
stdenv.mkDerivation rec {
  pname = "libcombine";
  version = "0.2.20";

  src = fetchFromGitHub {
    owner = "sbmlteam";
    repo = "libcombine";
    rev = "v${version}";
    hash = "sha256-3ZxJM+8I2zVQNTPCj3yl8sJuuM6xzrpCtyv//NsqsMk=";
  };

  prePatch = ''
    # we need to drop that directory otherwise dependencies are not found correctly
    rm -rf submodules
  '';

  nativeBuildInputs = [
    cmake
    pkg-config
  ] ++ lib.optional withPython python.pkgs.pythonImportsCheckHook;

  buildInputs = [
    swig
    (libsbml.override { inherit withPython python; })
    libxml2
    bzip2
    zlib
    zipper
  ] ++ lib.optional withPython python;

  env = {
    ZIPPER_DIR = "${zipper}";
  };

  cmakeFlags = [
    "-DEXTRA_LIBS=xml2;bz2;z"
  ] ++ lib.optional withPython "-DWITH_PYTHON=ON";

  postInstall = lib.optional withPython ''
    mv $out/${python.sitePackages}/libcombine/libcombine.py $out/${python.sitePackages}/libcombine/__init__.py
  '';

  pythonImportsCheck = [ "libcombine" ];

  meta = {
    homepage = "https://github.com/sbmlteam/libCombine";
    description = "A C++ library for working with the COMBINE Archive format";
    license = lib.licenses.bsd2;
    maintainers = lib.teams.helsinki-systems.members;
  };
}
