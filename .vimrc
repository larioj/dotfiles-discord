call plug#begin()
Plug 'tpope/vim-sensible'
Plug 'larioj/plum'
Plug 'vim-scripts/vim-auto-save'
Plug 'ervandew/supertab'
Plug 'Shougo/deoplete.nvim'
Plug 'Shougo/vimproc.vim'
Plug 'purescript-contrib/purescript-vim'
Plug 'airblade/vim-rooter'
Plug 'morhetz/gruvbox'
Plug 'rhysd/vim-clang-format'
Plug 'dense-analysis/ale'
Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
Plug 'junegunn/fzf.vim'
"Plug 'neoclide/coc.nvim', {'branch': 'release'}
Plug 'ycm-core/YouCompleteMe'
Plug 'udalov/kotlin-vim'
Plug 'tpope/vim-fugitive'
Plug 'tpope/vim-rhubarb'
"Plug 'vim-airline/vim-airline'
Plug 'godlygeek/tabular'
call plug#end()

set nocompatible 
filetype plugin indent on
syntax on

set nowrap
set autoread
set nocompatible
set noequalalways
set noswapfile
set smartcase
set smarttab
set tw=80
set history=1000
set tabstop=8 softtabstop=0 expandtab shiftwidth=2 smarttab
set clipboard=unnamed
set formatoptions-=t
set completeopt-=preview
set hlsearch
"set statusline=%{mode}
"set statusline+=\ %f:%l,%c
set sidescroll=1
set ve+=onemore
set wrap

colorscheme gruvbox
set background=dark

let $BASH_ENV = "~/.bash_aliases"
let g:auto_save = 1

let g:rooter_patterns = ['.git']

let &t_SI = "\<Esc>]50;CursorShape=1\x7"
let &t_SR = "\<Esc>]50;CursorShape=2\x7"
let &t_EI = "\<Esc>]50;CursorShape=0\x7"

call winman#EnableWinman()
let g:plum_open_cmd = 'WinmanOpen'
let g:plum_after_close = 'WinmanAfterClose'
let g:ale_default_navigation = 'WinmanOpen'
let g:fzf_action = { 'enter' : 'WinmanOpen' }

" ALE GOTO
function! MatchTsGoto()
  return ['', stridx(&filetype, 'typescript') == 0]
endfunction

function! TsGoto(p)
  if (a:p['key'][0] == 'S')
    ALEFindReferences
  else
    WinmanOpen
    ALEGoToDefinition
  endif
endfunction

" python goto
function! s:MatchPyGoTo()
  return ['', stridx(&filetype, 'python') == 0]
endfunction

function! s:PyGoTo(p)
  if (a:p['key'][0] == 'S')
    echom 'in-shift'
    YcmCompleter GoToReferences
  else
    WinmanOpen
    YcmCompleter GoTo
    YcmCompleter GoTo
  endif
endfunction

function! s:MatchQfFile()
  if &filetype != 'qf'
    return ['', v:false]
  endif
  let l:parts = split(getline('.'), '|')
  if len(l:parts) !=# 3
    return ['', v:false]
  endif
  let l:loc_parts = split(l:parts[1])
  let l:path = [l:parts[0], l:loc_parts[0]]
  return plum#fso#BestInterp(l:path)
endfunction

