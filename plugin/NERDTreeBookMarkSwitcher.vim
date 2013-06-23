" ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ "
" ~~~~~~~~~~~~~~~~~~~~~~~~~~~ NERDTreeBookMarkSwitcher.vim ~~~~~~~~~~~~~~~~~~~~~~~~~~ "
" ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ "
" Author:
" 	Sheldon Irwin
" Description: 	
" 	A simple script to allow switching between bookmark sets in NERDTree.
" File:
" 	plugin/NERDTreeBookMarkSwitcher.vim
" ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ "
" ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ "

" Fields {{{1

"guard against sourcing the script twice
if exists("g:loaded_nerdtree_bookmark_switcher")
    finish
endif
let g:loaded_nerdtree_bookmark_switcher = 1

let s:Switcher = {}
let g:NERDSwitcher = s:Switcher
let s:validChars = "[a-zA-Z0-9_\\- ]"

" FUNCTION! GetNERDFile(isSets) {{{1
function! s:Switcher.GetNERDFile(isSets)
	let fname = "NERDTreeBookmarks"
	if (a:isSets)
		" Get the sets file instead ("0" is falsy..)
		let fname = fname."Sets"
	endif
	if has("amiga")
		return "s:.".fname
	elseif has("win32")
		return $HOME."\_".fname
	else
		return $HOME."/.".fname
	endif
endfunction

" FUNCTION! SwitchBookmarkSet(name) - switch to the parameterized set {{{1
function! s:Switcher.SwitchBookmarkSet(name)
	" Get the two working files {{{2
	let bookmarksFile	= s:Switcher.GetNERDFile(0)
	let setsFile		= s:Switcher.GetNERDFile(1)
	" Basic Switch - Switch the #{current}# tag {{{2
	let currentRegex 	= "^#{current}# " . s:validChars . "*$"   
	let setRegex	 	= "^# " . a:name . "$"   
	" Loop through setsFile, look for #{current}# {{{2
	let sets 				= readfile(setsFile)
	let bookmarks 			= []
	let doCompileBookmarks 	= 0
	" Check if already active, else switch {{{2
	if (match(sets, "^#{current}# " . a:name . "$") >= 0)
		echo "Set '" . a:name . "' is already active."
	else
		" Find Current if Exists - save state {{{2
		let index = match(sets, currentRegex, 0, 1)
		if (index >= 0)
			" Current set exists, update bookmarks in sets; clear the bookmarks file
			let newLine = split(remove(sets, index), "#{current}")[0]
			call insert(sets, newLine, index)
			" remove each bookmark under current set
			while (index+1 < len(sets) && match(get(sets, index+1), "^[^#].*$") >= 0)
				call remove(sets, index+1)
			endwhile
		else
			" Add as new 'unnamed bookmark set'
			call add(sets, "# unnamed bookmark set")
		endif
		" add bookmarks from .NERDTreeBookmarks
		for line in reverse(readfile(bookmarksFile))
			if (match(line, "^$") < 0)
				if (index >= 0)
					call insert(sets, line, index + 1)
				else 
					call add(sets, line)
				endif
			endif
		endfor
		" Find Set if Exists (case insensitive) {{{2
		let index = match(sets, setRegex, 0, 1)
		if (index >= 0) 
			" Set exists, switch to it...
			let newLine = "#{current}" . remove(sets, index)
			call insert(sets, newLine, index)
			" Create a list of bookmarks from the (switch-to) set
			while (index+1 < len(sets) && match(get(sets, index+1), "^[^#].*$") >= 0)
				call add(bookmarks, get(sets, index+1))
				let index += 1
			endwhile
			" Write to the bookmarks file and reload it
			call writefile(bookmarks, bookmarksFile)
		else
			" Create a new set...
			call add(sets, "#{current}# " . a:name)
			call writefile(bookmarks, bookmarksFile)
		endif
	endif

	" Write the sets file..
	call writefile(sets, setsFile)
	
