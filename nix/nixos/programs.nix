{ pkgs, ... }: {
  # Login, security, keyring, etc.
  services.xserver.enable = true;
  services.xserver.displayManager.gdm.enable = true;
  services.gnome.gnome-keyring.enable = true;
  programs.seahorse.enable = true;
  programs.ssh.enableAskPassword = true;

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

  # Swaylock should have access to passwords, etc.
  security.pam.services.swaylock = {
    text = ''
      auth include login
    '';
  };

  # Docker
  virtualisation.docker.enable = true;
}
