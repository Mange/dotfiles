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

    ../_topics/bluetooth.nix
  ];
}
