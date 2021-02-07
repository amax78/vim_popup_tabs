function! amax#CustomizeYcmLocationWindow()
  " Move the window to the top of the screen.
  wincmd K
  " Set the window height to 5.
  5wincmd _
  " Switch back to working window.
  wincmd x
  wincmd p
endfunction

func! amax#init()
    augroup amax_cmds
        autocmd!
        autocmd TabNew * call amax#tab_new()
        autocmd TabEnter * call amax#tab_enter()
        autocmd TabLeave * call amax#tab_leave()
        autocmd TabClosed * call amax#tab_close()

        autocmd BufRead * call amax#buf_read_file()
        autocmd BufHidden * call amax#buf_hidden()
        autocmd BufEnter * call amax#buf_enter()
        autocmd BufLeave * call amax#buf_leave()
"        autocmd BufNew * call amax#buf_new()
        autocmd BufUnload * call amax#buf_unload()
"        autocmd BufAdd * call amax#buf_add()
        autocmd BufDelete * call amax#buf_delete()
"        autocmd BufWinEnter * call amax#buf_winenter()
"        autocmd BufWinLeave * call amax#buf_winleave()

"        autocmd WinLeave * call amax#win_leave()
"        autocmd WinEnter * call amax#win_enter()
    augroup END    

    " open tab id
    let s:otab_id = tabpagenr()

    " window list
 "   let s:wins = {  }

    " [0] - tab id
    " [1] - file name
    let s:tabs = {  s:otab_id : [ @% ] }

    " [0] - buffer id
    " [1] - buffer name
    " [2] - view buffer
    let s:buffers = { bufnr('%') : [  expand('%:p'), 1 ] }
endfunc

"
"   Other functions
"

func! amax#vim_enter()
    let l:msg = "Diff open"
 
    if &diff
        echomsg l:msg
    endif
endfunc

"
"   Window commands
"

func! amax#win_enter()
    echomsg "winenter winid=".winnr()
endfunc

func! amax#win_leave()
    echomsg "winleave winid=".winnr()
endfunc
"
"   Buffer functions
"   

func! amax#buf_open(buf_id, filename, open_flag)
"    echom "buf open ".a:buf_id

    if -1 == index(keys(s:buffers), ''.a:buf_id)
        return
    endif

    let s:buffers[a:buf_id][1] = 1
endfunc

"
"   Add buffer to list
"
func! amax#buf_create(buf_id, filename, open_flag)
"    echomsg "buf_create ".a:buf_id

"   The buffer is already exist
    if -1 != index(keys(s:buffers), ''.a:buf_id)
        return
    endif

    let l:fn = a:filename

    if "" == l:fn
        let l:fn = "[No name]"
    endif

    call extend(s:buffers, { a:buf_id : [ l:fn, a:open_flag ] })
endfunc

func! amax#buf_read_file()
"    echomsg "Buf read file ".bufnr()

    call amax#buf_create(bufnr(), expand('%:p'), 1)
endfunc

func! amax#buf_close(buf_id)
"    echomsg "buf_close ".a:buf_id

     if -1 == index(keys(s:buffers), ''.a:buf_id)
        return
    endif

    unlet s:buffers[a:buf_id]
"    call remove(s:buffers, s:buffers[a:buf_id])
endfunc

func! amax#buf_unload()
"    echomsg "Buf unload ".bufnr()
    call amax#buf_close(bufnr())
endfunc

func! amax#buf_new()
"    echomsg "Buf new ".bufnr()
endfunc

"
"   Remove buffer from tab list
"
func! amax#buf_switch(tab_id, buf_id)
"    echomsg "buf_switch ".a:buf_id

    if -1 == index(keys(s:tabs), a:tab_id)
        return
    endif

    call remove(s:tabs[a:tab_id], s:buffers[a:buf_id])
endfunc

func! amax#buf_enter()
"    echomsg "BufEnter ".bufnr()

    call amax#buf_open(bufnr(), expand('%:p'), 1)
endfunc

func! amax#buf_leave()
"    echomsg "buf_leave ".bufnr()

    call amax#buf_switch(tabpagenr(), bufnr())
