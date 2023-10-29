{ pkgs, ... }: {
  programs.bacon = {
    enable = true;
    settings = {};
  };

  home.packages = with pkgs; [
    rustup
    cargo-update
    cargo-edit
    cargo-watch
  ];
}
