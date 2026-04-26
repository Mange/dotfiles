{ pkgs, ... }:
{
  programs.steam = {
    enable = true;
    protontricks.enable = true;

    remotePlay.openFirewall = true;
    localNetworkGameTransfers.openFirewall = true;
  };

  programs.gamescope.enable = true;

  # Good for my Steam Controller, and maybe also for my Steam VR. Who knows…?
  hardware.steam-hardware.enable = true;

  environment.systemPackages = with pkgs; [
    wine
    wineWow64Packages.stable
    winetricks
    # Needs openldap??? Anyway, that fails to compile.
    # lutris

    prismlauncher
  ];
}
