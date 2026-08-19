{ lib, config, ... }:
{
  programs.jujutsu = {
    enable = true;
    settings = {
      user = {
        name = "Magnus Bergmark";
        email = "me@mange.dev";
      };

      merge-tools.difftastic = {
        program = "difft";
        diff-args = [
          "--color=always"
          "$left"
          "$right"
        ];
      };

      ui = {
        default-command = "log";
        diff-formatter = lib.mkIf config.programs.difftastic.enable "difftastic";
      };
    };
  };
}
