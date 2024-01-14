{ pkgs, ... }: {
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
    openssh.authorizedKeys.keys = [
      # TODO: Add your SSH public key(s) here, if you plan on using SSH to connect
    ];
  };

}
