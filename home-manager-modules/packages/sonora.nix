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
          name = "sonora-dmabuf";
          paths = [ base ];
          nativeBuildInputs = [ pkgs.makeWrapper ];
          postBuild = ''
            wrapProgram $out/bin/sonora \
            --set-default WEBKIT_DISABLE_DMABUF_RENDERER 0
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
