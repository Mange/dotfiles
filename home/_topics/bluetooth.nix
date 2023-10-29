{ pkgs, ... }: {
  home.packages = with pkgs; [
    bluez
    bluez-tools
    blueman
  ];
}
