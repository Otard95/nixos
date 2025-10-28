{ config, lib, pkgs, inputs, ... }:
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

    home.packages = [
      inputs.ngm.packages."${pkgs.system}".default
    ];

    programs = {
      delta = {
        enable = true;
        enableGitIntegration = true;
      };
      git = {
        enable = true;

        settings = {

          user ={
            name = cfg.user.name;
            email = cfg.user.email;
          };

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

          aliases = {
            co = ''checkout'';
            ci = ''commit'';
            remove = ''reset HEAD --'';
            st = ''status'';
            br = ''branch'';
            hist = ''log --pretty=format:"%h %ad | %s%d [%an]" --graph --date=short'';
            wta = lib.concatStrings (
              [ "!git branch $1 ; git worktree add ../$1 $1" ]
              ++ lib.optional config.modules.term.zoxide.enable " && zoxide add ../$1"
              ++ [ " #" ]
            );
            wtl = ''worktree list'';
            wtr = lib.concatStrings(
              [ ''!git worktree remove $1'' ]
              ++ lib.optional config.modules.term.zoxide.enable " && zoxide remove ../$1"
              ++ [ " #" ]
            );
          };

        };

        signing = {
          key = "914102AFC03F586D";
          signByDefault =  true;
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
          "**/.direnv"
        ];

        includes = [
          {
            condition = "gitdir:~/dev/personal/";
            contents = {
              user = {
                name = "Stian M";
                email = "otard.code@proton.me";
                signingKey = "A3D77EC138A73982";
              };
            };
          }
        ];
      };
    };

  };
}
