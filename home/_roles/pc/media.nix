{ pkgs, ... }: {
  programs.mpv = {
    enable = true;
  };

  home.packages = with pkgs; [
    jellyfin-media-player
    krita

    mediainfo
    youtube-dl

    playerctl # MPRIS control
    pulsemixer # TUI volume mixer
    pavucontrol # Volume control

    imagemagick # for image previews, etc.
    ghostscript # imagemagick optional dependency for PDF support
  ];

  xdg.mimeApps.defaultApplications = {
    "video/mp4" = "mpv.desktop";
    "video/quicktime" = "mpv.desktop";
    "video/x-matroska" = "mpv.desktop";
    "audio/mpeg" = "mpv.desktop";
    "audio/ogg" = "mpv.desktop";
  };
}
