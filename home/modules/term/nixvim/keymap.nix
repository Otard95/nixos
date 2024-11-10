{ config, lib, ... }:
let
  nixvim = config.lib.nixvim;
in {
  programs.nixvim.globals = {
    mapleader = " ";
    maplocalleader = " ";
  };

  programs.nixvim.keymaps = map (m: {
    mode = builtins.elemAt m 0;
    key = builtins.elemAt m 1;
    action = builtins.elemAt m 2;
    options = { silent = true; } // builtins.elemAt m 3;
  }) [
    # Keep the caret where it is
    [ "n" "J"     "mzJ`z"   {} ]
    [ "n" "<C-d>" "<C-d>zz" {} ]
    [ "n" "<C-u>" "<C-u>zz" {} ]
    [ "n" "n"     "nzzzv"   {} ]
    [ "n" "N"     "Nzzzv"   {} ]
    [ "n" "zm"    "zmzz"    {} ]
    [ "n" "zM"    "zMzz"    {} ]
    [ "n" "zr"    "zrzz"    {} ]
    [ "n" "zR"    "zRzz"    {} ]
    [ "n" "zo"    "zozz"    {} ]
    [ "n" "zO"    "zOzz"    {} ]
    [ "n" "zc"    "zczz"    {} ]
    [ "n" "zC"    "zCzz"    {} ]

    # Just no
    [ "n" "Q" "<nop>" {} ]

    # Move selected text in visual mode
    [ "v" "J" ":m '>+1<CR>gv=gv" {} ]
    [ "v" "K" ":m '<-2<CR>gv=gv" {} ]

    # Substitute word under cursor
    [ "n" "<leader>s" (nixvim.mkRaw ''[[:%s/\<<C-r><C-w>\>/<C-r><C-w>/gI<Left><Left><Left>]]'') {} ]

    # Make this file executable
    [ "n" "<leader>x" "<cmd>!chmod +x %<CR>" {} ]

    # Reselect visual selection after indenting
    [ "v" "<" "<gv" { noremap = true; } ]
    [ "v" ">" ">gv" { noremap = true; } ]

    # When text is wrapped or folded, move by terminal rows not lines
    [ "n" "j" "gj" { noremap = true; } ]
    [ "n" "k" "gk" { noremap = true; } ]
    [ "v" "j" "gj" { noremap = true; } ]
    [ "v" "k" "gk" { noremap = true; } ]
    # TODO: figure out the function
    # vim.keymap.set('n', '{', fn.partial(move.skipping_folds, '{'), { noremap = true; })
    # vim.keymap.set('n', '}', fn.partial(move.skipping_folds, '}'), { noremap = true; })

    # Paste replace visual selection without copy
    [ "v" "<leader>p" ''"_dP'' { noremap = true; } ]

    # Stop highlight
    [ "n" "<tab>" ":noh<CR>" { noremap = true; } ]

    # Buffer cleaning
    # TODO: Figure out the command file this is created in
    # [ "n" "<leader>bo" ":BufOnly<CR>" {} ]

    # Copy reference
    # TODO: Figure out the command file this is created in
    # [ "n" "<leader>cr" "Reference<CR>" {} ]
    # [ "v" "<leader>cr" "Reference<CR>" {} ]

    # Resizing
    [ "n" "<leader>>" ":vertical resize +4<CR>" {} ]
    [ "n" "<leader><" ":vertical resize -4<CR>" {} ]
  ];
}
