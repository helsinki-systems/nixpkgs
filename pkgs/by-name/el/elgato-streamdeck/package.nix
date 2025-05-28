{
  lib,
  rustPlatform,
  fetchFromGitHub,
  pkg-config,
  libusb1,
}:

rustPlatform.buildRustPackage rec {
  pname = "elgato-streamdeck";
  version = "unstable-2025-04-18";

  src = fetchFromGitHub {
    owner = "streamduck-org";
    repo = "elgato-streamdeck";
    rev = "ff8566546d7c6173a02472623a4df00e983113ef";
    hash = "sha256-c/ni5eZGE90A/J2tlTwsPNJgruODslaAFISIv7K5HF4=";
  };

  cargoLock = {
    lockFile = ./Cargo.lock;
  };

  postPatch = ''
    ln -s ${./Cargo.lock} Cargo.lock
  '';

  buildInputs = [
    libusb1
  ];

  nativeBuildInputs = [
    pkg-config
  ];

  checkFlags = [
    # error[E0425]: cannot find value `device` in this scope
    "--skip=StreamDeck::write_lcd_fill"
  ];

  postInstall = ''
    install -Dm444 40-streamdeck.rules -t $out/lib/udev/rules.d/
  '';

  meta = {
    description = "Rust library for interacting with Elgato Stream Deck and other stream controller hardware";
    homepage = "https://github.com/streamduck-org/elgato-streamdeck";
    license = lib.licenses.mpl20;
    maintainers = with lib.maintainers; [ ];
    mainProgram = "elgato-streamdeck";
  };
}
