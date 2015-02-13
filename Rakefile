require File.expand_path('../support/dotfile', __FILE__)
require File.expand_path('../support/binary', __FILE__)
require 'fileutils'

SYMLINKS = %w[
  Xmodmap
  gemrc
  git_template
  irbrc
  railsrc
  rspec
  slate.js
  sshrc
  sshrc.d
  tmux.conf
  vimrc
  zsh
  zshenv
  zshprofile
  zshrc
]
FILES = []
BINARIES = %w[
  di-download
]

SYMLINKS.each do |file|
  desc "Installs #{file} by symlinking it inside your home"
  task file do
    Dotfile.new(file).install_symlink
  end
end

BINARIES.each do |file|
  desc "Installs #{file} binary by symlinking it to your home's bin directory"
  task file => :bin do
    Binary.new(file).install_symlink
  end
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

  config["commit.gpgsign", "true"]

  config["merge.conflictstyle", "diff3"]
  config["merge.tool", "vimdiff"]

  config["rebase.autosquash", "true"]
  config["rebase.stat", "true"]

  config["init.templatedir", "~/.git_template"]

  # Aliases
  config["alias.new", %(!sh -c 'git log $1@{1}..$1@{0} "$@"')]
  config["alias.prune", %(!git remote | xargs -n 1 git remote prune)]
end

desc "Installs NeoBundle"
task :neobundle => :vim do
  unless File.exist?('vim/bundle/neobundle.vim/')
    unless system('git clone -q git://github.com/Shougo/neobundle.vim.git vim/bundle/neobundle.vim')
      STDERR.puts "Could not clone NeoBundle. Continuing..."
    end
  end
end

desc "Installs all neobundle plugins"
task :vimplugins => :neobundle do
  unless system('vim -c ":NeoBundleInstall" -c ":qa"')
    STDERR.puts "Could not automatically install vim bundles. Continuing..."
  end
end

desc "Installs vim config"
task :vim do
  Dotfile.new('vim').install_symlink
end

desc "Installs Karabiner config (on Macs)"
task :karabiner_config do
  app_support = Pathname.new("~/Library/Application Support").expand_path
  if app_support.directory?
    config = Dotfile.new("karabiner.xml")
    config.home_path = app_support.join("Karabiner", "private.xml")
    config.install_symlink
  end
end

desc "Generate a copy of the zshrc file for sshrc"
sshrc_zshrc = File.expand_path("~/.sshrc.d/.zshrc")
file sshrc_zshrc => "sshrc.d" do
  File.open(sshrc_zshrc, 'w') do |out|
    # Minify zshrc by removing comments and indentations
    source = File.expand_path("../zshrc", __FILE__)
    File.foreach(source) do |line|
      filtered = line.sub(/#.*$/, '').sub(/^\s+/, '')
      out << filtered unless filtered.empty?
    end
  end
end
task :install => sshrc_zshrc

desc "Installs all files"
task :install => (SYMLINKS + FILES + BINARIES + %w[karabiner_config gopath modules gitignore zsh gitconfig neobundle]) do
  if ENV['SHELL'] !~ /zsh/
    STDERR.puts "Warning: You seem to be using a shell different from zsh (#{ENV['SHELL']})"
    STDERR.puts "Fix this by running:"
    STDERR.puts "  chsh -s `which zsh`"
  end
end

desc "Clears all 'legacy' files (like old symlinks)"
task :cleanup do
  Dotfile.new('zshrc.d').delete_target(:only_symlink => true)
  Dotfile.new('ackrc').delete_target(:only_symlink => true)
  # Clean up backup created after converting ~/.zsh to a symlink
  `[ -d ~/.zsh~ ] && mv ~/.zsh\~/* ~/.zsh && rmdir ~/.zsh~`
end

desc "Install and clean up old files"
task :update => [:install, :cleanup]

desc "Clears all symlinks"
task :clear_symlinks do
  SYMLINKS.each do |file|
    Dotfile.new(file).delete_target(:only_symlink => true)
  end
end

task default: :update
