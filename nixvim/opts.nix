{ config, ... }:
let
  nixvim = config.lib.nixvim;
in {

  imports = [ ./ft-opts.nix ];

  config = {
    programs.nixvim.opts = {
      # Indenting
      # expandtab = true;
      shiftwidth = 4;
      tabstop = 4;
      autoindent = true;
      smartindent = true;

      # Line numbers
      relativenumber = true;
      number = true;

      # Colors
      termguicolors = false;

      # Folding
      foldlevel = 4;
      # foldlevelstart = 4;

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
      winborder = "rounded";
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

    modules.nixvim.ft-opts = {
      c = { commentstring = "//%s"; };
      cpp = { commentstring = "//%s"; };
      php = { shiftwidth = 4; tabstop = 4; autoindent = true; };
      json = { formatprg = "jq"; };
      go = { expandtab = false; };
    };
  };
}
