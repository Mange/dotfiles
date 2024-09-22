{ pkgs, ... }: {
  programs.firefox.enable = true;

  programs.jq = {
    enable = true;
  };

  home.packages = with pkgs; [
    # Extra browsers
    brave
    google-chrome

    # Others
    http-prompt
    httpie
    nodejs
    pastel
    pgcli
  ];

  xdg.configFile."pgcli/config".text = /*ini*/ ''
    [main]
    # Only execute query on Return when it ends with a semicolon
    multi_line = True

    # fo' life!
    vi = True 

    # Warn on things like "DROP TABLE".
    destructive_warning = True

    # Like \x auto in psql; transpose table when few rows.
    auto_expand = True

    # I'm weird LIKE that
    keyword_casing = upper
    generate_casing_file = False

    less_chatty = True
    null_string = ␀
    table_format = fancy_grid
    syntax_style = manni

    # More XDG-like; generated files should not go in ~/.config
    log_file = ~/.local/share/pgcli/log
    history_file = ~/.local/share/pgcli/history
    casing_file = ~/.local/share/pgcli/casing
  '';
}
