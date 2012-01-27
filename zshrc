#!/bin/zsh

setopt extendedglob

for file in ~/.zshrc.d/S*[^~] ; do
     source $file
done

