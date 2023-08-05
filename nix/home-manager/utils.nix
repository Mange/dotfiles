{ config, pkgs, ... }: let
  ooss = config.lib.file.mkOutOfStoreSymlink;

  dotfilesPath = "${config.home.homeDirectory}/Projects/dotfiles";

  linkConfig = path: ooss "${dotfilesPath}/config/${path}";
in
{
  inherit dotfilesPath linkConfig;
}
