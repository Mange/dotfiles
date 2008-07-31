      DOTFILES
====================

About this
----------
This is a git repository for my personal dotfiles, e.g. configuration files for *NIX systems. The reason I add these into a SCM is because they are getting increasingly large and I have several machines to place this files in and keep in sync.

I have this code in a open repository for other people to benefit from the code, too. No point in keeping it for yourself.

Please note that this repository is very personal, and small changes might be added all the time. If you want to use this for yourself and are not a mental clone of me, you'd want to fork this and marge back changes you like and ignore those you hate. If you have proposals for my repo, just do a pull request so I can check it out.

License
-------
Since this is basic configuration stuff, it doesn't need any license IMHO, but anyway: All files in this repository is released under a BSD license unless stated otherwise -- do whatever you want with it!

Features
--------
It's too many features to list. Most of the code is documented or obvious for anyone RTFM'ing.

The most major features included:

 * Advanced zsh configuration management
 * Advanced and extensive zsh completion configurations
 * Advanced zsh prompt designed to be useful but not clutter anything
 * Git status in zsh prompt when in a repository
 * GNU Screen "theme" with title features -- integrates into zsh prompt

Installation
------------
 * Begin by cloning this repository somewhere on your machine, for example ~/dotfiles.
 * Create a backup of the old dotfiles
     
        user@localhost ~% cp .zshrc .zshrc~
     
 * Remove the chosen dotfiles and replace them with a soft link into the repository instead:
     
        user@localhost ~% rm .zshrc
        user@localhost ~% ln -s ~/dotfiles/zshrc .zshrc 
     
 * You're done!

Credits
-------
Most of the scripts here are copied from other sources and then combined. Some of the sources:

 * _why's .screenrc (http://dotfiles.org/~why)
 * Bart's Blog (http://www.jukie.net/~bart/blog/zsh-git-prompt)

If you recognize your work here and want credit, just tell me. Some of the config is several months old, so I cannot remember each source.

All copied code comes from publicly available sources, like wikis, manuals and demonstrations on people's blogs.

