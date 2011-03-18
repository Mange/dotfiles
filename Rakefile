require 'support/dotfile'
require 'fileutils'

SYMLINKS = %w[vimrc zshprofile zshrc zshrc.d irbrc railsrc ackrc tmux.conf]
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

desc "Makes sure that the submodules are all initialized and up-to-date"
task :submodules do
  unless system('git submodule update --init')
    STDERR.puts "Could not update vim submodules. Continuing..."
  end
end

desc "Installs vim config"
task :vim => :submodules do
  Dotfile.new('vim').install_symlink
end

desc "Creates a blank .zsh directory"
task :zsh do
  `mkdir -p ~/.zsh`
end

desc "Installs all files"
task :install => (SYMLINKS + FILES + %w[gitignore zsh vim])

desc "Clears all 'legacy' files (like old symlinks)"
task :cleanup do
  Dotfile.new('screenrc').delete_target(:only_symlink => true)
end

desc "Install and clean up old files"
task :update => [:install, :cleanup]

desc "Clears all symlinks"
task :clear_symlinks do
  SYMLINKS.each do |file|
    Dotfile.new(file).delete_target
  end
end

