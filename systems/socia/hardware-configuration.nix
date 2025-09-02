{ lib, modulesPath, ... }:

{
  imports =
    [ (modulesPath + "/installer/scan/not-detected.nix")
    ];

  boot = {
    initrd = {
      systemd.enable = true;
      availableKernelModules = [ "nvme" "xhci_pci" "usbhid" ];
      kernelModules = [ ];
      luks.devices."luksdev".device = "/dev/disk/by-uuid/4e672fc9-b117-48d6-99fc-d0e2a30d2af9";
    };
    kernelModules = [ "kvm-amd" ];
    extraModulePackages = [ ];
  };

  fileSystems = {
    "/" =
      { device = "/dev/disk/by-uuid/c3645fb2-e588-4b48-8c4c-d3e1e6cf4d50";
        fsType = "btrfs";
        options = [ "subvol=@nixroot" ];
      };

    "/boot" =
      { device = "/dev/disk/by-uuid/B27D-FD44";
        fsType = "vfat";
      };

    "/home" =
      { device = "/dev/disk/by-uuid/c3645fb2-e588-4b48-8c4c-d3e1e6cf4d50";
        fsType = "btrfs";
        options = [ "subvol=@home" ];
      };

    "/.snapshots" =
      { device = "/dev/disk/by-uuid/c3645fb2-e588-4b48-8c4c-d3e1e6cf4d50";
        fsType = "btrfs";
        options = [ "subvol=@.snapshots" ];
      };

    "/var/log" =
      { device = "/dev/disk/by-uuid/c3645fb2-e588-4b48-8c4c-d3e1e6cf4d50";
        fsType = "btrfs";
        options = [ "subvol=@log" ];
      };
  };

  swapDevices = [ ];

  # Enables DHCP on each ethernet and wireless interface. In case of scripted networking
  # (the default) this is the recommended approach. When using systemd-networkd it's
  # still possible to use this option, but it's recommended to use it in conjunction
  # with explicit per-interface declarations with `networking.interfaces.<interface>.useDHCP`.
  networking.useDHCP = lib.mkDefault true;

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
}
