{ pkgs, ... }: {
  imports = [
    ../pc

    ../../_topics/bluetooth.nix
  ];

  environment.systemPackages = with pkgs; [
    powertop
    brightnessctl
  ];
}
