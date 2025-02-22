{ pkgs, ... }: {
  home.packages = with pkgs; [
    monero-cli
    monero-gui
    feather
  ];
}

