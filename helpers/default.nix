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
    int = name: lib.mkOption {
      description = name;
      type = lib.types.int;
    };
    ints = {
      positive = name: lib.mkOption {
        description = name;
        type = lib.types.positive;
      };
      unsigned = name: lib.mkOption {
        description = name;
        type = lib.types.unsigned;
      };
      u8 = name: lib.mkOption {
        description = name;
        type = lib.types.u8;
      };
    };
    bool = name: lib.mkOption {
      description = name;
      type = lib.types.bool;
    };
    submodule = name: options: lib.mkOption {
      description = name;
      type = lib.types.submodule {
        options = options;
      };
    };
    listOf = name: type: lib.mkOption {
      description = name;
      default = [];
      type = lib.types.listOf type;
    };
    attrsOf = name: type: lib.mkOption {
      description = name;
      default = {};
      type = lib.types.attrsOf type;
    };
    any = name: lib.mkOption {
      description = name;
      type = lib.types.anything;
    };
    image = name: lib.mkOption {
      description = "Path to the ${name} image to use";
      type = lib.types.path;
    };
    optional = option: option // {
      type = lib.types.nullOr option.type;
      default = null;
    };
    monitorBackground = default: lib.mkOption {
      description = "Path to the background image(s) to use";
      default = {
        horizontal = default;
        vertical   = null;
      };
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
