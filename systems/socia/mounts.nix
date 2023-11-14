{ config, ... }: let
  uid = toString config.users.users.mange.uid;
  consessorShares = [
    "Anime"
    "Audiobooks"
    "Downloads"
    "Kids"
    "Mange"
    "Movies"
    "Software"
    "TV"
  ];
  mkConsessorShare = name: {
    bindsTo = [ "tailscaled.service" ];
    description = "Consessor ${name}";
    type = "cifs";
    what = "//consessor/${name}";
    where = "/mnt/consessor/${name}";
    options = "workgroup=Samba,credentials=/etc/samba/credentials/consessor,uid=${uid}";
  };
  mkConsessorAutomount = name: {
    description = "Consessor ${name} automount";
    requires = [ "network-online.target" "tailscaled.service" ];
    where = "/mnt/consessor/${name}";
    wantedBy = ["multi-user.target"];
    # Automatically unmount after 30 minutes of inactivity.
    automountConfig = {
      TimeoutIdleSec = "30min";
    };
  };
in {
  systemd.mounts = map mkConsessorShare consessorShares;
  systemd.automounts = map mkConsessorAutomount consessorShares;
}
