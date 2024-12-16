{ pkgs, rootPath, ... }: {
  security.polkit.enable = true;
  security.sudo.enable = true;
  services.accounts-daemon.enable = true;

  users.users.mange = {
    uid = 1000;
    initialPassword = "mange";
    isNormalUser = true;
    description = "Magnus Bergmark";
    extraGroups = [
      "wheel"
      "video" # Control brightness
      "input" # Control LEDs
    ];
    shell = pkgs.zsh;
    openssh.authorizedKeys.keyFiles = [
      (rootPath + /data/ssh-keys/id_mange_2024.pub)
    ];
  };
}
