{ pkgs, ... }:
{
  home.packages = with pkgs; [
    godot
    gdscript-formatter
    aseprite
  ];
}
