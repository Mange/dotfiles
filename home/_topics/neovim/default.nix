{ inputs, pkgs, config, ... }: let
  utils = import ../../utils.nix { inherit config pkgs; };
  dotfiles = utils.linkConfig "nvim";
in 
{
  nixpkgs.overlays = [
    inputs.neovim-nightly-overlay.overlay
  ];

  xdg.configFile."nvim".source = dotfiles;

  home.sessionVariables = {
    VISUAL = "nvim";
    MANPAGER = "nvim +Man!"; # Neovim makes a better manpager than less.
  };

  programs.neovim = {
    enable = true;
    package = pkgs.neovim-nightly;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;
    vimdiffAlias = true;
    withNodeJs = true;

    extraPackages = with pkgs; [
      # Treesitter
      curl
      gcc
      clang

      # telescope-fzf-native
      fzf
      gnumake

      # Ruby should be installed manually inside of the Ruby version used for
      # projects.

      # Shell
      bash-completion
      nodePackages_latest.bash-language-server
      shellcheck
      shfmt

      # Javascript / Typescript / CSS / HTML / etc.
      typescript # includes tsserver
      nodePackages_latest.graphql-language-service-cli
      nodePackages_latest.svelte-language-server
      nodePackages_latest.typescript-language-server
      nodePackages_latest."@tailwindcss/language-server"
      vscode-langservers-extracted

      # Lua
      lua-language-server
      stylua

      # C
      bear # tool to generate compilation database for clang tooling
      ccls # C

      # Others
      marksman # Markdown
      nil # Nix
      nodePackages_latest.dockerfile-language-server-nodejs
      nodePackages_latest.prettier
      nodePackages_latest.yaml-language-server
      rust-analyzer
      terraform-ls
    ];
  };
}
