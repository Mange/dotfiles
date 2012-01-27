# Set PATH to be a bit more intelligent on Macs, etc.
function use_path() {
  if [[ -d $1 ]]; then
    if [[ $2 == "front" ]]; then
      export PATH="$1:$PATH"
    else
      export PATH="$PATH:$1"
    fi
  fi
}

# Give me admin tools in path
use_path /sbin
use_path /usr/sbin
use_path /usr/local/sbin

# This isn't standard on Mac. Wow...
use_path /usr/local/bin front

# Custom packages at the front
for dir in /opt/*/bin(/N); do
  use_path "$dir" front
done

# GNU coreutils, findutils, etc. on Mac
# This is the place where the original commands are placed; bins in /opt/local/bin are all named with a 'g' prefix
use_path /opt/local/libexec/gnubin front

# Personal stuff
use_path ~/bin front

unset use_path

# Login shells should still get a hold of rvm
if [[ $PS1 == "" ]]; then
  source $HOME/.zshrc.d/S99-rvm
fi
