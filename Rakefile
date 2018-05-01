require File.expand_path('../support/dotfile', __FILE__)
require 'fileutils'

SYMLINKS = %w[
  gruvbox-colors.env
  taskrc
]

SYMLINKS.each do |file|
  desc "Installs #{file} by symlinking it inside your home"
  task file do
    Dotfile.new(file).install_symlink
  end
end

desc "Initializes/updates other repos"
task :modules do
  {
    "config/zsh/vendor/zsh-syntax-highlighting" =>
      "https://github.com/zsh-users/zsh-syntax-highlighting.git",
    "config/zsh/vendor/zsh-history-substring-search" =>
      "https://github.com/zsh-users/zsh-history-substring-search.git",
  }.each_pair do |pathname, repo|
    path = File.expand_path(pathname, File.dirname(__FILE__))
    if File.exists?(path)
      system %(cd "#{path}" && git pull --rebase > /dev/null)
    else
      system %(git clone "#{repo}" "#{path}")
    end
  end
end

desc "Installs all files"
task :install => (
  SYMLINKS + %w[
    modules
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

desc "Clears all 'legacy' files (like old symlinks)"
task :cleanup do
  Dotfile.new('zshrc.d').delete_target(only_symlink: true)
  Dotfile.new('ackrc').delete_target(only_symlink: true)
  Dotfile.new('slate.js').delete_target(only_symlink: true)
  Dotfile.new('sshrc').delete_target(only_symlink: true)
  Dotfile.new('sshrc.d').delete_target(only_symlink: true)
  Dotfile.new('xinitrc').delete_target(only_symlink: true)
  system("rm -rf zsh/k") if Dir.exists?("zsh/k")
end

desc "Install and clean up old files"
task :update => [:install, :cleanup, :vimplugs]

desc "Clears all symlinks"
task :clear_symlinks do
  SYMLINKS.each do |file|
    Dotfile.new(file).delete_target(:only_symlink => true)
  end
end

task default: :update
