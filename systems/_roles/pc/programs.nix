{ pkgs, ... }:
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
    displayManager.gdm.enable = true;
    gnome.gnome-keyring.enable = true;
    gnome.gcr-ssh-agent.enable = true;

    # Note that kbfs is set up inside of home manager instead of here.
    keybase.enable = true;

    gvfs.enable = true; # Mount, trash, and other functionalities
    tumbler.enable = true; # Thumbnailing service
  };

  # GDM and Hyprlock should have access to passwords, etc.
  security.pam.services.gdm.enableGnomeKeyring = true;
  security.pam.services.hyprlock = { };

  # Include ZSH resources in final linked environment.
  environment.pathsToLink = [
    "/share/zsh"
  ];
}
