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
    ../_topics/catppuccin.nix
    ../_topics/home-network.nix
    ../_topics/mullvad.nix
    ../_topics/vm-host.nix
    ../_topics/wacom.nix
    ../_topics/yubikey.nix

    ./mounts.nix
  ];

  networking.hostName = "socia";

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  system.stateVersion = "23.11";

  # headsetcontrol requires udev rules to work without root.
  environment.systemPackages = [ pkgs.headsetcontrol ];
  services.udev.packages = [ pkgs.headsetcontrol ];

  #
  # ▖▖     ▌
  # ▙▌▀▌▛▘▛▌▌▌▌▀▌▛▘█▌
  # ▌▌█▌▌ ▙▌▚▚▘█▌▌ ▙▖
  #

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # AMD RX 7900 XT
  boot.kernelPackages = pkgs.linuxPackages_6_6;
  # Enable again after
  # https://github.com/NixOS/nixpkgs/issues/325907
  # https://nixpk.gs/pr-tracker.html?pr=325909
  # hardware.amdgpu.opencl.enable = true;
}
