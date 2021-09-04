{ lib, stdenv, autoreconfHook, fetchFromGitHub, zlib, libibmad, openssl, jsoncpp, pkg-config }:

stdenv.mkDerivation rec {
  pname = "mstflint";
  version = "4.17.0-1";

  src = fetchFromGitHub {
    owner = "Mellanox";
    repo = pname;
    rev = "v${version}";
    sha256 = "0k6q3r1i3g8m41nn4pj4c7zfjlybxkp0r6lw2pl7j58dmiy4v68g";
  };

  nativeBuildInputs = [ autoreconfHook pkg-config ];
  buildInputs = [
    jsoncpp
    zlib
    libibmad
    openssl
  ];

  meta = with lib; {
    description = "Open source version of Mellanox Firmware Tools (MFT)";
    homepage = "https://github.com/Mellanox/mstflint";
    license = with licenses; [ gpl2Only bsd2 ];
    platforms = platforms.linux;
  };
}
