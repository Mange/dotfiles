{ pkgs, ... }: {
  fonts.fontconfig.enable = true;

  home.packages = with pkgs; [
    # Main fonts
    jetbrains-mono
    overpass

    # Symbols
    (
     nerdfonts.override {
     fonts = [
     "JetBrainsMono"
     "Overpass"
     "NerdFontsSymbolsOnly"
     ];
     }
    )
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
