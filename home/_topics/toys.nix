{ pkgs, ... }:
let
  mkScript = text: {
    executable = true;
    inherit text;
  };
  upstreamFonts = "${pkgs.figlet}/share/figlet";
  extraFonts = pkgs.fetchFromGitHub {
    owner = "xero";
    repo = "figlet-fonts";
    rev = "5c250192890856486be8a85085e7915b1b655f3e";
    sha256 = "sha256-wT1DjM+3+UasAm2IHavBXs0R8eNMJn9uLtWSqwS+XU0=";
  };

in
{
  home.packages = with pkgs; [
    dotacat
    figlet
    ponysay
    nixos-stable.charasay

    # Music visualizer
    # Not enabled through home-manager so config file is not managed, so
    # Noctalia can overwrite it.
    cava
  ];

  home.file = {
    ".local/bin/banner" =
      # sh
      mkScript ''
        #!/bin/sh
        ${pkgs.figlet}/bin/figlet -f "${extraFonts}/3d.flf" "$@"
      '';

    ".local/bin/minibanner" =
      # sh
      mkScript ''
        #!/bin/sh
        ${pkgs.figlet}/bin/figlet -f "${extraFonts}/halfiwi.flf" "$@"
      '';

    ".local/bin/banners" =
      # sh
      mkScript ''
        #!/bin/sh
        set -e

        mode=text

        if [ "$1" = "--help" ]; then
          echo "Usage: banners [--font] [TEXT...]"
          exit 0
        fi

        if [ "$1" = "--font" ]; then
          mode=font
          shift
        fi

        text="$*"
        [ -z "$text" ] && text="Hello World"

        font=$(
          ${pkgs.fd}/bin/fd . "${upstreamFonts}" "${extraFonts}" --extension flf |
            ${pkgs.fzf}/bin/fzf --delimiter=/ --with-nth=-1 \
              --preview "figlet -w \$FZF_PREVIEW_COLUMNS -f {} \"$text\""
        )

        if [ "$mode" = "font" ]; then
          echo "$font"
        else
          ${pkgs.figlet}/bin/figlet -f "$font" "$text"
        fi
      '';
  };
}
