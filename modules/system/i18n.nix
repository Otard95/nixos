{ lib, config, ... }:
let
  cfg = config.modules.system.i18n;
  enable = cfg.enable;
in {

  options.modules.system.i18n = {
    enable = lib.mkEnableOption "i18n";
    timeZone = lib.mkOption {
      description = "Time zone of the system";
      default = "Europe/Oslo";
      type = lib.types.singleLineStr;
    };
    defaultLocale = lib.mkOption {
      description = "The default locale. It determines the language for program messages, the format for dates and times, sort order, and so on. It also determines the character set, such as UTF-8.";
      default = "en_US.UTF-8";
      type = lib.types.singleLineStr;
    };
    displayLocale = lib.mkOption {
      description = "The displayLocale overrides the default locale for things like numeric values, time and date, monetary values, etc.";
      default = "en_US.UTF-8";
      type = lib.types.singleLineStr;
    };
  };

  config = lib.mkIf enable {
    # Set your time zone.
    time.timeZone = cfg.timeZone;

    # Select internationalisation properties.
    i18n = {
      supportedLocales = [
        "C.UTF-8/UTF-8"
        "en_US.UTF-8/UTF-8"
        "nb_NO.UTF-8/UTF-8"
      ];
      defaultLocale = cfg.defaultLocale;

      extraLocaleSettings = {
        LC_ADDRESS = cfg.displayLocale;
        LC_IDENTIFICATION = cfg.displayLocale;
        LC_MEASUREMENT = cfg.displayLocale;
        LC_MONETARY = cfg.displayLocale;
        LC_NAME = cfg.displayLocale;
        LC_NUMERIC = cfg.displayLocale;
        LC_PAPER = cfg.displayLocale;
        LC_TELEPHONE = cfg.displayLocale;
        LC_TIME = cfg.displayLocale;
      };
    };

  };

}
