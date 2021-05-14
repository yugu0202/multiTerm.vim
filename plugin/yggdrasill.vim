if exists('g:loaded_yggdrasill')
	finish
endif
let g:loaded_yggdrasill = 1

command! Test call yggdrasill#Test()
