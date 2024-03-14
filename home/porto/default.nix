# 
#  ███████                    ██           
# ░██░░░░██                  ░██           
# ░██   ░██  ██████  ██████ ██████  ██████ 
# ░███████  ██░░░░██░░██░░█░░░██░  ██░░░░██
# ░██░░░░  ░██   ░██ ░██ ░   ░██  ░██   ░██
# ░██      ░██   ░██ ░██     ░██  ░██   ░██
# ░██      ░░██████ ░███     ░░██ ░░██████ 
# ░░        ░░░░░░  ░░░       ░░   ░░░░░░  
#
{ ... }: {
  imports = [
    ../_roles/base.nix
    ../_roles/laptop
    ../_topics/bluetooth.nix

    ../_topics/work/instabee.nix
  ];

  xdg.configFile."hypr/screens.conf".source = ./hyprland/screens.conf;
}
