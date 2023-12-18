{ pkgs, config, ... }: let
  utils = import ../../utils.nix { inherit config pkgs; };
in {
  programs.ags = {
    enable = true;
    extraPackages = [ pkgs.libsoup_3 ];

    # Manage config using symlinks to the dotfiles repo instead of embedding it in
    # the build. This makes it easier to do rapid development, and also including
    # things like typescript type files without getting a lot of churn in the nix
    # derivation.
    configDir = null;
  };

  xdg.configFile."ags".source = utils.linkConfig "ags";
}
