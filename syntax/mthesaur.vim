if exists("b:current_syntax")
    finish
endif

syn keyword mthesaurKeyword Synonyms Definition
syn match mthesaurSeparator "^=.*$"
syn match mthesaurDefinition "^Definition:.*$"

hi def link mthesaurKeyword Title
hi def link mthesaurSeparator Comment
hi def link mthesaurDefinition Identifier

let b:current_syntax = "mthesaur"