endfunction

" FUNCTION! ListBookmarkSets() - List all available sets {{{1
function! s:Switcher.ListBookmarkSets() 
	let setsFile = s:Switcher.GetNERDFile(1)
	if filereadable(setsFile)
		for line in readfile(setsFile)
			if match(line, "^# [a-zA-Z0-9 _-]*$") >= 0
				" Print only the set name
				echo split(line, "# ")[0]      
			elseif match(line, "^#{current}# [a-zA-Z0-9 _-]*$") >= 0   
				" Print the set name and append {current}
				echo split(line, "#{current}# ")[0] . " {current}"
			endif
		endfor
	else
		echo "No sets exist -> Create a new set with \"BookmarksNewSet {name}\""
	endif
endfunction

" FUNCTION! RenameBookmarkSet(toName) - Rename the current set to 'toName' {{{1
function! s:Switcher.RenameBookmarkSet(toName)
	if (exists("a:toName") && a:toName!="" && match(a:toName, "^" . s:validChars . "\\+$") >= 0)
		let setsFile = s:Switcher.GetNERDFile(1)
		let sets = readfile(setsFile)
		let index = match(sets, "^#({current}#)? " + a:toName + "$", 0, 1)
		if (index >= 0)
			" Set found, is current?
			if (match(get(sets, index), "^# " . a:toName . "$", 0, 1) >= 0)
				" Set with name 'a:toName..' already exists
				echo "Set '" . a:toName . "' already exists and is not active, could not rename current set."
			else
				" Set is current.. 
				echo "Current set already has name '" . a:toName . "'."
			endif
		else
			" Set does not exist, rename to this..
			let index = match(sets, "^#{current}# .*$")
				if (index >= 0)
				let newLine = "#{current}# " . a:toName
				call remove(sets, index)
				call insert(sets, newLine, index)
			else
				echo "There is no current set.. has the sets file been edited manually?"
			endif
		endif
		call writefile(sets, setsFile)
	endif
endfunction

" FUNCTION! RemoveBookmarkSet(toName) - Remove the parameterized set {{{1
function! s:Switcher.RemoveBookmarkSet(name)
	if (exists("a:name") && a:name!="" && match(a:name, "^" . s:validChars . "\\+$") >= 0)
		let setsFile = s:Switcher.GetNERDFile(1)
		let sets	 = readfile(setsFile)
		if (match(sets, "^# " . a:name . "$") >= 0)
			" The set exists
			let index = match(sets, "^# " . a:name . "$")
			call remove(sets, index)
			while (index < len(sets) && match(get(sets, index), "^[^#].*$") >= 0)
				call remove(sets, index)
			endwhile
		elseif (match(sets, "^#{current}# " . a:name . "$") >= 0)
			" Set is current
			let index = match(sets, "^#{current}# " . a:name . "$")
			call remove(sets, index)
			while (index < len(sets) && match(get(sets, index), "^[^#].*$") >= 0)
				call remove(sets, index)
			endwhile
			" Remove current bookmarks
			call writefile([], s:Switcher.GetNERDFile(0))
			" Switch to first set... if available
			if len(sets) > 0
				" Add #{current}# to the first set
				let newLine = "#{current}" . remove(sets, 0)
				" Replace the existing bookmarks with bookmarks from first set
				let bookmarks = []
				let index = 0
				while (index < len(sets) && match(get(sets, index), "^[^#].*$") >= 0)
					call add(bookmarks, get(sets, index))
					let index += 1
				endwhile
				call insert(sets, newLine, 0)
				" Write bookmarks to file
				call writefile(bookmarks, s:Switcher.GetNERDFile(0))
			endif
		else
			" The set does not exist
			echo "Set '" . a:name . "' does not exist"
		endif
		" Write any changes to setsFile
		call writefile(sets, setsFile)
		"for line in sets
		"	echo line
		"endfor
	else
		echo "'" . a:name . "' is not a valid set name."
	endif
endfunction

