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
    ../_topics/yubikey.nix
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
  boot.initrd.luks.devices."luks-85296862-3c53-4f66-a680-d1e0590a220c".device = "/dev/disk/by-uuid/85296862-3c53-4f66-a680-d1e0590a220c";
  boot.initrd.luks.devices."luks-85296862-3c53-4f66-a680-d1e0590a220c".keyFile = "/crypto_keyfile.bin";
}
