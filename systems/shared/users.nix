{ pkgs, ... }: {
  users.users.mange = {
    initialPassword = "mange";
    isNormalUser = true;
    description = "Magnus Bergmark";
    extraGroups = [
      "wheel"
      "docker"
      "video" # Control brightness
      "input" # Control LEDs
      "networkmanager"
    ];
    shell = pkgs.zsh;
    openssh.authorizedKeys.keys = [
      # TODO: Add your SSH public key(s) here, if you plan on using SSH to connect
    ];
  };

}
