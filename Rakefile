require File.expand_path('../support/dotfile', __FILE__)
require File.expand_path('../support/binary', __FILE__)
require 'fileutils'

SYMLINKS = %w[
  Xmodmap
  Xresources.d
  git_template
  gruvbox-colors.env
  railsrc
  rspec
  taskrc
  wallpapers
  xprofile
]

FILES = []

BINARIES = Dir.glob(
  File.expand_path("../bin/*", __FILE__)
).select { |path| File.file?(path) }.map { |path| File.basename(path) }

SYMLINKS.each do |file|
  desc "Installs #{file} by symlinking it inside your home"
  task file do
    Dotfile.new(file).install_symlink
  end
end

desc "Installs all binaries"
task :bins

BINARIES.each do |file|
  desc "Installs #{file} binary by symlinking it to your home's bin directory"
  task "bin/#{file}" => :bin do
    Binary.new(file).install_symlink
  end

  task :bins => "bin/#{file}"
end

FILES.each do |file|
  desc "Installs #{file} by copying it to your home"
  task file do
    Dotfile.new(file).install_copy
  end
end

desc "Creates your bin directory if not present"
task :bin do
  bin_path = File.join(Dir.home, "bin")
  unless File.directory? bin_path
    Dir.mkdir(bin_path, 0750)
  end
end

desc "Installs the global gitignore file"
task :gitignore do
  Dotfile.new('gitignore').install_symlink
  unless system('git config --global core.excludesfile "$HOME/.gitignore"')
    STDERR.puts "Could not set git excludesfile. Continuing..."
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

desc "Does some basic Git setup"
task :gitconfig do
  exec = lambda { |command| system(*command) or STDERR.puts "Command failed: #{command.join(' ')}" }
  config = lambda { |*args| exec[['git', 'config', '--global', *args]] }

  config["push.default", "tracking"]
  config["color.ui", "true"]

  config["user.name", "Magnus Bergmark"]
  config["user.email", "magnus.bergmark@gmail.com"]
  config["user.signingkey", "4D8E0309"]
  config["github.user", "Mange"]

  config["color.branch.current", "bold green"]
  config["color.branch.local", "green"]
  config["color.branch.remote", "blue"]

  config["diff.compactionHeuristic", "true"]
  config["diff.colorMoved", "zebra"]

  # For diff-highlight / diff-so-fancy
  config["color.diff-highlight.oldNormal", "red bold"]
  config["color.diff-highlight.oldHighlight", "red bold 52"]
  config["color.diff-highlight.newNormal", "green bold"]
  config["color.diff-highlight.newHighlight", "green bold 22"]
  config["pager.show", "diff-so-fancy | less --tabs=4 -RXin"]
  config["pager.diff", "diff-so-fancy | less --tabs=4 -RXin"]
  config["--unset", "interactive.diffFilter"]

  config["commit.gpgsign", "true"]

  # It's nice in theory, but too many scripts break with this on.
  config["log.showSignature", "false"]

  config["merge.conflictstyle", "diff3"]
  config["merge.tool", "vimdiff"]

  config["rebase.autosquash", "true"]
  config["rebase.stat", "true"]

  config["init.templatedir", "~/.git_template"]

  # Aliases
  config["alias.new", %(!sh -c 'git log $1@{1}..$1@{0} "$@"')]
  config["alias.prune", %(!git remote | xargs -n 1 git remote prune)]
end

desc "Installs font config"
task :fontconfig do
  xdg_home = ENV.fetch('XDG_HOME', '~/.config')
  dotfile = Dotfile.new("90-fallbacks.conf", "fonts/90-fallbacks.conf")
  dotfile.home_path = File.join(xdg_home, "fontconfig", "conf.d", dotfile.name)
  dotfile.install_symlink
  system("fc-cache")
end

desc "Installs all files"
task :install => (
  SYMLINKS + FILES + %w[
    bins
    fontconfig
    gitconfig
    gitignore
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
