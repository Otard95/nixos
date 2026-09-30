{ config, lib, pkgs, inputs, ... }:
let
  cfg = config.modules.packages.sonora;
  enable = cfg.enable;
in {
  options.modules.packages.sonora.enable =
    lib.mkEnableOption "sonora";

  config = lib.mkIf enable {
    programs.sonora = {
      enable = true;
      package =
        let
          base = inputs.sonora.packages.${pkgs.stdenv.hostPlatform.system}.default;
        in
        pkgs.symlinkJoin {
          name = "sonora-schemas";
          paths = [ base ];
          nativeBuildInputs = [ pkgs.makeWrapper ];
          postBuild = ''
            wrapProgram $out/bin/sonora \
              --prefix XDG_DATA_DIRS : "${pkgs.gsettings-desktop-schemas}/share/gsettings-schemas/${pkgs.gsettings-desktop-schemas.name}"
          '';
          meta.mainProgram = "sonora";
        };
      settings = {
        provider = "youtube";
        appearance.theme = "dark";
      };
    };
  };
}
