{ pkgs, lib }:
{
  mkExecutable = path:
    pkgs.runCommand (builtins.baseNameOf path) {} ''
      install -Dm755 ${path} $out
    '';

  mkOption = {
    str = name: lib.mkOption {
      description = name;
      type = lib.types.str;
    };
    any = name: lib.mkOption {
      description = name;
      type = lib.types.anything;
    };
    image = name: lib.mkOption {
      description = "Path to the ${name} image to use";
      type = lib.types.path;
    };
  };
}
