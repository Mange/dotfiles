#
#   ████████                  ██          
#  ██░░░░░░                  ░░           
# ░██         ██████   █████  ██  ██████  
# ░█████████ ██░░░░██ ██░░░██░██ ░░░░░░██ 
# ░░░░░░░░██░██   ░██░██  ░░ ░██  ███████ 
#        ░██░██   ░██░██   ██░██ ██░░░░██ 
#  ████████ ░░██████ ░░█████ ░██░░████████
# ░░░░░░░░   ░░░░░░   ░░░░░  ░░  ░░░░░░░░
#
{ inputs, pkgs, ... }: {
  imports = [
    # Hardware config
    inputs.hardware.nixosModules.common-pc
    inputs.hardware.nixosModules.common-pc-ssd
    inputs.hardware.nixosModules.common-cpu-amd
    inputs.hardware.nixosModules.common-cpu-amd-pstate
    inputs.hardware.nixosModules.common-gpu-amd
    ./hardware-configuration.nix

    ../_roles/workstation
    ../_topics/amd_rx_7900_xt.nix
    ../_topics/catppuccin.nix
    ../_topics/gaming.nix
    ../_topics/home-network.nix
    ../_topics/lg_headset.nix
    ../_topics/mullvad.nix
    ../_topics/ollama.nix
    ../_topics/vm-host.nix
    ../_topics/wacom.nix
    ../_topics/yubikey.nix

    ./mounts.nix
  ];

  networking.hostName = "socia";

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  system.stateVersion = "23.11";

  #
  # ▖▖     ▌
  # ▙▌▀▌▛▘▛▌▌▌▌▀▌▛▘█▌
  # ▌▌█▌▌ ▙▌▚▚▘█▌▌ ▙▖
  #

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # More recent kernel than the default. Helps with drivers and similar.
  boot.kernelPackages = pkgs.linuxPackages_6_13;
}
