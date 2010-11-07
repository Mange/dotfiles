require 'pathname'

class Dotfile
  SYMLINKS = %w[screenrc vimrc zshprofile zshrc vim zshrc.d irbrc railsrc]
  FILES = %w[zsh-named-directories]

  def initialize(name)
    @name = name
    @home_path = File.join('~', ".#{name}")
    @source_path = Pathname.new(File.dirname(__FILE__)).join(name).expand_path
    @target_path = Pathname.new(@home_path).expand_path
  end

  def install
    if SYMLINKS.include? @name
      install_symlink
    elsif FILES.include? @name
      install_copy
    else
      raise "Unknown file #{name}"
    end
  end

  protected
    def install_symlink
      if @target_path.exist?
        if @target_path.symlink?
          puts "#{@home_path} already exists and is a symlink. Deleting it"
          @target_path.delete
        else
          puts "#{@home_path} already exists and is not a symlink. Backing up to #{@home_path}~"
          @target_path.rename(@target_path.to_s + '~')
        end
      end
      File.symlink(@source_path, @target_path)
    end

    def install_copy
      unless @target_path.exist?
        @source_path.copy(@target_path)
      else
        puts "#{@home_path} already exists. Skipping it"
      end
    end
end

Dotfile::SYMLINKS.each do |file|
  desc "Installs #{file} by symlinking it inside your home"
  task file do
    Dotfile.new(file).install
  end
end

Dotfile::FILES.each do |file|
  desc "Installs #{file} by copying it to your home"
  task file do
    Dotfile.new(file).install
  end
end

desc "Installs all files"
task :install => (Dotfile::SYMLINKS + Dotfile::FILES)

