set history=500

"""""""""""""""""""""""""""
"" use vim for programming, like a normal person
"""""""""""""""""""""""""""
syntax on
filetype indent plugin on
au BufRead,BufNewFile *.go set filetype=go
au BufRead,BufNewFile *.ms set filetype=mustache
au BufRead,BufNewFile *pythonstartup set filetype=python
au Filetype html,xml,xsl,js source ~/.vim/scripts/closetag.vim
"" show matching brackets, and for how many deciseconds
set showmatch
set mat=2
"" show line numbers in gutter
set number

"""""""""""""""""""""""""""
"" spaces and tabs
"""""""""""""""""""""""""""
set ai "" autoindent
set si "smart indent
set wrap "wrap lines
"" sigopt uses indent=2 for everything
set shiftwidth=2 softtabstop=2
set tabstop=2 expandtab
"" python screws up smartindent, so dont use it
""au! FileType python setlocal nosmartindent
"" python wants to use 4 spaces; sigopt wants 2
au FileType python setlocal shiftwidth=2 softtabstop=2 expandtab

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

"" highlight common typos that aren't always caught by linters
augroup HighlightTypos
    autocmd!
    autocmd WinEnter,VimEnter * :silent! call matchadd('Todo', 'langauge\|flase\|Flase\|jsut\|tempalte\|timestmap', -1)
augroup end

"""""""""""""""""""""""""""
"" Navigate
"""""""""""""""""""""""""""
"" first non-blank character (smart BOL, not just BOL)
map 0 ^
noremap <Home> ^
"" backspace works like normal
set backspace=eol,start,indent
set whichwrap=<,>,h,l
"" keep the cursor as centered as possible (large scroll offset)
"" turning off for now, it makes me dizzy...
"" set scrolloff=999

"" more natural splits: below/to the right, rather than above/to the left
set splitbelow
set splitright

"" windows:
map <C-j> <C-W>j
map <C-k> <C-W>k
map <C-l> <C-W>l
map <C-h> <C-W>h

"" tabs
map <C-t><up> :tabr<cr>
map <C-t><down> :tabl<cr>
map <C-t><left> :tabp<cr>
map <C-t><right> :tabn<cr>

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
        "" http://www.deanbodenham.com/learn/tmux-pane-colours.html
        "" NOTE: copied murphy into ~/.vim/colors/ and changed:
        "" Normal: remove ctermbg; remove guibg; set gui=none
        "" so background turns gray when other (tmux) pane is highlighted
        colorscheme dwanderson-murphy
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
"" soft slate grey (http://vim.wikia.com/wiki/Xterm256_color_names_for_console_Vim)
hi pythonstring ctermfg=103
"" line numbers shouldn't stand out
highlight LineNr ctermfg=grey ctermbg=235 "" 235 is a dark dark grey

""""""""""""""""""""""""""""""""""""""""""""""""""""""
"" vim modules: pathogen, etc
""""""""""""""""""""""""""""""""""""""""""""""""""""""
execute pathogen#infect()

""""""""""""""""""""""""""""""
"" git-gutter
""""""""""""""""""""""""""""""
"" first tell vim-gitgutter to leave the ctermbg alone
let g:gitgutter_override_sign_column_highlight = 0
highlight SignColumn ctermbg=235

"""""""""""""""""""""""""
"" fuzzy file search
"""""""""""""""""""""""""
set rtp+=/usr/local/opt/fzf

"""""""""""""""""""""""""
"" show git diff markers in gutter
"""""""""""""""""""""""""
let g:gitgutter_realtime = 1
set updatetime=250

"""""""""""""""""""""""""""
"" mustache autocomplete
"""""""""""""""""""""""""""
let g:mustache_abbreviations = 1

"""""""""""""""""""""""""""
"" jedi-vim suppress inline popups (fights with ALE too much)
"""""""""""""""""""""""""""
let g:jedi#show_call_signatures = "2"

"""""""""""""""""""""""""""
"" syntax and style-checking
"""""""""""""""""""""""""""
"" use quickfix instead (not sure why? learning)
let g:ale_set_loclist = 0
let g:ale_set_quickfix = 1

"" make it open the list, at the desired height
let g:ale_open_list = 1
call ale#Set('list_window_size', 5)
"" small delay (in ms) when linting so it stops freaking out so much
let g:ale_lint_delay = 2000

"" leave the error window open even when empty. Less resizing, but
"" can be more annoying to close out of files (manually close list_window)
"let g:ale_keep_list_window_open = 1

"" ignore flake8 warnings I don't care about:
"" W391 = blank line at end of file [vim will add if necessary]
""        sigopt has this warning on, so I'll turn it on as well
"" E111 = indentation is not a multiple of four: I like this rule, but
""        sigopt uses indent of 2, and it's untenable to leave this on
"" E114 = indention is not a multiple of four (for comments): see E111
"" E121 = continuation line under-indented - consequence of 2-space indents
"" E123 = continuation line over-indented - [same as E121]
"" E127 = under-indented [too many edge cases]
"" E128 = over-indented [same as E127]
"" E131 - indent doesn't mach [same as E127]
"" E302 = expected 2 blank lines, found 1 [sigopt inconsistency]
"" E305 = expected 2 blank lines, found 1 [sigopt inconsistency]
""        different from 302?
"" F401 = import * unused [import zigopt.common.*]
"" F403 = import * undetectable [import zigopt.common.*]
"" F405 = {import} may be undefined or from star import
"" max-line-length used by sigopt is 120 rather than 80
let g:ale_python_flake8_args = '--ignore E111,E114,E121,E123,E127,E128,E131,E302,E305,F401,F403,F405 --max-line-length=120'

"" not sure why I only needed this once switching to Python3. hardcoded for sigopt-api
let _sigopt_api = "/Users/dwanderson/sigopt/sigopt-api/"
let _sigopt_paths = [
  \ _sigopt_api."src/python",
  \ _sigopt_api."prod",
  \ _sigopt_api."test",
  \ _sigopt_api."test/python",
  \ _sigopt_api."moe",
  \ _sigopt_api."scripts",
  \ ".",
  \ ]
let g:ale_python_pylint_options = "--init-hook='import sys; sys.path.extend(".join(_sigopt_paths).")'"

"" convenience for toggling on/off linters
cnoreabbrev SS cclose
cnoreabbrev SC ALEToggle
