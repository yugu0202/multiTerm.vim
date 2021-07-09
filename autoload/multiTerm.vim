"multiTerm vim plugin

let term_buflist = []
let job_dict = {}
let term_num = 1

hi MTactive ctermfg=46 ctermbg=8
hi MTpassive ctermfg=15 ctermbg=8


func! SetTermStatusLine()
	let l:term_statusline = '%#MTpassive#'
	for b in g:term_buflist
		if b == g:term_buflist[g:active_num]
			let l:term_statusline = l:term_statusline . '%#MTactive#' . bufname(b) . '%#MTpassive#|'
			let l:num = 1
		else
			let l:term_statusline = l:term_statusline . bufname(b) . "|"
		endif
	endfor
	return l:term_statusline
endfunc

func TermSetUp()
	tmap <silent><buffer> <C-m>l <C-w>:call multiTerm#TermNext()<CR>
	tmap <silent><buffer> <C-m><C-l> <C-w>:call multiTerm#TermNext()<CR>
	tmap <silent><buffer> <C-m>h <C-w>:call multiTerm#TermPrev()<CR>
	tmap <silent><buffer> <C-m><C-h> <C-w>:call multiTerm#TermPrev()<CR>
	setlocal statusline=%!SetTermStatusLine()
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
		let g:term_num = 1
		return 0
	elseif g:active_num > (len(g:term_buflist) - 1)
		let g:active_num = 0
	endif
	call execute("b! " . g:term_buflist[g:active_num])
	setlocal statusline=%!SetTermStatusLine()
endfunc


func multiTerm#multiTerm(mods,...)
	if index(a:000,"-screen") != -1
		let l:screen_name = a:000[index(a:000,"-screen") + 1]
	endif
	let l:active_term = term_start("/bin/bash",{"term_name":"yggdrasillTerm" . g:term_num,"hidden":1,"exit_cb":function("JobExit")})
	call add(g:term_buflist,l:active_term)
	let g:job_dict[job_info(term_getjob(l:active_term))["process"]] = l:active_term

	if !exists('g:active_num')
		let g:active_num = 0
		call execute(a:mods . " new")
	elseif bufwinid(g:term_buflist[g:active_num]) == -1
		call execute(a:mods . " new")
		let g:active_num = len(g:term_buflist) - 1
	else
		if winnr() != bufwinid(g:term_buflist[g:active_num])
			call win_gotoid(bufwinid(g:term_buflist[g:active_num]))
		endif
		let g:active_num = g:active_num + 1
	endif
	call execute("b! " . g:term_buflist[g:active_num])
	let g:term_win = bufwinid(g:term_buflist[g:active_num])

	call TermSetUp()
	let g:term_num = g:term_num + 1
endfunc


func multiTerm#multiScreen()
	let l:active_term = term_start("/bin/bash",{"term_name":"yggdrasillTerm" . g:term_num,"hidden":1,"exit_cb":function("JobExit")})
	call add(g:term_buflist,l:active_term)
	let g:job_dict[job_info(term_getjob(l:active_term))["process"]] = l:active_term

	if !exists('g:active_num')
		let g:active_num = 0
		call execute(a:mods . " new")
	elseif bufwinid(g:term_buflist[g:active_num]) == -1
		call execute(a:mods . " new")
		let g:active_num = len(g:term_buflist) - 1
	else
		if winnr() != g:term_num
			call win_gotoid(g:term_num)
		endif
		let g:active_num = g:active_num + 1
	endif
	call execute("b! " . g:term_buflist[g:active_num])
	let g:term_win = bufwinid(g:term_buflist[g:active_num])

	call TermSetUp()

	let g:term_num = g:term_num + 1
endfunc


func multiTerm#TermNext()
	let g:active_num = g:active_num + 1
	if g:active_num > (len(g:term_buflist) - 1)
		let g:active_num = 0
	endif
	call execute("b! " . g:term_buflist[g:active_num])
	setlocal statusline=%!SetTermStatusLine()
endfunc


func multiTerm#TermPrev()
	let g:active_num = g:active_num - 1
	if g:active_num < 0
		let g:active_num = (len(g:term_buflist) - 1)
	endif
	call execute("b! " . g:term_buflist[g:active_num])
	setlocal statusline=%!SetTermStatusLine()
endfunc


