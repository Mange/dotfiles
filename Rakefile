require 'support/dotfile'
require 'fileutils'

SYMLINKS = %w[screenrc vimrc zshprofile zshrc zshrc.d irbrc railsrc]
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

desc "Makes sure that the submodules are all initialized and up-to-date"
task :submodules do
  `git submodules update --init`
end

desc "Installs vim config"
task :vim => :submodules do
  Dotfile.new('vim').install_symlink
end

desc "Installs all files"
task :install => (SYMLINKS + FILES + [:vim])

desc "Clears all symlinks"
task :clear_symlinks do
  SYMLINKS.each do |file|
    Dotfile.new(file).delete_target
  end
end

