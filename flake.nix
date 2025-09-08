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

    zen-browser = {
      url = "github:youwen5/zen-browser-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    ngm = {
      url = "github:Otard95/ngm?ref=feat/go-rewrite";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { nixpkgs, nixpkgs-stable, home-manager, nixvim, catppuccin, ... } @ inputs:
  let
    system = "x86_64-linux";

    pkgs-stable = import nixpkgs-stable {
      system = system;
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
        regular = {
          default = "Meslo LG M";
          extra = [ "Noto Sans CJK JP" ];
        };
        mono = {
          default = "Meslo LG M DZ";
          extra = [ "Noto Sans CJK JP" ];
        };
        icons = "Symbols Nerd Font";
      };
    };

    sources = import ./sources;

    mkSystem = name: {
      specialArgs = {
        inherit theme inputs pkgs-stable sources;
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
          home-manager.extraSpecialArgs = { inherit theme inputs pkgs-stable sources; };
          home-manager.users.otard = {
            imports = [
              catppuccin.homeModules.catppuccin
              nixvim.homeModules.nixvim
              ./home-manager-modules
              ./nixvim
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
      deimos = nixpkgs.lib.nixosSystem (mkSystem "deimos");
    };

  };
}
