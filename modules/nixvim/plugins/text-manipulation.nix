{ ... }:
{
  programs.nixvim.plugins = {
    commentary.enable = true;
    vim-surround.enable = true;
    multicursors.enable = true;
    #TODO: nvim-align
    #TODO: vim-abolish
  };
}
