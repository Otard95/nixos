{ config, lib, ... }:
let
  cfg = config.modules.term.opencode;
  enable = cfg.enable;
in {

  options.modules.term.opencode.enable = lib.mkEnableOption "opencode configuration";

  config = lib.mkIf enable {

    programs.opencode = {
      enable = true;

      settings = {
        theme = lib.mkForce "catppuccin-frappe-transparent";
        permission = import ./permissions.nix;
        keybinds = {
          messages_first = "ctrl+g";
          messages_last = "ctrl+alt+g";
          messages_page_up = "ctrl+u,ctrl+alt+b";
          messages_page_down = "ctrl+d,ctrl+alt+f";
          input_submit = "ctrl+return";
          input_newline = "return,shift+return,alt+return";
          input_delete_to_line_start = "none";
          input_delete_to_line_end = "none";
          input_delete = "delete,shift+delete";
          input_buffer_home = "pageup";
          input_buffer_end = "pagedown";
          input_select_buffer_home = "shift+pageup";
          input_select_buffer_end = "shift+pagedown";
          input_line_home = "home,ctrl+a";
          input_line_end = "end,ctrl+e";
          input_select_line_home = "shift+home,ctrl+shift+a";
          input_select_line_end = "shift+end,ctrl+shift+e";
        };
      };

      themes = {
        catppuccin-frappe-transparent = import ./themes/catppuccin-frappe-transparent.nix;
      };

      commands = let
        fileNames = builtins.attrNames (builtins.readDir ./commands);
        files = map (name: {
          name = "${lib.strings.removeSuffix ".md" name}";
          value = builtins.readFile (lib.path.append ./commands "${name}");
        }) fileNames;
      in builtins.listToAttrs files;

      agents = let
        fileNames = builtins.attrNames (builtins.readDir ./agents);
        files = map (name: {
          name = "${lib.strings.removeSuffix ".md" name}";
          value = builtins.readFile (lib.path.append ./agents "${name}");
        }) fileNames;
      in builtins.listToAttrs files;

    };

  };

}
