{ pkgs, ... }: {
  virtualisation.libvirtd.enable = true;
  virtualisation.spiceUSBRedirection.enable = true;

  programs.dconf.enable = true;
  environment.systemPackages = [ pkgs.virt-manager ];

  users.users.mange.extraGroups = ["libvirtd"];
}
