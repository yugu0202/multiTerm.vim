"multiTerm vim plugin ver.0.1.4dev

let s:term_buflist = []
let s:job_dict = {}
let s:term_num = 1

hi MTactive ctermfg=46 ctermbg=8
hi MTpassive ctermfg=15 ctermbg=8


func! SetTermStatusLine()
	let l:term_statusline = '%#MTpassive#'
	for b in s:term_buflist
		if b == s:term_buflist[s:active_num]
			let l:term_statusline = l:term_statusline . '%#MTactive#' . bufname(b) . '%#MTpassive#|'
			let l:num = 1
		else
			let l:term_statusline = l:term_statusline . bufname(b) . "|"
		endif
	endfor
	return l:term_statusline
endfunc


func JobExit(job,status)
	let s:exit_buf = s:job_dict[job_info(a:job)["process"]]
	call filter(s:term_buflist,'v:val !~ s:exit_buf')
	unlet s:job_dict[job_info(a:job)["process"]]
	if winnr() != s:term_win
		call win_gotoid(s:term_win)
	endif
	if empty(s:term_buflist)
		quit!
		unlet s:active_num
		let s:term_num = 1
		return 0
	elseif s:active_num > (len(s:term_buflist) - 1)
		let s:active_num = 0
	endif
	call execute("b! " . s:term_buflist[s:active_num])
	setlocal statusline=%!SetTermStatusLine()
endfunc


func multiTerm#multiTerm(mods,...)
	if index(a:000,"-screen") != -1
		let l:screen_name = a:000[index(a:000,"-screen") + 1]
	endif
	let l:active_term = term_start("/bin/bash",{"term_name":"yggdrasillTerm" . s:term_num,"hidden":1,"exit_cb":function("JobExit")})
	call add(s:term_buflist,l:active_term)
	let s:job_dict[job_info(term_getjob(l:active_term))["process"]] = l:active_term

	if !exists('s:active_num')
		let s:active_num = 0
		call execute(a:mods . " new")
	elseif bufwinid(s:term_buflist[s:active_num]) == -1
		call execute(a:mods . " new")
		let s:active_num = len(s:term_buflist) - 1
	else
		if winnr() != bufwinid(s:term_buflist[s:active_num])
			call win_gotoid(bufwinid(s:term_buflist[s:active_num]))
		endif
		let s:active_num = s:active_num + 1
	endif
	call execute("b! " . s:term_buflist[s:active_num])
	let s:term_win = bufwinid(s:term_buflist[s:active_num])

	setlocal statusline=%!SetTermStatusLine()
	let s:term_num = s:term_num + 1
endfunc


func multiTerm#TermNext()
	let s:active_num = s:active_num + 1
	if s:active_num > (len(s:term_buflist) - 1)
		let s:active_num = 0
	endif
	call execute("b! " . s:term_buflist[s:active_num])
	setlocal statusline=%!SetTermStatusLine()
endfunc


func multiTerm#TermPrev()
	let s:active_num = s:active_num - 1
	if s:active_num < 0
		let s:active_num = (len(s:term_buflist) - 1)
	endif
	call execute("b! " . s:term_buflist[s:active_num])
	setlocal statusline=%!SetTermStatusLine()
endfunc


