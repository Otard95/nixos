{ config, lib, pkgs, inputs, ... }:
let
  cfg = config.modules.packages.quickemu;
  enable = cfg.enable;
in {

  options.modules.packages.quickemu.enable =
    lib.mkEnableOption "quickemu";

  config = lib.mkIf enable {
    virtualisation.spiceUSBRedirection.enable = true;
    environment.systemPackages = with pkgs; [
      inputs.quickemu.packages."${stdenv.hostPlatform.system}".default
      # (quickemu.overrideAttrs  (_: {
      #   pname = "quickemu";
      #   version = "4.9.7";

      #   src = fetchFromGitHub {
      #     owner = "quickemu-project";
      #     repo = "quickemu";
      #     rev = "2c22f0c31e5ece59c75ae9b8f1ef00890318f574";
      #     hash = "sha256-8ZV2BeuuByXI9iJfr6MTNati3iOTLSV7j1waERGEF3A=";
      #   };
      # }))
    ];
  };
}
