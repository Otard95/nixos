{ lib, ... }:
{
  programs.nixvim.extraFiles = let
    fileNames = builtins.attrNames (builtins.readDir ./utils);
    files = map (name: {
      name = "lua/utils/${name}";
      value = { source = lib.path.append ./utils "${name}"; };
    }) fileNames;
    extra = builtins.listToAttrs files;
  in extra;
}
