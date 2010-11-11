require 'pathname'

class Dotfile
  def initialize(name)
    @name = name
    @home_path = File.join('~', ".#{name}")
    @target_path = Pathname.new(@home_path).expand_path
    @source_path = Pathname.new(File.dirname(__FILE__)).join('..', name).expand_path
  end

  def install_symlink
    if @target_path.exist? or @target_path.symlink?
      return if target_is_symlink_to_source?
      puts "#{@home_path} already exists. Backing up to #{@home_path}~"
      File.delete(@target_path.to_s + '~') rescue nil
      @target_path.rename(@target_path.to_s + '~')
    end
    File.symlink(@source_path.relative_path_from(@target_path.dirname), @target_path)
  end

  def install_copy
    unless @target_path.exist?
      @source_path.copy(@target_path)
    else
      puts "#{@home_path} already exists. Skipping it"
    end
  end

  def delete_target
    @target_path.delete if @target_path.symlink? or @target_path.exist?
  end

  protected
   def target_is_symlink_to_source?
     @target_path.symlink? and @target_path.realpath == @source_path.realpath
   rescue Errno::ENOENT
     false
   end
end