endfunc

func! amax#buf_add()
"    echomsg "BufAdd bufnr=".bufnr()." ".@%
"    call amax#buf_push(bufnr(), @%, 1)
endfunc

func! amax#buf_delete()
"    echomsg "BufDelete ".bufnr()

    call amax#buf_close(bufnr())
endfunc

func! amax#buf_winenter()
"    echomsg "BufWinEnter bufnr=".bufnr()." ".@%  
"    call amax#buf_push(bufnr(), @%, 1)
endfunc

func! amax#buf_winleave()
"    echomsg "bufwinleave ".bufnr()

"    call amax#buf_close(bufnr())
endfunc

func! amax#buf_hidden()
"    echomsg "buf_hidden ".bufnr()
    let l:buf_id = bufnr()

    if -1 == index(keys(s:buffers), l:buf_id)
        return
    endif

    s:buffers[l:buf_id][1] = 0
endfunc

func! amax#obuf_list()
    let t:bufs = copy(s:buffers)
    let l:arr = []

    for [ key, val ] in items(t:bufs)
        let l:str = " "

        if 0 < val[1]
            let l:str = "*"
        endif

        let str = str." ".key. "  ".val[0]

        call add(l:arr, str)
    endfor

    if 0 == len(l:arr)
        echomsg "No buffers"
    endif

    :call popup_menu(l:arr, #{ title : 'Choose buffer', callback : 'amax#buf_select', line : 25, col: 40, highlight : 'Question', border : [], close : 'click',  padding : [1, 1, 0, 1] } )
endfunc

func! amax#buf_select(id, result)
    if -1 == a:result
        return
    endif

    let i = index(keys(s:buffers), keys(t:bufs)[a:result - 1])
    
    if -1 == i
       echo "Buffer not found!
    endif

    execute "buffer ". keys(s:buffers)[i]
endfunc

"
"   Tabs functions
"
func! amax#rm_tab(id)
    call remove(s:tabs, a:id)

    let s:otab_id = -1
endfunc

func! amax#hotkey_save(id, result)
    if a:result | :update | endif
endfunc

func! amax#tab_enter()
    echomsg "tab ent"
    let s:otab_id = tabpagenr() " opened tab id

    echomsg "Tab enter " . s:otab_id
endfunc

func! amax#tab_close()
    echomsg "Tab close"

    echomsg index(keys(s:tabs), s:otab_id)

    echomsg keys(s:tabs)

    if -1 == index(keys(s:tabs),  s:otab_id)
        echomsg "Tab not found " . s:otab_id

        return
    endif

    call amax#rm_tab(s:otab_id)
endfunc

func! amax#tab_leave()
    echomsg "Tab leave "
endfunc

func! amax#tab_new()
    echomsg "Tab new ".tabpagenr()

    :call extend(s:tabs, { tabpagenr() : [ 'No name' ] })
endfunc

func! amax#choise_tab_list(id, result)

    if -1 == a:result || len(t:tabs) < a:result
        return
    endif

    let tab_id = keys(t:tabs)[a:result - 1]
    let i = index(keys(s:tabs), tab_id)

    if -1 == i
        echomsg "The tab not found!"

        return
    endif

    execut a:result."tabn"
endfunc

func! amax#otab_list()
    let l:arr = []
    let l:my_id = tabpagenr()
    let t:tabs = copy(s:tabs)
    let w:curr_tab = 0
    let l:i = 0

    "around tabs
    for [ tab_id, buf_names ] in items(t:tabs)
        let l:str = " "

        if l:my_id == tab_id
            let l:str = "*"
            let w:curr_tab = l:i + 1
        endif

        let l:str = str.tab_id."  "

        " around open buffers
        for obuf in buf_names
            let str = str."  ".obuf
        endfor

        call add(l:arr, l:str)
        let l:i += 1
    endfor

    :call popup_menu(l:arr, #{ title : 'Choose tab', callback : 'amax#choise_tab_list', line : 25, col: 40, highlight : 'Question', border : [], close : 'click',  padding : [1, 1, 0, 1] } )
endfunc

"
"   Popup menus
"

"
"   ======================
"
