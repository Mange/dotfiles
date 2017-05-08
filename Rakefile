require File.expand_path('../support/dotfile', __FILE__)
require File.expand_path('../support/binary', __FILE__)
require 'fileutils'

XDG_SYMLINKS = %w[
  i3
  i3blocks
]

SYMLINKS = %w[
  Xresources.d
  Xmodmap
  gemrc
  git_template
  i3blocks.conf
  irbrc
  psqlrc
  railsrc
  rspec
  tmux.conf
  vimrc
  wallpapers
  xprofile
  zsh
  zshenv
  zshprofile
  zshrc
]

FILES = []

BINARIES = Dir.glob(
  File.expand_path("../bin/*", __FILE__)
).select { |path| File.file?(path) }.map { |path| File.basename(path) }

SYMLINKS.each do |file|
  desc "Installs #{file} by symlinking it inside your home"
  task file do
    Dotfile.new(file).install_symlink
  end
end

XDG_SYMLINKS.each do |file|
  desc "Installs #{file} by symlinking it inside your XDG_HOME"
  task file do
    xdg_home = ENV.fetch('XDG_HOME', '~/.config')

    dotfile = Dotfile.new(file)
    dotfile.home_path = File.join(xdg_home, file)
    dotfile.install_symlink
  end
end

desc "Installs all binaries"
task :bins

BINARIES.each do |file|
  desc "Installs #{file} binary by symlinking it to your home's bin directory"
  task "bin/#{file}" => :bin do
    Binary.new(file).install_symlink
  end

  task :bins => "bin/#{file}"
end

FILES.each do |file|
  desc "Installs #{file} by copying it to your home"
  task file do
    Dotfile.new(file).install_copy
  end
end

desc "Creates your bin directory if not present"
task :bin do
  bin_path = File.join(Dir.home, "bin")
  unless File.directory? bin_path
    Dir.mkdir(bin_path, 0750)
  end
end

desc "Creates your gopath directory"
task :gopath do
  gopath_path = File.join(Dir.home, "Projects", "gopath")
  unless File.directory? gopath_path
    FileUtils.mkdir_p(gopath_path, mode: 0750)
  end
end

desc "Installs the global gitignore file"
task :gitignore do
  Dotfile.new('gitignore').install_symlink
  unless system('git config --global core.excludesfile "$HOME/.gitignore"')
    STDERR.puts "Could not set git excludesfile. Continuing..."
  end
end

desc "Initializes/updates other repos"
task :modules do
  {
    "zsh/zsh-syntax-highlighting" => "https://github.com/zsh-users/zsh-syntax-highlighting.git",
    "zsh/zsh-history-substring-search" => "https://github.com/zsh-users/zsh-history-substring-search.git",
    "zsh/k" => "https://github.com/supercrabtree/k.git",
  }.each_pair do |pathname, repo|
    path = File.expand_path(pathname, File.dirname(__FILE__))
    if File.exists?(path)
      system %(cd "#{path}" && git pull --rebase > /dev/null)
    else
      system %(git clone "#{repo}" "#{path}")
    end
  end
end

desc "Does some basic Git setup"
task :gitconfig do
  exec = lambda { |command| system(*command) or STDERR.puts "Command failed: #{command.join(' ')}" }
  config = lambda { |setting, value| exec[['git', 'config', '--global', setting, value]] }

  config["push.default", "tracking"]
  config["color.ui", "true"]

  config["user.name", "Magnus Bergmark"]
  config["user.email", "magnus.bergmark@gmail.com"]
  config["user.signingkey", "4D8E0309"]
  config["github.user", "Mange"]

  config["color.branch.current", "bold green"]
  config["color.branch.local", "green"]
  config["color.branch.remote", "blue"]

  config["diff.compactionHeuristic", "true"]

  # For diff-highlight / diff-so-fancy
  config["color.diff-highlight.oldNormal", "red bold"]
  config["color.diff-highlight.oldHighlight", "red bold 52"]
  config["color.diff-highlight.newNormal", "green bold"]
  config["color.diff-highlight.newHighlight", "green bold 22"]
  config["pager.show",             "diff-so-fancy | less --tabs=4 -RXin"]
  config["pager.diff",             "diff-so-fancy | less --tabs=4 -RXin"]
  config["interactive.diffFilter", "diff-so-fancy | less --tabs=4 -RXin"]

  config["commit.gpgsign", "true"]

  # It's nice in theory, but too many scripts break with this on.
  config["log.showSignature", "false"]

  config["merge.conflictstyle", "diff3"]
  config["merge.tool", "vimdiff"]

  config["rebase.autosquash", "true"]
  config["rebase.stat", "true"]

  config["init.templatedir", "~/.git_template"]

  # Aliases
  config["alias.new", %(!sh -c 'git log $1@{1}..$1@{0} "$@"')]
  config["alias.prune", %(!git remote | xargs -n 1 git remote prune)]
end

desc "Installs vim config"
task :vim do
  Dotfile.new('vim').install_symlink
end

desc "Installs nvim config (symlinks to normal vim config)"
task :nvim => :vim do
  xdg_home = ENV.fetch('XDG_HOME', '~/.config')

  nvim = Dotfile.new('nvim', 'vim')
  nvim.home_path = File.join(xdg_home, 'nvim')
  nvim.install_symlink
end

desc "Installs all files"
task :install => (
  SYMLINKS + XDG_SYMLINKS + FILES + %w[
    bins
    gitconfig
    gitignore
    gopath
    modules
    nvim
    zsh
  ]
) do
  if ENV['SHELL'] !~ /zsh/
    STDERR.puts "Warning: You seem to be using a shell different from zsh (#{ENV['SHELL']})"
    STDERR.puts "Fix this by running:"
    STDERR.puts "  chsh -s `which zsh`"
  end
end

desc "Install plugs in vim"
task :vimplugs => :vim do
  system("${VISUAL:-${EDITOR:-nvim}} -u ~/.vim/plugs.vim +PlugInstall +qa")
end

desc "Clears all 'legacy' files (like old symlinks)"
task :cleanup do
  Dotfile.new('zshrc.d').delete_target(only_symlink: true)
  Dotfile.new('ackrc').delete_target(only_symlink: true)
  Dotfile.new('slate.js').delete_target(only_symlink: true)
  Dotfile.new('sshrc').delete_target(only_symlink: true)
  Dotfile.new('sshrc.d').delete_target(only_symlink: true)
  Dotfile.new('xinitrc').delete_target(only_symlink: true)
  # Clean up backup created after converting ~/.zsh to a symlink
  `[ -d ~/.zsh~ ] && mv ~/.zsh\~/* ~/.zsh && rmdir ~/.zsh~`
end

desc "Install and clean up old files"
task :update => [:install, :cleanup, :vimplugs]

desc "Clears all symlinks"
task :clear_symlinks do
  SYMLINKS.each do |file|
    Dotfile.new(file).delete_target(:only_symlink => true)
  end
end

task default: :update
