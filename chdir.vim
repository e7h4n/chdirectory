" ##### Configurations Begin #####
if !exists("g:dir_file_pos")
	if has("win32") || has("win64")
		let g:dir_file_pos = expand($VIM) . "\\vimfiles\\dirfile"
	elseif has("unix")
		let g:dir_file_pos = expand($HOME) . "/.vim/dirfile"
	endif
endif

	" ### User-defined command ###
command Changedir call ChangeWorkDir()
command Addcurrentdir call AddCurrentDir()
command Deletedir call DelDir()
command Showdirlist call ShowDirList()

	" ### Mapping ###
nmap <leader>cd :Changedir<CR>
nmap <leader>da :Addcurrentdir<CR>
nmap <leader>dd :Deletedir<CR>
nmap <leader>sd :Showdirlist<CR>

" ##### Configurations End #####



" ##### Main function Begin #####
function ChangeWorkDir()
	try
		call CheckIfDirFileExists()
	catch /Quit/
		return 0
	endtry
    
    call PrintDirs()

    let s:dirNum = InputSth("\nChoose directory number: ")

    try
		call ValidateInputDirNumber("\nPlease enter a valid number!\nOr \"q\" to quit.\n", "Choose directory number: ")
	catch /Quit/
		return 0
	endtry

    try
        execute "cd " . s:dirsList[s:dirNum - 1]
    catch /E344:/
        echo "\nPlease choose a valid path, maybe you should edit the DirFile."
    endtry
    echo "\nNow you are in \"" . getcwd() . "\""

    return 0
endfunction

	" ### Add Current Dir to the DirFile ###
function AddCurrentDir() 
	try
		call CheckIfDirFileExists()
	catch /Quit/
		return 0
	endtry

    let l:currentDir = getcwd()

    let l:index = 0
    while l:index < len(s:dirsList)
        if (l:currentDir ==# s:dirsList[l:index]) || (l:currentDir ==# strpart(s:dirsList[l:index], 0, strlen(s:dirsList[l:index]) - 1))
            echo "\nCurrnt directory is already in the list."
            return 0
        endif
        let l:index += 1
    endwhile

    call add(s:dirsList, l:currentDir)
    call writefile(s:dirsList, g:dir_file_pos)
	echo "Current directory has been added."

    return 0
endfunction

	" ### Delete a specified Dir from the DirFile ###
function DelDir() 
	try
		call CheckIfDirFileExists()
	catch /Quit/
        echo "\nNothing to delete."
		return 0
	endtry

    let s:dirsList = readfile(g:dir_file_pos)
    call PrintDirs()

    let s:dirNum = InputSth("\nDelete which one? ")

    try
		call ValidateInputDirNumber("\nPlease enter a valid number\nOr \"q\" to quit\n", "Delete which one? ")
	catch /Quit/
		return 0
	endtry

	echo "\"" . s:dirsList[s:dirNum - 1] . "\" has been deleted."
    unlet s:dirsList[s:dirNum - 1]
    call writefile(s:dirsList, g:dir_file_pos)

    return 0
endfunction

	" ### Simply show a list of directories stored in DirFile ###
function ShowDirList()
    let s:dirsList = readfile(g:dir_file_pos)
    call PrintDirs()
endfunction

" ##### Main Functions Ends #####



" ##### Minor Functions Begin #####
	" ### A wrapper func to simplify the input function ###
	" ### _entry arg is the string wanted to tell user to input ###
function InputSth(_entry)
    call inputsave()
    let l:getInput = input(a:_entry)
    call inputrestore()

    return l:getInput
endfunction

	" ### Print directories list on screen ###
function PrintDirs()
	echo "Your directories:\n"

    let l:index = 0
    while l:index < len(s:dirsList)
        echo l:index + 1 . ". " . s:dirsList[l:index] . "\n"
        let l:index += 1
    endwhile

    return 0
endfunction

	" ### Validate if the user inputs the valid value ###
	" ### warningString arg showed while validation failed ###
	" ### promptString arg tell user to reinput the value ###
function ValidateInputDirNumber(warningString, promptString)
	if s:dirNum == "q"
		throw "Quit"
	endif

    while (s:dirNum > len(s:dirsList)) || (s:dirNum < 1) || (str2nr(s:dirNum) == 0)
        echo a:warningString
        unlet s:dirNum
        let s:dirNum = InputSth(a:promptString)
        if s:dirNum == "q"
			throw "Quit"
            break
        endif
    endwhile

    return 0
endfunction

function CheckIfDirFileExists()
    try
        let s:dirsList = readfile(g:dir_file_pos)
    catch /E484:/
        let l:_validate = InputSth("\nThe spcified DirFile does not seem to exist, Do you want to create one?\n(You must first create or specify a DirFile in order to use this plugin.) (y/n): ")

        while (l:_validate != "y") && (l:_validate != "n")
            echo "\nPlease enter 'y' or 'n'."
            let l:_validate = InputSth("\nThe spcified DirFile does not exist, Do you want to create one?(y/n): ")
        endwhile

        if l:_validate == "y"
            execute "e " . g:dir_file_pos
            execute "w " . g:dir_file_pos
            echo "\nDirFile created at \"" . g:dir_file_pos . "\" please add Dir paths(one per line)"
			throw "Quit"
        elseif l:_validate == "n"
			throw "Quit"
        endif
    endtry

    return 0
endfunction

" ##### Minor Functions Ends #####
