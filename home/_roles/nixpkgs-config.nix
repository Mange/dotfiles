{
  allowUnfree = true;
  # Workaround for https://github.com/nix-community/home-manager/issues/2942
  allowUnfreePredicate = _: true;

  permittedInsecurePackages = [
    # Used by Obsidian
    # https://forum.obsidian.md/t/electron-25-is-now-eol-please-upgrade-to-a-newer-version/72878
    "electron-25.9.0"

    # TODO: Pulled in by catppuccin-cursors
    # (Last tested 2025-09-06)
    "qtwebengine-5.15.19"
  ];
}
