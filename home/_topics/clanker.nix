# Let's see what the big deal is…
{ pkgs, ... }:
{
  home.packages = with pkgs; [
    claude-code
  ];
}
