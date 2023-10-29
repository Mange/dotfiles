{ pkgs, ... }: {
  xdg.configFile."wezterm" = {
    source = ./wezterm;
    recursive = true;
  };

  home.packages = with pkgs; [
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
