{ outputs, ... }: let 
  nixConfig = ./nixpkgs-config.nix;
in {
  nixpkgs = {
    # You can add overlays here
    overlays = [
      outputs.overlays.additions
      outputs.overlays.modifications
    ];
  };
  nixpkgs.config = import nixConfig;
  xdg.configFile."nixpkgs/config.nix".source = nixConfig;

  programs.home-manager.enable = true;

  manual = {
    html.enable = true;
    json.enable = true;
    manpages.enable = true;
  };

  home = {
    username = "mange";
    homeDirectory = "/home/mange";

    sessionPath = [
      "$HOME/.local/bin"
    ];

    # Setup symlinks.
    file.".local/bin" = {source = ../../bin; recursive = true; };
  };

  # Nicely reload system units when changing configs
  systemd.user.startServices = "sd-switch";

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  home.stateVersion = "23.05";
}

