{ config, lib, meta, ... }:
let
  cfg = config.modules.system.networking;
  enable = cfg.enable;
in {
  options.modules.system.networking = {
    enable = lib.mkEnableOption "networking";

    preset = {
      smb-backend.enable =
        lib.mkEnableOption "Enable extra hosts and open ports for local backends";
    };
  };

  config = lib.mkIf enable (lib.mkMerge [
    {
      networking.hostName = meta.hostname; # Define your hostname.
      systemd.network.wait-online.enable = false;
      boot.initrd.systemd.network.wait-online.enable = false;
      # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

      # Configure network proxy if necessary
      # networking.proxy.default = "http://user:password@proxy:port/";
      # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

      # Enable networking
      networking.networkmanager.enable = true;

      # Open ports in the firewall.
      # networking.firewall.allowedTCPPorts = [ ... ];
      # networking.firewall.allowedUDPPorts = [ ... ];
      # Or disable the firewall altogether.
      # networking.firewall.enable = false;
    }
    (lib.mkIf cfg.preset.smb-backend.enable {
      networking.firewall = {
        allowedTCPPortRanges = [ { from = 9000; to = 9020; } ];
      };
      networking.extraHosts = ''
        127.0.0.1 tenderms.dart ma2.dart melvis.dart ticketms.dart
      '';
    })
  ]);
}
