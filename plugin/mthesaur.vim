" MThesaur Vim Plugin
" Author: Woland
"
" This plugin provides thesaurus functionality
" using a local mthesaur.txt file via a standalone
" Go binary for fast lookups.

if exists("g:loaded_mthesaur")
    finish
endif
let g:loaded_mthesaur = 1

let s:save_cpo = &cpo
set cpo&vim

if !exists("g:mthesaur_binary")
    " Try to find the binary in common locations
    let s:plugin_dir = expand('<sfile>:p:h:h')
    let s:build_binary = s:plugin_dir . '/build/mthesaur'
    let s:root_binary = s:plugin_dir . '/mthesaur'
    
    if executable(s:build_binary)
        let g:mthesaur_binary = s:build_binary
    elseif executable(s:root_binary)
        let g:mthesaur_binary = s:root_binary
    elseif executable('mthesaur')
        let g:mthesaur_binary = 'mthesaur'
    else
        let g:mthesaur_binary = 'mthesaur'  " Default fallback
    endif
endif

if !exists("g:mthesaur_file")
    let g:mthesaur_file = "~/.vim/mthesaur.txt"
endif

command! -nargs=1 MThesaur :call mthesaur#Lookup(<q-args>, 0)
command! MThesaurCurrentWord :call mthesaur#LookupCurrentWord(0)
command! -nargs=1 MThesaurReplace :call mthesaur#Lookup(<q-args>, 1)
command! MThesaurReplaceCurrentWord :call mthesaur#LookupCurrentWord(1)
command! MThesaurInfo :call mthesaur#ShowInfo()

let &cpo = s:save_cpo
