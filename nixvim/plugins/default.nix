{ config, lib, ... }:
let
  cfg = config.modules.nixvim.plugins;
  enable = cfg.enable;
in {
  options.modules.nixvim.plugins.enable =
    lib.mkEnableOption "plugins";

  options.modules.nixvim.plugins.preset = lib.mkOption {
    default = "basic";
    description = "Select a plugin preset. This enables/disables a set of plugins.";
    type = lib.types.enum [
      "minimal"
      "basic"
      "all"
    ];
  };

  imports = [
    ./barbecue.nix
    ./cloak.nix
    ./cmp.nix
    ./colorize.nix
    ./dap.nix
    ./fidget.nix
    ./git.nix
    ./harpoon.nix
    ./lsp.nix
    ./lualine.nix
    ./luasnip.nix
    ./markdown.nix
    ./nvim-tree.nix
    ./oil.nix
    ./rest.nix
    ./telescope.nix
    ./text-manipulation.nix
    ./tmux-navigator.nix
    ./treesitter.nix
    ./trouble.nix
    ./undotree.nix
    # TODO: dadbod
    # TODO: obsidian - work only?
    # TODO: linediff
  ];

  config = let
    presetInt =
      if      cfg.preset == "minimal" then 1
      else if cfg.preset == "basic"   then 2
      else /* cfg.preset == "all"       */ 3;
  in lib.mkIf enable {
    programs.nixvim.plugins.mini = {
      enable = true;
      mockDevIcons = true;
      modules = {
        icons.enable = true;
      };
    };

    modules.nixvim.plugins = lib.mkMerge [
      (lib.mkIf (presetInt > 0) {
        cloak.enable = lib.mkDefault true;
        git.enable = lib.mkDefault true;
        harpoon.enable = lib.mkDefault true;
        nvim-tree.enable = lib.mkDefault true;
        oil.enable = lib.mkDefault true;
        telescope.enable = lib.mkDefault true;
        text-manipulation.enable = lib.mkDefault true;
        tmux-navigator.enable = lib.mkDefault true;
        undotree.enable = lib.mkDefault true;
      })
      (lib.mkIf (presetInt > 1) {
        barbecue.enable = lib.mkDefault true;
        cmp.enable = lib.mkDefault true;
        colorize.enable = lib.mkDefault true;
        fidget.enable = lib.mkDefault true;
        lsp.enable = lib.mkDefault true;
        lualine.enable = lib.mkDefault true;
        luasnip.enable = lib.mkDefault true;
        markdown.enable = lib.mkDefault true;
        treesitter.enable = lib.mkDefault true;
        trouble.enable = lib.mkDefault true;
      })
      (lib.mkIf (presetInt > 2) {
        dap.enable = lib.mkDefault true;
        rest.enable = lib.mkDefault true;
      })
    ];
  };
}
