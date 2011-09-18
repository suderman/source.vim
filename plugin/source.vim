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

" I'm going to change this. This is, like, so unneccessary
function s:encode(string)
  let l:string = substitute(a:string, ":\/\/", "!", "g") 
  let l:string = substitute(l:string, ":", ";", "g")
  " return (s:win) ? substitute(l:string, "\/", "#", "g") : l:string 
  return substitute(l:string, "\/", "#", "g")
endfunction

" Definitely don't need this
function s:decode(string)
  let l:string = substitute(a:string, "#", "/", "g") 
  let l:string = substitute(l:string, ";", ":", "g")
  return substitute(l:string, "!", "://", "g") 
endfunction

" l337 notifcation system
function s:notify(message)
  echo "source.vim => ".a:message
endfunction

" Gimme the path to the bundle
function s:path(url)
  return s:bundledir.s:slash.s:encode(a:url)
endfunction

function s:install(url)
  call s:notify("Plugin not found. Downloading ".a:url)
  call system('git clone '.a:url.' '.s:path(a:url))
  return 1
endfunction

" Add (and install) a bundle
function s:add(url)
  let l:installed = 0
  let l:paths = s:split(&rtp)
  let l:path = s:path(a:url)

  " Install if necessary
  if glob(l:path.s:slash.'*') == ''
    let l:installed = s:install(a:url)
  endif

  " Add bundle to runtime path
  if index(l:paths, l:path) == -1
    call s:notify("Adding plugin to path - ".a:url)
    let l:paths = insert(l:paths, l:path)
  endif

  let &rtp = s:join(l:paths)
  return l:installed
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


" Supa-fly public interface or something
function s:source(args)
  let l:args = split(a:args, ' ')
  let l:url = remove(l:args, 0)
  let l:command = substitute(join(l:args, ' '), '^\s*\(.\{-}\)\s*$', '\1', '')
  
  " Add a bundle to the runtime path
  let l:installed = s:add(l:url)

  " If it was installed, and there's a command, do that too!
  if ((l:installed) && (l:command != ''))
    call s:command(l:url, l:command)
  endif

endfunction

command! -nargs=+ Source call s:source(<q-args>)
