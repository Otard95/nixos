{ ... }:
{
  programs.nixvim.plugins.nvim-colorizer = {
    enable = true;

    fileTypes = [
      { language = "markdown"; names = false; }
    ];
  };
}
