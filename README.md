source.vim
==========

Super-fast install!

  `git clone git://github.com/suderman/source.vim.git`  
  `cp source.vim/plugin/source.vim ~/.vim/plugin/source.vim`  

Start your .vimrc with this:

  `runtime plugin/source.vim`

Usage
-----
Use in a similar fashion as the built-in `source` command:

  `Source git://github.com/mileszs/ack.vim.git`  
  `Source git://gist.github.com/1229444.git`  
  `Source https://raw.github.com/gist/1229444/6d07d825fa99a26d2dcc0fd83e9a8b1c78978bfa/statusline-help.vim`  

If sourcing a repository on Github, you can source the project page instead:

  `Source https://github.com/mileszs/ack.vim`  
  `Source https://gist.github.com/1229444`  

If installing a plugin requires a few commands, add them after the repository:

  `Source git://git.wincent.com/command-t.git rake make`  

Automatic updates occur once a week when starting Vim. This will git
pull any repositories and re-download any other files. You can force an
update calling the Source command with a bang.

  `Source! https://github.com/mileszs/ack.vim`

Requirements
------------
Several system commands are assumed available (echo, cat, cd, mkdir, rm, mv). 
Also, if sourcing a git repository, the git command is used. And if sourcing 
a text file over HTTP, the curl command is used. 

So far, I've only really tested this with OS X 10.8.

Things to do...
--------------
- Make this work on other platforms (Windows, Linux)
