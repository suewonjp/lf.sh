set tabstop=2 softtabstop=2 shiftwidth=2 expandtab

:nnoremap <f8> :wa \| !test/file-listing.bats<CR>
:nnoremap <f9> :wa \| !test/selecting.bats && test/filtering.bats<CR>

