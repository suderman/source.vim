source.vim
==========

Super-fast install!

  `git clone git://github.com/suderman/source.vim.git`  
  `cp source.vim/plugin/source.vim ~/.vim/plugin/source.vim`  

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

Coming Soon...
--------------
- Forced updates when calling Source! (with a bang)
- Automatic weekly updates (oh-my-zsh style) would be nice!
