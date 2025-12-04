{ config, lib, pkgs, helpers, ... }:
let
  cfg = config.modules.packages.apps.logitech.logiops;
  enable = cfg.enable;
  utils = import ./logiops-utils.nix { inherit pkgs; inherit lib; inherit helpers; };

  mergedConfig =
  let
    enabledPresets =
      lib.filterAttrs (name: _: cfg.preset.${name}) utils.preset;

    mergedPresets =
      lib.foldl' utils.recursiveUpdateNonNull {} (lib.attrValues enabledPresets);
  in
    utils.recursiveUpdateNonNull mergedPresets cfg.settings;


  finalConfig = mergedConfig // {
    devices = utils.toListDevices mergedConfig.devices;
  };

  configFormat = pkgs.formats.libconfig {};
  configFile = configFormat.generate "logid.cfg" (utils.filterDeep (_: v: v != null) (builtins.trace (builtins.toJSON finalConfig) finalConfig));
in {
  options.modules.packages.apps.logitech.logiops = {
    enable = lib.mkEnableOption "logiops";

    settings = lib.mkOption {
      description = "logiops configuration";
      default = {};
      type = utils.settings-type;
    };

    preset = {
      sensibleMXMaster4 = lib.mkEnableOption "Sensible defaults MX Master 4";
    };
  };

  config = lib.mkIf enable {
    environment.systemPackages =
      []
      ++ lib.optional cfg.enable pkgs.logiops;

    systemd.services.logid = lib.mkIf cfg.enable {
      enable = true;
      description = "Logitech Configuration Daemon";
      wants = ["multi-user.target"];
      after = ["multi-user.target"];
      wantedBy = ["graphical.target"];
      startLimitIntervalSec = 0;
      serviceConfig = {
        Type = "simple";
        ExecStart = "${pkgs.logiops}/bin/logid -c ${configFile}";
        User = "root";
      };
    };
  };
}
