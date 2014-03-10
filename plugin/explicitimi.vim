" vi:set ts=8 sts=2 sw=2 tw=0:
scriptencoding utf-8

" explicitimi.vim - 日本語IMオンにして編集開始するコマンドを別に定義。
" Maintainer: KIHARA Hideto <deton@m1.interq.or.jp>
" Last Change: 2014-03-10

if exists('g:loaded_explicitimi')
  finish
endif
let g:loaded_explicitimi = 1

if !exists('g:explicitimi_prefixkey')
  let g:explicitimi_prefixkey = 'g'
endif

if !exists('g:explicitimi_mapuppercase')
  let g:explicitimi_mapuppercase = 1
endif

" 日本語入力IMをオンにしてInsert modeを開始するためのNormal modeモード用map。

" cf. 'imactivatefunc'
function! s:activatefunc_default(active)
  if a:active
    set iminsert=2
  else
    set iminsert=0
  endif
  if a:active == 2
    set imsearch=2
  else
    set imsearch=0
  endif
endfunction

if !exists('explicitimi_activatefunc')
  let explicitimi_activatefunc = 's:activatefunc_default'
endif
let s:activatefunc = function(explicitimi_activatefunc)

let s:imiforc = 0
let s:ccmd = 0

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

" 'cgtあ'の場合は日本語入力オフにしたい
" 'gctX'の場合は日本語入力オンにしたい
function! s:imcontrol_c()
  if s:ccmd == 1
    call s:activatefunc(s:imiforc)
  endif
  let s:ccmd = 0
endfunction

augroup ExplicitImi
  autocmd!
  autocmd InsertEnter * call <SID>imcontrol_c()
augroup END

function! s:SetIgnoreThisCmd(cmd)
  let s:ccmd = 0
  return a:cmd
endfunction

noremap <expr> c <SID>imactivate(0, 'c')
noremap <expr> C <SID>imactivate(0, 'C')
nnoremap <expr> a <SID>SetIgnoreThisCmd('a')
nnoremap <expr> A <SID>SetIgnoreThisCmd('A')
nnoremap <expr> i <SID>SetIgnoreThisCmd('i')
nnoremap <expr> I <SID>SetIgnoreThisCmd('I')
nnoremap <expr> o <SID>SetIgnoreThisCmd('o')
nnoremap <expr> O <SID>SetIgnoreThisCmd('O')

" gr,gf,gtで一度IMオンにするとそのままになるので、r,f,tでは明示的にオフに
noremap <expr> r <SID>imactivate(0, 'r')
noremap <expr> f <SID>imactivate(0, 'f')
noremap <expr> F <SID>imactivate(0, 'F')
noremap <expr> t <SID>imactivate(0, 't')
noremap <expr> T <SID>imactivate(0, 'T')
noremap <expr> / <SID>imactivate(0, '/')
noremap <expr> ? <SID>imactivate(0, '?')

" G, gi, gI, ga, go, gs, gr, gf, gtを上書き。
"noremap gz G
"noremap qf gf

let s:mapkeys = ['i','I','a','A','o','O','s','S','c','C','r','R','/','?','f','F','t','T']

function! s:explicitmap(prefix)
  let prefixupper = toupper(a:prefix)
  for key in s:mapkeys
    " nnoremapだとcと組み合わせた際にf,tが使えないのでnoremap
    execute 'noremap <expr> ' . a:prefix . key . ' <SID>imactivate(1, "' . key . '")'
    if g:explicitimi_mapuppercase && key =~ '\u'
      execute 'noremap <expr> ' . prefixupper . key . ' <SID>imactivate(1, "' . key . '")'
    endif
  endfor
endfunction

if !get(g:, 'explicitimi_no_default_key_mappings', 0)
  call s:explicitmap(g:explicitimi_prefixkey)
endif
