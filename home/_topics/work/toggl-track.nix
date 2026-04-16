{
  config,
  ...
}:
let
  uid = toString config.home.uid;
in
{
  sops.secrets = {
    "toggl_track/password" = {
      path = "/var/run/user/${uid}/secrets/toggl-track-password";
    };
    "toggl_track/api_key" = {
      path = "/var/run/user/${uid}/secrets/toggl-track-api-key";
    };
  };
}
