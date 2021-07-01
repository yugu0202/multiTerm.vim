"yggdrasilt vim plugin

let term_buflist = []
let job_dict = {}
let term_num = 1

hi User8 ctermfg=46 ctermbg=16
hi User9 ctermfg=15 ctermbg=16

func! SetTermStatusLine()
	let l:term_statusline = '%9*'
	for b in g:term_buflist
		if b == g:term_buflist[g:active_num]
			let l:term_statusline = trim(l:term_statusline,'|') . '%*%8*' . bufname(b) . '%*%9*'
		else
			let l:term_statusline = l:term_statusline . bufname(b) . '|'
		endif
	endfor
	return l:term_statusline
endfunc

func TermWindow(mods)
	call execute(a:mods . " new")
endfunc


func JobExit(job,status)
	let g:exit_buf = g:job_dict[job_info(a:job)["process"]]
	call filter(g:term_buflist,'v:val !~ g:exit_buf')
	unlet g:job_dict[job_info(a:job)["process"]]
	if winnr() != g:term_win
		call win_gotoid(g:term_win)
	endif
	if empty(g:term_buflist)
		quit!
		unlet g:active_num
		return 0
	elseif g:active_num > (len(g:term_buflist) - 1)
		let g:active_num = 0
	endif
	call execute("b! " . g:term_buflist[g:active_num])
	setlocal statusline=%!SetTermStatusLine()
endfunc


func yggdrasill#YggdrasillTerm(mods)
	let l:active_term = term_start("/bin/bash",{"term_name":"yggdrasillTerm" . g:term_num,"hidden":1,"exit_cb":function("JobExit")})
	call add(g:term_buflist,l:active_term)
	let g:job_dict[job_info(term_getjob(l:active_term))["process"]] = l:active_term
	if !exists('g:active_num')
		let g:active_num = 0
		call TermWindow(a:mods)
	else
		if bufwinid(g:term_buflist[g:active_num]) == -1
			call TermWindow(a:mods)
		elseif winnr() != bufwinid(g:term_buflist[g:active_num])
			call win_gotoid(bufwinid(g:term_buflist[g:active_num]))
		endif
		let g:term_win = bufwinid(g:term_buflist[g:active_num])
		let g:active_num = g:active_num + 1
	endif
	call execute("b! " . g:term_buflist[g:active_num])
	tmap <silent><buffer> <C-y>l <C-w>:call yggdrasill#TermNext()<CR>
	tmap <silent><buffer> <C-y><C-l> <C-w>:call yggdrasill#TermNext()<CR>
	tmap <silent><buffer> <C-y>h <C-w>:call yggdrasill#TermPrev()<CR>
	tmap <silent><buffer> <C-y><C-h> <C-w>:call yggdrasill#TermPrev()<CR>
	setlocal statusline=%!SetTermStatusLine()
	let g:term_num = g:term_num + 1
endfunc


func yggdrasill#YggdrasillScreen()
	let l:active_term = term_start("/bin/bash",{"term_name":"yggdrasillTerm" . g:term_num,"hidden":1,"exit_cb":function("JobExit")})
	call add(g:term_buflist,l:active_term)
	let g:job_dict[job_info(term_getjob(l:active_term))["process"]] = l:active_term
	if !exists('g:term_win')
		call TermWindow(a:mods)
		let g:active_num = 0
	else
		let g:active_num = g:active_num + 1
	endif
	if winnr() != g:term_win
		call win_gotoid(g:term_win)
	endif
	call execute("b! " . g:term_buflist[g:active_num])
	tmap <silent><buffer> <C-y>l <C-w>:call yggdrasill#TermNext()<CR>
	tmap <silent><buffer> <C-y><C-l> <C-w>:call yggdrasill#TermNext()<CR>
	tmap <silent><buffer> <C-y>h <C-w>:call yggdrasill#TermPrev()<CR>
	tmap <silent><buffer> <C-y><C-h> <C-w>:call yggdrasill#TermPrev()<CR>
	setlocal statusline=%!SetTermStatusLine()
	let g:term_num = g:term_num + 1
endfunc


func yggdrasill#TermNext()
	let g:active_num = g:active_num + 1
	if g:active_num > (len(g:term_buflist) - 1)
		let g:active_num = 0
	endif
	call execute("b! " . g:term_buflist[g:active_num])
	setlocal statusline=%!SetTermStatusLine()
endfunc


func yggdrasill#TermPrev()
	let g:active_num = g:active_num - 1
	if g:active_num < 0
		let g:active_num = (len(g:term_buflist) - 1)
	endif
	call execute("b! " . g:term_buflist[g:active_num])
	setlocal statusline=%!SetTermStatusLine()
endfunc


