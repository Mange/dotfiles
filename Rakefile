require File.expand_path('../support/dotfile', __FILE__)
require 'fileutils'

SYMLINKS = %w[
  ackrc
  gemrc
  irbrc
  railsrc
  rspec
  tmux.conf
  vimrc
  zshenv
  zshprofile
  zshrc
  zshrc.d
]
FILES = []

SYMLINKS.each do |file|
  desc "Installs #{file} by symlinking it inside your home"
  task file do
    Dotfile.new(file).install_symlink
  end
end

FILES.each do |file|
  desc "Installs #{file} by copying it to your home"
  task file do
    Dotfile.new(file).install_copy
  end
end

desc "Installs the global gitignore file"
task :gitignore do
  Dotfile.new('gitignore').install_symlink
  unless system('git config --global core.excludesfile "$HOME/.gitignore"')
    STDERR.puts "Could not set git excludesfile. Continuing..."
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
  config["github.user", "Mange"]

  config["color.branch.current", "bold green"]
  config["color.branch.local", "green"]
  config["color.branch.remote", "blue"]

  config["merge.conflictstyle", "diff3"]
  config["merge.fugitive.cmd", 'mvim -f -c "Gdiff" "$MERGED"']
  config["merge.tool", "fugitive"]
end

desc "Installs Vundle"
task :vundle => [:vim] do
  unless File.exist?('vim/bundle/vundle')
    if system('git clone -q git://github.com/gmarik/vundle.git vim/bundle/vundle')
      unless system('vim -c ":BundleInstall" -c ":qa"')
        STDERR.puts "Could not automatically install vim bundles. Continuing..."
      end
    else
      STDERR.puts "Could not clone Vundle. Continuing..."
    end
  end
end

desc "Installs vim config"
task :vim do
  Dotfile.new('vim').install_symlink
end

desc "Creates a blank .zsh directory"
task :zsh do
  `mkdir -p ~/.zsh`
end

desc "Installs all files"
task :install => (SYMLINKS + FILES + %w[gitignore zsh gitconfig vundle]) do
  if ENV['SHELL'] !~ /zsh/
    STDERR.puts "Warning: You seem to be using a shell different from zsh (#{ENV['SHELL']})"
    STDERR.puts "Fix this by running:"
    STDERR.puts "  chsh -s `which zsh`"
  end
end

desc "Clears all 'legacy' files (like old symlinks)"
task :cleanup do
  Dotfile.new('screenrc').delete_target(:only_symlink => true)
  Dotfile.new('pentadactylrc').delete_target(:only_symlink => true)
end

desc "Install and clean up old files"
task :update => [:install, :cleanup]

desc "Clears all symlinks"
task :clear_symlinks do
  SYMLINKS.each do |file|
    Dotfile.new(file).delete_target
  end
end

