{ ... }:
{
  programs.nixvim.plugins.cloak = {
    enable = true;

    settings = {
      patterns = [
        { file_pattern = ".env*"; cloak_pattern = "=.+"; }
        {
          file_pattern = "services.json";
          cloak_pattern = [
            ''(pass": ")[^"]*''
            ''(password": ")[^"]*''
          ];
          replace = "%1";
        }
      ];
    };
  };
}
