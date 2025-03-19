# dotfiles

This is a repo of my settings and computer customization preferences.

Quick summary of my stack:

- **OS:** [NixOS]
- **Window manager:** [Niri] (Wayland)
- **Editor:** [Neovim]
- **Shell:** [ZSH]
- **Terminal emulator:** [Wezterm]
- **Web browser:** [Firefox]
- **Colors:** [Catppuccin]

## Nix

A lot of my config is very very old and I have not moved everything over to Nix
yet. This will take its own sweet time.

## How to bootstrap

1. Install NixOS on a machine.
2. Get my age secret key and save it as `~/.config/sops/age/keys.txt`.
3. Clone the repo.
4. `nix develop` and `nh os switch`.
5. Install home manager things with `nh home switch`.

## Copyright

I really don't think most settings and configs could be worthy enough to
require licenses, but in case you are a person that cares about matters like
these:
I hereby give full rights to use or modify anything found in this repo, unless
it has an attached copyright notice in which case that copyright notice needs
to be honored.

No warranty or guarantees are provided in case you run any code from this
repository.

[NixOS]: https://www.nixos.org
[Niri]: https://github.com/YaLTeR/niri
[Neovim]: https://neovim.io/
[ZSH]: http://zsh.sourceforge.net/
[Wezterm]: https://wezfurlong.org/wezterm/
[Firefox]: https://www.mozilla.org/firefox/
[Catppuccin]: https://github.com/catppuccin/catppuccin
