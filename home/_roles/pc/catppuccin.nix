{ pkgs, ... }: {
  programs.tmux.plugins = [ pkgs.tmuxPlugins.catppuccin ];
}
