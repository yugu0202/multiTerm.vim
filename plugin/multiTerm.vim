if exists('g:loaded_multiTerm')
	finish
endif
let g:loaded_multiTerm = 1
let g:MT_screen_cooperation = 0

func! MTcomp(lead,line,pos)
	let l:comp = []

	if g:MT_screen_cooperation == 0
		return []
	endif

	if a:line == "MTerm "
		call add(l:comp,"-screen")
	elseif a:line =~ "^MTerm -screen "
		call add(l:comp,"example")
	endif

	let l:rtComp = deepcopy(l:comp)

	for l:text in l:comp
		if l:text !~ "^".a:lead
			call filter(l:rtComp, 'v:val != "'.l:text.'"')
		endif
	endfor

	return l:rtComp
endfunc

command! -nargs=* -complete=customlist,MTcomp MTerm call multiTerm#multiTerm(<q-mods>,<f-args>)
command! MNext call multiTerm#TermNext()
command! MPrev call multiTerm#TermPrev()
