{ pkgs, config, lib, ... }: let
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

    # Neovide also needs access to all the binaries and libraries that Neovim
    # needs to access. All extraPackages have been moved down to the
    # `home.package` list.
    # extraPackages = [];
  };

  programs.neovide = {
    enable = true;
    # Must be specified, or else Nix build fails.
    settings = {
      font = {
        # In order for the settings to be valid, both `size` and `normal`
        # parameters must be set. Font is configured in `fonts.nix`, so just
        # place a default placeholder here to ensure the settings are valid.
        size = 12.0;
        normal = lib.mkDefault [];
      };
    };
  };

  home.packages = with pkgs; [
    # Treesitter downloads and installation.
    curl
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
    # nodePackages_latest.graphql-language-service-cli
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

    # Java & Kotlin
    # (Neovide needs to be able to access them too, so
    # add to PATH outside of pure neovim)
    jdt-language-server # eclipse.jdt.ls
    kotlin-language-server

    # Rust
    # rust-analyzer replaced by rustup
    rustup
    cargo-nextest

    # Others
    marksman # Markdown
    nil # Nix
    nodePackages_latest.dockerfile-language-server-nodejs
    nodePackages_latest.prettier
    nodePackages_latest.yaml-language-server
    terraform-ls
  ];
}
