" Setup PATH
" ------------------------------------------------
" {{{

function! IncludePath(path)
  let delimiter = ":"
  let pathlist = split($PATH, delimiter)

  if isdirectory(a:path) && index(pathlist, a:path) == -1
    let $PATH = a:path.delimiter.$PATH
  endif
endfunction

call IncludePath(expand("~/.pyenv/shims"))
call IncludePath(expand("~/.rbenv/shims"))
call IncludePath(expand("~/.goenv/shims"))

" }}}

" General Settings
" ------------------------------------------------
" {{{

" Define and re-initialize augroup for vimrc
augroup vimrc
  autocmd!
augroup END

syntax on
filetype plugin indent on

" buffer setting
set hidden

" Tab/Indent Settings
set smartindent

" Search Settings
set hlsearch
set incsearch
set ignorecase
set smartcase

" Editor Settings
set number
set backspace=indent,eol,start

" Display Settings
set title
set laststatus=2

" Wildmode settings
set wildmenu
set wildmode=longest,full

set clipboard^=unnamed,unnamedplus

" Leader
let mapleader = "\<Space>"

" Swap file location
if !isdirectory(expand('~/.vim/tmp'))
  call mkdir(expand('~/.vim/tmp'), 'p')
endif

set directory=~/.vim/tmp
set backup
set backupdir=~/.vim/tmp
set undodir=~/.vim/tmp

" Enable matchit
runtime macros/matchit.vim

" Enable persistent undo only when the feature is implemented
if has('persistent_undo')
  " Undo file location
  if !isdirectory(expand('~/.vim/undo'))
    call mkdir(expand('~/.vim/undo'), 'p')
  endif

  set undodir=~/.vim/undo
  set undofile
endif

" }}}

" General Key Bindings
" ------------------------------------------------
" {{{

" Edit/Reload .vimrc
nnoremap <Leader>fed :<C-u>edit $MYVIMRC<Return>
nnoremap <Leader>feR :<C-u>source $MYVIMRC<Return>

" Swap up/down with up/down with display lines
nnoremap j gj
nnoremap k gk
nnoremap gj j
nnoremap gk k

" Switch buffer "DON'T USE CURSOR KEYS, USE HJKL"
nnoremap <Left> :<C-u>bprevious<Return>
nnoremap <Right> :<C-u>bNext<Return>

" The drill sergeant says "DON'T USE CURSOR KEYS, USE HJKL"
nnoremap <Up> :echoe<Space>"Use k"<Return>
nnoremap <Down> :echoe<Space>"Use j"<Return>

" Deleting a buffer without closing the window
nnoremap <silent> <leader>bd :<C-u>bprevious\|:bdelete<Space>#<Return>
nnoremap <silent> <leader>bw :<C-u>bprevious\|:bwipe<Space>#<Return>

" <ESC> when typing 'jj' quick
inoremap jj <Esc>

" Select from the cursor to the end of line by typing 'vv' quick.
vnoremap v $

" Open repl
if has("terminal")
  nnoremap <Leader>irb :<C-u>terminal irb<Return>
  nnoremap <Leader>py :<C-u>terminal python<Return>
  nnoremap <Leader>node :<C-u>terminal node<Return>
  if executable('gosh')
    nnoremap <Leader>gosh :<C-u>terminal gosh<Return>
  end
endif

" }}}

" Plugins
" ------------------------------------------------
" {{{

" Requires plug.vim installed in the autoload directory.
" See https://github.com/junegunn/vim-plug for details.

function! DoUpdateRemotePlugins(arg)
  if has('nvim')
    UpdateRemotePlugins
  end
endfunction

call plug#begin('~/.vim/plugged')

" window
Plug 'simeji/winresizer'
Plug 'itchyny/lightline.vim'
Plug 'rhysd/vim-color-spring-night'

" fuzzy-finder
Plug 'ctrlpvim/ctrlp.vim'
Plug 'mattn/ctrlp-matchfuzzy'

" vim-molder
Plug 'mattn/vim-molder'
Plug 'mattn/vim-molder-operations'

" snippet
Plug 'mattn/sonictemplate-vim'
Plug 'Shougo/neosnippet'
Plug 'Shougo/neosnippet-snippets'

" search
Plug 'osyo-manga/vim-anzu'

