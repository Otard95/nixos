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
    ./99.nix
    ./ai.nix
    ./barbecue.nix
    ./cloak.nix
    ./cmp.nix
    ./colorize.nix
    ./conform.nix
    ./dadbod.nix
    ./dap.nix
    ./fidget.nix
    ./git.nix
    ./harpoon.nix
    ./image.nix
    ./indent-blankline.nix
    ./lazydev.nix
    ./lsp.nix
    ./lualine.nix
    ./luasnip.nix
    ./markdown.nix
    ./mini.nix
    ./neotest.nix
    ./nvim-tree.nix
    ./obsidian.nix
    ./oil.nix
    ./rest.nix
    ./telescope.nix
    ./text-manipulation.nix
    ./tmux-navigator.nix
    ./treesitter-context.nix
    ./treesitter.nix
    ./trouble.nix
    ./undotree.nix
    # TODO: linediff
  ];

  config = let
    presetInt =
      if      cfg.preset == "minimal" then 1
      else if cfg.preset == "basic"   then 2
      else /* cfg.preset == "all"       */ 3;
  in lib.mkIf enable {

    modules.nixvim.plugins = lib.mkMerge [
      {
        mini.modules = {
          icons.enable = lib.mkDefault true;
        };
      }
      (lib.mkIf (presetInt > 0) {
        cloak.enable = lib.mkDefault true;
        git.enable = lib.mkDefault true;
        harpoon.enable = lib.mkDefault true;
        mini.enable = lib.mkDefault true;
        nvim-tree.enable = lib.mkDefault true;
        oil.enable = lib.mkDefault true;
        telescope.enable = lib.mkDefault true;
        text-manipulation.enable = lib.mkDefault true;
        tmux-navigator.enable = lib.mkDefault (config.modules.nixvim.defaultTerminal == "kitty"); # (config.modules.nixvim.defaultTerminal == "kitty")
        undotree.enable = lib.mkDefault true;
      })
      (lib.mkIf (presetInt > 1) {
        barbecue.enable = lib.mkDefault true;
        cmp.enable = lib.mkDefault true;
        colorize.enable = lib.mkDefault true;
        conform.enable = lib.mkDefault true;
        fidget.enable = lib.mkDefault true;
        indent-blankline.enable = lib.mkDefault true;
        lazydev.enable = lib.mkDefault true;
        lsp.enable = lib.mkDefault true;
        lualine.enable = lib.mkDefault true;
        luasnip.enable = lib.mkDefault true;
        markdown.enable = lib.mkDefault true;
        treesitter-context.enable = lib.mkDefault true;
        treesitter.enable = lib.mkDefault true;
        trouble.enable = lib.mkDefault true;
      })
      (lib.mkIf (presetInt > 2) {
        _99.enable = lib.mkDefault true;
        ai.enable = lib.mkDefault true;
        dadbod.enable = lib.mkDefault true;
        dap.enable = lib.mkDefault true;
        image.enable = lib.mkDefault true;
        neotest.enable = lib.mkDefault true;
        rest.enable = lib.mkDefault true;
        obsidian.enable = lib.mkDefault true;
      })
    ];
  };
}
