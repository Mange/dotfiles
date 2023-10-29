{ pkgs, ... }: {
  home.packages = with pkgs; [
    slack
    spotify
    telegram-desktop

    (discord.override {
      withOpenASAR = true;
      withVencord = true;
    })
  ];

  xdg.mimeApps.defaultApplications = {
    "x-scheme-handler/tg" = "org.telegram.desktop.desktop";
  };
}
