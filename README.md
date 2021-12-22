# dotfiles

This is a repo of my settings and computer customization preferences.

Quick summary of my stack:

- **OS:** [Arch Linux][arch]
- **Window manager:** [Awesome WM][awesome] + [picom] (compositor)
- **Editor:** [Neovim]
- **Shell:** [ZSH]
- **Terminal emulator:** [Wezterm]
- **Web browser:** [Firefox] (Developer Edition)
- **Colors:** [Catppuccin]

## Structure

This repo is structured in three different sections.

 * Root section (actual dotfiles)
 * Platforms section (setup scripts for setting up machines)
 * `dotfiles-cli` section (CLI util for managing dotfiles)

### Root section

Dotfiles are mainly placed in accordance with the XDG directory specification.
This simplifies things a whole lot. You can find files for the configuration
directory inside the `config` directory, data files inside the `data` directory
and executables inside the `bin` directory.

Some software does not follow XDG specifications and might require custom
locations. Those files are inside the `snowflakes` directory, managed with
`snowflakes/manifest.txt`.

### Platforms section

The `platforms` directory contains setup scripts for setting up machines and
manage software or system-level configuration on them.

- `platforms/arch.sh` - Sets up wanted software and preferences on an Arch
  machine.
- `platforms/arch-bootstrap.sh` - Sets up a *new* Arch machine (adds my user,
  clones this repo, etc.).

#### How to bootstrap

As root, on you newly booted Arch machine:

```bash
pacman -Sy wget
wget https://github.com/Mange/dotfiles/raw/master/platforms/arch-bootstrap.sh
chmod +x arch-bootstrap.sh
./arch-bootstrap.sh
```


### `dotfiles-cli`

`dotfiles` is a CLI utility that is written in Rust and can be called to manage
the dotfiles in this repo; installing files, etc.

It will be extended in the future to deal with even more parts of this repo.

## How to install

Run `initial-setup.sh` file at the project root. It will compile `dotfiles` and
use it to install itself in your HOME, together with all the other files.

After this initial install you can call `dotfiles --help` to see other
operations that you can use.

In order to compile this binary Rust must be installed and set up. You can run
the platform scripts first in order to bootstrap and prepare your machine.

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
[awesome]: https://awesomewm.org/
[picom]: https://github.com/yshui/picom
[Neovim]: https://neovim.io/
[ZSH]: http://zsh.sourceforge.net/
[Wezterm]: https://wezfurlong.org/wezterm/
[Firefox]: https://www.mozilla.org/en-US/firefox/
[Catppuccin]: https://github.com/catppuccin/catppuccin
