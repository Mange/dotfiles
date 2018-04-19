#!/usr/bin/env ruby

require 'irb/completion'
require 'irb/ext/save-history'

IRB.conf[:SAVE_HISTORY] = 1000
IRB.conf[:HISTORY_FILE] = "#{ENV['HOME']}/.irb_history"
IRB.conf[:EVAL_HISTORY] = 20

IRB.conf[:AUTO_INDENT] = true

require 'pp'

%w[rubygems wirble looksee/shortcuts].each do |gem|
  begin
    require gem
  rescue LoadError
  end
end

if defined? Wirble
  Wirble.init
  Wirble.colorize
end

module ShellEmulation
  def ls
    `ls`.split("\n")
  end

  def cd(path)
    Dir.chdir(path)
    Dir.pwd
  end

  def pwd
    Dir.pwd
  end
  alias cwd pwd

  def cat(path)
    puts File.read(path)
  end
end

class Object
  include ShellEmulation
  def cool_methods(matcher = nil)
    messages = (methods - Object.methods).sort
    if matcher
      messages.grep matcher
    else
      messages
    end
  end

  def my_methods(matcher = nil)
    messages = (self.methods - self.class.superclass.instance_methods).sort
    if matcher
      messages.grep matcher
    else
      messages
    end
  end
end

require File.join(File.dirname(__FILE__), '.railsrc') if $0 == 'irb' and ENV['RAILS_ENV']
