{ config, lib, pkgs, ... }:
let
  cfg = config.modules.packages.apps.tldraw;
  enable = cfg.enable;
in {
  options.modules.packages.apps.tldraw.enable = lib.mkEnableOption "tldraw";

  config = lib.mkIf enable {

    environment.systemPackages = let
      pname = "tldraw-offline";
      version = "1.11.0";

      src = pkgs.fetchurl {
        url = "https://github.com/tldraw/${pname}/releases/download/v${version}/tldraw-offline-linux-x86_64.AppImage";
        hash = "sha256-CUkGdHYz22gOYV5X+yAdB4yWi1Ii5zHJ53qgdnNEDgU=";
      };
      icon = pkgs.fetchurl {
        url = "https://raw.githubusercontent.com/tldraw/tldraw/refs/heads/main/apps/mcp-app/plugins/tldraw-mcp/assets/logo.svg";
        hash = "sha256-hv93+xZv9qOOUPrasWFEpBdMh29aDYvL6WHDEuIxLF0=";
      };
    in [
      (pkgs.appimageTools.wrapType2 { inherit pname version src; })
      (pkgs.makeDesktopItem {
        name = pname;
        desktopName = "tldraw";
        exec = pname;
        icon = icon;
        comment = "Infinite whiteboard and diagramming tool";
        categories = [ "Graphics" "Office" ];
        terminal = false;
        startupNotify = true;
      })
    ];

  };
}
