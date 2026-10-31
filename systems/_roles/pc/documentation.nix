{ pkgs, ... }: {
  # On a Personal Computer, one would like to have documentation available.
  documentation = {
    enable = true;
    dev.enable = true;
    doc.enable = true;
    nixos.enable = true;

    man = {
      enable = true;
      cache.enable = true;
      man-db.enable = true;
    };
  };

  # C development man pages.
  environment.systemPackages = with pkgs; [
    man-pages
    clang-manpages
  ];
}
