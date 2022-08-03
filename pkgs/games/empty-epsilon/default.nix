{ lib, stdenv, fetchFromGitHub, cmake, sfml, libX11, glew, python3, glm }:

let

  major = "2022";
  minor = "03";
  patch.seriousproton = "16";
  patch.emptyepsilon = "16";

  version.seriousproton = "${major}.${minor}.${patch.seriousproton}";
  version.emptyepsilon = "${major}.${minor}.${patch.emptyepsilon}";

  serious-proton = stdenv.mkDerivation {
    pname = "serious-proton";
    version = version.seriousproton;

    src = fetchFromGitHub {
      owner = "daid";
      repo = "SeriousProton";
      rev = "EE-${version.seriousproton}";
      hash = "sha256-wfrKSEx1v9Py+C3rU5foh9n8hfWbxHJno9BJkvZmzb0=";
    };

    nativeBuildInputs = [ cmake ];
    buildInputs = [ sfml libX11 glm ];

    meta = with lib; {
      description = "C++ game engine coded on top of SFML used for EmptyEpsilon";
      homepage = "https://github.com/daid/SeriousProton";
      license = licenses.mit;
      maintainers = with maintainers; [ fpletz ];
      platforms = platforms.linux;
    };
  };

in


stdenv.mkDerivation {
  pname = "empty-epsilon";
  version = version.emptyepsilon;

  src = fetchFromGitHub {
    owner = "daid";
    repo = "EmptyEpsilon";
    rev = "EE-${version.emptyepsilon}";
    hash = "sha256-4bIC960GB7M/ZZb0x6vmASqxIAZeTv8RN9Qx4vZMAIo=";
  };

  nativeBuildInputs = [ cmake ];
  buildInputs = [ serious-proton sfml glew libX11 python3 glm ];

  cmakeFlags = [
    "-DSERIOUS_PROTON_DIR=${serious-proton.src}"
    "-DCPACK_PACKAGE_VERSION=${version.emptyepsilon}"
    "-DCPACK_PACKAGE_VERSION_MAJOR=${major}"
    "-DCPACK_PACKAGE_VERSION_MINOR=${minor}"
    "-DCPACK_PACKAGE_VERSION_PATCH=${patch.emptyepsilon}"
  ];

  meta = with lib; {
    description = "Open source bridge simulator based on Artemis";
    homepage = "https://daid.github.io/EmptyEpsilon/";
    license = licenses.gpl2Plus;
    maintainers = with maintainers; [ fpletz lheckemann ma27 ];
    platforms = platforms.linux;
  };
}
