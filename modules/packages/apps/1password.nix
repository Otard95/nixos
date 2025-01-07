{ config, lib, ... }:
let
  cfg = config.modules.packages.apps._1password;
  enable = cfg.enable;
in {
  options.modules.packages.apps._1password.enable =
    lib.mkEnableOption "_1password";

  config = lib.mkIf enable {

    programs = {
      _1password.enable = true;
      _1password-gui = {
        enable = true;
        polkitPolicyOwners = [ "otard" ];
      };
    };

    environment.etc = {
      "1password/custom_allowed_browsers" = {
        text = ''
          zen
          .zen-wrapped
        '';
        mode = "0755";
      };
    };

  };
}
