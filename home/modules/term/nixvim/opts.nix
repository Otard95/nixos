{ config, ... }:
let
  nixvim = config.lib.nixvim;
in {
  programs.nixvim.opts = {
    # Indenting
    expandtab = true;
    shiftwidth = 2;
    tabstop = 2;
    autoindent = true;
    smartindent = true;

    # Line numbers
    relativenumber = true;
    number = true;

    # Colors
    termguicolors = false;

    # Folding
    foldlevel = 2;

    # Search
    # smartcase = true;
    ignorecase = true;

    # Line wrapping
    wrap = true;
    showbreak = "↪ ";
    linebreak = true;
    colorcolumn = "80";
    signcolumn = "yes";

    # Undo, swap, backup
    swapfile = false;
    backup = false;
    undodir = nixvim.mkRaw "os.getenv('HOME') .. '/.local/state/nvim/undodir'";
    undofile = true;

    # Misc
    wildmode = "longest:full,full";
    list = true;
    listchars = "tab:󰌒 ,trail:⋅";
    scrolloff = 20;
    sidescrolloff = 10;
    cmdheight = 2;
    mouse = "a";
    updatetime = 50;
    # "formatoptions:remove" = nixvim.mkRaw "{ 'o' }";
  };
}
