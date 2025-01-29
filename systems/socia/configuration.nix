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
    ../_topics/ollama.nix
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
  boot.kernelPackages = pkgs.linuxPackages_6_11;
  hardware.amdgpu.opencl.enable = true;

  # Seems to be breaking too much…
  # nixpkgs.config.rocmSupport = true;
  # Waiting for https://nixpk.gs/pr-tracker.html?pr=377629
  # services.ollama.acceleration = "rocm";
  # nix-shell -p "rocmPackages.rocminfo" --run "rocminfo" | grep "gfx"
  # services.ollama.rocmOverrideGfx = "11.0.0"; # i.e. `gfx1100`.
  services.ollama.package = pkgs.ollama-rocm;
}
