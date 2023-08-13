{ pkgs, ... }: {
  programs.adb.enable = true;
  users.users.mange.extraGroups = ["adbusers"];

  environment.systemPackages = with pkgs; [
    scrcpy
  ];
}
