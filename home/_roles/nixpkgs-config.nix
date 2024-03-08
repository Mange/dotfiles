{
  allowUnfree = true;
  # Workaround for https://github.com/nix-community/home-manager/issues/2942
  allowUnfreePredicate = (_: true);

  # Used by Obsidian
  # https://forum.obsidian.md/t/electron-25-is-now-eol-please-upgrade-to-a-newer-version/72878
  permittedInsecurePackages = [
    "electron-25.9.0"
  ];
}
