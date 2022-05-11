if exists('g:loaded_multiTerm')
	finish
endif
let g:loaded_multiTerm = 1
if system("screen -v 1>/dev/null") == ""
	let g:MT_screen_cooperation = 1
else
	let g:MT_screen_cooperation = 0
endif

func! MTcomp(lead,line,pos)
	let l:comp = []

	if a:line =~ "^MTerm.*-screen \a*$" && g:MT_screen_cooperation == 1
		let s:screenList = system("screen -ls") "ここで分割してfor文でリスト化　このままだと動かない　screenが死んでるときの対策必要
		call add(l:comp,s:screenList)
	elseif a:line =~ "MTerm.*$"
		if g:MT_screen_cooperation == 1
			call add(l:comp,"-screen")
		endif
		call add(l:comp,"-name")
	endif

	let l:rtComp = deepcopy(l:comp)

	for l:text in l:comp
		if l:text !~ "^". a:lead
			call filter(l:rtComp, 'v:val != "'.l:text.'"')
		endif
		
		if match(a:line,l:text) != -1
			call filter(l:rtComp, 'v:val != "'.l:text.'"')
		endif
	endfor


	return l:rtComp
endfunc

command! -nargs=* -complete=customlist,MTcomp MTerm call multiTerm#multiTerm(<q-mods>,<f-args>)
command! MNext call multiTerm#TermNext()
command! MPrev call multiTerm#TermPrev()
