{ config, ... }: let
  # Although this option enables the XDG_* variables both
  # in home.sessionVariables and in
  # systemd.user.sessionVariables, they will be added last
  # in the variables list (as it will be sorted).
  # Since other entries in this list are supposed to link
  # to these directories, we must also have our own copy
  # of the values and duplicate it instead of referencing
  # the XDG_* variables directly.
  XDG_CACHE_HOME = config.xdg.cacheHome;
  XDG_CONFIG_HOME = config.xdg.configHome;
  XDG_DATA_HOME = config.xdg.dataHome;
  XDG_STATE_HOME = config.xdg.stateHome;

  variables = {
    inherit XDG_CACHE_HOME;
    inherit XDG_CONFIG_HOME;
    inherit XDG_DATA_HOME;
    inherit XDG_STATE_HOME;

    #
    # XDG base directory exports for special snowflakes
    #

    # Rust
    CARGO_HOME="${XDG_DATA_HOME}/cargo";
    RUSTUP_HOME="${XDG_DATA_HOME}/rustup";

    # npm (…are assholes)
    # https://github.com/npm/npm/issues/6675
    NPM_CONFIG_USERCONFIG="${XDG_CONFIG_HOME}/npm/config";

    # Other Node stuff
    NVM_DIR="${XDG_DATA_HOME}/nvm";

    # Postgres
    PSQLRC="${XDG_CONFIG_HOME}/postgresql/psqlrc";

    # GNUGP / GPG
    # TODO: Move into GPG configuration in Nix instead?
    GNUPGHOME="${XDG_DATA_HOME}/gnupg";

    # Go >:(
    GOPATH="${XDG_DATA_HOME}/go";

    # Docker, Kubernetes, etc.
    DOCKER_CONFIG="${XDG_CONFIG_HOME}/docker";
    KUBECONFIG="${XDG_CONFIG_HOME}/kube/config";

    # Awscli
    # See https://github.com/aws/aws-sdk/issues/30
    AWS_CONFIG_FILE="${XDG_CONFIG_HOME}/aws/config";
    AWS_CLI_HISTORY_FILE="${XDG_DATA_HOME}/aws/history";
    AWS_CREDENTIALS_FILE="${XDG_DATA_HOME}/aws/credentials";
    AWS_WEB_IDENTITY_TOKEN_FILE="${XDG_DATA_HOME}/aws/token";
    AWS_SHARED_CREDENTIALS_FILE="${XDG_DATA_HOME}/aws/shared-credentials";
  };
in {
  xdg.enable = true;

  home.sessionVariables = variables;
  systemd.user.sessionVariables = variables;
}
