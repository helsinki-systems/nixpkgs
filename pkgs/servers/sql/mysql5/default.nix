args: with args;

# Note: zlib is not required; MySQL can use an internal zlib.

stdenv.mkDerivation {
  name = "mysql-5.0.67";

  src = fetchurl {
    url = "http://downloads.mysql.com/archives/mysql-5.0/mysql-5.0.67.tar.gz";
    sha256 = "sha256-e2TmCYSf9k8vy4KityiD95rciT6fb8DTVGXvfZdUIFg=";
  };

  buildInputs = [ps ncurses zlib perl openssl];
  postInstall = "ln -s mysqld_safe $out/bin/mysqld";

  configureFlags = "--enable-thread-safe-client --with-embedded-server --disable-static --with-openssl=${openssl} --with-berkeley-db";
}
