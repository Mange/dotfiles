require File.expand_path('../dotfile', __FILE__)

class Binary < Dotfile
  def source_path
    @source_path ||= Pathname.new(File.expand_path("../../bin/#{name}", __FILE__))
  end

  def home_path
    @home_path ||= File.join('~', 'bin', name)
  end
end
