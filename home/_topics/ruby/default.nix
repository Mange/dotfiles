{ pkgs, ... }: {
  xdg.configFile."rspec/options".text = ''
    --color
    --format documentation
  '';

  #
  # To allow gem mimemagic to be installed.
  # https://github.com/mimemagicrb/mimemagic/issues/160
  # https://github.com/mimemagicrb/mimemagic/pull/163
  #

  home.packages = [ pkgs.shared-mime-info ];
  systemd.user.sessionVariables = {
    FREEDESKTOP_MIME_TYPES_PATH = "${pkgs.shared-mime-info}/share/mime/packages/freedesktop.org.xml";
  };
}
