{ pkgs, ... }:
{
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

  users.users.mange.extraGroups = [
    "scanner"
    "lp"
  ];

  environment.systemPackages = with pkgs; [
    kdePackages.skanlite
  ];

  # Printers
  services.printing = {
    enable = true;
    drivers = with pkgs; [
      brlaser
      # Brother DCP-L3550CDW printer driver
      cups-brother-dcpl3550cdw
    ];
  };

  # Scanners
  hardware.sane = {
    enable = true;
    brscan5.enable = true; # Brother scanner driver
  };
}
