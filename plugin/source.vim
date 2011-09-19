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


" Supa-fly public interface or something
command! -nargs=+ Source call <SID>source(<q-args>)
function s:source(args)

  let args = split(a:args, ' ')
  let url = remove(args, 0)
  let command = substitute(join(args, ' '), '^\s*\(.\{-}\)\s*$', '\1', '')

  " Add a bundle to the runtime path
  let installed = s:require(url)

  " If it was installed, and there's a command, do that too!
  if ((installed) && (command != ''))
    call s:command(url, command)
  endif

endfunction


" raw.github.com-suderman-source.vim-master-plugin-source.vim

" l337 notifcation system
function s:notify(message)
  echo "[source.vim] ".a:message
endfunction

" Burninate leading/trailing whitespace
function s:strip(string)
  return substitute(a:string, '^\s*\(.\{-}\)\s*$', '\1', '')
endfunction

" Decide what variety of url is
function s:type(url)
  let url = s:strip(a:url)

  if (match(url, '.git$')>=0)
    return 'git'
  endif

  if (match(url, '^http')>=0)
    return 'http'
  endif

  return 'file'
endfunction

" Returns the repo name from a URL
function s:name(url)
  let type = s:type(a:url)

  if (type=='git')
    return split(split(a:url, '/')[-1], '.git')[0]
  endif

endfunction

" Gimme the path to the bundle
function s:path(url)
  return s:bundledir.s:slash.s:name(a:url)
endfunction

function s:install(url)
  call s:notify("Downloading plugin - ".a:url)
  call system('git clone '.a:url.' '.s:path(a:url))
  return 1
endfunction

" Source anything in the path ie: ~/.vim/bundle/*.vim
function s:source_path(path)
  for file in split(glob(a:path),"\n")
    exec 'silent! source '.fnameescape(file)
  endfor
endfunction

" Add (and install) a bundle
function s:require(url)
  let installed = 0
  let paths = s:split(&rtp)
  let path = s:path(a:url)

  " Install if necessary
  if glob(path.s:slash.'*') == ''
    let installed = s:install(a:url)
  endif

  " Add bundle to runtime path
  if index(paths, path) == -1
    let paths = insert(paths, path)
  endif

  let &rtp = s:join(paths)
  return installed
endfunction

function s:command(url, command)
  call system('cd '.s:path(a:url))
  call system(a:command)
  call system('cd -')
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


