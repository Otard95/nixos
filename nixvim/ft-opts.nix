{ config, lib, ... }:
let
  cfg = config.modules.nixvim.ft-opts;

  nixvim = config.lib.nixvim;
in {
  options.modules.nixvim.ft-opts = lib.mkOption {
    type = with lib.types; attrsOf (attrsOf anything);
    description = "A set of filetypes as keays and `nixvim.opts` values";
    default = {};
  };

  config = {
    programs.nixvim = {

      extraConfigLuaPre = ''
        local __ft_options = ${nixvim.toLuaObject cfg}
      '';

      autoCmd = [
        {
          event = ["FileType"];
          pattern = ["*"];
          callback = nixvim.mkRaw ''
            function (event)
              local ft = event.match
              if __ft_options[ft] then
                for k, v in pairs(__ft_options[ft]) do
                  vim.opt_local[k] = v
                end
              end
            end
          '';
        }
      ];

    };
  };
}
