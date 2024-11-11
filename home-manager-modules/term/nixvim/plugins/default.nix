{ ... }:
{
  imports = [
    ./barbecue.nix
    ./cloak.nix
    ./colorize.nix
    ./dap.nix
    ./git.nix
    ./harpoon.nix
    ./lsp.nix
    ./lualine.nix
    ./markdown.nix
    ./nvim-tree.nix
    ./oil.nix
    ./telescope.nix
    ./text-manipulation.nix
    ./tmux-navigator.nix
    ./treesitter.nix
    ./trouble.nix
    ./undotree.nix
    # TODO: dadbod
    # TODO: obsidian - work only?
    # TODO: linediff
    # TODO: nvim-rest
    # TODO: snippets
    # TODO: cmp?
    # TODO: fidget
  ];

# plugins.mini.modules.icons
  programs.nixvim.plugins.mini = {
    enable = true;
    mockDevIcons = true;
    modules = {
      icons.enable = true;
    };
  };
}
