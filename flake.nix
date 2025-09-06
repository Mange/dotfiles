{
  description = "Mange's computation dungeon";

  inputs = {
    # Nixpkgs
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    # You can access packages and modules from different nixpkgs revs
    # at the same time. Here's an working example:
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    nixos-stable.url = "github:nixos/nixpkgs/nixos-24.05";
    # Also see the 'unstable-packages' overlay at 'overlays/default.nix'.

    # For random cases where I need something straight from Git.
    nixpkgs-master.url = "github:nixos/nixpkgs/master";

    # Hardware configuration
    hardware.url = "github:nixos/nixos-hardware";

    # Nix index DB
    nix-index-database.url = "github:nix-community/nix-index-database";
    nix-index-database.inputs.nixpkgs.follows = "nixpkgs";

    # Sops
    sops-nix.url = "github:Mic92/sops-nix";
    sops-nix.inputs.nixpkgs.follows = "nixpkgs";

    # Home manager
    home-manager.url = "github:nix-community/home-manager/master";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    # Catppuccin
    catppuccin.url = "github:catppuccin/nix";
  };

  outputs = { self, nixpkgs, sops-nix, home-manager, nix-index-database, ... }@inputs:
    let
      inherit (self) outputs;
      extraSystemModules = [ nix-index-database.nixosModules.nix-index ];
      forAllSystems = nixpkgs.lib.genAttrs [
        "x86_64-linux"
      ];
    in
    {
      # Your custom packages
      # Acessible through 'nix build', 'nix shell', etc
      packages = forAllSystems (system:
        let pkgs = nixpkgs.legacyPackages.${system};
        in import ./nix/pkgs { inherit pkgs; }
      );
      # Devshell for bootstrapping
      # Acessible through 'nix develop' or 'nix-shell' (legacy)
      devShells = forAllSystems (system:
        let pkgs = nixpkgs.legacyPackages.${system};
        in import ./shell.nix { inherit pkgs; }
      );

      # Your custom packages and modifications, exported as overlays
      overlays = import ./nix/overlays { inherit inputs; };
      # Reusable nixos modules you might want to export
      # These are usually stuff you would upstream into nixpkgs
      nixosModules = import ./nix/modules/nixos;
      # Reusable home-manager modules you might want to export
      # These are usually stuff you would upstream into home-manager
      homeManagerModules = import ./nix/modules/home-manager;

      # NixOS configuration entrypoint
      # Available through 'nixos-rebuild switch --flake .#your-hostname'
      nixosConfigurations = let
        specialArgs = {
          inherit inputs outputs;
          rootPath = ./.;
        };
      in {
        socia = nixpkgs.lib.nixosSystem {
          inherit specialArgs;
          modules = extraSystemModules ++ [./systems/socia/configuration.nix];
        };
        vera = nixpkgs.lib.nixosSystem {
          inherit specialArgs;
          modules = extraSystemModules ++ [./systems/vera/configuration.nix];
        };
        porto = nixpkgs.lib.nixosSystem {
          inherit specialArgs;
          modules = extraSystemModules ++ [./systems/porto/configuration.nix];
        };
      };

      # Standalone home-manager configuration entrypoint
      # Available through 'home-manager --flake .#your-username@your-hostname'
      homeConfigurations = let
        homeConfig = home-manager.lib.homeManagerConfiguration;
        extraSpecialArgs = {
          inherit inputs outputs;
          rootPath = ./.;
        };
      in {
        "mange@socia" = homeConfig {
          extraSpecialArgs = extraSpecialArgs // {
            isLaptop = false;
          };
          pkgs = nixpkgs.legacyPackages.x86_64-linux;
          modules = [ ./home/socia ];
        };
        "mange@vera" = homeConfig {
          extraSpecialArgs = extraSpecialArgs // {
            isLaptop = true;
          };
          pkgs = nixpkgs.legacyPackages.x86_64-linux;
          modules = [ ./home/vera ];
        };
        "mange@porto" = homeConfig {
          extraSpecialArgs = extraSpecialArgs // {
            isLaptop = true;
          };
          pkgs = nixpkgs.legacyPackages.x86_64-linux;
          modules = [ ./home/porto ];
        };
      };
    };
}
