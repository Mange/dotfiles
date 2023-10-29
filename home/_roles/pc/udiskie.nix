{ pkgs, ... }: {
  services.udiskie = {
    enable = true;
    automount = false;
    tray = "auto"; # Smart tray icon; only show when a device is connected
  };

  home.packages = with pkgs; [
    udiskie # to get access to CLI tools not enabled through services.udiskie
  ];
}
