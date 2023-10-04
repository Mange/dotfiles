# Shared configuration for "personal computer", which includes things like
# workstations and laptops.
# "PC" here does not refer to a CPU architecture, but to the concept of having
# a personal computation device for personal use.
# A "server" role would be used for unpersonal headless machines, and "vm" for
# virtual machines.
{ inputs, ... }: {
  imports = [
    ../../_topics/nixconfig.nix
    inputs.hyprland.nixosModules.default

    ./catppuccin.nix
    ./keybase.nix
    ./networking.nix
    ./programs.nix
    ./sound.nix
    ./users.nix
  ];

  # Literally doxxing myself
  time.timeZone = "Europe/Stockholm";
  i18n.supportedLocales = [ "C.UTF-8/UTF-8" "en_US.UTF-8/UTF-8" "sv_SE.UTF-8/UTF-8" ];
  i18n.defaultLocale = "en_US.UTF-8";

  # Setup nice looking boot screen.
  boot.plymouth.enable = true;
  boot.kernelParams = ["quiet" "udev.log_level=3"];

  console = {
    font = "Lat2-Terminus16";
    keyMap = "us";
  };
}
