# This file defines overlays
{ inputs, ... }:
{
  # This one brings our custom packages from the 'pkgs' directory
  additions = final: _prev: import ../pkgs { pkgs = final; };

  # This one contains whatever you want to overlay
  # You can change versions, add patches, set compilation flags, anything really.
  # https://nixos.wiki/wiki/Overlays
  modifications = final: prev: {
    # example = prev.example.overrideAttrs (oldAttrs: rec {
    # ...
    # });

    # hyprlandPlugins = prev.hyprlandPlugins //
    #   {
    #     # Patch to 0.46.0
    #     hy3 = prev.hyprlandPlugins.hy3.overrideAttrs (oldAttrs: {
    #       version = "0.46.0";
    #       src = prev.fetchFromGitHub {
    #         owner = "outfoxxed";
    #         repo = "hy3";
    #         rev = "refs/tags/hl0.46.0";
    #         hash = "sha256-etPkIYs38eDgJOpsFfgljlGIy0FPRXgU3DRWuib1wWc=";
    #       };
    #     });
    #   };
  };

  # When applied, the unstable nixpkgs set (declared in the flake inputs) will
  # be accessible through 'pkgs.unstable'
  unstable-packages = final: _prev: {
    unstable = import inputs.nixpkgs-unstable {
      system = final.system;
      config.allowUnfree = true;
    };
    nixos-stable = import inputs.nixos-stable {
      system = final.system;
      config.allowUnfree = true;
    };
  };
}
