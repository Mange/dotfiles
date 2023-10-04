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
    ../_topics/wacom.nix
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

  # AMD RX 7900 XT
  boot.kernelPackages = pkgs.linuxPackages_6_4; # Works better with newer kernels…
  hardware.amdgpu.opencl = true;
}
