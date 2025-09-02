_: {
  # PDF and comics
  programs.zathura.enable = true;

  xdg.mimeApps.defaultApplications = {
    "application/pdf" = "org.pwmt.zathura.desktop";
    "application/vnd.comicbook+zip" = "org.pwmt.zathura-djvu.desktop";
  };
}
