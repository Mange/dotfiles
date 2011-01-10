require 'pathname'
require 'fileutils'

class Dotfile
  def initialize(name)
    @name = name
  end

  def install_symlink
    if target_path.exist? or target_path.symlink?
      return if target_is_symlink_to_source?
      puts "#{home_path} already exists. Backing up to #{home_path}~"
      File.delete(target_path.to_s + '~') rescue nil
      target_path.rename(target_path.to_s + '~')
    end
    File.symlink(source_path.relative_path_from(target_path.dirname), target_path)
  end

  def install_copy
    unless target_path.exist?
      FileUtils.copy source_path, target_path
    else
      puts "#{home_path} already exists. Skipping it"
    end
  end

  def delete_target(options = {})
    target_path.delete if target_path.symlink? or (not options[:only_symlink] and target_path.exist?)
  end

  protected
   attr_reader :name

   def target_path
     @target_path ||= Pathname.new(home_path).expand_path
   end

   def source_path
     @source_path ||= Pathname.new(File.expand_path("../../#{name}", __FILE__))
   end

   def home_path
     @home_path ||= File.join('~', ".#{name}")
   end

   def target_is_symlink_to_source?
     target_path.symlink? and target_path.realpath == source_path.realpath
   rescue Errno::ENOENT
     false
   end
end

