{ outputs, ... }: {
  nixpkgs = {
    # You can add overlays here
    overlays = [
      outputs.overlays.additions
      outputs.overlays.modifications
    ];

    config = {
      allowUnfree = true;
      # Workaround for https://github.com/nix-community/home-manager/issues/2942
      allowUnfreePredicate = (_: true);
    };
  };

  programs.home-manager.enable = true;

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

