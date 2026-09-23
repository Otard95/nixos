{
  description = "Top level NixOS Flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    nixpkgs-stable.url = "github:nixos/nixpkgs?ref=nixos-26.05";

    # Home Manager
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Nixvim
    nixvim = {
      url = "github:nix-community/nixvim";
      # inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-index-database = {
      url = "github:nix-community/nix-index-database";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    catppuccin.url = "github:catppuccin/nix";

    zen-browser = {
      url = "github:youwen5/zen-browser-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    vicinae-extensions = {
      url = "github:vicinaehq/extensions";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    pass-env = {
      url = "github:Otard95/pass-env";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    ed-expedition = {
      url = "github:Otard95/ed-expedition";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    voxtype = {
      url = "github:peteonrails/voxtype";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    pi-extensions.url = "github:Otard95/pi-extensions/v0.20.0";

    # Tmp fix until nixpkgs are updated
    firezone.url = "github:firezone/firezone/gui-client-1.5.16";

    sonora = {
      url = "github:sonorahq/sonora";
    };
  };

  outputs = { nixpkgs, nixpkgs-stable, home-manager, nixvim, catppuccin, nix-index-database, voxtype, sonora, firezone, ... } @ inputs:
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
    helpers = import ./helpers { pkgs = import nixpkgs { inherit system; }; };

    mkSystem = hostname: nixpkgs.lib.nixosSystem {
      specialArgs = {
        inherit theme inputs pkgs-stable sources helpers;
        meta = { hostname = hostname; };
      };
      system = system;
      modules = [
        catppuccin.nixosModules.catppuccin
        nixvim.nixosModules.nixvim
        firezone.nixosModules.default
        ./nixvim
        ./modules
        (nixpkgs.lib.path.append ./hosts "${hostname}/configuration.nix")

        home-manager.nixosModules.home-manager
        {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.backupFileExtension = "bak";
          home-manager.extraSpecialArgs = { inherit theme inputs pkgs-stable sources helpers; };
          home-manager.users.otard = {
            imports = [
              catppuccin.homeModules.catppuccin
              nixvim.homeModules.nixvim
              nix-index-database.homeModules.default
              voxtype.homeManagerModules.default
              sonora.homeManagerModules.default
              ./home-manager-modules
              ./nixvim
              (nixpkgs.lib.path.append ./hosts "${hostname}/home.nix")
            ];
          };
        }
      ];
    };
  in {

    nixosConfigurations = {
      terra = mkSystem "terra";
      phobos = mkSystem "phobos";
      deimos = mkSystem "deimos";
    };

  };
}
