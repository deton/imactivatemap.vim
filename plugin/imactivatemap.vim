" vi:set ts=8 sts=2 sw=2 tw=0:
scriptencoding utf-8

" imactivatemap.vim - 日本語IMオンにして編集開始するコマンドを別に定義。
" Maintainer: KIHARA Hideto <deton@m1.interq.or.jp>
" Last Change: 2014-03-11

if exists('g:loaded_imactivatemap')
  finish
endif
let g:loaded_imactivatemap = 1

if !exists('g:imactivatemap_prefixkey')
  let g:imactivatemap_prefixkey = 'g'
endif

if !exists('g:imactivatemap_mapuppercase')
  let g:imactivatemap_mapuppercase = 0
endif

" cf. 'imactivatefunc'
function! s:activatefunc_default(active)
  if a:active
    set iminsert=2
  else
    set iminsert=0
  endif
endfunction

" imsearchのオン/オフの切り替えを行うために呼ぶ関数
function! s:imsactivatefunc_default(active)
  if a:active
    set imsearch=2
  else
    set imsearch=0
  endif
endfunction

if !exists('imactivatemap_imifunc')
  let imactivatemap_imifunc = 's:activatefunc_default'
endif
let s:activatefunc = function(imactivatemap_imifunc)
if !exists('imactivatemap_imsfunc')
  let imactivatemap_imsfunc = 's:imsactivatefunc_default'
endif
let s:imsactivatefunc = function(imactivatemap_imsfunc)

let s:imiforc = 0
let s:ccmd = 0

function! s:esc()
  set iminsert=0 imsearch=0
  call s:reset_ccmd()
endfunction

inoremap <script> <silent> <Plug>(imactivatemap-esc) <ESC>:call <SID>esc()<CR>

function! s:imactivate(active, cmd)
  call s:activatefunc(a:active)
  if a:cmd ==? 'c'
    let s:imiforc = a:active
    let s:ccmd = 1
  elseif s:ccmd == 1 && (a:cmd ==? 'f' || a:cmd ==? 't' || a:cmd == '/' || a:cmd == '?')
  else
    let s:ccmd = 0
  endif
  return a:cmd
endfunction

function! s:imsactivate(active, cmd)
  call s:imsactivatefunc(a:active)
  " XXX: <C-^>を返すことで切り替えを行う場合用に、戻り値を付加する?
  return a:cmd
endfunction

" 'cgtあ'の場合は日本語入力オフにしたい
" 'gctX'の場合は日本語入力オンにしたい
function! s:imcontrol_c()
  if s:ccmd == 1
    call s:activatefunc(s:imiforc)
  endif
endfunction

function! s:reset_ccmd()
  let s:ccmd = 0
endfunction

augroup ImActivateMap
  autocmd!
  "autocmd BufEnter * set iminsert=0 imsearch=0
  autocmd InsertEnter * call <SID>imcontrol_c()
  autocmd InsertLeave * call <SID>reset_ccmd()
augroup END

noremap <expr> c <SID>imactivate(0, 'c')
noremap <expr> C <SID>imactivate(0, 'C')

" gr,gf,gtで一度IMオンにするとそのままになるので、r,f,tでは明示的にオフに
noremap <expr> r <SID>imactivate(0, 'r')
noremap <expr> f <SID>imactivate(0, 'f')
noremap <expr> F <SID>imactivate(0, 'F')
noremap <expr> t <SID>imactivate(0, 't')
noremap <expr> T <SID>imactivate(0, 'T')
noremap <expr> / <SID>imsactivate(0, '/')
noremap <expr> ? <SID>imsactivate(0, '?')

" G, gi, gI, ga, go, gs, gr, gf, gtを上書き。
"noremap gz G
"noremap qf gf

let s:mapkeys = ['i','I','a','A','o','O','s','S','c','C','r','R','f','F','t','T']

function! s:imactivatemap(prefix)
  let prefixupper = toupper(a:prefix)
  for key in s:mapkeys
    " nnoremapだとcと組み合わせた際にf,tが使えないのでnoremap
    execute 'noremap <expr>' a:prefix . key '<SID>imactivate(1, "' . key . '")'
    if g:imactivatemap_mapuppercase && key =~ '\u'
      execute 'noremap <expr>' prefixupper . key '<SID>imactivate(1, "' . key . '")'
    endif
  endfor
  " `/`,`?`は&imsを設定。&imiを設定すると直後の`a`等に影響するので
  execute 'noremap <expr>' a:prefix . '/ <SID>imsactivate(1, "/")'
  execute 'noremap <expr>' a:prefix . '? <SID>imsactivate(1, "?")'
endfunction

call s:imactivatemap(g:imactivatemap_prefixkey)
