{
  description = "Top level NixOS Flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    nixpkgs-stable.url = "github:nixos/nixpkgs?ref=nixos-24.11";

    # Home Manager
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Nixvim
    nixvim = {
      url = "github:nix-community/nixvim";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    quickemu = {
      url = "github:quickemu-project/quickemu";
      inputs.nixpkgs.follows = "nixpkgs";
    };


    catppuccin.url = "github:catppuccin/nix";

    zen-browser.url = "github:omarcresp/zen-browser-flake";
  };

  outputs = { nixpkgs, nixpkgs-stable, home-manager, nixvim, catppuccin, ... } @ inputs:
  let
    system = "x86_64-linux";

    pkgs = import nixpkgs {
      inherit system;
      config = {
        allowUnfree = true;
      };
    };
    pkgs-stable = import nixpkgs-stable {
      inherit system;
      config = {
        allowUnfree = true;
      };
    };

    theme = {
      flavor = "frappe";
      accent = "teal";
      size = "standard";
      tweaks = [];
      font = {
        regular = "MesloLGM";
        mono = "MesloLGMDZ Mono";
        icons = "Symbols Nerd Font";
      };
    };

    sources = import ./sources;
  in {

    nixosConfigurations = {
      terra = nixpkgs.lib.nixosSystem {
        specialArgs = {
          inherit pkgs pkgs-stable theme inputs;
          meta = { hostname = "terra"; };
        };
        system = system;
        modules = [
          catppuccin.nixosModules.catppuccin
          nixvim.nixosModules.nixvim
          ./nixvim
          ./modules
          ./hosts/terra/configuration.nix

          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.backupFileExtension = "bak";
            home-manager.extraSpecialArgs = { inherit pkgs pkgs-stable theme inputs sources; };
            home-manager.users.otard = {
              imports = [
                catppuccin.homeManagerModules.catppuccin
                nixvim.homeManagerModules.nixvim
                ./nixvim
                ./home-manager-modules
                ./hosts/terra/home.nix
              ];
            };
          }
        ];
      };

      phobos = nixpkgs.lib.nixosSystem {
        specialArgs = {
          inherit pkgs pkgs-stable theme inputs;
          meta = { hostname = "phobos"; };
        };
        system = system;
        modules = [
          catppuccin.nixosModules.catppuccin
          nixvim.nixosModules.nixvim
          ./nixvim
          ./modules
          ./hosts/phobos/configuration.nix

          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.backupFileExtension = "bak";
            home-manager.extraSpecialArgs = { inherit pkgs pkgs-stable theme inputs sources; };
            home-manager.users.otard = {
              imports = [
                catppuccin.homeManagerModules.catppuccin
                nixvim.homeManagerModules.nixvim
                ./nixvim
                ./home-manager-modules
                ./hosts/phobos/home.nix
              ];
            };
          }
        ];
      };
    };

  };
}
