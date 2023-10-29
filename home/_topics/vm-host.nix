{ pkgs, ... }: {
  home.packages = with pkgs; [
    spice
    spice-gtk
  ];

  dconf.settings = {
    "org/virt-manager/virt-manager/connections" = {
      autoconnect = ["qemu:///system"];
      uris = ["qemu:///system"];
    };
  };
}
