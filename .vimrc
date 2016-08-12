set history=500

"""""""""""""""""""""""""""
"" use vim for programming, like a normal person
"""""""""""""""""""""""""""
"" get rid of bold text inside vim; it annoys me
"" copied from https://groups.google.com/forum/#!topic/vim_use/cI7ritLRH8Q
if !has('gui_running')
    set t_Co=8 t_md=
endif

syntax on
filetype indent plugin on
au BufRead,BufNewFile *.go set filetype=go
"" show matching brackets, and for how many deciseconds
set showmatch
set mat=2

"""""""""""""""""""""""""""
"" spaces and tabs
"""""""""""""""""""""""""""
set shiftwidth=4 softtabstop=4
set tabstop=4 expandtab
set ai "" autoindent
set si "smart indent
set wrap "wrap lines

"""""""""""""""""""""""""""
"" search and display
"""""""""""""""""""""""""""
"" show line, position
set ruler
"" helpful when looking for commands
set wildmenu
set wildmode=list:full
"" search in text
set incsearch ignorecase hlsearch
"" for regular expressions
set magic
"" un-highlight with spacebar after search
nnoremap <silent> <Space> :silent noh<Bar>echo<CR>
"" allow clicking (I think?)
set mouse=ar mousemodel=extend
"" doesn't slow down during macros
set lazyredraw
"" open file at previous close location
au BufReadPost * if line("'\"") > 1 && line("'\"") <= line("$") | exe "normal! g'\"" | endif

"""""""""""""""""""""""""""
"" Navigate
"""""""""""""""""""""""""""
"" first non-blank character
map 0 ^
noremap <Home> ^
"" backspace works like normal
set backspace=eol,start,indent
set whichwrap=<,>,h,l
"" more natural splits: below/to the right, rather than above/to the left
set splitbelow
set splitright
"" windows:
map <C-j> <C-W>j
map <C-k> <C-W>k
map <C-l> <C-W>l
map <C-h> <C-W>h

"""""""""""""""""""""""""""
"" no annooying noises, or files
"""""""""""""""""""""""""""
"" noises
set noerrorbells
set novisualbell
set t_vb=
set tm=500
"" files - everything should be in a gitrepo anyway....
set nobackup
set nowb
set noswapfile

"""""""""""""""""""""""""""
"" colors
"""""""""""""""""""""""""""
set background=dark
"" default colorscheme
colorscheme evening
if has ("unix")
    let s:uname = system("uname")
    if s:uname == "Darwin\n"
        colorscheme murphy
    endif
endif

"""""""""""""""""""""""""""
"" vim modules: pathogen, etc
"""""""""""""""""""""""""""
execute pathogen#infect()

"" syntastic goodness
set statusline+=%#warningmsg#
set statusline+=%{SyntasticStatuslineFlag()}
set statusline+=%*

let g:syntastic_always_populate_loc_list = 1
let g:syntastic_auto_loc_list = 1
"let g:syntastic_check_on_open = 1
let g:syntastic_check_on_wq = 0
"" get python3 syntax accepted
let g:syntastic_python_python_exec="/usr/bin/python3"
let g:syntastic_python_flake8_args = "--ignore W391,E302 --max-lin-length=80"
let g:syntastic_haskell_ghc_mod_checker = 1

"" SS will first turn Syntastic off; next time it will turn it on
"" but it won't actually re-run the check (until say :w), so :SC now checks
cnoreabbrev SS SyntasticToggleMode
cnoreabbrev SC SyntasticCheck
