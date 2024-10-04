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
stdenv.mkDerivation {
  pname = "libsedml";
  version = "2.0.32-unstable";

  src = fetchFromGitHub {
    owner = "fbergmann";
    repo = "libsedml";
    rev = "b577099e9215ebde9daedc3b6a60e3b1fa2b8c35";
    hash = "sha256-Lot2utER01h7Oiw4EGic2Ld9D3ixdylS4KzbTaoh1QY=";
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
    (libnuml.override { inherit withPython python; })
    libxml2
    bzip2
    zlib
  ] ++ lib.optional withPython python;

  cmakeFlags = [
    "-DEXTRA_LIBS=xml2;bz2;z"
  ] ++ lib.optional withPython "-DWITH_PYTHON=ON";

  postInstall = lib.optional withPython ''
    mv $out/${python.sitePackages}/libsedml/libsedml.py $out/${python.sitePackages}/libsedml/__init__.py
  '';

  pythonImportsCheck = [ "libsedml" ];

  meta = {
    homepage = "https://github.com/fbergmann/libSEDML";
    description = "SED-ML library based on libSBML";
    license = lib.licenses.bsd2;
    maintainers = lib.teams.helsinki-systems.members;
  };
}
