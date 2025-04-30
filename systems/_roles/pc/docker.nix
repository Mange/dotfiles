{ ... }: {
  virtualisation.docker.enable = true;
  users.users.mange.extraGroups = ["docker"];

  # Waiting for Docker to start during system boot takes an additional 20s or so.
  virtualisation.docker.enableOnBoot = false;
  systemd.sockets.docker.wantedBy = ["multi-user.target"];
}
