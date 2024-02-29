{ ... }: let
  username = "mange";
in {
  networking.firewall.allowPing = true;

  # NetworkManager
  networking.networkmanager.enable = true;
  users.users.mange.extraGroups = ["networkmanager"];

  # Enable Tailscale
  services.tailscale = {
    enable = true;
    extraUpFlags = [
      "--operator=${username}"
      "--accept-routes=true"
    ];
  };

  # OpenSSH server
  services.openssh = {
    enable = true;
    settings = {
      # Forbid root login through SSH.
      PermitRootLogin = "no";
      # Use keys only. Remove if you want to SSH using password (not recommended)
      PasswordAuthentication = false;
    };
  };
  networking.firewall.allowedTCPPorts = [22];
}
