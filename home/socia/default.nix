#
#   ████████                  ██          
#  ██░░░░░░                  ░░           
# ░██         ██████   █████  ██  ██████  
# ░█████████ ██░░░░██ ██░░░██░██ ░░░░░░██ 
# ░░░░░░░░██░██   ░██░██  ░░ ░██  ███████ 
#        ░██░██   ░██░██   ██░██ ██░░░░██ 
#  ████████ ░░██████ ░░█████ ░██░░████████
# ░░░░░░░░   ░░░░░░   ░░░░░  ░░  ░░░░░░░░
#
{ pkgs, ... }: {
  imports = [
    ../_roles/base.nix
    ../_roles/workstation
    ../_topics/bluetooth.nix

    ../_topics/android-dev.nix
    ../_topics/vm-host.nix
    ../_topics/gaming
    ../_topics/work/instabee.nix
  ];

  home.packages = [
    pkgs.duplicity
    pkgs.thunderbird
  ];

  xdg.configFile."hypr/screens.conf".source = ./hyprland/screens.conf;
}
