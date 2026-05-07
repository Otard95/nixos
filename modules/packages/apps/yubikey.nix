{ config, lib, pkgs, ... }:
let
  cfg = config.modules.packages.apps.yubikey;
  enable = cfg.enable;
in {
  options.modules.packages.apps.yubikey.enable = lib.mkEnableOption "yubikey";

  config = lib.mkIf enable {

    # YubiKey
    environment.systemPackages = with pkgs; [
      yubioath-flutter         # GUI app for otp and more
      yubikey-personalization  # CLI tools for configuring YubiKey
      yubikey-manager          # Manage YubiKey settings
      yubikey-agent
      libfido2                 # Support for FIDO2/WebAuthn
      opensc                   # Smart card support
      gnupg                    # If using GPG with YubiKey
      pcsclite
    ];

    hardware.gpgSmartcards.enable = true;

    services = {
      udev.packages = with pkgs; [ yubikey-personalization ];
      pcscd.enable = true;
      yubikey-agent.enable = true;
    };

  };
}
