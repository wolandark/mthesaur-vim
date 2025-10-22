# MThesaur Vim Plugin

A clean, fast thesaurus plugin for Vim that uses a standalone Go binary to query a local `mthesaur.txt` file. <br> 
Inspired by the Python-based [thesaurus_query](https://github.com/Ron89/thesaurus_query.vim) plugin, this implementation leverages a single Go binary for speed and simplicity.

## Features

- **Fast**: Written in Go for optimal performance
- **Offline**: Works entirely offline with local `mthesaur.txt` file
- **Clean**: Minimal dependencies, no Python required
- **Simple**: Easy to use commands and key mappings

## Requirements

- Go compiler (for building the binary)
- `mthesaur.txt` file from Project Gutenberg

## Installation

1. **Download the mthesaur.txt file**:
   ```bash
   mkdir -p ~/.vim
   wget http://www.gutenberg.org/files/3202/files/mthesaur.txt -O ~/.vim/mthesaur.txt
   ```

2. **Build the Go binary**:
   ```bash
   cd /path/to/plugin/directory
   make build
   ```

3. **Install the binary** (choose one):

See [Binary Detection](#binary-detection)
   ```bash
   # System-wide installation (requires sudo)
   make install
   
   # Or local installation
   make install-local
   ```

4. **Add to your PATH** (if using local installation):
   ```bash
   echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.bashrc
   source ~/.bashrc
   ```

## Configuration

### Variables

- `g:mthesaur_binary`: Path to the Go binary (auto-detected if not set)
- `g:mthesaur_file`: Path to mthesaur.txt file (default: "~/.vim/mthesaur.txt")
- `g:mthesaur_map_keys`: Enable key mappings (default: 1)

### Binary Detection

The plugin automatically detects the binary in this order:
1. `g:mthesaur_binary` (if set manually)
2. `{plugin_dir}/build/mthesaur` (built binary)
3. `{plugin_dir}/mthesaur` (root directory binary)
4. `mthesaur` (system PATH)

### Example Configuration

```vim
" Custom binary path (optional - auto-detection works for most cases)
let g:mthesaur_binary = "/path/to/your/mthesaur"

" Custom thesaurus file location
let g:mthesaur_file = "~/.config/nvim/thesaurus/mthesaur.txt"

" Disable key mappings
let g:mthesaur_map_keys = 0
```

## Usage

### Commands

- `:MThesaur <word>` - Look up synonyms for a word (display in buffer)
- `:MThesaurCurrentWord` - Look up synonyms for word under cursor (display in buffer)
- `:MThesaurReplace <word>` - Look up synonyms and replace word interactively
- `:MThesaurReplaceCurrentWord` - Look up synonyms for word under cursor and replace interactively
- `:MThesaurInfo` - Show plugin configuration and binary path information

## Building

```bash
# Build the binary
make build

# Test the binary
make test

# Install system-wide
make install

# Clean build artifacts
make clean
```
## License

Same as Vim. See `:help license`.
