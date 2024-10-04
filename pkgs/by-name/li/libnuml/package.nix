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
stdenv.mkDerivation {
  pname = "libnuml";
  version = "1.1.6-unstable";

  src =
    fetchFromGitHub {
      owner = "numl";
      repo = "numl";
      rev = "ac00cd349da12819eeb6b54a22e569374ff108d8";
      hash = "sha256-eYt69903blR6+CNDbXpi8S00WsHSYKmlOCKtutQtfyA=";
    }
    + "/libnuml";

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
  ] ++ lib.optional withPython python;

  cmakeFlags = [
    "-DEXTRA_LIBS=xml2;bz2;z"
  ] ++ lib.optional withPython "-DWITH_PYTHON=ON";

  postInstall = lib.optional withPython ''
    mv $out/${python.sitePackages}/libnuml/libnuml.py $out/${python.sitePackages}/libnuml/__init__.py
  '';

  pythonImportsCheck = [ "libnuml" ];

  meta = {
    homepage = "https://github.com/NuML/NuML";
    description = "The Numerical Markup Language (NuML) aims to standardize the exchange and archiving of numerical results.";
    license = lib.licenses.lgpl21Plus;
    maintainers = lib.teams.helsinki-systems.members;
  };
}
