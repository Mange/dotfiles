{ pkgs, ... }: {
  services.pcscd.enable = true;
  services.udev.packages = [ pkgs.yubikey-personalization ];

  hardware.gpgSmartcards.enable = true;

  environment.systemPackages = with pkgs; [
    yubikey-personalization
    yubikey-personalization-gui
    yubikey-manager
    yubikey-manager-qt
  ];
}
