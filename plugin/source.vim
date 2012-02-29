" Maintainer:   Jon Suderman
" Homepage:     https://github.com/suderman/source.vim
" License:      VIM License

if exists("g:loaded_source")
  finish
endif
let g:loaded_source = 1

" Set some variables
let s:win = has("win16") || has("win32") || has("win64")
let s:slash = !exists("+shellslash") || &shellslash ? '/' : '\'
let s:vimhome = $HOME.s:slash. ((s:win) ? 'vimfiles' : '.vim')
let s:bundledir = s:vimhome.s:slash.'bundle'

let s:auto_update = 0
let s:force_update = 0

" Supa-fly public interface or something
command! -nargs=+ -bang Source call <SID>source(<bang>0, <q-args>)
function s:source(force_update, args)
  let s:force_update = a:force_update

  let args = split(a:args, ' ')
  let url = s:resolve(remove(args, 0))
  let command = s:strip(join(args, ' '))

  " Add a bundle to the runtime path
  let installed = s:require(url)

  " If it was installed, and there's a command, do that too!
  if ((installed) && (command != ''))
    call s:command(url, command)
  endif

  let s:force_update = 0
endfunction


" Transmute url into what we REALLY want
function s:resolve(url)

  " Burninate leading/trailing whitespace
  let url = s:strip(a:url)

  " Get the repo link from any Github project page or Gist
  if ( (match(url, 'github.com')>=0) && (match(url, 'raw.github.com')<0) && (match(url, '.git$')<0) )
    let url = s:sub(url, ['^https://', '^http://'], 'git://') . '.git'
  endif

  return url
endfunction


" Add (and install) a bundle
function s:require(url)
  let installed = 0
  let path = s:path(a:url)

  " Install if necessary
  let installed = s:install(a:url)

  " Okay, run that code!
  call s:activate(path)

  return installed
endfunction


" Gimme the path to the installed resource
function s:path(url)
  let resource = s:resource(a:url)
  if (resource=='git')
    let dir = split(split(a:url, '/')[-1], '.git')[0]
  endif

  return s:bundledir.s:slash.s:name(a:url)
endfunction


" Decide what kind of resource the url is
function s:resource(url)

  if (match(a:url, '.git$')>=0)
    return 'git'
  endif
  if (match(a:url, '^http')>=0)
    return 'http'
  endif

  return 'file'
endfunction


