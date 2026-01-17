{ stdenv }:
stdenv.mkDerivation rec {
  pname = "ed-eXploration-dashboard";
  version = "v0.5.0.3";

  src = fetchTarball {
    url = "https://github.com/Kepas-Beleglorn/EDXD/releases/download/${version}/edxd-dashboard-Linux.tar.gz";
    sha256 = "sha256:1h2zh965p7nhz5pyy3dizci88x33171r2r5c8g1y5sbjfhkwj2sf";
  };

  installPhase = ''
    mkdir -p $out/bin
    cp ed-eXploration-dashboard $out/bin
  '';
}
