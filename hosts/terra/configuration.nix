#nixpkgs-unstable Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, pkgs-stable, meta, inputs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  networking.hostName = meta.hostname; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable networking
  networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = "Europe/Oslo";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "nb_NO.UTF-8";
    LC_IDENTIFICATION = "nb_NO.UTF-8";
    LC_MEASUREMENT = "nb_NO.UTF-8";
    LC_MONETARY = "nb_NO.UTF-8";
    LC_NAME = "nb_NO.UTF-8";
    LC_NUMERIC = "nb_NO.UTF-8";
    LC_PAPER = "nb_NO.UTF-8";
    LC_TELEPHONE = "nb_NO.UTF-8";
    LC_TIME = "nb_NO.UTF-8";
  };

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.otard = {
    isNormalUser = true;
    description = "Stian";
    extraGroups = [ "networkmanager" "wheel" ];
    packages = with pkgs; [];
  };

  # Graphics
  hardware.graphics = {
    enable = true;
  };

  hardware.nvidia = {
    modesetting.enable = true;
    # powerManagement = true;
    open = false;
    nvidiaSettings = true;
    package = config.boot.kernelPackages.nvidiaPackages.stable;
  };

  # Sound
  hardware.pulseaudio = {
    enable = false;
    extraModules = [ pkgs.pulseaudio-modules-bt ];
  };

  # Bluetooth
  hardware.bluetooth = {
    enable = true;
  };

  # Desktop Environment
  programs.hyprland = {
    enable = true;
    xwayland.enable = true;
  };
  environment.sessionVariables = {
    # If cursor becomes invisible
    # WLR_NO_HARDWARE_CURSORS = "1";
    # Hint electron apps to use wayland
    NIXOS_OZONE_WL = "1";
  };
  security = {
    rtkit.enable = true;
    polkit.enable = true;
  };
  services = {
    displayManager.sddm = {
      enable = false;
      # package = pkgs-stable.sddm;
      wayland.enable = true;
    };
    pipewire = {
      enable = true;
      alsa.enable = true;
      pulse.enable = true;
    };
  };

  # programs.sway.enable = true;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    neovim
    kitty
    hyprcursor
    waybar
    dunst
    libnotify
    swww
    rofi-wayland
    git
    fzf
    jq
    ripgrep
    tmux
    firefox
    inputs.zen-browser.packages."${system}".default
    gcc
    nodejs
    unzip
    pkgs-stable.pavucontrol
  #  vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
  #  wget
  ];

  fonts.packages = with pkgs; [
    (nerdfonts.override { fonts = [ "Meslo" ]; })
  ];

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

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "24.05"; # Did you read the comment?

}
