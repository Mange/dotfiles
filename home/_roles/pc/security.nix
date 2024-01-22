# Keyring, SSH, GPG stuff
{ config, pkgs, lib, ... }: {
  # Keyring and gpg agent
  services.gnome-keyring.enable = true;
  home.sessionVariables.SSH_AUTH_SOCK = "$XDG_RUNTIME_DIR/keyring/ssh"; # gnome-keyring
  services.gpg-agent = {
    enable = true;
    pinentryFlavor = "gnome3";
  };
  programs.gpg = {
    enable = true;
    homedir = "${config.xdg.dataHome}/gnupg";
    settings = {
      keyserver = "hkp://keys.gnupg.net";
      use-agent = true;
      keyserver-options = "auto-key-retrieve";
      default-key = "DB2D6BB84D8E0309";
    };
  };

  # Keybase
  services.keybase.enable = true;
  services.kbfs = {
    enable = true;
    mountPoint = "Keybase";
  };

  # https://github.com/nix-community/home-manager/issues/4722
  systemd.user.services.kbfs.Service.PrivateTmp = lib.mkForce false;

  home.packages = with pkgs; [
    keybase-gui
    monero
    monero-gui
  ];
}
