{
  description = "Top level NixOS Flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    # nixpkgs-stable.url = "github:nixos/nixpkgs?ref=nixos-24.05";

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

    zen-browser = {
      url = "github:youwen5/zen-browser-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { nixpkgs, home-manager, nixvim, catppuccin, ... } @ inputs:
  let
    system = "x86_64-linux";

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

    mkSystem = name: {
      specialArgs = {
        inherit theme inputs;
        meta = { hostname = name; };
      };
      system = system;
      modules = [
        catppuccin.nixosModules.catppuccin
        nixvim.nixosModules.nixvim
        ./nixvim
        ./modules
        (nixpkgs.lib.path.append ./hosts "${name}/configuration.nix")

        home-manager.nixosModules.home-manager
        {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.backupFileExtension = "bak";
          home-manager.extraSpecialArgs = { inherit theme inputs sources; };
          home-manager.users.otard = {
            imports = [
              catppuccin.homeManagerModules.catppuccin
              nixvim.homeManagerModules.nixvim
              ./nixvim
              ./home-manager-modules
              (nixpkgs.lib.path.append ./hosts "${name}/home.nix")
            ];
          };
        }
      ];
    };
  in {

    nixosConfigurations = {
      terra = nixpkgs.lib.nixosSystem (mkSystem "terra");
      phobos = nixpkgs.lib.nixosSystem (mkSystem "phobos");
    };

  };
}
