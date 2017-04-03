set history=500

"""""""""""""""""""""""""""
"" use vim for programming, like a normal person
"""""""""""""""""""""""""""
syntax on
filetype indent plugin on
au BufRead,BufNewFile *.go set filetype=go
au BufRead,BufNewFile *pythonstartup set filetype=python
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
"" python screws up smartindent, so dont use it
au! FileType python setl nosmartindent

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
set clipboard=unnamed

"" highlight TODO and FIXME regardless of filetype
augroup HighlightBuzzwords
    autocmd!
    autocmd WinEnter,VimEnter * :silent! call matchadd('Todo', 'TODO\|FIXME\|NOTE', -1)
augroup end

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
"" no annoying noises, or files
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
    else
        "" get rid of bold text inside vim; it annoys me on Unix but not Mac.
        "" from https://groups.google.com/forum/#!topic/vim_use/cI7ritLRH8Q
        if !has('gui_running')
            set t_Co=8 t_md=
        endif
    endif
endif

"" highlight Python strings so they stand out better
syn region pythonstring matchgroup=pythonstring start=/["']/ end=/["']/
hi pythonstring ctermfg=7265

""""""""""""""""""""""""""""""""""""""""""""""""""""""
"" vim modules: pathogen, etc
""""""""""""""""""""""""""""""""""""""""""""""""""""""
execute pathogen#infect()

"""""""""""""""""""""""""""
"" syntastic goodness
"""""""""""""""""""""""""""
"" recommended settings
set statusline+=%#warningmsg#
set statusline+=%{SyntasticStatuslineFlag()}
set statusline+=%*

let g:syntastic_always_populate_loc_list = 1
let g:syntastic_auto_loc_list = 1
let g:syntastic_check_on_open = 1
let g:syntastic_check_on_wq = 0
"" (on mac, at least) no errors populate unless quiet_messages is set
let g:syntastic_quiet_messages = {'level': 'warnings'}

"" for python
let g:syntastic_python_checkers = ['flake8', 'pylint']
"" ignore flake8 warnings I don't care about:
"" W391 = blank line at end of file [vim will add if necessary]
"" E127 = under-indented [too many edge cases]
"" E128 = over-indented [same as E127]
"" E262 = inline comments '# ' [I prefer '## ']
"" E266 = block commentes '# ' [same as E262]
let g:syntastic_python_flake8_args = '--ignore W391,E127,E128,E262,E266 --max-line-length=80'
"" ignore pylint warnings, just give me the big errors
let g:syntastic_python_pylint_args = '-E'

"" for haskell
let g:syntastic_haskell_ghc_mod_checker = 1

"" SS will first turn Syntastic off; next time it will turn it on
"" but it won't actually re-run the check (until say :w), so :SC now checks
cnoreabbrev SS SyntasticToggleMode
cnoreabbrev SC SyntasticCheck
