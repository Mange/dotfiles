{ pkgs, ... }: {
  virtualisation.libvirtd.enable = true;
  virtualisation.spiceUSBRedirection.enable = true;

  programs.dconf.enable = true;
  environment.systemPackages = with pkgs; [
    virt-manager
    virtiofsd
  ];

  users.users.mange.extraGroups = ["libvirtd"];
}
