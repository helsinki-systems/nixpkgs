{
  lib,
  rustPlatform,
  fetchFromGitHub,
  makeWrapper,
  openssl,
  pkg-config,
  protobuf,
  zlib,
}:

rustPlatform.buildRustPackage {
  pname = "hydra-queue-runner";
  version = "unstable-2025-07-17";

  src = fetchFromGitHub {
    owner = "helsinki-systems";
    repo = "hydra-queue-runner";
    rev = "d887db71ed2cab756259b080f8ec0f2649630321";
    hash = "sha256-wgdZKzRPuqcfhmXyH23c4ZEH/OMnccMokt1HAGsHRZM=";
    leaveDotGit = true;
    postFetch = ''
      git -C "$out" rev-parse HEAD > $out/COMMIT
      find "$out" -name .git -print0 | xargs -0 rm -rf
    '';
  };

  cargoHash = "sha256-BkJpMnkoAmcxTwwLDPsa28SHZzVtCMP7N5zikzKwhOk=";

  nativeBuildInputs = [
    pkg-config
    protobuf
    makeWrapper
  ];
  buildInputs = [
    openssl
    zlib
    protobuf
  ];

  meta = {
    description = "Hydra queue runner rewrite";
    homepage = "https://github.com/helsinki-systems/hydra-queue-runner";
    license = lib.licenses.gpl3Only;
    teams = [ lib.teams.helsinki-systems ];
    mainProgram = "hydra-queue-runner";
  };
}
