{ config, lib, pkgs-stable, ... }:
let
  cfg = config.modules.term.aws;
  enable = cfg.enable;
in {
  options.modules.term.aws.enable =
    lib.mkEnableOption "aws";

  config = lib.mkIf enable {

    home.packages = with pkgs-stable; [
      awscli2
      (pkgs-stable.writeShellScriptBin "aws-mfa" ''
        json="$(aws sts get-session-token --serial-number arn:aws:iam::455170233623:mfa/stian.myklebostad-yubikey --token-code $@)"
        echo "$json"
        echo "[default]
        aws_access_key_id = $(echo "$json" | jq '.Credentials.AccessKeyId')
        aws_secret_access_key = $(echo "$json" | jq '.Credentials.SecretAccessKey')
        aws_session_token = $(echo "$json" | jq '.Credentials.SessionToken')
        expiration = $(echo "$json" | jq '.Credentials.Expiration')" > ~/.aws/credentials
        '')
      ];

      modules.term.bash.bindToSecret.aws-mfa = {
        AWS_ACCESS_KEY_ID = "aws/access-key-id";
        AWS_SECRET_ACCESS_KEY = "aws/secret-access-key";
      };

    };
  }
