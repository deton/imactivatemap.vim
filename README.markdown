# Vimでの日本語入力・編集用に別コマンドを割り当てる

日本語入力IMをオンにしてInsert modeを開始するコマンドをNormal mode用にmapするVimプラグインです
(`i`,`a`,`c`,`o`等に対して、日本語入力オンで開始する`gi`,`ga`,`gc`,`go`等をmap)。
Insert modeに入る際には、日本語を編集したいことは意識しているので、
その意図を直接表現するコマンドを用意すると操作が気持ち良くできるかと思って作ってみました。

[`c`,`s`,`r`コマンドで、書き換え前の文字列に応じてIMオン/オフを切り替えるVimプラグインを作った](http://qiita.com/deton/items/ce21f80265753134e7e9)のですが、
日本語入力オン/オフ制御が意図から外れる場合がたまにあってストレスになるので、
逆方向のアプローチとして、日本語で編集することを指定するコマンドを割り当てる方法のプラグインです。
vi的には、日本語入力IMオンにしてInsert modeを開始するコマンドを用意する方が
自然な気がしたので。

さらに、Insert modeのままでのIMオン/オフ切り替えは使わずに、
オンに切り替えたい場合は一度Insert modeを抜ける形にするのがvi的かもしれません。
つまり、以下の2種類のコマンドとみなす形。
* `i`で始まり、ASCII文字列を入力して、`Esc`で終わるコマンド。
* `gi`で始まり、日本語文字列を入力して、`Esc`で終わるコマンド。

この場合は、以下のようにInsert modeを抜けるとIMオフになるように設定しておいてください。
```
 inoremap <silent> <unique> <Esc> <Esc>:set imsearch=0 iminsert=0<CR>
```

## 特徴

* 新たなモードの追加無しに、vi操作中に日本語編集を融合
  ([日本語入力固定モード](https://sites.google.com/site/fudist/Home/vim-nihongo-ban/vim-japanese/ime-control)
  のように、IMEオン固定モードとIMEオフ固定モードを追加して切り替えるのではなく)
 * `が`までの文字列をIMオフで編集する`cgtが`や、
   `h`までの文字列をIMオンで編集する`gcth`等の組み合わせも可。
* 現在の日本語入力モードがオンかオフかを意識しなくて良い。
  `ga`でInsert modeを始めれば常に日本語入力オンで入力できますし、
  `a`で始めれば常に日本語入力オフで入力できます。
* Insert mode中に日本語入力オンオフ切り替え操作をしなくて良い。
  かわりに`Esc`で抜けてInsert modeに入り直す操作が多くなりますが。

## 欠点

`i`のかわりに`gi`を入力する必要があるので、操作が少し長くなります。

日本語入力メインで行う場合は、`i`のかわりに`gi`を打つのは面倒なので、
Insert modeを抜けてもオフにしない方がいいかもしれません。
(その場合は、日本語入力オフでInsert modeを開始するコマンドを、
`qi`等に割り当てておくのがいいかも。)

このあたりは、viを使い始めた時に`i`を打つのを面倒に感じたのと同様に、
慣れの問題かもしれないので、しばらく使ってみる予定です。

## 少し使ってみての感想

* Insert modeに入ってからIMを切り替えるよりも、`ga`等のコマンドを使う方が楽な印象。
  たとえ、`Esc`で抜けて`ga`を押してIMをオンにし直さないといけない場合でも。
  IM切り替えはコントロールキーを使うからかも。
* `g/`で直接日本語入力を開始できるのは便利。
  `CTRL-^`を押して切り替えるのは面倒だったので。
* 日本語編集をするつもりなのに`gc`でなく`c`を押してしまう場合がよくある。
  同様に`a`や`i`でも。この場合、一度`Esc`で抜けて`gc`を押し直す形。
  慣れると意識せずにできるようになるか?
* 一番良く使うのは`ga`。逆に、日本語入力をするつもりが無いのに押してしまって、
  一度`Esc`で抜けて`a`を押し直すことも。
  その他便利なのは`gs`。`gc`は少し考えないとまだ使えない。
* Vim以外のアプリではIMオン/オフ操作が必要なので、操作の統一性が無くなるため、
  意識のスイッチが必要。
  (Vimを使う時点である程度スイッチしているので慣れればほぼ無意識にできるはず?)

## mapするキー
デフォルトでは、日本語入力IMオンにして編集を開始する以下のキーをmapします。
* `gi`, `gI`, `ga`, `gA`, `go`, `gO`, `gs`, `gS`, `gc`, `gC`, `gr`, `gR`
* `gf`, `gF`, `gt`, `gT`
* `g/`, `g?`

デフォルトでは、打ちやすさを考慮して`g`に割り当てていますが、
`gi`, `gI`, `ga`, `go`, `gs`, `gr`, `gR`, `gf`, `gt`, `g?`を上書きしてしまいます。
他のキーに割り当てるには、`g:imactivatemap_prefixkey`を設定してください。
```
  let g:imactivatemap_prefixkey = 'q'
```
候補となるprefixキー:
* `q`: 少し打ちにくい。
* `m`: `ma`等はよく使うので、指が意識せずに動いてしまっていまいち。
* `s`: `cl`で代替可能なので。ただ個人的に`s`はよく使うのでつぶしたくない。

また、`gI`よりも`GI`のようにシフトキー押しっぱなしの方が入力しやすい気がするので、
`GI`も`gI`と同じ機能にmapしたい場合は(`GA`等に関しても同様)、
~/.vimrcで`let g:imactivatemap_mapuppercase = 1`と設定してください。

## IMのオン/オフの切り替え制御
IMのオン/オフの切り替え制御は、デフォルトでは
`&iminsert`や`&imsearch`(`/`,`?`向け)の値を2や0に設定することで行います。
(Windowsのgvimの場合など。)

その他のIM切り替え方法に関しては、以下を参考にしてください。

* [日本語入力固定モード](https://sites.google.com/site/fudist/Home/vim-nihongo-ban/vim-japanese/ime-control)
* `'imactivatekey'`関係
 * https://github.com/koron/imcsc-vim/
 * [Ubuntu上のVimでIME(ibus制御)](http://www.kaoriya.net/blog/2013/07/15/)
 * [CUIでもimaf/imsfを使いたい - Issue #444 - vim-jp/issues - GitHub](https://github.com/vim-jp/issues/issues/444)

IM切り替え方法のカスタマイズをしたい場合は、
IM切り替えを行う関数を定義して、
その関数名を`imactivatemap_imifunc`や`imactivatemap_imsfunc`に設定してください
(以下の設定例も参考)。

関数の引数は`'imactivatefunc'`と同じです。

これらのカスタマイズした関数をIMオフ目的で呼ぶ`<Plug>`として、
`<Plug>(imactivatemap-reset)`をnnoremapしてあります。
Insert modeを`Esc`で抜けるとIMオフになるように設定するには、
```
 inoremap <silent> <unique> <Esc> <Esc>:set imsearch=0 iminsert=0<CR>
```
のかわりに
```
 imap <silent> <unique> <Esc> <Esc><Plug>(imactivatemap-reset)
```
と設定してください。

## 設定例: tcvime(1.5.0)の場合
tcvimeは`keymap`を使うので、
tcvime#Activate()では、`&iminsert`の値を1や0に設定しています。

```vim
" g/, g?, /, ?の検索でIMのオン/オフを切り替えるため、imsearchをセットする関数
function! ImActivateMapImsFunc(active)
  if !a:active
    set imsearch=0
    return
  endif
  if &keymap != ''
    set imsearch=1
    return
  endif
  " keymap未設定時はロードが必要
  call tcvime#Activate(1)
  set imsearch=1
  " tcvime#Activate(1)で&imi=1になるが、g/直後のa等ではオフにしておきたいので
  call tcvime#Activate(0)
endfunction
let imactivatemap_imsfunc = 'ImActivateMapImsFunc'
let imactivatemap_imifunc = 'tcvime#Activate'
imap <silent> <unique> <Esc> <Esc><Plug>(imactivatemap-reset)
```

## 関連
* [contextimi.vim](https://github.com/deton/contextimi.vim):
  `c`,`s`,`r`コマンドで、書き換え前の文字列に応じてIMオン/オフを切り替えるVimプラグイン。
  imactivatemap.vimとの共存は未対応。

* [日本語入力固定モード](https://sites.google.com/site/fudist/Home/vim-nihongo-ban/vim-japanese/ime-control)
