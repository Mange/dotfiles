# Keyring, SSH, GPG stuff
{ config, pkgs, lib, rootPath, inputs, ... }: let
  home = config.home.homeDirectory;
  sshPubKeys = lib.filesystem.listFilesRecursive (rootPath + /data/ssh-keys);
  sshKeyNames = lib.lists.map (file: lib.removeSuffix ".pub" (builtins.baseNameOf file)) sshPubKeys;
in {
  imports = [ inputs.sops-nix.homeManagerModules.sops ];

  # Setup sops
  sops = {
    defaultSopsFile = rootPath + /secrets/secrets.yaml;
    defaultSopsFormat = "yaml";
    age.keyFile = "/home/mange/.config/sops/age/keys.txt";
    secrets = lib.attrsets.mergeAttrsList (
      lib.lists.map (basename: {
        "ssh/private_keys/${basename}" = {
          path = "${home}/.ssh/${basename}";
        };
      }) sshKeyNames);
  };

  home = {
    # Install SSH public and private keys
    file = lib.attrsets.mergeAttrsList (
      lib.lists.map (file: {
      ".ssh/${builtins.baseNameOf file}" = { source = file; };
      }) sshPubKeys);
    sessionVariables.SSH_AUTH_SOCK = "$XDG_RUNTIME_DIR/keyring/ssh";

    packages = with pkgs; [
      keybase-gui
      polkit_gnome
      # libsecret
    ];
  };

  services = {
    # Keyring and gpg agent
    gnome-keyring.enable = true;
    gpg-agent = {
      enable = true;
      pinentry.package = pkgs.pinentry-gnome3;
    };

    # Keybase
    keybase.enable = true;
    kbfs = {
      enable = true;
      mountPoint = "Keybase";
    };
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