" DX
Plug 'neoclide/coc.nvim', {'branch': 'release'}
Plug 'w0rp/ale'
Plug 'junegunn/vim-easy-align'
Plug 'tyru/caw.vim'
Plug 'ntpeters/vim-better-whitespace'
" cs, ds, yss
Plug 'tpope/vim-surround'

" Language
Plug 'dag/vim-fish', { 'for': 'fish' }
Plug 'tpope/vim-endwise', { 'for': 'ruby' }
Plug 'jgdavey/vim-blockle', { 'for': 'ruby' }
Plug 'sunaku/vim-ruby-minitest', { 'for': 'ruby' }
Plug 'slim-template/vim-slim', { 'for': 'slim' }
Plug 'hashivim/vim-terraform'
Plug 'chr4/nginx.vim'
Plug 'pangloss/vim-javascript', { 'for': ['javascript', 'javascript.jsx'] }
Plug 'mxw/vim-jsx', { 'for': 'javascript.jsx' }
Plug 'lepture/vim-jinja'
Plug 'plasticboy/vim-markdown', { 'for': 'markdown' }
Plug 'itkq/fluentd-vim'

call plug#end()

" }}}

" Vim Plugin Molder Extension
" ------------------------------------------------
" {{{

function! CreateNewfileInMolder() abort
  let l:name = input('Create file: ')
  if empty(l:name)
    return
  endif

  if l:name == '.' || l:name == '..' || l:name =~# '[/\\]'
    call molder#error('Invalid file name: ' .. l:name)
    return
  endif

  let l:fullpath = molder#curdir() .. l:name

  if getftype(l:fullpath) != ''
    call molder#error(l:name .. ' exists')
    return
  endif

  call writefile([], l:fullpath)
  call molder#reload()
endfunction

" 開いている場合は何もしない
" 開いているけど表示していない場合は close and reopen
function! OpenMolder()
  for buffer in getbufinfo()
    if has_key(buffer['variables'], 'current_syntax')
      if buffer['variables']['current_syntax'] == 'molder'
        if buffer['loaded'] == 0
          " not loaded な場合、利用されていないから閉じる
          exe 'bwipe' buffer.bufnr
          :continue
        endif

        exe 'buffer' buffer.bufnr
        return 0
      end
    endif
  endfor

  " open current directory
  " nnoremap <silent> <Leader>nt :<C-u>set nosplitright\|vnew\|vertical resize 30\|edit .<CR>
  set nosplitright
  vnew
  edit .
  return 0
endfunction

nnoremap <silent> <Leader>nt :<C-u>call OpenMolder()<CR>

augroup VimMolder
  autocmd!
  autocmd FileType molder nnoremap <silent><buffer>q :<C-u>bwipe!<CR>
  autocmd FileType molder nnoremap <buffer>f :<C-u>call CreateNewfileInMolder()<CR>
augroup END

" }}}

" Plugin Settings
" ------------------------------------------------
" {{{

" CtrlP
let g:ctrlp_match_func = { 'match': 'ctrlp_matchfuzzy#matcher' }

let g:ctrlp_user_command = {
  \ 'types': {
    \ 1: ['.git', 'git -C %s ls-files --cached --exclude-standard --others'],
    \ },
  \ 'fallback': 'find %s -type f'
  \ }
let g:ctrlp_match_window = 'bottom,order:btt,min:3,max:15,results:15'
let g:ctrlp_open_new_file = 'r'

" winresizer
let g:winresizer_start_key = "<Leader>w"

" ale
highlight ALEWarning ctermbg=124
let g:ale_fixers = {
      \   'javascript': ['eslint', 'prettier'],
      \   'ruby': ['rubocop'],
      \}

" vim-anzu
nmap n <Plug>(anzu-n)
nmap N <Plug>(anzu-N)
nmap * <Plug>(anzu-star)
nmap # <Plug>(anzu-sharp)
nmap <silent> <Esc><Esc> :<C-u>nohlsearch<Return><Plug>(anzu-clear-search-status)

" vim-easy-align
xmap ga <Plug>(EasyAlign)
nmap ga <Plug>(EasyAlign)

" vim-markdown
let g:vim_markdown_folding_disabled = 1
let g:vim_markdown_frontmatter = 1

" terraform-vim
autocmd FileType terraform nmap <Leader>fmt :<C-u>TerraformFmt<Return>

" sonictemplate-vim
let g:sonictemplate_vim_template_dir = [
\ '$HOME/.config/nvim/template'
\]

