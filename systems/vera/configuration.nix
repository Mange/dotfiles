#
#  ██      ██                         
# ░██     ░██                         
# ░██     ░██  █████  ██████  ██████  
# ░░██    ██  ██░░░██░░██░░█ ░░░░░░██ 
#  ░░██  ██  ░███████ ░██ ░   ███████ 
#   ░░████   ░██░░░░  ░██    ██░░░░██ 
#    ░░██    ░░██████░███   ░░████████
#     ░░      ░░░░░░ ░░░     ░░░░░░░░ 
#
{ inputs, ... }: {
  imports = [
    # Hardware config
    inputs.hardware.nixosModules.system76-darp6
    ./hardware-configuration.nix

    ../_roles/laptop
  ];

  networking.hostName = "vera";

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

  hardware.system76.darp6.soundVendorId = "0x10ec0293";
  hardware.system76.darp6.soundSubsystemId = "0x15581404";

  # Setup keyfile
  boot.initrd.secrets = {
    "/crypto_keyfile.bin" = null;
  };

  # Enable swap on luks
  boot.initrd.luks.devices = {
    "luks-3acac906-7c1f-4e48-be8c-f575436d922d" = {
      device = "/dev/disk/by-uuid/3acac906-7c1f-4e48-be8c-f575436d922d";
      keyFile = "/crypto_keyfile.bin";
    };
  };
}
