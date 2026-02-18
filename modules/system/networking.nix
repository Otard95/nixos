{ config, lib, meta, ... }:
let
  cfg = config.modules.system.networking;
  enable = cfg.enable;

  baseDnsServers = [
    # Cloudflare (Block malware)
    "1.1.1.2" "1.0.0.2"
    # Quad9
    "9.9.9.9" "149.112.112.112"
    # AdGuard
    "94.140.14.14" "94.140.15.15"

    # Cloudflare
    "2606:4700:4700::1112" "2606:4700:4700::1002"
    # Quad9
    "2620:fe::fe" "2620:fe::fe"
    # AdGuard
    "2a10:50c0::ad1:ff" "2a10:50c0::ad2:ff"
  ];
in {
  options.modules.system.networking = {
    enable = lib.mkEnableOption "networking";

    additionalDnsServers = lib.mkOption {
      description = "Additional prioritized DNS servers on top of the module default.";
      default = [];
      type = with lib.types; listOf str;
    };

    resolved.enable = lib.mkEnableOption "systemd-resolved";

    preset = {
      smb-backend.enable =
        lib.mkEnableOption "Enable extra hosts and open ports for local backends";
      smb-frontend.enable = 
        lib.mkEnableOption "Enable extra hosts and open ports for local frontends";
    };
  };

  config = lib.mkIf enable (lib.mkMerge [
    {
      networking.hostName = meta.hostname; # Define your hostname.

      # This services makes the 'graphical.target' delay.
      # Which fucks with login and session startup
      systemd.network.wait-online.enable = false;
      systemd.services.NetworkManager-wait-online.enable = false;
      boot.initrd.systemd.network.wait-online.enable = false;

      # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

      # Configure network proxy if necessary
      # networking.proxy.default = "http://user:password@proxy:port/";
      # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

      # Redirect only localhost HTTP/HTTPS to high ports.
      # Use -C first so we don't duplicate rules on rebuild.
      networking.firewall.extraCommands = ''
        iptables -t nat -C OUTPUT -p tcp -d 127.0.0.1/8 --dport 80  -j REDIRECT --to-ports 1080 2>/dev/null \
          || iptables -t nat -A OUTPUT -p tcp -d 127.0.0.1/8 --dport 80  -j REDIRECT --to-ports 1080

        iptables -t nat -C OUTPUT -p tcp -d 127.0.0.1/8 --dport 443 -j REDIRECT --to-ports 1443 2>/dev/null \
          || iptables -t nat -A OUTPUT -p tcp -d 127.0.0.1/8 --dport 443 -j REDIRECT --to-ports 1443
      '';

      # Enable networking
      networking.networkmanager = {
        enable = true;
        # Required to set custom dns
        dns =  "none";
      };

      # These options are unnecessary when managing DNS ourselves
      networking.useDHCP = false;
      networking.dhcpcd.enable = false;

      networking.nameservers = cfg.additionalDnsServers ++ baseDnsServers;

      # Open ports in the firewall.
      # networking.firewall.allowedTCPPorts = [ ... ];
      # networking.firewall.allowedUDPPorts = [ ... ];
      # Or disable the firewall altogether.
      # networking.firewall.enable = false;
    }
    (lib.mkIf cfg.resolved.enable {
      networking.networkmanager.dns = lib.mkForce "systemd-resolved";
      services.resolved = {
        enable = true;

        settings.Resolve.FallbackDNS = cfg.additionalDnsServers ++ baseDnsServers;
      };
    })
    (lib.mkIf cfg.preset.smb-backend.enable {
      networking.firewall = {
        allowedTCPPortRanges = [ { from = 9000; to = 9020; } ];
      };
      networking.extraHosts = ''
        127.0.0.1 tenderms.dart ma2.dart melvis.dart ticketms.dart
      '';
    })
    (lib.mkIf cfg.preset.smb-frontend.enable {
      networking.extraHosts = ''
        127.0.0.1 ma-local.click business.ma-local.click consumer.ma-local.click
      '';
    })
  ]);
}
