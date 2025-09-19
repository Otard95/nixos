{ stdenvNoCC, lib, makeWrapper, bash, coreutils }:
stdenvNoCC.mkDerivation {
  pname = "pass-env";
  version = "1.0.0";

  src = ./script.sh;
  dontUnpack = true;

  nativeBuildInputs = [ makeWrapper ];

  installPhase = ''
    mkdir -p $out/bin
    cp $src $out/bin/pass-env
    chmod +x $out/bin/pass-env
    # Ensure shebangs are rewritten to Nix-store interpreters
    patchShebangs $out/bin
    # If your script needs runtime tools, put them on PATH:
    wrapProgram $out/bin/pass-env --prefix PATH : ${lib.makeBinPath [ coreutils bash ]}
  '';
}
