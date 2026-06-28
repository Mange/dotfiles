{ pkgs, ... }: {
  services.hardware.openrgb.enable = true;

  environment.systemPackages = with pkgs; [
    openrgb
  ];
}
