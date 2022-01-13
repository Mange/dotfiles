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

This repo uses Ansible to setup new machines. Usage of roles makes it possible
to quickly pick what I want to include or not include on a new machine.

You can see all roles under `roles/` and the initial setup in `environment.yml`.

Ansible also copies the dotfiles and installs them for the user in question.

### Dotfiles

Dotfiles are mainly placed in accordance with the XDG directory specification.
This simplifies things a whole lot. You can find files for the configuration
directory inside the `config` directory, data files inside the `data` directory
and executables inside the `bin` directory.

Some software does not follow XDG specifications and might require custom
locations. Those files are inside the `snowflakes` directory.

## Dotfiles CLI

After installing the dotfiles there is a CLI you can use.

```bash
dotfiles --help

# Update and install
dotfiles update

# Update symlinks
dotfiles update -t dotfiles
# …or without checking out new changes
dotfiles setup -t dotfiles

# If you want to edit a file
dotfiles edit
```

## How to bootstrap

As root, run the install script:

```bash
# For Arch:
pacman -Sy --noconfirm curl

curl -o - https://github.com/Mange/dotfiles/raw/master/bootstrap/bootstrap.sh | bash -
```

This script will run the bootstrap playbook (see `bootstrap/bootstrap.yml`),
which should create my user account. Follow the prompts to get running.

After you've set up the account, log in as the user and go to the dotfiles
checkout. Run the `setup.sh` script.

```bash
sudo su - mange
cd Projects/dotfiles
./setup.sh
```

## Tests

If you want to test the dotfiles and/or setup, you can use the test script
under `test/test.sh`. It will boot up a Docker container for the given platform
and bootstrap it. Then you are free to use the shell to test out the dotfiles.

```
host-machine$ dotfiles test --rebuild arch
docker-container$ cd Projects/dotfiles
docker-container$ ./setup.sh
```

## Copyright

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
