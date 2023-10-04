{ pkgs, ... }: {
  hardware.bluetooth = {
    enable = true;
    # Enable A2DP Sink
    settings = {
      General = {
        Enable = "Source,Sink,Media,Socket";
      };
    };
  };

  services.blueman.enable = true;
}
