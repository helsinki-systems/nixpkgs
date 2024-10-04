{
  lib,
  stdenv,
  symlinkJoin,
  python3,
  fetchFromGitHub,
  libnuml,
  bzip2,
  expat,
  gtest,
  libsedml,
  libsbml,
  zlib,
  cmake,
  pkg-config,
  boost,
  eigen,
  poco,
  sundials,
  libxml2,
  mpi,
  llvm_13,
  swig,
  pcre,
}:
let
  full-libsbml = libsbml.override {
    withCPP = true;
    withStablePackages = true;
  };
  nleq1 = stdenv.mkDerivation {
    pname = "nleq1";
    version = "0.unstable-2024-10-04";

    src = fetchFromGitHub {
      owner = "sys-bio";
      repo = "nleq1";
      rev = "233ad05074c1203d98226c4312225ba63f6cacb1";
      hash = "sha256-iaFsgNJl7p8JhYpf/SjYcMwIWJgpKh/Y/o7jg79Kxfo=";
    };

    nativeBuildInputs = [ cmake ];
  };

  nleq2 = stdenv.mkDerivation {
    pname = "nleq2";
    version = "0.unstable-2024-10-04";

    src = fetchFromGitHub {
      owner = "sys-bio";
      repo = "nleq2";
      rev = "6ee0dbf739e550f13cc6837c197d21b9ea0d07a7";
      hash = "sha256-mLhAZo5K7FCK3DAWGziLtz4eBQJusZoG1sWXn/wIF9c=";
    };

    nativeBuildInputs = [ cmake ];
  };

  sbmlnetwork = stdenv.mkDerivation {
    pname = "sbmlnetwork";
    version = "0.unstable-2024-10-04";

    src = fetchFromGitHub {
      owner = "sys-bio";
      repo = "SBMLNetwork";
      rev = "7c0fb54d59fe6600a5aeb1ab5d5b19ffb0a4da23";
      hash = "sha256-TPaKBOowmyPVj+cfJiHAY783idFitjZ8sERADrVBkUE=";
    };

    nativeBuildInputs = [
      cmake
      full-libsbml
      expat
      zlib
    ];
  };

  clapack = stdenv.mkDerivation rec {
    pname = "clapack";
    version = "2.2.1";

    hardeningDisable = [ "format" ];
    src = fetchFromGitHub {
      owner = "sys-bio";
      repo = "libroadrunner-deps";
      rev = "v${version}";
      hash = "sha256-Hsb/fxH7mJGUj3NRPsrteuz1/USG8Tm6vX5WHcPj3Ao=";
    };
    sourceRoot = "${src.name}/third_party/clapack/";

    nativeBuildInputs = [ cmake ];
  };

  rr-libstruct = stdenv.mkDerivation {
    pname = "rr-libstruct";
    version = "0.unstable-2024-10-04";

    src = fetchFromGitHub {
      owner = "sys-bio";
      repo = "rr-libstruct";
      rev = "8664272a9823e646736df148081f4830337bfb19";
      hash = "sha256-6eMC1lCDntI73qQ92D4M8fhXhlzVTW9T/vUcwXAmTgk=";
    };

    nativeBuildInputs = [
      cmake
      full-libsbml
      clapack
    ];

    cmakeFlags = [
      "-DLIBSBML_INCLUDE_DIR=${full-libsbml}/include"
      "-DCLAPACK_INCLUDE_DIR=${clapack}/include/clapack"
    ];
  };

  bio-sys-poco = poco.overrideAttrs (_: {
    version = "poco-v1.10.1-unstable";
    src = fetchFromGitHub {
      owner = "sys-bio";
      repo = "poco";
      rev = "87f35dd70717893fe69e635ca0c59e19bc4ff705";
      hash = "sha256-lT2cMx/eauDvhCAMyvcyP9TDQXVnJu9tXW3J3tKsqQQ=";
    };

    cmakeFlags = [
      "-DENABLE_APACHECONNECTOR=OFF"
      "-DENABLE_CPPPARSER=OFF"
      "-DENABLE_CRYPTO=OFF"
      "-DENABLE_DATA=OFF"
      "-DENABLE_DATA_MYSQL=OFF"
      "-DENABLE_DATA_ODBC=OFF"
      "-DENABLE_DATA_POSTGRESQL=OFF"
      "-DENABLE_DATA_SQLITE=OFF"
      "-DENABLE_ENCODINGS=OFF"
      "-DENABLE_ENCODINGS_COMPILER=OFF"
      "-DENABLE_FOUNDATION=ON"
      "-DENABLE_JSON=OFF"
      "-DENABLE_JWT=OFF"
      "-DENABLE_MONGODB=OFF"
      "-DENABLE_PDF=OFF"
      "-DENABLE_NET=ON"
      "-DENABLE_NETSSL=OFF"
      "-DENABLE_NETSSL_WIN=OFF"
      "-DENABLE_UTIL=OFF"
      "-DENABLE_XML=ON"
      "-DENABLE_ZIP=OFF"
      "-DENABLE_PAGECOMPILER=OFF"
      "-DENABLE_PAGECOMPILER_FILE2PAGE=OFF"
      "-DENABLE_REDIS=OFF"
      "-DENABLE_POCODOC=OFF"
      "-DENABLE_TESTS=OFF"
      "-DBUILD_SHARED_LIBS=OFF"
    ];
  });

  libroadrunner-deps2 = symlinkJoin {
    name = "libroadrunner-deps2";
    paths = [
      libnuml
      sbmlnetwork
      bzip2
      clapack
      expat
      gtest
      libsedml
      full-libsbml
      llvm_13
      nleq1
      nleq2
      bio-sys-poco.out
      bio-sys-poco.dev
      rr-libstruct
      (sundials.overrideAttrs (_: {
        version = "5.8";
        src = fetchFromGitHub {
          owner = "LLNL";
          repo = "sundials";
          rev = "2e94b7c0f02038aa2dabcac270e22d037950c095";
          hash = "sha256-cYcWzuaBDR213enA79m3jOM/fAsJByyTnYaIox+ZE6Y=";
        };
      }))
      zlib
      zlib.static
    ];

    postBuild = ''
      sed "s:\$out:$out:g" ${./zlib-config.cmake.in} > $out/lib/cmake/zlib-config.cmake
      sed "s:\$out:$out:g" ${./zlib-config-release.cmake.in} > $out/lib/cmake/zlib-config-release.cmake
    '';
  };

  swig4 = swig.overrideAttrs (_: rec {
    version = "4.0.2";
    src = fetchFromGitHub {
      owner = "swig";
      repo = "swig";
      rev = "v${version}";
      hash = "sha256-TMvmWGDj17s8CIcM2puoOIjukQZIRIDRZHx3Y46+dIs=";
    };

    PCRE_CONFIG = "${pcre.dev}/bin/pcre-config";
    buildInputs = [ pcre ];
  });

  roadrunner = stdenv.mkDerivation rec {
    version = "2.6.0";
    pname = "roadrunner";

    src = fetchFromGitHub {
      owner = "sys-bio";
      repo = pname;
      rev = "e8106081f2109b3a2661b0fb901bfa7b716b32fc";
      # rev = "v${version}";
      # hash = "sha256-2khOg0/6v4uOamM9fO1N6Y9gBEXPPgH5gBI2A9gA9gs=";
      hash = "sha256-rs302ybuySypS1Hxk+Tv6mSPX/vqN3la+Cr7/fCEAS4=";
    };

    patches = [
      ./0001-fix-gcc13.patch
    ];

    cmakeFlags = [
      "-DBUILD_RR_PLUGINS=ON"
      "-DRR_DEPENDENCIES_INSTALL_PREFIX=${libroadrunner-deps2}"
      "-DLLVM_INSTALL_PREFIX=${llvm_13}"
      "-DBUILD_TESTS=ON"
      "-DBUILD_PYTHON=ON"
      "-DSWIG_EXECUTABLE=${swig4}/bin/swig"
      "-DPython_ROOT_DIR=${python3}"
      "-DPython_EXECUTABLE=${python3}/bin/python"
      "-DPython_INCLUDE_DIRS=${python3}/include"
      "-DPython_LIBRARIES=${python3}/lib"
      "-DLIBXML_INCLUDE_DIR=${lib.getDev libxml2}/include/libxml2"
      "-DLIBXML_LIBRARY=${lib.getLib libxml2}/lib/libxml2${stdenv.hostPlatform.extensions.sharedLibrary}"
    ];

    hardeningDisable = [ "format" ];
    doCheck = false;

    nativeBuildInputs = [
      cmake
      pkg-config
      expat
    ];
    buildInputs = [
      boost
      eigen
      libxml2
      mpi
      python3
      python3.pkgs.numpy
      python3.pkgs.matplotlib
      libroadrunner-deps2
      llvm_13
      swig4
      bzip2
    ];

    enableParallelBuilding = true;
  };

  roadrunner-python = python3.pkgs.buildPythonPackage {
    pname = "roadrunner-python";
    version = "2.6.0";
    src = roadrunner;
    pythonImportsCheck = [ "roadrunner" ];

    buildInputs = [ python3.pkgs.numpy ];
  };
in
roadrunner-python
// {
  passthru.python = roadrunner-python;
}
