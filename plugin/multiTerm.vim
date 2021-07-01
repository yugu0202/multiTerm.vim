if exists('g:loaded_multiTerm')
	finish
endif
let g:loaded_multiTerm = 1

command! -complete=file -nargs=* MTerm call multiTerm#multiTerm(<q-mods>,<f-args>)
