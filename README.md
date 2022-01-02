# dotfiles

This is a repo of my settings and computer customization preferences.

Quick summary of my stack:

- **OS:** [Arch Linux][arch]
- **Window manager:** [Awesome WM][awesome] + [picom] (compositor)
- **Editor:** [Neovim]
- **Shell:** [ZSH]
- **Terminal emulator:** [Wezterm]
- **Web browser:** [Brave]
- **Colors:** [Catppuccin]

## Structure

This repo is structured in three different sections.

 * Root section (actual dotfiles)
 * `ansible` for setting up and installing dependencies on computers.
 * `bootstrap` for bootstrapping a new machine, creating my user, etc.
 * `dotfiles-cli` section (CLI util for managing dotfiles)

### Root section

Dotfiles are mainly placed in accordance with the XDG directory specification.
This simplifies things a whole lot. You can find files for the configuration
directory inside the `config` directory, data files inside the `data` directory
and executables inside the `bin` directory.

Some software does not follow XDG specifications and might require custom
locations. Those files are inside the `snowflakes` directory, managed with
`snowflakes/manifest.txt`.

#### How to bootstrap

As root, on you newly booted Arch machine:

```bash
pacman -Sy --noconfirm curl
curl -o /root/bootstrap.sh https://github.com/Mange/dotfiles/raw/master/bootstrap/bootstrap.sh
chmod +x /root/arch-bootstrap.sh
/root/arch-bootstrap.sh
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
[Brave]: https://brave.com/
[Catppuccin]: https://github.com/catppuccin/catppuccin
