NERD Bookmark Switcher
======================

1.0 (2013-06-23)

Description
-----------

The NERD Bookmark Switcher is a complementary bookmarks set management plugin
for The NERD Tree. It allows you to organise your NERD Tree bookmarks into sets
which can then be switched between, renamed, removed, added, etc. with four 
simple commands:

	:ListBookmarkSets			- List all bookmark sets
	:SwitchBookmarkSet (name)	- Switch to (or add) set
	:RemoveBookmarkSet (name)	- Remove an existing bookmark set
	:RenameBookmarkSet (toName)	- Rename the current bookmark set

TODO
----

The following features and functionality have yet to be implemented:

  * Common Bookmarks
  * Alternate (:b# style) between two sets
  * Segregate installation process from NERD Tree 
    * Remove 'nerdtree/lib/nerdtree/creator.vim' integration
    * Discover nerdtree init event
  * Create vim documentation

Installation
------------

Install [nerdtree.vim](https://github.com/scrooloose/nerdtree).

[pathogen.vim](https://github.com/tpope/vim-pathogen) is the recommended way to install 
nerdtree and the the bookmark switcher plugin.

    cd ~/.vim/bundle
    git clone https://github.com/sheldonirwin/bookmark-switcher.git


Append the following lines to the bottom of the 'function! s:Creator._bindMappings()' 
function in 'nerdtree/lib/nerdtree/creator.vim'. (approximately line 23)

    " START {NERDBookmarksSwitcher}
    command! -buffer -complete=customlist,bookmarkswitcher#completeSets -nargs=1 SwitchBookmarkSet call g:NERDSwitcher.SwitchBookmarkSet('<args>') <bar> call g:NERDTreeBookmark.CacheBookmarks(0) <bar> call nerdtree#renderView()
    command! -buffer -complete=customlist,bookmarkswitcher#completeSets -nargs=1 RemoveBookmarkSet call g:NERDSwitcher.RemoveBookmarkSet('<args>') <bar> call g:NERDTreeBookmark.CacheBookmarks(0) <bar> call nerdtree#renderView()
    command! -buffer -nargs=1 RenameBookmarkSet call g:NERDSwitcher.RenameBookmarkSet('<args>')
    command! -buffer -nargs=0 ListBookmarkSets call g:NERDSwitcher.ListBookmarkSets()
    " END {NERDBookmarksSwitcher}

