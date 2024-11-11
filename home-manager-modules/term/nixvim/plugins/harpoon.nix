{ ... }:
{
  programs.nixvim.plugins.harpoon = {
    enable = true;

    keymaps = {
      addFile = "<leader>a";
      toggleQuickMenu = "<leader>e";
      navFile = {
        "1" = "<leader>h";
        "2" = "<leader>j";
        "3" = "<leader>k";
        "4" = "<leader>l";
        "5" = "<leader>;";
        "6" = "<leader>'";
      };
      navNext = "<leader>n";
      navPrev = "<leader>p";
    };
  };
}
