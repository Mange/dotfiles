{ config, pkgs, ... }: let
  username = "mange";
in {
  # No, thanks…
  # I build too many apps and stuff that I want to expose on the network. I
  # always put my machines behind NATs and trust the local networks.
  # Perhaps this will change in the future when I have a laptop, but only when
  # more of my config is over inside Nix.
  networking.firewall.enable = false;

  # NetworkManager
  networking.networkmanager.enable = true;
  users.users.mange.extraGroups = ["networkmanager"];

  # Enable Tailscale
  services.tailscale = {
    enable = true;
    extraUpFlags = "--operator=${username}";
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

  # Avahi
  services.avahi = {
    enable = true;
    nssmdns4 = true;
    openFirewall = true;
  };

  # Home network devices
  services.printing = {
    enable = true;
    drivers = [ pkgs.brlaser ];
  };
}
