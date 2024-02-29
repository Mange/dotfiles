{ pkgs, ... }: {
  # No, thanks…
  # I trust my home network and this makes it a lot easier to access my stuff
  # through my Tailscale VPN.
  networking.firewall.enable = false;

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
