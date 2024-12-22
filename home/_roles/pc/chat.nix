{ pkgs, ... }: {
  home.packages = with pkgs; [
    slack
    spotify
    telegram-desktop
    discord-canary
  ];

  xdg.mimeApps.defaultApplications = {
    "x-scheme-handler/tg" = "org.telegram.desktop.desktop";
  };
}
