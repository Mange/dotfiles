{ pkgs, ... }: {
  home.packages = with pkgs; [
    jellyfin-media-player
    krita
    mpv

    mediainfo
    youtube-dl

    playerctl # MPRIS control
    pulsemixer # TUI volume mixer
  ];

  xdg.mimeApps.defaultApplications = {
    "video/mp4" = "mpv.desktop";
    "video/quicktime" = "mpv.desktop";
    "video/x-matroska" = "mpv.desktop";
    "audio/mpeg" = "mpv.desktop";
    "audio/ogg" = "mpv.desktop";
  };
}
