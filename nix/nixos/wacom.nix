{ pkgs, ... }: {
  environment.systemPackages = with pkgs; [
    libwacom
    krita
  ];
}
