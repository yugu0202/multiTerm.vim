if exists('g:loaded_multiTerm')
	finish
endif
let g:loaded_multiTerm = 1
if ! system("screen -v 1>/dev/null")
	let g:MT_screen_cooperation = 1
else
	let g:MT_screen_cooperation = 0
endif

func! MTcomp(lead,line,pos)
	let l:comp = []

	if a:line =~ "^MTerm.*-screen.*$" && g:MT_screen_cooperation == 1
		let l:screen = system('screen -ls | sed -e ''1d'' -e ''$d'' -e ''s/.*\.\(.*\)*(.*(.*/\1/'' -e s/"\t"//g') " screenが死んでるときの対策必要
		let l:screen_list = split(l:screen,"\n")
		for l:screen_name in l:screen_list
			call add(l:comp,l:screen_name)
		endfor
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
	endfor


	return l:rtComp
endfunc

command! -nargs=* -complete=customlist,MTcomp MTerm call multiTerm#multiTerm(<q-mods>,<f-args>)
command! MNext call multiTerm#TermNext()
command! MPrev call multiTerm#TermPrev()
