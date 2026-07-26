{
  pkgs,
  inputs,
  config,
  ...
}:
{
  environment.systemPackages = with pkgs; [
    # Should be able to run home-manager after initial install.
    git
    home-manager

    # Filesystem support
    btrfs-progs
    cifs-utils
    exfat
    nfs-utils
    ntfs3g

    # Better X11 support in Niri
    xwayland-satellite

    # Noctalia shell
    inputs.noctalia.packages.${pkgs.stdenv.hostPlatform.system}.default

    # Niri uses XDG Portal from Gnome, which requires Nautilus to be installed
    # in order to have working file chooser dialogs.
    nautilus
  ];

  programs = {
    # Login, security, keyring, etc.
    gnupg.agent.enable = true;
    gnupg.agent.pinentryPackage = pkgs.pinentry-gnome3;
    seahorse.enable = true;
    ssh.enableAskPassword = true;

    # Nix index + comma for quick access to packages
    nix-index-database = {
      comma.enable = true;
    };

    # Graphical
    dconf.enable = true;

    regreet = {
      enable = true;
      font = {
        name = "Inter";
        size = 12;
        package = pkgs.inter;
      };
      settings = {
        skip_selection = true;
        background = {
          path = ../../../home/_roles/pc/wallpapers/wallhaven-618670.jpg;
          fit = "Cover";
        };
        GTK = {
          application_prefer_dark_theme = true;
        };
      };
    };

    niri = {
      enable = true;
    };

    # Shell
    zsh.enable = true; # Thumbnail support for images

    # NPM should be integrated with Nixos so global installs use a custom prefix.
    npm = {
      enable = true;
      npmrc = ''
        prefix = ''${HOME}/.local/share/npm
      '';
    };
  };

  services = {
    gnome.gnome-keyring.enable = true;
    gnome.gcr-ssh-agent.enable = true;

    greetd.enable = true;
    displayManager.sessionPackages = [ config.programs.niri.package ];

    # Note that kbfs is set up inside of home manager instead of here.
    keybase.enable = true;

    gvfs.enable = true; # Mount, trash, and other functionalities
    tumbler.enable = true; # Thumbnailing service
  };

  # May be required for greetd to work properly.
  systemd.user.services.niri.enableDefaultPath = false;

  # Include ZSH resources in final linked environment.
  environment.pathsToLink = [
    "/share/zsh"
  ];
}
