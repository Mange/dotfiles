{ pkgs, ... }: {
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

  # Login, security, keyring, etc.
  programs.gnupg.agent.enable = true;
  programs.gnupg.agent.pinentryPackage = pkgs.pinentry-gnome3;
  programs.seahorse.enable = true;
  programs.ssh.enableAskPassword = true;
  security.pam.services.gdm.enableGnomeKeyring = true;
  services.gnome.gnome-keyring.enable = true;
  # Note that kbfs is set up inside of home manager instead of here.
  services.keybase.enable = true;

  # Nix index + comma for quick access to packages
  programs.nix-index-database = {
    comma.enable = true;
  };

  # Graphical
  programs.dconf.enable = true;
  services.xserver.displayManager.gdm.enable = true;
  services.xserver.enable = true;
  programs.niri = { enable = true; };

  # Hyprlock should have access to passwords, etc.
  security.pam.services.hyprlock = {};

  # Shell
  programs.zsh.enable = true;
  environment.pathsToLink = [
    "/share/zsh"
  ];

  services.gvfs.enable = true; # Mount, trash, and other functionalities
  services.tumbler.enable = true; # Thumbnail support for images

  # NPM should be integrated with Nixos so global installs use a custom prefix.
  programs.npm = {
    enable = true;
    npmrc = ''
      prefix = ''${HOME}/.local/share/npm
    '';
  };
}
