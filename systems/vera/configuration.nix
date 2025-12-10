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
{ inputs, ... }:
{
  imports = [
    # Hardware config
    inputs.hardware.nixosModules.system76-darp6
    ./hardware-configuration.nix

    ../_roles/laptop
    ../_topics/yubikey.nix
  ];

  networking.hostName = "vera";

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

    # Setup keyfile
    initrd.secrets = {
      "/crypto_keyfile.bin" = null;
    };

    # Enable swap on luks
    initrd.luks.devices = {
      "luks-3acac906-7c1f-4e48-be8c-f575436d922d" = {
        device = "/dev/disk/by-uuid/3acac906-7c1f-4e48-be8c-f575436d922d";
        keyFile = "/crypto_keyfile.bin";
      };
    };
  };
  hardware.system76.darp6.soundVendorId = "0x10ec0293";
  hardware.system76.darp6.soundSubsystemId = "0x15581404";
}
