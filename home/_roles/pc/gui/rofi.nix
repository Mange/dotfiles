{ pkgs, config, ... }: let
  utils = import ../../../utils.nix { inherit config pkgs; };
  themeFile = utils.linkConfig "rofi/catpuccin.rasi";
  # inherit (config.lib.formats.rasi) mkLiteral;
in {
  xdg.configFile."rofi/catpuccin.rasi".source = themeFile;

  home.packages = with pkgs; [
    wtype
    wl-clipboard
  ];

  programs.rofi = {
    enable = true;
    plugins = [pkgs.rofi-emoji];
    theme = "catpuccin.rasi";
    font = "Overpass Light 10";
    terminal = "wezterm";

    extraConfig = {
      ssh-command = "{terminal} start -- {ssh-client} {host} [-p {port}]";
      run-shell-command = "{terminal} start -- {cmd}";
      dpi = 1;
      drun-display-format = "{name}";
      threads = 0;
      disable-history = false;
      scroll-method = 0;
      matching = "normal";
      sort = true;
      # Must not be set to "fzf" or else sorting will be ruined.
      # sorting-method = "fzf";
      sorting-method = "normal";
    
      display-window = "Goto";
      display-run = "Run";
      display-drun = "DRun";
      display-ssh = "SSH";
      display-combi = "Rofi";
      display-emoji = "Emoji";
    
      kb-clear-line = "Control+l";
      kb-mode-complete = "";
    
      kb-remove-word-back = "Control+w";
    
      kb-element-next = "";
      kb-mode-next = "Tab";
      kb-element-prev = "";
      kb-mode-previous = "Shift+Tab,ISO_Left_Tab";
    
      kb-row-up = "Up";
      kb-row-tab = "";
    
      show-icons = true;
      icon-theme = "Papirus-Dark";
      fullscreen = false;
      window-thumbnail = true;
    };
  };
}
