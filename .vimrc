" vim: sw=2:

set tabstop=2 softtabstop=2 shiftwidth=2 expandtab

set cpt+=ktest/*.bats,ktest/*.bash

set path=$PWD,$PWD/test/**,$PWD/extra/**

set wildignore+=tags,test/fixtures/**,test/.tmp/**,.git/**

let $BASH_ENV=''

nnoremap <f8> :wa \| !test/file-listing.bats && test/grepping.bats<CR>
nnoremap <f9> :wa \| !test/selecting.bats && test/filtering.bats<CR>

au BufRead,BufNewFile *.bats set filetype=sh

let g:is_bash = 1

silent! args $PWD lf.sh test/*.bats test/*.bash