" vim-coc
highlight CocErrorSign ctermfg=15 ctermbg=196
highlight CocWarningSign ctermfg=0 ctermbg=172

" coc-git
" TODO: gitgutterのハイライトを調整したい

" Neosnippet
imap <C-k> <Plug>(neosnippet_expand_or_jump)
smap <C-k> <Plug>(neosnippet_expand_or_jump)
xmap <C-k> <Plug>(neosnippet_expand_target)
let g:neosnippet#enable_snipmate_compatibility = 1
let g:neosnippet#snippets_directory='~/.vim/snippets'

let g:airline_powerline_fonts = 1
let g:lightline = {
    \ 'colorscheme': 'PaperColor_light',
    \ 'active': {
    \   'left': [ [ 'mode', 'paste' ],
    \             [ 'gitbranch', 'readonly', 'filename', 'modified' ] ]
    \ },
    \ 'component_function': {
    \   'gitbranch': 'LightlineGitStatus'
    \ },
\ }

function! LightlineGitStatus() abort
  let l:git_status = get(g:, 'coc_git_status', '')
  return l:git_status
endfunction

" coclist
nnoremap <Leader>cb :<C-u>CocList buffers<Return>

" grep word under cursor
command! -nargs=+ -complete=custom,s:GrepArgs Rg exe 'CocList grep '.<q-args>

function! s:GrepArgs(...)
  let list = ['-S', '-smartcase', '-i', '-ignorecase', '-w', '-word',
        \ '-e', '-regex', '-u', '-skip-vcs-ignores', '-t', '-extension']
  return join(list, "\n")
endfunction

" Keymapping for grep word under cursor with interactive mode
nnoremap <Leader>cf :<C-u>exe 'CocList -I --input='.expand('<cword>').' grep'<CR>
vnoremap <leader>cf :<C-u>call <SID>GrepFromSelected(visualmode())<CR>

function! s:GrepFromSelected(type)
  let saved_unnamed_register = @@
  if a:type ==# 'v'
    normal! `<v`>y
  elseif a:type ==# 'char'
    normal! `[v`]y
  else
    return
  endif
  let word = substitute(@@, '\n$', '', 'g')
  let word = escape(word, '| ')
  let @@ = saved_unnamed_register
  execute 'CocList grep '.word
endfunction

nnoremap <Leader>cgs :<C-u>CocList --normal gstatus<Return>
nnoremap <Leader>cgb :<C-u>CocList --normal bcommits<Return>
nnoremap <Leader>cgc :<C-u>CocCommand git.showCommit<Return>

" }}}

" Extra Commands
" ------------------------------------------------
" {{{

" Prettify JSON
if executable('jq')
  command! -range=% PrettyJson :execute "<line1>,<line2>!jq '.'"
elseif executable('python2')
  command! -range=% PrettyJson :execute '<line1>,<line2>!python2 -c "import sys, json;
    \ print json.dumps(json.loads(sys.stdin.read()), indent=2,
    \ separators=(\",\", \": \"), ensure_ascii=False).encode(\"utf8\")"'
else
  command! -range=% PrettyJson :execute '<line1>,<line2>!python -c "import sys, json;
    \ print json.dumps(json.loads(sys.stdin.read()), indent=2,
    \ separators=(\",\", \": \"), ensure_ascii=False).encode(\"utf8\")"'
endif

" =========
" ruby
" =========
command! ExecuteRuby call s:execute_ruby()
function! s:execute_ruby() abort
  if filereadable(expand("%"))
    call term_start(printf('ruby %s', expand("%")))
  else
    ruby << EOS
    eval(Vim::Buffer.current.length.times.inject("") { |res, i| res << Vim::Buffer::current[i+1] << "\n" })
EOS
  endif
endfunction
" nnoremap <silent> <leader>rb :ruby<Space>eval(Vim::Buffer.current.length.times.inject(''){<Bar>res,i<Bar>res<lt><lt><Space>Vim::Buffer.current[i+1]<lt><lt><Space>"<Bslash>n"})<Return>
nnoremap <silent> <Leader>rb :<C-u>ExecuteRuby<Return>

" }}}

" TODO
" auto-git-diff っぽいいのある？
"   - rhysd/committia.vim
"   - coc-git の `CocCommand git.showCommit` でも良いかも
" cocの選択肢の最初を選択肢ない状態にしたい

let color = 'spring-night'
colorscheme spring-night

set shell=fish

" vim:set foldmethod=marker:
