# Try out the Zed editor
{ pkgs, ... }:
{
  programs.zed-editor = {
    enable = true;
    defaultEditor = false;

    installRemoteServer = true;
    mutableUserSettings = true;

    extensions = [
      "nix"
      "toml"
      "rust"
    ];

    extraPackages = with pkgs; [
      nixd
    ];

    userSettings = {
      vim_mode = true;
    };
  };
}
