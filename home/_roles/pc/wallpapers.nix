{ pkgs, ... }: {
  xdg.dataFile."wallpapers" = {
    source = ./wallpapers;
    recursive = true;
  };

  home.packages = with pkgs; [
    swww
  ];
}
