{ pkgs, ... }: {
  programs.firefox = {
    enable = true;
  };

  home.packages = with pkgs; [
    # Extra web browser(s)
    brave

    # File management
    file-roller
    gnome-font-viewer
    nemo-with-extensions

    # Remote desktop and hardware management
    gnome-disk-utility

    # Photography
    shotwell

    # Note taking
    obsidian

    # How else can I get new Linux ISOs?
    transmission-remote-gtk

    # Mobile integration
    scrcpy
    android-file-transfer

    # Misc
    xdg-utils
    zenity
    gnuplot
    libqalculate
  ];

  xdg.mimeApps.defaultApplications = {
    # Nemo as my default GUI file manager
    "inode/directory" = "nemo.desktop";

    # Firefox as my default browser
    "text/html" = "firefox.desktop";
    "x-scheme-handler/http" = "firefox.desktop";
    "x-scheme-handler/https" = "firefox.desktop";
    "x-scheme-handler/mailto" = "firefox.desktop";
    "x-scheme-handler/webcal" = "firefox.desktop";
    "x-scheme-handler/unknown" = "firefox.desktop";

    # Use file-roller for archives
    "application/x-7z-compressed" = "org.gnome.FileRoller.desktop";
    "application/x-bzip-compressed-tar" = "org.gnome.FileRoller.desktop";
    "application/x-compressed-tar" = "org.gnome.FileRoller.desktop";
    "application/x-gzip-compressed-tar" = "org.gnome.FileRoller.desktop";
    "application/x-rar-compressed" = "org.gnome.FileRoller.desktop";
    "application/x-tar" = "org.gnome.FileRoller.desktop";
    "application/x-xz-compressed-tar" = "org.gnome.FileRoller.desktop";
    "application/zip" = "org.gnome.FileRoller.desktop";
  };
}
