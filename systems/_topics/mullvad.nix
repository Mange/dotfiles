{ pkgs, ... }: {
  services.mullvad-vpn.enable = true;

  environment.systemPackages = with pkgs; [
    mullvad
    mullvad-vpn
    mullvad-browser
  ];
}
