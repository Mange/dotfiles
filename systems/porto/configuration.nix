# 
#  ███████                    ██           
# ░██░░░░██                  ░██           
# ░██   ░██  ██████  ██████ ██████  ██████ 
# ░███████  ██░░░░██░░██░░█░░░██░  ██░░░░██
# ░██░░░░  ░██   ░██ ░██ ░   ░██  ░██   ░██
# ░██      ░██   ░██ ░██     ░██  ░██   ░██
# ░██      ░░██████ ░███     ░░██ ░░██████ 
# ░░        ░░░░░░  ░░░       ░░   ░░░░░░  
#
{ inputs, ... }: {
  imports = [
    # Hardware config
    inputs.hardware.nixosModules.lenovo-thinkpad-t14s
    ./hardware-configuration.nix

    ../_roles/laptop
    ../_topics/catppuccin.nix
    ../_topics/yubikey.nix
    ../_topics/annepro.nix
  ];

  networking.hostName = "porto";

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

  # Setup keyfile
  boot.initrd.secrets = {
    "/crypto_keyfile.bin" = null;
  };

  # Enable swap on luks
  boot.initrd.luks.devices."luks-f5daa918-0b21-4bbd-b1b9-b5f3fc2db563".device = "/dev/disk/by-uuid/f5daa918-0b21-4bbd-b1b9-b5f3fc2db563";
  boot.initrd.luks.devices."luks-f5daa918-0b21-4bbd-b1b9-b5f3fc2db563".keyFile = "/crypto_keyfile.bin";
}
