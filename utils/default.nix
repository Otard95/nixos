{ pkgs, lib }:
{
  mkExecutable = path:
    pkgs.runCommand (builtins.baseNameOf path) {} ''
      install -Dm755 ${path} $out
    '';
  };
}
