{stdenv, fetchurl, gccCross ? null, binutilsCross ? null}:

stdenv.mkDerivation {
  name = "busybox-1.2.2.1";
  builder = ./builder.sh;

  src = fetchurl {
    url = "http://busybox.net/downloads/busybox-1.2.2.1.tar.bz2";
    md5 = "153f7a4d7580c19ed6f6570f039b64b5";
  };

  # inherit gccCross;
  # buildinputs = [binutilsCross];
  # fixme, need a decent config for MIPS or so
  config = ./x86-config-1.2;
}
