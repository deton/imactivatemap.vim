" vi:set ts=8 sts=2 sw=2 tw=0:
scriptencoding utf-8

" imactivatemap.vim - 日本語IMオンにして編集開始するコマンドを別に定義。
" Maintainer: KIHARA Hideto <deton@m1.interq.or.jp>
" Last Change: 2014-03-13

if exists('g:loaded_imactivatemap')
  finish
endif
let g:loaded_imactivatemap = 1

if !exists('g:imactivatemap_prefixkey')
  let g:imactivatemap_prefixkey = 'g'
endif

" 'gI'に加え同機能を'GI'にもmapするかどうか
" ('GI'の方が'gI'よりも打ちやすい気がするので)
if !exists('g:imactivatemap_mapuppercase')
  let g:imactivatemap_mapuppercase = 0
endif

" iminsertのオン/オフの切り替えを行うために呼ぶ関数
" cf. 'imactivatefunc'
function! s:imifunc_default(active)
  if a:active
    set iminsert=2
  else
    set iminsert=0
  endif
endfunction

" imsearchのオン/オフの切り替えを行うために呼ぶ関数
function! s:imsfunc_default(active)
  if a:active
    set imsearch=2
  else
    set imsearch=0
  endif
endfunction

if !exists('imactivatemap_imifunc')
  let imactivatemap_imifunc = 's:imifunc_default'
endif
let s:imifunc = function(imactivatemap_imifunc)
if !exists('imactivatemap_imsfunc')
  let imactivatemap_imsfunc = 's:imsfunc_default'
endif
let s:imsfunc = function(imactivatemap_imsfunc)

let s:imiforc = 0
let s:isccmd = 0

function! s:esc()
  set iminsert=0 imsearch=0
  call s:reset_isccmd() " InsertLeaveでもしてるけどいちおう
endfunction

inoremap <script> <silent> <Plug>(imactivatemap-esc) <ESC>:call <SID>esc()<CR>

" 'a','c','f'等に対してIMオン/オフを行う。
function! s:imiactivate(active, cmd)
  call s:imifunc(a:active)
  if a:cmd ==? 'c'
    let s:imiforc = a:active
    let s:isccmd = 1
  elseif s:isccmd == 1 && stridx('fFtT', a:cmd) >= 0
  else
    let s:isccmd = 0
  endif
  return a:cmd
endfunction

" '/','?'に対してIMオン/オフを行う。
" &imsearchの制御を、&iminsertとは別にして、
" 直後の`a`等に対する影響を回避するため、s:imiactivate()とは別関数を用意。
function! s:imsactivate(active, cmd)
  call s:imsfunc(a:active)
  " XXX: <C-^>を返すことで切り替えを行う場合用に、戻り値を付加する?
  return a:cmd
endfunction

" 'c'か'gc'用にIMオン/オフを設定する。
" 'cgtあ'の場合は日本語入力オフにしたい
" 'gctX'の場合は日本語入力オンにしたい
function! s:imcontrol_c()
  if s:isccmd == 1
    call s:imifunc(s:imiforc)
  endif
endfunction

function! s:reset_isccmd()
  let s:isccmd = 0
endfunction

augroup ImActivateMap
  autocmd!
  "autocmd BufEnter * set iminsert=0 imsearch=0
  autocmd InsertEnter * call <SID>imcontrol_c()
  autocmd InsertLeave * call <SID>reset_isccmd()
augroup END

" f,tでIMオンにしても、gcでなくcだったらIMオフにするため
noremap <expr> c <SID>imiactivate(0, 'c')
noremap <expr> C <SID>imiactivate(0, 'C')

" gr,gf,gtで一度IMオンにするとそのままになるので、r,f,tでは明示的にオフに
noremap <expr> r <SID>imiactivate(0, 'r')
noremap <expr> f <SID>imiactivate(0, 'f')
noremap <expr> F <SID>imiactivate(0, 'F')
noremap <expr> t <SID>imiactivate(0, 't')
noremap <expr> T <SID>imiactivate(0, 'T')
noremap <expr> / <SID>imsactivate(0, '/')
noremap <expr> ? <SID>imsactivate(0, '?')

" gi, gI, ga, go, gs, gr, gf, gtを上書き。
"noremap qf gf
"noremap gz G

let s:mapkeys = ['i','I','a','A','o','O','s','S','c','C','r','R','f','F','t','T']

" IMオンで編集開始するためのmapを登録
function! s:mapimactivate(prefix)
  let prefixupper = toupper(a:prefix)
  for key in s:mapkeys
    " nnoremapだとcと組み合わせた際にf,tが使えないのでnoremap
    execute 'noremap <expr>' a:prefix . key '<SID>imiactivate(1, "' . key . '")'
    if g:imactivatemap_mapuppercase && key =~ '\u'
      execute 'noremap <expr>' prefixupper . key '<SID>imiactivate(1, "' . key . '")'
    endif
  endfor
  " `/`,`?`は&imsを設定。&imiを設定すると直後の`a`等に影響するので
  execute 'noremap <expr>' a:prefix . '/ <SID>imsactivate(1, "/")'
  execute 'noremap <expr>' a:prefix . '? <SID>imsactivate(1, "?")'
endfunction

call s:mapimactivate(g:imactivatemap_prefixkey)
