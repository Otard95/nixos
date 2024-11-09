return {
  { 'norcalli/nvim-colorizer.lua', config = function ()
    require 'colorizer'.setup {
      '*';
      markdown = { names = false }
    }
  end }
}
