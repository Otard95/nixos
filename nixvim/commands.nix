{ lib, pkgs, ... }:
{
  programs.nixvim = {

    extraPackages = with pkgs; [
      wl-clipboard # For Reference command
    ];

    extraConfigLua = ''
      require 'commands'
    '';

    extraFiles = let
      fileNames = builtins.attrNames (builtins.readDir ./commands);
      files = map (name: {
        name = "lua/commands/${name}";
        value = { source = lib.path.append ./commands "${name}"; };
      }) fileNames;
      extra = builtins.listToAttrs files;
    in extra;

  };
}
