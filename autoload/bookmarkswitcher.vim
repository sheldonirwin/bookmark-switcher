" ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ "
" ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ bookmarkswitcher.vim ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ "
" ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ "
" Author:
" 	Sheldon Irwin
" Description: 	
" 	A simple script to allow switching between bookmark sets in NERDTree.
" File:
" 	autoload/bookmarksswitcher.vim
" ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ "
" ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ "

"guard against sourcing the script twice
if exists("g:loaded_bookmarkswitcher")
    finish
endif
let g:loaded_bookmarkswitcher = 1

" FUNCTION! completeSets {{{1
function! bookmarkswitcher#completeSets(A,L,P)
	let setsFile = g:NERDSwitcher.GetNERDFile(1)
	let completeList = []
	if filereadable(setsFile)
		for line in readfile(setsFile)
			if match(line, "^# [a-zA-Z0-9 _-]*$") >= 0
				" Add name only to list
				call add(completeList, split(line, "# ")[0])
			elseif match(line, "^#{current}# [a-zA-Z0-9 _-]*$") >= 0   
				" Add name only to list (remove {current})
				call add(completeList, split(line, "#{current}# ")[0])
			endif
		endfor
	endif
    "return filter(completeList, 'v:val =~# "^' . a:A . '"')
	return filter(completeList, 'v:val =~# "^' . a:A . '.*$"')
endfunction

