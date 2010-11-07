require 'pathname'

class Dotfile
  def initialize(name)
    @name = name
    @home_path = File.join('~', ".#{name}")
    @source_path = Pathname.new(File.dirname(__FILE__)).join('..', name).expand_path
    @target_path = Pathname.new(@home_path).expand_path
  end

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

