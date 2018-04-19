# dotfiles

This is a repo of my settings and computer customization preferences.

Quick summary of my stack:

- **OS:** [Arch Linux][arch]
- **Window manager:** [i3 WM][i3] ([i3-gaps fork][i3-gaps]) +
  [polybar] (bars) + [compton] (compositor)
- **Editor:** [Neovim]
- **Shell:** [ZSH]
- **Terminal emulator:** [termite]
- **Web browser:** [Firefox] (Developer Edition)
- **Colors:** [Gruvbox]

## Main level

This is normal user-level dotfiles. It is currently installed using `rake`:

```bash
rake
```

## Platforms level

The platforms layer (`platforms` directory) contains setup scripts for setting
up machines and manage software or system-level configuration on them.

- `platforms/arch.sh` - Sets up wanted software and preferences on an Arch
  machine.
- `platforms/arch-bootstrap.sh` - Sets up a *new* Arch machine (adds my user,
  clones this repo, etc.).

### How to bootstrap

As root, on you newly booted Arch machine:

```bash
pacman -Sy wget
wget https://github.com/Mange/dotfiles/raw/master/platforms/arch-bootstrap.sh
chmod +x arch-bootstrap.sh
./arch-bootstrap.sh
```

# Copyright

I really don't think most settings and configs could be worthy enough to
require licenses, but in case you are a person that cares about matters like
these:
I hereby give full rights to use or modify anything found in this repo, unless
it has an attached copyright notice in which case that copyright notice needs
to be honored.

No warranty or guarantees are provided in case you run any code from this
repository.

[arch]: https://www.archlinux.org/
[i3]: https://i3wm.org/
[i3-gaps]: https://github.com/Airblader/i3
[polybar]: https://github.com/jaagr/polybar
[compton]: https://github.com/chjj/compton
[Neovim]: https://neovim.io/
[ZSH]: http://zsh.sourceforge.net/
[termite]: https://github.com/thestinger/termite
[Firefox]: https://www.mozilla.org/en-US/firefox/
[Gruvbox]: https://github.com/morhetz/gruvbox
