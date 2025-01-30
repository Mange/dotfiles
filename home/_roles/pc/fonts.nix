{ pkgs, ... }: {
  fonts.fontconfig = {
    enable = true;
    defaultFonts = {
      emoji = ["Noto Color Emoji" "Nerd Fonts Symbols Only"];
      monospace = ["JetBrainsMono Nerd Font"];
      sansSerif = ["Inter" "Nerd Fonts Symbols Only"];
      serif = ["Inter" "Nerd Fonts Symbols Only"];
    };
  };

  gtk.font = {
    name = "Inter";
    size = 12;
    package = pkgs.inter;
  };

  programs.rofi.font = "Inter Light 10";
  programs.neovide.settings.font.normal = ["JetBrains Mono"];

  home.packages = with pkgs; [
    # Main fonts
    jetbrains-mono
    inter

    # Symbols
    nerd-fonts.jetbrains-mono
    nerd-fonts.symbols-only
    noto-fonts-emoji # Emoji
    noto-fonts-extra # etc.

    # Compatibility with other things
    dejavu_fonts
    liberation_ttf # Arial, Times New Roman, etc.
    roboto # Android

    # Eastern fonts, for Kaomoji, when opening Japanese websites, etc.
    ipafont # Japanese
    arphic-uming # Chinese
    baekmuk-ttf # Korean
    lohit-fonts.kannada # Indic; includes ಠ_ಠ

    # ancient fonts - Just because it is cool
    # https://dn-works.com/ufas/
    aegan
    aegyptus
    symbola
    unidings
    eemusic
    textfonts
    assyrian
    akkadian
    maya
  ];
}

