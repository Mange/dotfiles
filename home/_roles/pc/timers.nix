{ pkgs, ... }: let
removeOldScreenshots = pkgs.writeShellApplication {
  name = "remove-old-screenshots";
  runtimeInputs = with pkgs; [
    fd
    glib # for "gio trash"
  ];

  text = ''
    fd '(Screenshot|Skärmbild|Screenrecording).*\.(png|jpg)' \
      --max-depth 1 \
      --type file \
      --change-older-than "4days" \
      --exec-batch "gio" "trash" "{}" ";" \
      "$HOME/Media/Pictures"
  '';
};
in {
  systemd.user = {
    timers = {
      remove-old-screenshots = {
        Unit.Description = "Delete old screenshots";
        Timer = {
          WakeSystem = false;
          OnStartupSec = "30min";
          OnUnitInactiveSec = "6h";
        };
      };
    };

    services = {
      remove-old-screenshots = {
        Unit.Description = "Delete old screenshots";
        Service.Type = "oneshot";
        Service.ExecStart = "${removeOldScreenshots}/bin/remove-old-screenshots";
      };
    };
  };
}
