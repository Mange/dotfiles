{
  config,
  ...
}:
let
  uid = toString config.home.uid;
in
{
  sops.secrets = {
    "toggl_track_api_key" = {
      path = "/var/run/user/${uid}/secrets/toggl-track-api-key";
    };
  };
}
