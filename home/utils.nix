{ config, ... }: let
  lib = config.lib;
  ooss = lib.file.mkOutOfStoreSymlink;

  dotfilesPath = "${config.home.homeDirectory}/Projects/dotfiles";

  linkConfig = path: ooss "${dotfilesPath}/config/${path}";

  mergeAttrs = attrs: lib.fold (acc: item: acc // item) {} attrs;
in
{
  inherit dotfilesPath linkConfig mergeAttrs;
}
