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
  let string = substitute(a:string, ":\/\/", "!", "g") 
  let string = substitute(string, ":", ";", "g")
  " return (s:win) ? substitute(string, "\/", "#", "g") : string 
  return substitute(string, "\/", "#", "g")
endfunction

" Definitely don't need this
function s:decode(string)
  let string = substitute(a:string, "#", "/", "g") 
  let string = substitute(string, ";", ":", "g")
  return substitute(string, "!", "://", "g") 
endfunction

" l337 notifcation system
function s:notify(message)
  echo "source.vim => ".a:message
endfunction

" Returns the repo name from a git URL
function s:name(url)
  return split(split(a:url, '/')[-1], '.git')[0]
endfunction

" Gimme the path to the bundle
function s:path(url)
  return s:bundledir.s:slash.s:name(a:url)
endfunction

function s:install(url)
  call s:notify("Plugin not found. Downloading ".a:url)
  call system('git clone '.a:url.' '.s:path(a:url))
  return 1
endfunction

" Source anything in the path ie: ~/.vim/bundle/*.vim
" function s:source_path(path)
"   let l:listing = system('ls -1Ap '. a:path .' | grep -v /\$')
"   let l:files = split(l:listing, '\n')
"   for l:file in l:files
"     exec 'silent! source ' . l:file
"   endfor
" endfunction


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
    call s:notify("Adding plugin to path - ".a:url)
    let paths = insert(paths, path)
    call s:notify(path.s:slash.'plugin'.s:slash.'*.vim')
    " call s:source_path(l:path.s:slash.'plugin'.s:slash.'*.vim')
    " call s:source_path(l:path.s:slash.'after'.s:slash.'*.vim')
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


" Supa-fly public interface or something
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

command! -nargs=+ Source call s:source(<q-args>)
