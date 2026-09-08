{ pkgs, ... }:
let
  theme-pkg = pkgs.phinger-cursors;
  theme-name = "phinger-cursors-dark";
in
{
  # Note: Although this sets up the cursor theme for the system and a global
  # fallback, actually using this theme requires setting it up in the home
  # manager configuration as well.
  environment.systemPackages = [ theme-pkg ];

  programs.regreet.cursorTheme = {
    name = theme-name;
    package = theme-pkg;
  };

  xdg.icons.fallbackCursorThemes = [ theme-name ];
}
