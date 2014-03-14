" vi:set ts=8 sts=2 sw=2 tw=0:
scriptencoding utf-8

" imactivatemap.vim - 日本語IMオンにして編集開始するコマンドを別に定義。
" Maintainer: KIHARA Hideto <deton@m1.interq.or.jp>
" Last Change: 2014-03-14

if exists('g:loaded_imactivatemap')
  finish
endif
let g:loaded_imactivatemap = 1

" gf等を上書きしたくない場合、g以外のprefixを指定
if !exists('g:imactivatemap_prefixkey')
  let g:imactivatemap_prefixkey = 'g'
endif

" 'gI'に加え同機能を'GI'にもmapするかどうか
" ('GI'の方が'gI'よりも打ちやすい気がするので)
if !exists('g:imactivatemap_mapuppercase')
  let g:imactivatemap_mapuppercase = 0
endif

" &imi制御対象にするコマンドの配列
" (gf,gtを上書きしたくない場合に外す設定ができるように)
if !exists('imactivatemap_imicmdlist')
  let imactivatemap_imicmdlist = ['i','I','a','A','o','O','s','S','c','C','r','R','f','F','t','T']
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

function! s:reset()
  call s:imifunc(0)
  call s:imsfunc(0)
  call s:reset_isccmd()
endfunction

" Insert modeをEscで抜けるとIMオフになるように設定するには、
"  imap <silent> <unique> <Esc> <Esc><Plug>(imactivatemap-reset)
nnoremap <script> <silent> <Plug>(imactivatemap-reset) :<C-U>call <SID>reset()<CR>

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
  "autocmd BufEnter * call <SID>reset()
  autocmd InsertEnter * call <SID>imcontrol_c()
  autocmd InsertLeave * call <SID>reset_isccmd()
augroup END

" gi, gI, ga, go, gs, gr, gf, gtを上書き。
"noremap qf gf
"noremap gz G

let s:imicmdlist = ['i','I','a','A','o','O','s','S','c','C','r','R','f','F','t','T']

" prefix無しコマンドをmapする必要のあるコマンドの配列。
" c: gf,gtでIMオンにしても、gcでなくcだったらIMオフにするため(例: 'cgfが')。
" r,f,t: gr,gf,gtで一度IMオンにするとそのままになるので、r,f,tでは明示的にオフに
let s:imioffcmdlist = ['c','r','f','F','t','T']

" <Plug>をmap
function! s:mapplug()
  for cmd in s:imicmdlist
    " nnoremapだとcと組み合わせた際にf,tが使えないのでnoremap
    execute 'noremap <expr> <Plug>(imactivatemap-on-' . cmd . ') <SID>imiactivate(1, "' . cmd . '")'
  endfor
  for cmd in s:imioffcmdlist
    execute 'noremap <expr> <Plug>(imactivatemap-off-' . cmd . ') <SID>imiactivate(0, "' . cmd . '")'
  endfor
  " `/`,`?`は&imsを設定。&imiを設定すると直後の`a`等に影響するので
  noremap <expr> <Plug>(imactivatemap-on-/) <SID>imsactivate(1, '/')
  noremap <expr> <Plug>(imactivatemap-on-?) <SID>imsactivate(1, '?')
  noremap <expr> <Plug>(imactivatemap-off-/) <SID>imsactivate(0, '/')
  noremap <expr> <Plug>(imactivatemap-off-?) <SID>imsactivate(0, '?')
endfunction

" IMオンで編集開始するためのmapを登録
function! s:mapimactivate(prefix)
  let prefixupper = toupper(a:prefix)
  for cmd in g:imactivatemap_imicmdlist
    " nmapだとcと組み合わせた際にf,tが使えないのでmap
    execute 'map' a:prefix . cmd '<Plug>(imactivatemap-on-' . cmd . ')'
    if index(s:imioffcmdlist, cmd) >= 0
      execute 'map' cmd '<Plug>(imactivatemap-off-' . cmd . ')'
    endif
    if g:imactivatemap_mapuppercase && cmd =~ '\u'
      execute 'map' prefixupper . cmd '<Plug>(imactivatemap-on-' . cmd . ')'
    endif
  endfor
  execute 'map' a:prefix . '/ <Plug>(imactivatemap-on-/)'
  execute 'map' a:prefix . '? <Plug>(imactivatemap-on-?)'
  map / <Plug>(imactivatemap-off-/)
  map ? <Plug>(imactivatemap-off-?)
endfunction

call s:mapplug()
if !get(g:, 'imactivatemap_no_default_key_mappings', 0)
  call s:mapimactivate(g:imactivatemap_prefixkey)
endif
