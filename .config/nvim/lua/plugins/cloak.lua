return {
  {
    'laytan/cloak.nvim',
    event = {
      'BufEnter .env*',
      'BufEnter services.json',
    },
    opts = {
      patterns = {
        { file_pattern = '.env*', cloak_pattern = '=.+' },
        {
          file_pattern = 'services.json',
          cloak_pattern = {
            '(pass": ")[^"]*',
            '(password": ")[^"]*',
          },
          replace = '%1',
        }
      }
    },
  },
}
