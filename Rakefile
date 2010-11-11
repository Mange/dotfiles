require 'support/dotfile'

SYMLINKS = %w[screenrc vimrc zshprofile zshrc vim zshrc.d irbrc railsrc]
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

desc "Installs all files"
task :install => (SYMLINKS + FILES)

desc "Clears all symlinks"
task :clear_symlinks do
  SYMLINKS.each do |file|
    Dotfile.new(file).delete_target
  end
end

