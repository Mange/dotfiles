{
  description = "Mange's computation dungeon";

  inputs = {
    # Nixpkgs
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    # You can access packages and modules from different nixpkgs revs
    # at the same time. Here's an working example:
    # nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
    # Also see the 'unstable-packages' overlay at 'overlays/default.nix'.

    # Home manager
    home-manager.url = "github:nix-community/home-manager/master";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    hardware.url = "github:nixos/nixos-hardware";

    neovim-nightly-overlay.url = "github:nix-community/neovim-nightly-overlay";

    hyprland.url = "github:hyprwm/Hyprland";
    hy3 = {
      url = "github:outfoxxed/hy3";
      inputs.hyprland.follows = "hyprland";
    };

    android-nixpkgs = {
      url = "github:tadfisher/android-nixpkgs";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager, ... }@inputs:
    let
      inherit (self) outputs;
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
      nixosConfigurations = {
        socia = nixpkgs.lib.nixosSystem {
          specialArgs = { inherit inputs outputs; };
          modules = [./systems/socia/configuration.nix];
        };
        vera = nixpkgs.lib.nixosSystem {
          specialArgs = { inherit inputs outputs; };
          modules = [./systems/vera/configuration.nix];
        };
        porto = nixpkgs.lib.nixosSystem {
          specialArgs = { inherit inputs outputs; };
          modules = [./systems/porto/configuration.nix];
        };
      };

      # Standalone home-manager configuration entrypoint
      # Available through 'home-manager --flake .#your-username@your-hostname'
      homeConfigurations = let
        homeConfig = home-manager.lib.homeManagerConfiguration;
        hyprlandModule = inputs.hyprland.homeManagerModules.default;
        extraSpecialArgs = { inherit inputs outputs; };
      in {
        "mange@socia" = homeConfig {
          inherit extraSpecialArgs;
          pkgs = nixpkgs.legacyPackages.x86_64-linux;
          modules = [
            hyprlandModule
            ./home/socia
          ];
        };
        "mange@vera" = homeConfig {
          inherit extraSpecialArgs;
          pkgs = nixpkgs.legacyPackages.x86_64-linux;
          modules = [
            hyprlandModule
            ./home/vera
          ];
        };
        "mange@porto" = homeConfig {
          inherit extraSpecialArgs;
          pkgs = nixpkgs.legacyPackages.x86_64-linux;
          modules = [
            hyprlandModule
            ./home/porto
          ];
        };
      };
    };
}
