" Vim syntax file
" Language:     Source highlighting for vimscript
" Maintainer:   Jon Suderman
" Last Change:  Sept 18, 2011
" Version:      1

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
