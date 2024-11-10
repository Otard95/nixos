{
  description = "Top level NixOS Flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    nixpkgs-stable.url = "github:nixos/nixpkgs?ref=nixos-24.05";

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

    catppuccin.url = "github:catppuccin/nix";

    zen-browser.url = "github:ch4og/zen-browser-flake";
  };

  outputs = { self, nixpkgs, nixpkgs-stable, home-manager, nixvim, catppuccin, ... } @ inputs:
  let
    inherit (self) outputs;

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
    };
  in {

    pkgs-stable = nixpkgs-stable.legacyPackages.${system};

    nixosConfigurations.terra = nixpkgs.lib.nixosSystem {
      specialArgs = {
        inherit pkgs pkgs-stable theme inputs;
        meta = { hostname = "terra"; };
      };
      system = system;
      modules = [
        catppuccin.nixosModules.catppuccin
        nixvim.nixosModules.nixvim
        ./hosts/terra/configuration.nix
        ./modules
        ./modules/theme.nix
        home-manager.nixosModules.home-manager
        {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.backupFileExtension = "bak";
          home-manager.users.otard = {
            imports = [
              ./home/home.nix
              catppuccin.homeManagerModules.catppuccin
              nixvim.homeManagerModules.nixvim
            ];
          };
          home-manager.extraSpecialArgs = { inherit theme inputs; };
        }
      ];
    };

    homeConfigurations.otard = home-manager.lib.homeManagerConfiguration {
      inherit pkgs;
      extraSpecialArgs = { inherit pkgs-stable inputs; };

      modules = [
        ./home.nix
        catppuccin.homeManagerModules.catppuccin
        nixvim.homeManagerModules.nixvim
      ];
    };

  };
}
