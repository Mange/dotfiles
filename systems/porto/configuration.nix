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
    ../_topics/capslock-mapping
  ];

  networking.hostName = "porto";

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  system.stateVersion = "23.11";

  #
  # ▖▖     ▌
  # ▙▌▀▌▛▘▛▌▌▌▌▀▌▛▘█▌
  # ▌▌█▌▌ ▙▌▚▚▘█▌▌ ▙▖
  #

  boot = {
    # Use the systemd-boot EFI boot loader.
    loader.systemd-boot.enable = true;
    loader.efi.canTouchEfiVariables = true;

    initrd = {
      # Setup keyfile
      secrets = {
        "/crypto_keyfile.bin" = null;
      };

      # Enable swap on luks
      luks.devices."luks-f5daa918-0b21-4bbd-b1b9-b5f3fc2db563".device = "/dev/disk/by-uuid/f5daa918-0b21-4bbd-b1b9-b5f3fc2db563";
      luks.devices."luks-f5daa918-0b21-4bbd-b1b9-b5f3fc2db563".keyFile = "/crypto_keyfile.bin";
    };
  };
}
