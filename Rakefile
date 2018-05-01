require File.expand_path('../support/dotfile', __FILE__)
require 'fileutils'

desc "Installs all files"
task :install do
  if ENV['SHELL'] !~ /zsh/
    STDERR.puts "Warning: You seem to be using a shell different from zsh (#{ENV['SHELL']})"
    STDERR.puts "Fix this by running:"
    STDERR.puts "  chsh -s `which zsh`"
  end
end

desc "Install and clean up old files"
task :update => [:install]

task default: :update
