{ lib, stdenv, fetchgit, cmake, gnumake, openmpi, m4, zlib, flex }:

stdenv.mkDerivation rec {
  pname = "openfoam";
  version = "2206";

  src = fetchgit {
    url = "https://develop.openfoam.com/Development/openfoam.git";
    rev = "OpenFOAM-v${version}";
    sha256 = "sha256-snrFOsENf/siqFd1mzxAsYbw1ba67TXMgaNDpb26uX0=";
  };

  nativeBuildInputs = [ cmake gnumake ];
  buildInputs = [ openmpi m4 zlib flex ];

  dontConfigure = true;

  postPatch = ''
    patchShebangs --build wmake/wmake
    patchShebangs --build wmake/scripts/wrap-lemon
  '';

  buildPhase = ''
    set +e
    # TODO: This somehow errors out
    source ./etc/bashrc
    set -e
    foamSystemCheck
    ./Allwmake -s -j
  '';

  meta = {
    description = "OpenFOAM free, open source CFD software";
    homepage = "https://www.openfoam.com/";
    license = with lib.licenses; [ gpl3 ];
    maintainers = with lib.maintainers; [ cheriimoya ];
    platforms = lib.platforms.unix;
  };
}
