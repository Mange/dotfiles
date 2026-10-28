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
{ pkgs, ... }:
{
  imports = [
    ../_roles/base.nix
    ../_roles/workstation
    ../_topics/bluetooth.nix

    ../_topics/crypto.nix
    ../_topics/gamedev.nix
    ../_topics/vm-host.nix

    ../_topics/work/toggl-track.nix

    ../_topics/clanker
  ];

  home.packages = with pkgs; [
    duplicity
    thunderbird

    # Sonos control
    noson
  ];
}
