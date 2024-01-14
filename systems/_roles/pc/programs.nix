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
  ];

  # Login, security, keyring, etc.
  programs.gnupg.agent.enable = true;
  programs.gnupg.agent.pinentryFlavor = "gnome3";
  programs.seahorse.enable = true;
  programs.ssh.enableAskPassword = true;
  security.pam.services.gdm.enableGnomeKeyring = true;
  services.gnome.gnome-keyring.enable = true;
  services.pcscd.enable = true;
  # Note that kbfs is set up inside of home manager instead of here.
  services.keybase.enable = true;

  # Graphical
  programs.dconf.enable = true;
  services.xserver.displayManager.gdm.enable = true;
  services.xserver.enable = true;
  programs.hyprland.enable = true;

  # Swaylock should have access to passwords, etc.
  security.pam.services.swaylock = {
    text = /*pamconf*/ ''
      auth include login
    '';
  };

  # Shell
  programs.zsh.enable = true;
  environment.pathsToLink = [
    "/share/zsh"
  ];

  # Thunar must be enabled on the system instead of in home manager. I don't
  # know why, but it might relate to a bunch of services that are needed.
  programs.thunar = {
    enable = true;
    plugins = with pkgs.xfce; [
      thunar-archive-plugin
    ];
  };
  services.gvfs.enable = true; # Mount, trash, and other functionalities
  services.tumbler.enable = true; # Thumbnail support for images

  # Docker
  virtualisation.docker.enable = true;
  users.users.mange.extraGroups = ["docker"];
}
