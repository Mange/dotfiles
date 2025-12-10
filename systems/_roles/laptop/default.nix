{ pkgs, ... }:
{
  imports = [
    ../pc

    ../../_topics/bluetooth.nix
  ];

  environment.systemPackages = with pkgs; [
    powertop
    brightnessctl
  ];

  services.power-profiles-daemon.enable = true;
  services.upower.enable = true;
}
