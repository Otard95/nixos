{ config, lib, pkgs, ... }:
let
  cfg = config.modules.nixvim.plugins.dadbod;
  enable = cfg.enable;
in {
  options.modules.nixvim.plugins.dadbod.enable =
    lib.mkEnableOption "dadbod plugin";

  config = lib.mkIf enable {
    programs.nixvim = {
      extraPackages = with pkgs; [
        mariadb
        redis
      ];
      plugins = {
        vim-dadbod.enable = true;
        vim-dadbod-completion.enable = true;
        vim-dadbod-ui.enable = true;
      };
      extraConfigLua = ''
        local db_ui_pass_config = nil
        local function resolveDB(name)
          return function()
            if db_ui_pass_config == nil then
              -- Secret with json structure:
              -- {
              --   "urls": { "<url-name>": "[user[:pass]@]<host>" },
              --   "databases": { "<name>": { "url": "<url-name>", path = "<path-with-slash>" } }
              -- }
              db_ui_pass_config = vim.fn.json_decode(vim.fn.system('pass show database/db-ui-config'))
            end

            local database_config = db_ui_pass_config.databases[name]
            if database_config == nil then
              print('[DB_UI](resolveDB) Could no config for db with name: '..name)
              return ""
            end

            local url = db_ui_pass_config.urls[database_config.url]
            if url == nil then
              print('[DB_UI](resolveDB) No url: '..database_config.url)
              return ""
            end

            return 'mariadb://'..url..database_config.path
          end
        end

        vim.g.dbs = {
          { name = 'ms-dev', url = resolveDB('ms-dev') },
          { name = 'ms-pre', url = resolveDB('ms-pre') },
          { name = 'ms-pro', url = resolveDB('ms-pro') },
          { name = 'tenderms-dev', url = resolveDB('tenderms-dev') },
          { name = 'tenderms-pre', url = resolveDB('tenderms-pre') },
          { name = 'tenderms-pro', url = resolveDB('tenderms-pro') },
          { name = 'ma2-dev', url = resolveDB('ma2-dev') },
          { name = 'ma2-pre', url = resolveDB('ma2-pre') },
          { name = 'ma2-pro', url = resolveDB('ma2-pro') },
          { name = 'chatms-dev', url = resolveDB('chatms-dev') },
          { name = 'chatms-pre', url = resolveDB('chatms-pre') },
          { name = 'chatms-pro', url = resolveDB('chatms-pro') },
          { name = 'reviewms-dev', url = resolveDB('reviewms-dev') },
          { name = 'reviewms-pre', url = resolveDB('reviewms-pre') },
          { name = 'reviewms-pro', url = resolveDB('reviewms-pro') },
          { name = 'ticketms-dev', url = resolveDB('ticketms-dev') },
          { name = 'ticketms-pre', url = resolveDB('ticketms-pre') },
          { name = 'ticketms-pro', url = resolveDB('ticketms-pro') },
          { name = 'service-manager-dev', url = resolveDB('service-manager-dev') },
          { name = 'service-manager-pre', url = resolveDB('service-manager-pre') },
          { name = 'service-manager-pro', url = resolveDB('service-manager-pro') },
          { name = 'melvis-dev', url = resolveDB('melvis-dev') },
          { name = 'melvis-pre', url = resolveDB('melvis-pre') },
          { name = 'melvis-pro', url = resolveDB('melvis-pro') },
        }
      '';
    };
  };
}
