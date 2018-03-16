require 'pathname'
require 'fileutils'

class Dotfile
  attr_reader :name, :source
  attr_writer :home_path

  def initialize(name, source = name)
    @name = name
    @source = source
  end

  def install_symlink
    if clear_target_path
      File.symlink(source_path.relative_path_from(target_path.dirname), target_path)
    end
  end

  def install_copy
    unless target_path.exist?
      FileUtils.copy source_path, target_path
    else
      puts "#{home_path} already exists. Skipping it"
    end
  end

  def delete_target(options = {})
    should_delete_files = !options[:only_symlink]
    target_path.delete if target_path.symlink? or (target_path.exist? and should_delete_files)
  end

  def target_path
    @target_path ||= Pathname.new(home_path).expand_path
  end

  def source_path
    @source_path ||= Pathname.new(File.expand_path("../../#{source}", __FILE__))
  end

  def home_path
    @home_path ||= File.join('~', ".#{name}")
  end

  protected
  def clear_target_path
    # Broken symlinks does not exist, so test for presence of a symlink as well
    present = (target_path.exist? || target_path.symlink?)
    if present and not target_is_symlink_to_source?
      puts "#{home_path} already exists. Backing up to #{home_path}~"
      backup_target
      true
    else
      not present
    end
  end

  def backup_target
    File.delete(target_path.to_s + '~') rescue nil
    target_path.rename(target_path.to_s + '~')
  end

  def target_is_symlink_to_source?
    target_path.realpath == source_path.realpath
  rescue Errno::ENOENT
    false
  end
end

