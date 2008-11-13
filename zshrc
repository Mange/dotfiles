#!/bin/zsh

setopt extendedglob

# Source /etc/profile if /etc/zprofile does not exist
if [ ! -e /etc/zprofile ]; then
    source /etc/profile
fi

for zshrc_file in ~/.zshrc.d/S[0-9][0-9]*[^~] ; do
     source $zshrc_file
done

