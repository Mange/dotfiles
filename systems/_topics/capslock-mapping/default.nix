{ pkgs, ... }: let
  intercept = "${pkgs.interception-tools}/bin/intercept";
  uinput = "${pkgs.interception-tools}/bin/uinput";
  dfk = pkgs.interception-tools-plugins.dual-function-keys;
  dfkConfig = ./dfk-config.yaml;
in {
  services.interception-tools = {
    enable = true;
    plugins = [dfk];
    udevmonConfig = /* yaml */ ''
      - JOB: "${intercept} -g $DEVNODE | ${dfk}/bin/dual-function-keys -c ${dfkConfig} | ${uinput} -d $DEVNODE"
        DEVICE:
          NAME: "AT Translated Set 2 keyboard" # Porto built-in-keyboard
    '';
  };
}
