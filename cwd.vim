" Main function Begins here
function ChangeWorkDir()
    call DirFilePos()

    " No DirFile exists exception handling
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
            echo "\nDirFile created, please add Dir paths(one per line)"
            return 0
        elseif l:_validate == "n"
            return 0
        endif
    endtry
    " End exception handling
    
    call PrintDirs()

    let s:dirNum = InputSth("\nEnter Dir Number: ")

    " This if control need to be improved
    if s:dirNum == "q"
        return 0
    endif

    call ValidateInputDirNumber("Please enter a valid number!\n" . 'Or "q" to quit.' . "\n", "\nEnter Dir Number: ") " Make sure the input number is valid

    " So is this one
    if s:dirNum == "q"
        return 0
    endif

    try
        execute "cd " . s:dirsList[s:dirNum - 1]
    catch /E344:/
        echo "\nPlease choose a valid path, maybe you should edit the DirFile."
    endtry
    echo "\nNow you are in \"" . getcwd() . "\""

    return 0
endfunction
" Main Function ENDS 


function AddCurrentDir() " Add Current Dir to the DirFile
    call DirFilePos()
    let l:currentDir = getcwd()
    let s:dirsList = readfile(g:dir_file_pos)

    let l:index = 0
    while l:index < len(s:dirsList)
        if l:currentDir == expand(s:dirsList[l:index])
            echo "\nCurrnt Dir is already in the DirFile."
            return 0
        endif
        let l:index += 1
    endwhile

    call add(s:dirsList, l:currentDir)
    call writefile(s:dirsList, g:dir_file_pos)

    return 0
endfunction

function DelDir() " Delete a specified Dir from the DirFile
    call DirFilePos()
    let s:dirsList = readfile(g:dir_file_pos)
    call PrintDirs()

    let s:dirNum = InputSth("\nEnter Dir Number: ")

    if s:dirNum == "q"
        return 0
    endif

    call ValidateInputDirNumber("\nPlease enter a valid number\nor \"q\" to quit", "\nDelete which one? ")
    if s:dirNum == "q"
        return 0
    endif

    unlet s:dirsList[s:dirNum - 1]
    call writefile(s:dirsList, g:dir_file_pos)

    return 0
endfunction

function ShowDirList() " Simply show a list of directories stored in DirFile
    call DirFilePos()
    let s:dirsList = readfile(g:dir_file_pos)
    call PrintDirs()
endfunction

function InputSth(_entry) " To simplify the input function
    call inputsave()
    let l:getInput = input(a:_entry)
    call inputrestore()

    return l:getInput
endfunction

function PrintDirs() " Print directories list on screen
    let l:index = 0
    while l:index < len(s:dirsList)
        echo l:index + 1 . ". " . s:dirsList[l:index] . "\n"
        let l:index += 1
    endwhile

    return 0
endfunction

function ValidateInputDirNumber(warningString, promptString) " Validate if the user inputs the valid value.
    while (s:dirNum > len(s:dirsList)) || (s:dirNum < 1) || (str2nr(s:dirNum) == 0)
        echo a:warningString
        unlet s:dirNum
        let s:dirNum = InputSth(a:promptString)
        if s:dirNum == "q"
            break
        endif
    endwhile

    return 0
endfunction

function DirFilePos() " Check if the global option exists in .vimrc
    if !exists("g:dir_file_pos")
        let g:dir_file_pos = "/home/kols/.vim/own_funcs/cdworkdir/dirs"
    endif
endfunction
