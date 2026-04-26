# Let's see what the big deal is…
{ pkgs, ... }:
{
  home.packages = with pkgs; [
    claude-code
    claude-agent-acp

    gemini-cli
  ];

  home.file.".claude/skills/review-code/SKILL.md".text = /* markdown */ ''
    ---
    name: review-code
    description: Perform a local code-review of a commit range.
    argument-hint: [base]
    ---

    Perform a local code review of the commits in this repository so I can deal
    with issues before pushing them to a remote.

    If no arguments are given I want to review commits from the default branch
    (master or main) to the current HEAD. If a single argument is given, then
    treat that as the base commit to compare from to HEAD. For more complex
    arguments, try to convert them to a sensible commit range.
  '';
}
