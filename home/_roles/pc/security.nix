# Keyring, SSH, GPG stuff
{ config, pkgs, lib, rootPath, ... }: let
  sshPubKeys = lib.filesystem.listFilesRecursive (rootPath + /data/ssh-keys);
  sshKeyFiles = lib.lists.map (file: {
    ".ssh/${builtins.baseNameOf file}" = { source = file; };
  }) sshPubKeys;
in {
  # Install SSH public keys
  home.file = (lib.attrsets.mergeAttrsList sshKeyFiles);

  # Keyring and gpg agent
  services.gnome-keyring.enable = true;
  home.sessionVariables.SSH_AUTH_SOCK = "$XDG_RUNTIME_DIR/keyring/ssh"; # gnome-keyring
  services.gpg-agent = {
    enable = true;
    pinentryPackage = pkgs.pinentry-gnome3;
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
    polkit_gnome
    libsecret

    nixos-stable.monero
    nixos-stable.monero-gui
  ];

  systemd.user.services.polkit-gnome-authentication-agent-1 = {
    Unit = {
      Description = "polkit-gnome-authentication-agent-1";
      Wants = [ "graphical-session.target" ];
      After = [ "graphical-session.target" ];
    };

    Service = {
      Type = "simple";
      ExecStart = "${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1";
      Restart = "on-failure";
      RestartSec = 1;
      TimeoutStopSec = 10;
    };

    Install = {
      WantedBy = [ "graphical-session.target" ];
    };
  };
}
