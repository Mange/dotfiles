{ pkgs, ... }: {
  # headsetcontrol requires udev rules to work without root.
  environment.systemPackages = [ pkgs.headsetcontrol ];
  services.udev.packages = [ pkgs.headsetcontrol ];
}
