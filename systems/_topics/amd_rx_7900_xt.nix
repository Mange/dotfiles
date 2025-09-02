# ▄▄▄ ▄▄▄ ▄▄      ▄▄▄ ▄ ▄     ▄▄▄ ▄▄▄ ▄▄▄ ▄▄▄     ▄ ▄ ▄▄▄
# █ █ ███ █ █     █▄▀ ▀▄▀       █ █▄█ █▀█ █▀█     ▀▄▀  █
# █▀█ █ █ █▄▀     █ █ █ █       █ ▄▄█ ███ ███     █ █  █
# 
{ pkgs, ... }: {
  services = {
    xserver.videoDrivers = [ "amdgpu" ];

    # Let Ollama use my GPU.
    ollama.acceleration = "rocm";
    # nix-shell -p "rocmPackages.rocminfo" --run "rocminfo" | grep "gfx"
    ollama.rocmOverrideGfx = "11.0.0"; # i.e. `gfx1100`.
  };

  # Seems to be breaking too much… Complains about python3 torch 12 being broken.
  # nixpkgs.config.rocmSupport = true;

  hardware.amdgpu = {
    # Go for default RADV instead of AMDVLK.
    amdvlk.enable = false;
    opencl.enable = true;
    initrd.enable = true;
  };

  hardware.graphics = {
    enable = true;
    enable32Bit = true;
    extraPackages = [ pkgs.rocmPackages.clr.icd ];
  };

  environment.systemPackages = with pkgs; [
    clinfo
    nvtopPackages.amd
    vulkan-tools # to get vulkaninfo
  ];
}
