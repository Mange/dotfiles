require 'pathname'

SYMLINKS = %w[screenrc vimrc zshprofile zshrc vim zshrc.d irbrc railsrc]
FILES = %w[zsh-named-directories]

SYMLINKS.each do |file|
  desc "Installs #{file} by symlinking it inside your home"
  task file do
    symlink_to_home file
  end
end

FILES.each do |file|
  desc "Installs #{file} by copying it to your home"
  task file do
    copy_to_home file
  end
end

desc "Installs all files"
task :install => (SYMLINKS + FILES)

def target_path(file)
  Pathname.new('~').join(".#{file}").expand_path
end

def source_path(file)
  Pathname.new(File.dirname(__FILE__)).join(file).expand_path
end

def symlink_to_home(file)
  source = source_path(file)
  destination = target_path(file)
  if destination.exist?
    if destination.symlink?
      puts "#{destination} already exists and is a symlink. Deleting it"
      destination.delete
    else
      puts "#{destination} already exists and is not a symlink. Backing up to #{destination.to_s + '~'}"
      destination.rename(destination.to_s + '~')
    end
  end
  File.symlink(source, destination)
end

def copy_to_home(file)
  source = source_path(file)
  destination = target_path(file)

  unless destination.exist?
    source.copy(destination)
  else
    puts "#{destination} already exists. Skipping it"
  end
end
