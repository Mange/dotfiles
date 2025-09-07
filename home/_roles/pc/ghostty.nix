_: {
  programs.ghostty = {
    enable = true;

    enableBashIntegration = true;
    enableZshIntegration = true;
    installBatSyntax = true;

    clearDefaultKeybinds = true;
    settings = {
      keybind = [
        "ctrl+shift+c=copy_to_clipboard"
        "ctrl+shift+v=paste_from_clipboard"
        "ctrl+shift+s=paste_from_selection"

        "ctrl+shift+n=new_window"
        "ctrl+shift+t=new_tab"
        "ctrl+tab=next_tab"
        "ctrl+shift+tab=previous_tab"

        "ctrl+shift+comma=reload_config"
        "ctrl+comma=open_config"
        "ctrl+shift+plus=increase_font_size:1"
        "ctrl+minus=decrease_font_size:1"

        "ctrl+0=reset_font_size"

        "ctrl+shift+page_up=jump_to_prompt:-1"
        "ctrl+shift+page_down=jump_to_prompt:1"
        "ctrl+shift+up=scroll_page_fractional:-0.5"
        "ctrl+shift+down=scroll_page_fractional:0.5"

        "ctrl+page_up=scroll_page_up"
        "ctrl+page_down=scroll_page_down"
      ];

      background-opacity = 0.9; # 0.8; Until Niri gets blurred backgrounds

      link-url = true;
      window-inherit-working-directory = true;
      window-inherit-font-size = true;
      window-decoration = "server";

      app-notifications = "no-clipboard-copy";
      auto-update = "off";

      # Requires Ghostty 1.2.0+
      # custom-shader = "${./ghostty/shaders/cursor_smear.glsl}";
    };
  };

  # Install as an easter egg.
  home.file.".config/ghostty/shaders/in-game-crt.glsl".source = ./ghostty/shaders/in-game-crt.glsl;
}
