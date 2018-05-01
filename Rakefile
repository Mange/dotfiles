require File.expand_path('../support/dotfile', __FILE__)
require 'fileutils'

desc "Installs all files"
task :install => (
  %w[
    vimplug
  ]
) do
  if ENV['SHELL'] !~ /zsh/
    STDERR.puts "Warning: You seem to be using a shell different from zsh (#{ENV['SHELL']})"
    STDERR.puts "Fix this by running:"
    STDERR.puts "  chsh -s `which zsh`"
  end
end

desc "Install vim-plug"
task :vimplug do
  xdg_data_home = ENV.fetch('XDG_DATA_HOME', '~/.local/share')
  output_filename = File.join(xdg_data_home, "nvim/site/autoload/plug.vim")

  unless File.exist?(output_filename)
    system(
      "curl --create-dirs --silent --fail --location --output \"#{output_filename}\" " \
        "https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim"
    )
  end
end

desc "Install plugs in vim"
task :vimplugs => :vimplug do
  system("${VISUAL:-${EDITOR:-nvim}} -u ${XDG_CONFIG_HOME}/nvim/plugs.vim +PlugInstall +qa")
end

desc "Install and clean up old files"
task :update => [:install, :vimplugs]

task default: :update
