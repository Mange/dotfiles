{ pkgs, config, ... }: let
  utils = import ../../utils.nix { inherit config pkgs; };
  dotfiles = utils.linkConfig "nvim";
in 
{
  xdg.configFile."nvim".source = dotfiles;

  home.sessionVariables = {
    VISUAL = "nvim";
    MANPAGER = "nvim +Man!"; # Neovim makes a better manpager than less.

    # Lombok support in JDTLS (Java LSP)
    JDTLS_JVM_ARGS = "-javaagent:${pkgs.lombok}/share/java/lombok.jar";
  };

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

      # telescope-fzf-native
      fzf
      gnumake

      # LuaSnip
      luajitPackages.luasnip

      # "libuv-watchdirs has known performance issues. Consider installing fswatch."
      fswatch

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

      # Java & Kotlin set up in home.packages

      # Rust
      rust-analyzer
      cargo-nextest # Won't be found; also installed globally.

      # Others
      marksman # Markdown
      nil # Nix
      nodePackages_latest.dockerfile-language-server-nodejs
      nodePackages_latest.prettier
      nodePackages_latest.yaml-language-server
      terraform-ls
    ];
  };

  home.packages = with pkgs; [
    cargo-nextest
    neovide

    # Java & Kotlin
    # (Neovide needs to be able to access them too, so
    # add to PATH outside of pure neovim)
    jdt-language-server # eclipse.jdt.ls
    kotlin-language-server
  ];
}
