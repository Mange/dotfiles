{ pkgs, ... }: {
  xdg.configFile."wezterm" = {
    source = ./wezterm;
    recursive = true;
  };

  home.packages = with pkgs; [
    # Wezterm configuration through home-manager is still too limited. Use
    # normal lua file and package.
    wezterm
  ];

  programs.rofi = {
    terminal = "wezterm";
    extraConfig = {
      ssh-command = "{terminal} start -- {ssh-client} {host} [-p {port}]";
      run-shell-command = "{terminal} start -- {cmd}";
    };
  };
}
