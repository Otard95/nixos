{ config, lib, ... }:
let
  cfg = config.modules.term.git;
  enable = cfg.enable;
in {
  options.modules.term.git = {
    enable = lib.mkEnableOption "git";
    user = {
      name = lib.mkOption {
        description = "The git user name";
        type = lib.types.str;
        default = "Stian M";
      };
      email = lib.mkOption {
        description = "The git user email";
        type = lib.types.str;
        default = "otard.code@proton.me";
      };
    };
  };

  config = lib.mkIf enable {
    programs.git = {
      enable = true;

      userName = cfg.user.name;
      userEmail = cfg.user.email;

      delta.enable = true;

      signing = {
        key = "914102AFC03F586D";
        signByDefault =  true;
      };

      aliases = {
        co = ''checkout'';
        ci = ''commit'';
        remove = ''reset HEAD --'';
        st = ''status'';
        br = ''branch'';
        hist = ''log --pretty=format:\"%h %ad | %s%d [%an]\" --graph --date=short'';
        sta = lib.concatStrings (
          [ "!git branch $1 ; git subtree add --prefix ../$1 $1" ]
          ++ lib.optional config.modules.term.zoxide.enable " && zoxide add ../$1"
          ++ [ " #" ]
        );
        stu = ''subtree pull --prefix'';
        stp = ''subtree push --prefix'';
      };

      ignores = [
        "**/NetrwTreeListing*"
        "**/.netrwhist"
        "**/*.swo"
        "**/*.swn"
        "*.vim"
        "*.BAK"
        "*-BAK"
        "*_BAK"
        ".vscode/"
        "**.swp"
        "**/ctags-index-files.rc"
        "**/tags"
        ".php_cs"
        ".ngm"
        "*.pem"
        "**/dictionary.latin1.add"
        "**/dictionary.latin1.add.spl"
        "**/.vimspector.json"
        "**/.watchmanconfig"
        "**/.tmp"
        "*.tmp"
        "**/.nvmrc"
        "**/_*"
        "**/_*.*"
      ];

      extraConfig = {
        init = {
          defaultBranch = "main";
        };
        pull = {
          rebase = true;
        };
        checkout = {
          defaultRemote = "origin";
        };
        rerere = {
          enabled = true;
        };
      };

      includes = [
        {
          condition = "gitdir:~/dev/personal/";
          contents = {
            user = {
              name = "Stian M";
              email = "otard.code@proton.me";
            };
          };
        }
      ];
    };
  };
}
