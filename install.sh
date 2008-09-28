#!/bin/zsh
#
# Installs the chosen files, automatically if specified as parameters or 
# interactivly if started without parameters.
#
# Parameters:
# --help     : Displays usage
# [file/dir] : Install this file
#
#

target_dir="$HOME"

loadcolors() {
  # If zsh is used and colors have been loaded, we will now get
  # variables containing colors instead of just empty vars
  autoload colors
  colors
  
    file_color="$fg_bold[blue]"
      ok_color="$fg_bold[green]"
  cancel_color="$fg_bold[yellow]"
   error_color="$fg_bold[red]"
   #reset_color=" Already defined by 'colors'! :-) "
}

usage() {
  echo "install.sh -- Installs the chosen dotfiles."
  echo "If no parameter is specified, the script will enter interactive"
  echo "mode and let you choose from there."
  echo
  echo "Parameters:"
  echo "${file_color}install.sh${reset_color} ( [${file_color}--help${reset_color}] | [${file_color}FILE${reset_color}] [${file_color}FILE2${reset_color}] [${file_color}FILE${reset_color}n] ... )"
  echo "\t${file_color}--help${reset_color}\t\tDisplay this uasage"
  echo "\t${file_color}FILE${reset_color}\t\tInstall the file"
  echo "\t\t\tThe script will look for the file inside this directory."
}

# Check the working directory to see if "install.sh" is there -- hopefully, 
# this will mean that we started the file from the current working directory.
checkdirectory() {
  if [[ -f ./install.sh ]]; then
    return 0
  else
    echo "${error_color}Could not find ${file_color}install.sh${error_color} in current working directory. Make sure you're"
    echo "actually inside the directory where this file is located."
    echo "If you want to skip this warning, just press return. If you are unsure"
    echo "just press ^C (CTRL-C) to abort the script.${reset_color}"
    read
  fi
}

gendoc() {
  local command
  command="markdown.pl README.markdown > README.html"
  
  if [[ $command == 0 ]]; then
    echo "${ok_color}Generated README successfully and saved it as README.html${reset_color}"
  else
    echo "${error_color}Could not generate ${file_color}README.html${error_color} from ${file_color}README.markdown${error_color}; make sure you have ${file_color}markdown.pl${error_color} installed."
    echo "NOTE: You can actually read ${file_color}README.markdown${error_color} in any ASCII reader -- it's plaintext.${reset_color}"
  fi
}

copyfile() {
  local target
  target="$target_dir/.$1"
  
  if [[ -f "$target" ]]; then
    echo "${cancel_color}Backing up ${file_color}$target${cancel_color} as ${file_color}$target~${reset_color}"
    mv "$target" "$target~"
  fi
  
  echo "${ok_color}Copying ${file_color}$1${ok_color} to ${file_color}$target${reset_color}"
  cp "$1" "$target"
}

linkfile() {
  local target source
  target="$target_dir/.$1"
  
  # The ln(1) command will save the relative
  # path when created, not resolve said path and
  # save the absolute one instead. We must
  # therefore find the absolute path of the
  # file. This is a bad and hackish soloution, but
  # it will probably work...
  source="$(pwd)/$1"
  
  if [[ -e "$target" ]]; then
    echo "${cancel_color}Backing up ${file_color}$target${cancel_color} as ${file_color}$target~${reset_color}"
    mv "$target" "$target~"
  fi
  echo "${ok_color}Soft-linking ${file_color}$target${ok_color} to ${file_color}$1${reset_color}"
  ln -s "$source" "$target"
}

# Do the appropriate action on the parameter specified
# 0. Check for any reserved "keyword" like "--help"
# 1. Check if it's a existing file
# 2. Check if we have any action for it
# 3. Do the action
useparam() {

  case "$1" in
    --help) 
        usage
        exit 0
    ;;
  esac
  
  # Check for existing file/dir
  if [[ -e $1 ]]; then
  
    # Do we have any action associated with it?
    case $1 in
      README.markdown)
        gendoc
      ;;
              
      README.html) 
        echo "${file_ok}Skipping README.html${reset_color}"
      ;;
              
      zsh-named-directories) 
        copyfile "zsh-named-directories"
      ;;
              
#      zshrc.d)
#       copyfile "zshrc.d"
#     ;;
              
      *) 
        linkfile "$1" 
      ;;
    esac
    
  else
  
    echo "${error_color}Could not find $p"
    echo "Just to be sure not to screw up anything, I will now abort :-(${reset_color}"
    exit 1
  
  fi
}

# Go into interactive mode. Loop through each file and ask the user if he wants to install them
interactive() {
  local answer
  echo "Target directory: ${file_color}$target_dir${reset_color}"
  
  for file in *; do
    
    # skip everything having to do with this script, readmes or backups
    if [[ $file != *install* && $file != README* && $file != *~ ]]; then
      echo -n "Do you want to install ${file_color}$file${reset_color} to ${file_color}$target_dir/.$file${reset_color}? (${ok_color}y${reset_color}/${error_color}N${reset_color}) "
      
      read answer
      if [[ $answer = y* ]]; then
        useparam $file
      else
        echo "${cancel_color}Skipping file...${reset_color}"
      fi
      
      # Empty line to make it more readable
      echo
    fi
    
    
    
  done
}

#
# Loop through each parameter and run the right action on it!
#
loadcolors
if [[ ${#} == 0 ]]; then
  interactive
else
  for p in $@; do
    useparam "$p"
  done
fi
