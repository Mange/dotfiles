{ pkgs, ... }: {
  home.packages = with pkgs; [
    # Connecting to work VPN
    tailscale

    # HTTP stuff for microservices
    bruno

    # Cloud, k8s, etc.
    terraform
    kubectl
    sops
    (google-cloud-sdk.withExtraComponents ([
      google-cloud-sdk.components.gke-gcloud-auth-plugin
    ]))
    google-cloud-sql-proxy

    # Old cloud env
    awscli2

    # Common DB and misc tooling
    gnumake
    mongodb-compass
    postgresql
    mariadb
    mycli
  ];

  home.file.".myclirc".text =  /*ini*/ ''
    [main]
    # Only execute query on Return when it ends with a semicolon
    multi_line = True

    # fo' life!
    key_bindings = vi

    # Warn on things like "DROP TABLE".
    destructive_warning = True

    # Like \x auto in psql; transpose table when few rows.
    auto_expand = True

    # I'm weird LIKE that
    keyword_casing = upper

    less_chatty = True
    table_format = fancy_grid
    syntax_style = manni

    enable_pager = True
    wider_completion_menu = True
    auto_vertical_output = True

    # More XDG-like; generated files should not go in ~/.config
    log_file = ~/.local/share/mycli/log
    history_file = ~/.local/share/mycli/history
    casing_file = ~/.local/share/mycli/casing
  '';
}
