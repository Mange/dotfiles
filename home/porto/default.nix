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
{ pkgs, ... }: {
  imports = [
    ../_roles/base.nix
    ../_roles/laptop

    ../_topics/bluetooth.nix
  ];

  home.packages = with pkgs; [
    insomnia

    kubectl
    google-cloud-sdk
    terraform
    tailscale
    mongodb-compass
  ];

  xdg.configFile."hypr/screens.conf".source = ./hyprland/screens.conf;
}
