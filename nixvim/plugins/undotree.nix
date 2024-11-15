{ config, lib, ... }:
let
  cfg = config.modules.nixvim.plugins.undotree;
  enable = cfg.enable;
in {
  options.modules.nixvim.plugins.undotree.enable =
    lib.mkEnableOption "undotree plugin";

  config = lib.mkIf enable {
    programs.nixvim = {
      keymaps = [{
        mode = "n";
        key = "<leader>u";
        action = ":UndotreeToggle<CR>";
        options = { silent = true; };
      }];

      plugins.undotree.enable = true;
    };
  };
}
