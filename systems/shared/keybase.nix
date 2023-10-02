# Setup keybase
# Note that kbfs is set up inside of home manager instead of here.
{ pkgs, ... }: {
  services.keybase.enable = true;

  environment.systemPackages = with pkgs; [
    keybase
    keybase-gui
  ];
}
