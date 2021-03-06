{ lib, stdenv, fetchurl, meson, ninja, pkg-config, gnome3, gettext }:

stdenv.mkDerivation rec {
  pname = "gnome-backgrounds";
  version = "40.1";

  src = fetchurl {
    url = "mirror://gnome/sources/gnome-backgrounds/${lib.versions.major version}/${pname}-${version}.tar.xz";
    sha256 = "YN+KDaMBzkJbcEPUKuMuxAEf8I8Y4Pxi8pQBMF2jpw4=";
  };

  passthru = {
    updateScript = gnome3.updateScript { packageName = "gnome-backgrounds"; attrPath = "gnome3.gnome-backgrounds"; };
  };

  nativeBuildInputs = [ meson ninja pkg-config gettext ];

  meta = with lib; {
    platforms = platforms.unix;
    maintainers = teams.gnome.members;
  };
}
