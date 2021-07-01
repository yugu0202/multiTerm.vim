if exists('g:loaded_yggdrasill')
	finish
endif
let g:loaded_yggdrasill = 1

command! -complete=file -nargs=* YTerm call yggdrasill#YggdrasillTerm(<q-mods>,<f-args>)
