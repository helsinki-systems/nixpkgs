{
  lib,
  buildGoModule,
  fetchFromGitHub,
}:

buildGoModule rec {
  pname = "kraken";
  version = "0.1.23";

  src = fetchFromGitHub {
    owner = "uber";
    repo = "kraken";
    rev = "v${version}";
    hash = "sha256-wBqVm3Kc+f+gHAZm72E5meVa16RZwB8ULNTTI0cGm+Q=";
  };

  vendorHash = "sha256-nTXZhatmpOnaNH7/Qj9bBmKbDZyqVvh1ddtAuWW0f04=";

  ldflags = [
    "-s"
    "-w"
  ];

  meta = {
    description = "P2P Docker registry capable of distributing TBs of data in seconds";
    homepage = "https://github.com/uber/kraken";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ ];
    mainProgram = "kraken";
  };
}
