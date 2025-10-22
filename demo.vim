" Demo script
" This shows how to use the plugin in practice

" ┌───────────────┐
" │Load the plugin│
" └───────────────┘
source plugin/mthesaur.vim
source autoload/mthesaur.vim

" ┌───────────────┐
" │Set binary path│
" └───────────────┘
let g:mthesaur_binary = "mthesaur"

echo "=== MThesaur Plugin Demo ==="
echo ""

" ┌────────────────────┐
" │Test 1: Simple query│
" └────────────────────┘
echo "1. Testing simple query for 'happy':"
let result = mthesaur#Query("happy")
echo "Status: " . result[0]
echo "Found " . len(result[1]) . " synonym groups"
echo ""

" ┌──────────────────────┐
" │Test 2: Word not found│
" └──────────────────────┘
echo "2. Testing word not found ('nonexistentword'):"
let result2 = mthesaur#Query("nonexistentword")
echo "Status: " . result2[0] . " (1 means not found, as expected)"
echo ""

" ┌───────────────────────────────┐
" │Test 3: Show first few synonyms│
" └───────────────────────────────┘
echo "3. First few synonyms for 'happy':"
let result3 = mthesaur#Query("happy")
if result3[0] == 0 && len(result3[1]) > 0
    let synonyms = result3[1][0][1]  " Get first synonym group
    echo "Synonyms: " . join(synonyms[:5], ", ") . "..."
endif
echo ""

echo "=== Demo completed! ==="
echo ""
echo "To use in your vimrc, add:"
echo "let g:mthesaur_binary = 'mthesaur'"
echo ""
echo "Commands available:"
echo ":MThesaur <word>           - Look up synonyms"
echo ":MThesaurCurrentWord       - Look up word under cursor"
echo ":MThesaurReplace <word>    - Replace word interactively"
echo ":MThesaurReplaceCurrentWord - Replace current word"
echo ""
echo "Key mappings (if enabled):"
echo "<Leader>mt - Replace current word"
echo "<Leader>ml - Look up current word"
