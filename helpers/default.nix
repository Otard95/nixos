{ pkgs }:
let
  lib = pkgs.lib;
in {
  mkExecutable = path:
    pkgs.runCommand (builtins.baseNameOf path) {} ''
      install -Dm755 ${path} $out
    '';

  toShellVarRaw = name: value:
    lib.throwIfNot (lib.isValidPosixName name)
      "toShellVarRaw: ${name} is not a valid shell variable name"
      "${name}=${value}";

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
    optional = option: option // { type = lib.types.nullOr option.type; };
    monitorBackground = default: lib.mkOption {
      description = "Path to the background image(s) to use";
      type = lib.types.submodule {
        options = {
          horizontal = lib.mkOption {
            description = "Path to the horizontal background image to use";
            default = default;
            type = lib.types.path;
          };
          vertical = lib.mkOption {
            description = "Path to the horizontal background image to use";
            default = null;
            type = lib.types.nullOr lib.types.path;
          };
        };
      };
    };
  };
}
