require 'support/dotfile'
require 'fileutils'

SYMLINKS = %w[vimrc zshprofile zshrc zshrc.d irbrc railsrc ackrc tmux.conf]
FILES = %w[zsh-named-directories]

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
  `git config --global core.excludesfile "$HOME/.gitignore"`
end

desc "Makes sure that the submodules are all initialized and up-to-date"
task :submodules do
  `git submodule update --init`
end

desc "Installs vim config"
task :vim => :submodules do
  Dotfile.new('vim').install_symlink
end

desc "Installs all files"
task :install => (SYMLINKS + FILES + [:vim, :gitignore])

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