" Returns the repo name from a URL
function s:name(url)
  let resource = s:resource(a:url)

  if (resource=='git')
    let prefix = (match(a:url, 'gist.github.com', '')>=0) ? 'gist-' : ''
    let name = prefix . split(split(a:url, '/')[-1], '\.git')[0]
  endif

  if (resource=='http')
    let name = split(a:url, '//')[1]
    let name = s:sub(name, ['/','\',':','~'], '-')
  endif

  if (resource=='file')
    let name = s:sub(a:url, ['/','\',':','~'], '-')
  endif

  return name
endfunction


" Install
function s:install(url)
  let path = s:path(a:url)
  let resource = s:resource(a:url)

  if glob(path.s:slash.'*') == ''

    if (resource=='git')
      call s:notify("Cloning ".a:url)
      call system('git clone '.a:url.' '.path)
    endif

    if (resource=='http')
      call s:notify("Downloading ".a:url)
      let vimscript = substitute(split(a:url, '/')[-1], '.vim$', '', '').'.vim'
      let command = 'mkdir -p '.path.';'
                 \. 'curl -o '.path.s:slash.vimscript.' '.a:url
      call system(command)
    endif

    return 1
  endif

  if (s:auto_update) || (s:force_update)

    if (resource=='git')
      call s:notify("Pulling ".a:url)
      let output = system('cd '.path.';git pull')
      call s:notify(output)
    endif

    if (resource=='http')
      call s:notify("Re-downloading ".a:url)
      let vimscript = substitute(split(a:url, '/')[-1], '.vim$', '', '').'.vim'
      let command = 'rm -rf '.path.'.backup;'
                 \. 'mv '.path.' '.path.'.backup;'
                 \. 'mkdir -p '.path.';'
                 \. 'curl -o '.path.s:slash.vimscript.' '.a:url
      call system(command)
    endif

    return 1
  endif

  return 0
endfunction



" Run any commands the plugin requires
function s:command(url, command)
  let command = 'cd '.s:path(a:url).';'
             \. a:command
  call s:notify(command)
  call system(command)
endfunction


" Activate
function s:activate(path)

  if s:is_plugin(a:path)

    " Add bundle to runtime path
    let paths = s:split(&rtp)
    if index(paths, a:path) == -1
      let paths = insert(paths, a:path)
    endif
    let &rtp = s:join(paths)

    " If vim has already started, also source any scripts
    if (has('vim_starting')<=0)
      call s:gsource(a:path.s:slash.'plugin'.s:slash.'**'.s:slash.'*.vim')
      call s:gsource(a:path.s:slash.'autoload'.s:slash.'**'.s:slash.'*.vim')
    endif

  " If this aint no stinkin plugin, just load any scripts inside
  else
    call s:gsource(a:path.s:slash.'**'.s:slash.'*.vim')
  endif

endfunction


" Detect if this is a plugin or just a script
function s:is_plugin(path)

  " Look for directories that resemeble a plugin
  let dirs = ['after','autoload','color','ftplugin','plugin','syntax']
  for dir in dirs
    if glob(a:path.s:slash.dir.s:slash.'*') != ''
      return 1
    endif
  endfor

  " Nothing? I guess this isn't a plugin, but just a script in a folder!
  return 0
endfunction


" Check if it's time for auto updates (TODO: less shell, more vimscript)
" Obviously much of this is taken from oh-my-zsh update system!
function s:automatic_updates()

  " Determine current epoch
  let current_epoch = system('echo $(($(date +%s) / 60 / 60 / 24))')

  " Pull the last epoch from the filesystem
  let last_epoch = system('cat '.s:vimhome.s:slash.'last_epoch.txt')

  " Check if the last_epoch is older than 6 days from the current_epoch
  if (current_epoch - last_epoch) > 6

    " Enable auto_update
    let s:auto_update = 1

    " Update the last_epoch file
    call system('echo "'.current_epoch.'" > '.s:vimhome.s:slash.'last_epoch.txt')

  endif
endfunction

" -----------------------------
"  SOME HELPFUL HELPER METHODS
" -----------------------------

" l337 notifcation system
function s:notify(string)
  echo "[source.vim] ".a:string
endfunction


" Source anything in the path ie: ~/.vim/bundle/*.vim function s:gsource(path)
function s:gsource(path)
  for file in split(glob(a:path),"\n")
    exec 'silent! source '.fnameescape(file)
  endfor
endfunction

" Mighty multi-pattern subtitution!
function s:sub(string, patterns, substitution)
  let string = a:string
  let patterns = (type(a:patterns) == type("")) ? [a:patterns] : a:patterns
  for pattern in patterns
    if (pattern == '~')
      let pattern = '\'.pattern
    endif
    let string = substitute(string, pattern, a:substitution, 'g')
  endfor
  return string
endfunction


" Burninate leading/trailing whitespace
function s:strip(string)
  return substitute(a:string, '^\s*\(.\{-}\)\s*$', '\1', '')
endfunction


" Tim Pope's brilliance - split a path into a list
function s:split(path)
  if type(a:path) == type([]) | return a:path | endif
  let split = split(a:path,'\\\@<!\%(\\\\\)*\zs,')
  return map(split,'substitute(v:val,''\\\([\\,]\)'',''\1'',"g")')
endfunction


" Tim Pope's brilliance - convert a list to a path
function s:join(...)
  if type(a:1) == type(1) && a:1
    let i = 1
    let space = ' '
  else
    let i = 0
    let space = ''
  endif
  let path = ""
  while i < a:0
    if type(a:000[i]) == type([])
      let list = a:000[i]
      let j = 0
      while j < len(list)
        let escaped = substitute(list[j],'[,'.space.']\|\\[\,'.space.']\@=','\\&','g')
        let path .= ',' . escaped
        let j += 1
      endwhile
    else
      let path .= "," . a:000[i]
    endif
    let i += 1
  endwhile
  return substitute(path,'^,','','')
endfunction


" Check for automatic updates when script is loaded
call s:automatic_updates()

augroup source.vim
  autocmd!

  " Make sure autoupdates aren't called after the vimrc is loaded
  autocmd VimEnter * let s:auto_update = 0

  " Highlight Source properly 
  autocmd BufEnter {.vimrc,vimrc,.gvimrc,gvimrc,*.vim} call <SID>SourceSyntax()

augroup END


" --------------------------------------------------------
"  SYNTAX MOVED HERE TO KEEP IT ALL IN ONE BEAUTIFUL FILE
" --------------------------------------------------------
" Moved from ~/.vim/after/syntax/vim/source.vim
function! s:SourceSyntax()

  syn region sourceName	start=/^runtime / end=/\n/ contains=sourceURL
  syn region sourceName	start=/^ru / end=/\n/ contains=sourceURL
  syn region sourceName	start=/^runtime! / end=/\n/ contains=sourceURL
  syn region sourceName	start=/^ru! / end=/\n/ contains=sourceURL

  syn region sourceName	start=/^source / end=/\n/ contains=sourceURL
  syn region sourceName	start=/^so / end=/\n/ contains=sourceURL
  syn region sourceName	start=/^source! / end=/\n/ contains=sourceURL
  syn region sourceName	start=/^so! / end=/\n/ contains=sourceURL

  syn region sourceName	start=/^Source / end=/\n/ contains=sourceURL
  syn region sourceName	start=/^So / end=/\n/ contains=sourceURL
  syn region sourceName	start=/^Source! / end=/\n/ contains=sourceURL
  syn region sourceName	start=/^So! / end=/\n/ contains=sourceURL

  syn match sourceURL	contained "\s\S\+"

  highlight link sourceName Keyword
  highlight link sourceURL String

endfunction
