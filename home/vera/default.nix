#
#  ██      ██                         
# ░██     ░██                         
# ░██     ░██  █████  ██████  ██████  
# ░░██    ██  ██░░░██░░██░░█ ░░░░░░██ 
#  ░░██  ██  ░███████ ░██ ░   ███████ 
#   ░░████   ░██░░░░  ░██    ██░░░░██ 
#    ░░██    ░░██████░███   ░░████████
#     ░░      ░░░░░░ ░░░     ░░░░░░░░ 
#
{ ... }: {
  imports = [
    ../_roles/base.nix
    ../_roles/laptop

    ../_topics/android-dev.nix
  ];
}
