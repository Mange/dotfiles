{ inputs, pkgs, config, ... }: let
  utils = import ./utils.nix { inherit config pkgs; };
  dotfiles = utils.linkConfig "nvim";
in 
{
  xdg.configFile."nvim".source = dotfiles;

  programs.neovim = {
    enable = true;
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

      # Ruby
      rubocop
      rubyPackages.solargraph

      # Shell
      bash-completion
      nodePackages_latest.bash-language-server
      shellcheck
      shfmt

      # Javascript / Typescript / CSS / HTML / etc.
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
      nil # Nix
      fzf
      nodePackages_latest.dockerfile-language-server-nodejs
      nodePackages_latest.prettier
      nodePackages_latest.yaml-language-server
      prettierd
      rust-analyzer
    ];
  };
}
