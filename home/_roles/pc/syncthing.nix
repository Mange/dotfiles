_: {
  services.syncthing = {
    enable = true;
    tray.enable = true;
    tray.command = "syncthingtray --wait"; # Add --wait
  };
}
