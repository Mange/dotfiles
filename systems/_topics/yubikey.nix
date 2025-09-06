{ pkgs, ... }: {
  services.pcscd.enable = true;
  services.udev.packages = [ pkgs.yubikey-personalization ];

  hardware.gpgSmartcards.enable = true;

  environment.systemPackages = with pkgs; [
    yubikey-manager
    yubikey-personalization

    # Deprecated in favor of:
    # yubikey-manager-qt
    # Removed in favor of:
    # yubikey-personalization-gui
    yubioath-flutter
  ];
}
