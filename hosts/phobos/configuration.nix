# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ sources, ... }:
{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.timeout = 5;
  boot.initrd.luks.devices."luks-d92c3033-d16d-4ada-a92e-59ce038c5acb".device = "/dev/disk/by-uuid/d92c3033-d16d-4ada-a92e-59ce038c5acb";

  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.otard = {
    isNormalUser = true;
    description = "Stian";
    extraGroups = [ "networkmanager" "wheel" "input" ];
    # packages = with pkgs; [];
  };

  services.logind.settings.Login.HandleLidSwitchDocked = "ignore";
  services.logind.settings.Login.HandleLidSwitchExternalPower = "ignore";
  # services.logind.lidSwitchDocked = "ignore";
  # services.logind.lidSwitchExternalPower = "ignore";

  # Modules
  modules = {
    desktopEnvironment.sddm.background = sources.images.background.forrest-lake-train;
    nixvim.enable = true;
    system = {
      battery-monitor.enable = true;
      fingerprint.enable = true;
      graphics = {
        nvidia.open = true;
        prime = {
          enable = true;
          mode = "offload";
          finegrainedPowerManagement = true;
          intelBusId = "PCI:0:2:0";
          nvidiaBusId = "PCI:1:0:0";
        };
      };
      networking.preset.smb-backend.enable = true;
      printing.enable = true;
      # shell.kind = "zsh";
    };
    packages = {
      docker.enable = true;
      fabric.enable = true;
      ollama.enable = true;
      apps = {
        _1password.enable = true;
        appgate.enable = true;
        clickup.enable = true;
        clocks.enable = true;
        dbeaver.enable = true;
        kdeconnect.enable = true;
        slack.enable = true;
        vivaldi.enable = true;
        games.enable = true;
      };
    };
  };

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  # environment.systemPackages = with pkgs; [ ];

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "24.11"; # Did you read the comment?

}
