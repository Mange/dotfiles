{ pkgs, ... }: {
  home.packages = with pkgs; [
    libnotify
    mako
  ];

  xdg.configFile."mako/config".text = /*ini*/ ''
    layer=overlay
    max-history=10
    # Oldest on top
    sort=+time

    on-button-left=invoke-default-action
    on-button-middle=exec makoctl menu -n "$id" rofi -dmenu -p 'Select action: '
    on-button-right=dismiss

    font=Inter 12
    width=400
    height=200
    border-radius=10
    padding=10,15
    default-timeout=10000

    format=<span font="14">%s</span>\n%b

    ### Catppuccin mocha
    # …but I want transparent background
    background-color=#1e1e2eCC
    text-color=#cdd6f4
    border-color=#cba6f7
    progress-color=over #313244
    [urgency=high]
    border-color=#fab387
    ###

    # Urgent notifications get a sound effect and stay
    [urgency=high]
    on-notify=exec mpv /usr/share/sounds/freedesktop/stereo/message.oga
    default-timeout=0

    # Critical notifications get a sound effect and stay
    [urgency=critical]
    on-notify=exec mpv /usr/share/sounds/freedesktop/stereo/bell.oga
    default-timeout=0
    border-color=#eba0ac
    anchor=center

    ### Matchers ###

    # Google Calendar notifications are important!
    # Brave/Chromium identifies the website source in messages, but Firefox
    # does not. For Firefox, assume messages with patterns like
    # "09:00 – 09:15" are calendar events. (NOTE: That's a unicode
    # dash)
    [app-name=Firefox body~="\d\d:\d\d – \d\d:\d\d"]
    default-timeout=0
    border-color=#fab387
    on-notify=exec mpv /usr/share/sounds/freedesktop/stereo/bell.oga
    [app-name=Brave body~="^calendar.google.com"]
    default-timeout=0
    border-color=#fab387
    on-notify=exec mpv /usr/share/sounds/freedesktop/stereo/bell.oga

    # Spotify notifications should disappear quickly
    [app-name=Spotify]
    default-timeout=2000
    anchor=top-left
    format=<b>%s</b>\n%b

    # Some persistent notifications from Android can be annoying to see all the
    # time.
    [summary="Android-system" body~="^Datavarning:"]
    max-visible=0

    # My own toasts should be quick to hide and centered
    [category=x-mange.toast]
    default-timeout=1000
    anchor=center
    background-color=#313244CC
    progress-color=source #b4befeCC
    border-color=#b4befeCC
    [category=x-mange.toast summary~=Volume:]
    on-notify=exec mpv /usr/share/sounds/freedesktop/stereo/audio-volume-change.oga

    # Do-not-Disturb mode
    [mode=dnd]
    invisible=1
    [mode=dnd urgency=critical]
    on-notify=exec mpv /usr/share/sounds/freedesktop/stereo/bell.oga
    anchor=top-right
  '';
}
