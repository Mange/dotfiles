{ pkgs, ... }: {
  # Broken right now https://github.com/NixOS/nixpkgs/issues/385996
  # services.mullvad-vpn.enable = true;

  environment.systemPackages = with pkgs; [
    # mullvad
    # mullvad-vpn
    mullvad-browser
  ];
}
