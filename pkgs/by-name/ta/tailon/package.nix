{
  lib,
  buildGoModule,
  fetchFromGitHub,
}:

buildGoModule rec {
  pname = "tailon";
  version = "2.0.0";

  src = fetchFromGitHub {
    owner = "gvalkov";
    repo = "tailon";
    rev = "v${version}";
    hash = "sha256-ivk1q1delkd1nlYpwVV9qPUjDjrSZolyqnP6duQ2eTk=";
  };

  vendorHash = "sha256-BUqezHUp8O+lUaZNPvrAoVc1piFIddkZCnECGLIqerY=";

  ldflags = [ "-s" "-w" ];

  meta = {
    description = "Webapp for looking at and searching through files and streams";
    homepage = "https://github.com/gvalkov/tailon";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ ];
    mainProgram = "tailon";
  };
}
