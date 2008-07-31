#!/bin/zsh

setopt extendedglob

for zshrc_file in ~/.zshrc.d/S[0-9][0-9]*[^~] ; do
     source $zshrc_file
done

