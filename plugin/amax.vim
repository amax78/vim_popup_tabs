
if has('vim_starting')
    augroup amax_init
        autocmd!
        autocmd VimEnter * call amax#init()
    augroup END
else
    call amax#init()
endif
