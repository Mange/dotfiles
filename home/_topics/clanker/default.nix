{ pkgs, config, ... }:
let
  uid = toString config.home.uid;
in
{
  sops.secrets = {
    "claude/oauth_token" = {
      path = "/var/run/user/${uid}/secrets/claude-oauth-token";
    };
  };

  home = {
    packages = with pkgs; [
      claude-code
      claude-agent-acp
    ];

    # Have most of Claude placed under `.config`. It's not XDG compliant, but
    # better than to clutter my home dir.
    sessionVariables.CLAUDE_CONFIG_DIR = "${config.xdg.configHome}/claude";
  };

  xdg.configFile = {
    "claude/CLAUDE.md".source = ./CLAUDE.md;

    "claude/skills/review-code" = {
      source = ./skills/review-code;
      recursive = true;
    };
  };

  # Claude code sandbox keeps seeing files that don't exist when it runs "git
  # status".
  # Let's add it to my global ignores for now so the agent stops getting
  # confused by them and/or accidentally adds/gitignores them inside of repos.
  programs.git.ignores = [
    "/.bash_profile"
    "/.bashrc"
    "/.gitconfig"
    "/.gitmodules"
    "/.idea"
    "/.mcp.json"
    "/.profile"
    "/.ripgreprc"
    "/.vscode"
    "/.zprofile"
    "/.zshrc"
  ];
}
