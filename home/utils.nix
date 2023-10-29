{ config, pkgs, ... }: let
  ooss = config.lib.file.mkOutOfStoreSymlink;

  dotfilesPath = "${config.home.homeDirectory}/Projects/dotfiles";

  linkConfig = path: ooss "${dotfilesPath}/config/${path}";

  mergeAttrs = attrs: pkgs.lib.fold (acc: item: acc // item) {} attrs;

  filesIn = path: builtins.attrNames (builtins.readDir path);
in
{
  inherit dotfilesPath linkConfig mergeAttrs filesIn;
}