function! s:OpenQfFso()
  return [ { a, b -> s:MatchQfFile() }
        \, { p, i -> plum#fso2#Open(p, i.key[0:0] ==# 'S') } ]
endfunction

" Url Matching
function! MatchUrl(url)
  let url = expand('<cfile>')
  return [url, url =~# '\v^https?://.+$']
endfunction

function! OpenUrl(url)
  call job_start(['open', a:url])
endfunction

set mouse=a
call plum#SetMouseBindings()
nnoremap o :call plum#Plum('n', 0)<cr>
nnoremap e :call winman#Close()<cr>
let g:plum_actions = [
      \ plum#term2#Term(),
      \ plum#mk2#Block(),
      \ plum#vim#Execute(),
      \ s:OpenQfFso(),
      \ plum#fso2#OpenFso(),
      \ [{c, p -> MatchUrl(trim(c))}, {c, p -> OpenUrl(c)}],
      \ [{c, p -> MatchTsGoto()}, {c, p -> TsGoto(p)}],
      \ [{c, p -> s:MatchPyGoTo()}, {c, p -> s:PyGoTo(p)}],
      \ ]

vnoremap <cr> y
nnoremap <cr> yy
vnoremap <bs> d
nnoremap <bs> dd
"inoremap <c-v> <esc><c-v>
nnoremap * *``

let mapleader=' '
nnoremap <SPACE> <Nop>
nnoremap <leader><SPACE> :call execute('WinmanOpen ~/.common-commands.md')<cr>

let CursorColumnI = 0
augroup change_cursor
  autocmd!
  autocmd InsertEnter * let CursorColumnI = col('.')
  autocmd CursorMovedI * let CursorColumnI = col('.')
  autocmd InsertLeave * if col('.') != CursorColumnI | call cursor(0, col('.')+1) | endif
augroup END

augroup larioj_misc
  autocmd TerminalOpen * :if &buftype ==# 'terminal' | set nonumber | endif
augroup END

nnoremap <c-k> :Rg<cr>
inoremap <c-k> <esc>:Rg<cr>

" Linting

let g:ale_sign_error = '▻'
let g:ale_sign_warning = '•'
let g:ale_lint_on_text_changed = 'always'
let g:ale_lint_delay = 100
" use eslint_d instead of the local eslint for speed!
" `yarn global add eslint_d`
" NOTE: if you upgrade your eslint version, run
" `eslint_d restart`
let g:ale_javascript_eslint_executable = 'eslint_d'
" so that we prefer eslint_d over the local version :\
let g:ale_javascript_eslint_use_global = 1
" setup ale autofixing
let g:ale_fixers = {}
let g:ale_fixers.javascript = [
\ 'eslint',
\ 'prettier',
\]
let g:ale_fixers.typescript = g:ale_fixers.javascript
let g:ale_fixers.typescriptreact = g:ale_fixers.javascript
let g:ale_fixers.css = [
\ 'prettier',
\]
let g:ale_fix_on_save = 0
" handy key mappings to move to the next/previous error
nnoremap [; :ALEPreviousWrap<cr>
nnoremap ]; :ALENextWrap<cr>


" NOTE: update this to point to your discord root directory
let s:discoHome = $HOME . '/Repos/discord'

func! s:OnFormatted(tempFilePath, _buffer, _output)
    return readfile(a:tempFilePath)
endfunc

func! FormatDiscoPython(buffer, lines) abort
    " NOTE: clid's python format will ONLY operate correctly on a file
    " if it lives in the same discord repo root that clid does, so
    " we have to manually create the temp file/directory here:

    let dir = s:discoHome . '/.ale-tmp'
    if !isdirectory(dir)
        call mkdir(dir)
    endif
    call ale#command#ManageDirectory(a:buffer, dir)

    " this may be overkill, but just in case:
    let filename = localtime() . '-' . rand() . '-' . bufname(a:buffer)
    let path = dir . '/' . filename
    call mkdir(fnamemodify(path, ':h'), 'p')
    call writefile(a:lines, path)

    let blackw = s:discoHome . '/tools/blackw'
    let command = blackw . ' ' . path
    return {
        \ 'command': command,
        \ 'read_buffer': 0,
        \ 'process_with': function('s:OnFormatted', [path]),
        \ }
endfunc

call ale#fix#registry#Add('clid-format', 'FormatDiscoPython', ['python'], 'clid formatting for python')

let g:ale_fixers.python = ['clid-format']
"let g:ale_linters = {}
"let g:ale_linters.python = ['flake8', 'pylint']

" YCM
let g:ycm_autoclose_preview_window_after_completion=1
let g:ycm_filetype_whitelist = {'python': 1}
let g:ycm_auto_hover = -1
let g:ycm_key_list_previous_completion = ['<Up>']
let g:ycm_key_list_select_completion = ['<Down>']
let g:ycm_key_invoke_completion = '<s-right>'

"let g:ycm_goto_buffer_command = 'split-or-existing-window'

hi StatusLine ctermbg=black ctermfg=white
hi StatusLineNc ctermbg=white ctermfg=brown

func! LariojYankFileLoc()
  let @* = "\n" . expand('%') . ':' . line('.')
endfunc

nnoremap yf :call LariojYankFileLoc()<cr>
