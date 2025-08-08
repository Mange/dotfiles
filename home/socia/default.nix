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

    ../_topics/vm-host.nix
    ../_topics/crypto.nix
    ../_topics/work/instabee.nix
  ];

  home.packages = with pkgs; [
    duplicity
    thunderbird

    # Sonos control
    noson
  ];
}
