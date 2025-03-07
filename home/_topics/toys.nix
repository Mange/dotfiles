{ pkgs, ... }: let
  mkScript = text: {
    executable = true;
    text = text;
  };
  upstreamFonts = "${pkgs.figlet}/share/figlet";
  extraFonts = pkgs.fetchFromGitHub {
    owner = "xero";
    repo = "figlet-fonts";
    rev = "0c0697139d6db66878eee720ebf299bc3a605fd0";
    sha256 = "0b1m8w836p4wq6cgylm9rgiyjsvxsnqsglf0qab9q7wqqgmvsqqy";
  };

in {
  home.packages = with pkgs; [
    dotacat
    figlet
    ponysay

    nixos-stable.charasay
  ];

  # Music visualizer
  programs.cava.enable = true;

  home.file = {
    ".local/bin/banner" = mkScript /* sh */ ''
      #!/bin/sh
      ${pkgs.figlet}/bin/figlet -f "${extraFonts}/3d.flf" "$@"
    '';

    ".local/bin/minibanner" = mkScript /* sh */ ''
      #!/bin/sh
      ${pkgs.figlet}/bin/figlet -f "${extraFonts}/halfiwi.flf" "$@"
    '';

    ".local/bin/banners" = mkScript /* sh */ ''
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
