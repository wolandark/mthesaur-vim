let s:save_cpo = &cpo
set cpo&vim

function! s:Trim(input_string)
    let l:str = substitute(a:input_string, '[ \t]*[\r\n:][ \t]*', ' ', 'g')
    return substitute(l:str, '^[ \t]*\(.\{-}\)[ \t]*$', '\1', '')
endfunction

function! s:EchoHighlight(message)
    let l:index = 0
    for item in split(a:message, "|")
        if l:index % 2
            echon item
        else
            exec "echohl " . item
        endif
        let l:index+=1
    endfor
endfunction

function! s:CheckBinary()
    if !executable(g:mthesaur_binary)
        call s:EchoHighlight("ErrorMsg|Error: mthesaur binary not found at: " . g:mthesaur_binary . "|None")
        call s:EchoHighlight("ErrorMsg|Options to fix this:|None")
        call s:EchoHighlight("ErrorMsg|1. Build binary: make build|None")
        call s:EchoHighlight("ErrorMsg|2. Install globally: make install|None")
        call s:EchoHighlight("ErrorMsg|3. Install locally: make install-local|None")
        call s:EchoHighlight("ErrorMsg|4. Set g:mthesaur_binary to correct path in vimrc|None")
        return 0
    endif
    return 1
endfunction

function! mthesaur#Query(word)
    if !s:CheckBinary()
        return [-1, []]
    endif

    let l:word = s:Trim(a:word)
    let l:word = tolower(l:word)
    let l:word = substitute(l:word, '"', '', 'g')
    
    if l:word == ""
        return [-1, []]
    endif

    let l:cmd = g:mthesaur_binary . ' ' . shellescape(l:word)
    let l:result = system(l:cmd)
    
    if v:shell_error != 0
        call s:EchoHighlight("ErrorMsg|Error calling mthesaur binary|None")
        return [-1, []]
    endif

    try
        let l:data = json_decode(l:result)
        if type(l:data) != v:t_dict
            throw "Invalid JSON response"
        endif
        
        let l:status = get(l:data, 'status', -1)
        let l:synonyms = get(l:data, 'synonyms', [])
        
        return [l:status, l:synonyms]
    catch
        call s:EchoHighlight("ErrorMsg|Error parsing mthesaur response: " . v:exception . "|None")
        return [-1, []]
    endtry
endfunction

function! s:DisplaySynonyms(synonyms, word)
    if empty(a:synonyms)
        call s:EchoHighlight("WarningMsg|No synonyms found for: " . a:word . "|None")
        return 0
    endif

    let l:bufname = "MThesaur: " . a:word
    let l:bufnr = bufnr(l:bufname)
    
    if l:bufnr != -1
        " Buffer exists, switch to it
        execute 'buffer ' . l:bufnr
        normal! ggVGd
    else
        " Create new buffer
        execute 'new ' . l:bufname
        setlocal buftype=nofile
        setlocal bufhidden=wipe
        setlocal noswapfile
        setlocal filetype=mthesaur
    endif

    " Add header
    call append(0, "Synonyms for: " . a:word)
    call append(1, "=" . repeat("=", len("Synonyms for: " . a:word)))
    call append(2, "")

    " Add synonyms
    let l:line_num = 3
    for synonym_group in a:synonyms
        if len(synonym_group) >= 2
            let l:definition = synonym_group[0]
            let l:words = synonym_group[1]
            
            if l:definition != ""
                call append(l:line_num, "Definition: " . l:definition)
                let l:line_num += 1
            endif
            
            call append(l:line_num, "  " . join(l:words, ", "))
            let l:line_num += 1
            call append(l:line_num, "")
            let l:line_num += 1
        endif
    endfor

    normal! gg
    return 1
endfunction

function! s:SelectAndReplace(synonyms, word)
    if empty(a:synonyms)
        call s:EchoHighlight("WarningMsg|No synonyms found for: " . a:word . "|None")
        return 0
    endif

    " Collect all synonyms into a single list
    let l:all_synonyms = []
    for synonym_group in a:synonyms
        if len(synonym_group) >= 2
            let l:words = synonym_group[1]
            call extend(l:all_synonyms, l:words)
        endif
    endfor

    if empty(l:all_synonyms)
        call s:EchoHighlight("WarningMsg|No synonyms found for: " . a:word . "|None")
        return 0
    endif

    " Display selection menu
    let l:prompt = "Select synonym for '" . a:word . "':\n"
    let l:i = 1
    for synonym in l:all_synonyms
        let l:prompt .= l:i . ". " . synonym . "\n"
        let l:i += 1
    endfor
    let l:prompt .= "0. Cancel\n"

    let l:choice = input(l:prompt . "Choice: ")
    
    if l:choice == 0 || l:choice == ""
        return 0
    endif

    let l:choice_num = str2nr(l:choice)
    if l:choice_num < 1 || l:choice_num > len(l:all_synonyms)
        call s:EchoHighlight("ErrorMsg|Invalid choice|None")
        return 0
    endif

    let l:selected_synonym = l:all_synonyms[l:choice_num - 1]
    
    " Replace the word under cursor
    let l:current_word = expand('<cword>')
    execute 'normal! ciw' . l:selected_synonym
    
    call s:EchoHighlight("None|Replaced '" . l:current_word . "' with '" . l:selected_synonym . "'|None")
    return 1
endfunction

function! mthesaur#Lookup(word, replace)
    let l:status = mthesaur#Query(a:word)
    let l:result_status = l:status[0]
    let l:synonyms = l:status[1]

    if l:result_status == -1
        call s:EchoHighlight("ErrorMsg|Error occurred during lookup|None")
        return
    elseif l:result_status == 1
        call s:EchoHighlight("WarningMsg|No synonyms found for: " . a:word . "|None")
        return
    endif

    if a:replace
        call s:SelectAndReplace(l:synonyms, a:word)
    else
        call s:DisplaySynonyms(l:synonyms, a:word)
    endif
endfunction

function! mthesaur#LookupCurrentWord(replace)
    let l:word = expand('<cword>')
    if l:word == ""
        call s:EchoHighlight("WarningMsg|No word under cursor|None")
        return
    endif
    call mthesaur#Lookup(l:word, a:replace)
endfunction

function! mthesaur#ShowInfo()
    call s:EchoHighlight("None|=== MThesaur Plugin Info ===|None")
    call s:EchoHighlight("None|Binary path: " . g:mthesaur_binary . "|None")
    call s:EchoHighlight("None|Binary executable: " . (executable(g:mthesaur_binary) ? "Yes" : "No") . "|None")
    call s:EchoHighlight("None|Thesaurus file: " . g:mthesaur_file . "|None")
    call s:EchoHighlight("None|Key mappings enabled: " . (g:mthesaur_map_keys ? "Yes" : "No") . "|None")
endfunction

let &cpo = s:save_cpo
