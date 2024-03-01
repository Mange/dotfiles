{ pkgs, ... }: let
  # From: https://github.com/obinslab/obinslab-starter-translations/issues/9
  # But group changed from "plugdev" to "input" to match NixOS.
  udev-rules = pkgs.writeTextFile {
    name = "obinslab-starter.rules";
    text = ''
      SUBSYSTEM=="input", GROUP="input", MODE="0666"

      # For ANNE PRO 2
      SUBSYSTEM=="usb", ATTRS{idVendor}=="04d9", ATTRS{idProduct}=="8008", MODE="0666", GROUP="input"
      KERNEL=="hidraw*", ATTRS{idVendor}=="04d9", ATTRS{idProduct}=="8008", MODE="0666", GROUP="input"
      SUBSYSTEM=="usb", ATTRS{idVendor}=="04d9", ATTRS{idProduct}=="8009", MODE="0666", GROUP="input"
      KERNEL=="hidraw*", ATTRS{idVendor}=="04d9", ATTRS{idProduct}=="8009", MODE="0666", GROUP="input"

      ## For ANNE PRO
      SUBSYSTEM=="usb", ATTRS{idVendor}=="0483", ATTRS{idProduct}=="5710", MODE="0666", GROUP="input"
      KERNEL=="hidraw*", ATTRS{idVendor}=="0483", ATTRS{idProduct}=="5710", MODE="0666", GROUP="input"
    '';
    destination = "/etc/udev/rules.d/obinslab-starter.rules";
  };
in {
  services.udev.packages = [ udev-rules ];
  environment.systemPackages = [ pkgs.obinskit ];

  nixpkgs.config.permittedInsecurePackages = [
    "electron-13.6.9"
  ];
}
