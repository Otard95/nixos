{ config, lib, ... }:
let
  cfg = config.modules.packages.ollama;
  enable = cfg.enable;
in {
  options.modules.packages.ollama.enable =
    lib.mkEnableOption "ollama";

  config = lib.mkIf enable {
    services.ollama = {
      enable = true;
      acceleration = "cuda";
    };
  };
}
