
; AmirAli Amini 
; assembly project 
; code editor




section     .fileIOMessages
    error_create_dir    db      "error in creating directory        ", NL, 0
    suces_create        db      "file created and opened for R/W    ", NL, 0
    suces_create_dir    db      "dir created and opened for R/W     ", NL, 0
    suces_close         db      "file closed                        ", NL, 0
    suces_write         db      "written to file                    ", NL, 0
    suces_open          db      "file opend for R/W                 ", NL, 0
    suces_open_dir      db      "dir opened for R/W                 ", NL, 0
    suces_append        db      "file opened for appending          ", NL, 0
    error_create        db      "error in creating file             ", NL, 0
    error_close         db      "error in closing file              ", NL, 0
    error_write         db      "error in writing file              ", NL, 0
    error_open          db      "error in opening file              ", NL, 0
    error_open_dir      db      "error in opening dir               ", NL, 0
    error_append        db      "error in appending file            ", NL, 0
    error_delete        db      "error in deleting file             ", NL, 0
    error_read          db      "error in reading file              ", NL, 0
    error_print         db      "error in printing file             ", NL, 0
    error_seek          db      "error in seeking file              ", NL, 0
    suces_delete        db      "file deleted                       ", NL, 0
    suces_read          db      "reading file is done               ", NL, 0
    suces_seek          db      "seeking file                       ", NL, 0
    inputMsg            db      "enter your file address            ", NL, 0 
    enterSearchingWord  db      "enter searching word :             ", NL, 0 
    enterReplacingWord  db      "enter replacing word :             ", NL, 0 
    numberOfChar        db      "number of char :                   ", 0 
    numberOfWord        db      "number of word :                   ", 0 
    numberOfLine        db      "number of line :                   ", 0 
    numberOfResualt     db      "number of founded words :          ", 0 
    EnterToReplace      db      "press enter to replace or anything else to continue:          ",NL, 0 
    enterWhatToAppend   db      "enter what you want to append to this file                    ",NL, 0 
    removeCharNumber    db      "how many char do you want to                                  ",NL, 0 
    saveAsDirectoryEnter db     "enter directory to save as :                                  ",NL, 0 
    fileExists          db      "file exists                                 ",NL, 0 



    endLine             db      "===================================", NL, 0 
    Menu            db      "enter what you want to do : ", NL ,"0 : Exit ", NL ,"1 : show file ", NL ,"2 : properties ", NL ,"3 : search", NL ,"4 : search and replace word", NL ,"5 : append ", NL ,"6 : remove from end ", NL ,"7 : save ", NL ,"8 : save as            ", NL, "9 : search and replace expression" ,NL, 0

    error_getdents dq 'An error appierd .',NL,0
    onReding dq "on reading : " , 0
    onSearchig dq "on searching : ",0
    fileOpend dq "file opend",NL,0


NewLine      equ     0xA
bufferlen    equ     999999999
sum_bufferlen equ     999999999


; syscall
    sys_read     equ     0
    sys_write    equ     1
    sys_open     equ     2
    sys_close    equ     3
    
    sys_lseek    equ     8
    sys_create   equ     85
    sys_unlink   equ     87

    sys_chdir    equ     80
    sys_exit     equ     60
    sys_getdents64 equ   217
    sys_mkdir      equ   83

    stdin        equ     0
    stdout       equ     1
    stderr       equ     3

; access mode
    O_directory  equ    0q0200000
    O_RDONLY     equ    0q000000
    O_WRONLY     equ    0q000001
    O_RDWR       equ    0q000002
    O_CREAT      equ    0q000100
    O_APPEND     equ    0q002000
    
;create permission mode
    sys_IRUSR    equ     0q400     ; user read premission
    sys_IWUSR    equ     0q200     ; user write premission
    sys_makenewdir equ   0q777     ;permission when making new directory




section .data
    FDfolder dq 1
    end_of_buff dq 0
    globalWordCounter dq 0
    FileNumber dq 0
    testFile db "amirali.txt",0
    lineNumber dq 0 ,
    wordNumber dq 0 ,
    charNumber dq 0 ,
    FileTextLen dq 0 ,


    clear_screen: db 27, '[2J', 27, '[H', 0 ; ANSI escape codes to clear screen and move cursor to top-left





section .intConstants
    max_byte    dd  0xff

section .stringConstants
    file_extention       db  ".txt", 0
    splitter            db  "/", 0
    outPutName          db 'resualt.txt',0

    
section .bss
    pixels                  resb    10000000

    pixels_64x_pointer      resq    1
    the_n                   resq    1
    n_array                 resb    16
    
    bfSize                  resb    4
    bfOffbits               resb    4
    biSize                  resb    4
    biWidth                 resb    4
    biHeigth                resb    4
    
    allPixelsSize           resq    1
    file_header             resb    14
    image_header            resb    100
    padding_count           resq    1
    widthSize               resq    1

    headers_pixels_gap      resb    1000000
    gap_size                resq    1
    file_tail               resb    100000
    tail_size               resq    1
    current_dir_info_buff   resb    bufferlen
    temp_bufff              resb    bufferlen
    buffer                  resb    bufferlen
    FD_first                resb    1000
    curDir                  resb    1000
    sourceFileName          resb    1000
    directory               resb    1000
    searchingWord               resb    1000
    currentFileText         resb    bufferlen
    currentFileName         resb    100
    allFilesInDirectory     resb    10000
    oneLineAnswer           resb    1000
    searchResualt           resq    1000
    replacingWord           resq    1000
    saveAsDirectory         resq    1000
    saveAsDirectoryPath     resq    1000





section .text
    global  _start

_start:

    mov rsi , inputMsg 
    call printString
    mov rax, 0
    mov rdi, 0
    mov rsi, directory
    mov rdx, 1000
    syscall

    mov byte[rsi + rax-1], 0

    mov rsi , directory
    push rsi
    call openAndReadFile


MenuWhile:

    mov rsi , Menu
    call printString

    call readNum
    
    cmp rax , 0 
    je Exit

    cmp rax , 1
    jne cm2
    call ShowFile

cm2:
    cmp rax , 2
    jne cm3
    call ShowProperties

cm3:
    cmp rax , 3
    jne cm4
    call SearchWord

cm4:
    cmp rax , 4
    jne cm5
    call SearchWordAndReplace


cm5:
    cmp rax , 5
    jne cm6
    call AppendFile

cm6:
    cmp rax , 6
    jne cm7
    call RemoveFromEnd

cm7:
    cmp rax , 7
    jne cm8
    call saveFile

cm8:
    cmp rax , 8
    jne cm9
    call saveAs

cm9:
    cmp rax , 9
    jne newOpr
    call SearchPhrsAndReplace



newOpr:
    call newLine
    mov rsi , endLine
    call printString
    call newLine
    
jmp MenuWhile







    mov rax, 0
    mov rdi, 0
    mov rsi, searchingWord
    mov rdx, 1000
    syscall
    mov byte [rsi+rax-1], 0

    mov rsi, searchingWord





    xor rax , rax 
    xor rbx , rbx 
    xor rcx , rcx
    xor rdx , rdx 
    xor r8 , r8
    xor r9 , r9
    xor r10 , r10
    xor r11 , r11




Exit:
	mov     rax,    60
    mov     rdi,    0
    syscall








ClearTerminal:

    push rax 
    push rdi 
    push rsi
    push rdx 

    mov rax, 1               ; syscall number for write (1)
    mov rdi, 1               ; file descriptor for stdout (1)
    lea rsi, clear_screen ; address of the clear_screen string
    mov rdx, 6               ; length of the clear_screen string
    syscall


    pop rdx 
    pop rsi
    pop rdi
    pop rax 
    
    
    ret



saveFile:
    push rsi
    push rdi 
    push rdx 
    push rax 
; rdi : file name; rsi : file access mode 
; rdx: file permission, do not need

    mov rdi , directory
    mov rsi ,O_RDWR

    call createFile

; rdi : file descriptor ; rsi : buffer ; rdx : length

    mov rdi , rax 
    mov rsi , currentFileText
    mov rdx , [FileTextLen]
    call writeFile

    call closeFile
    pop rax 
    pop rdx 
    pop rdi
    pop rsi
    ret



saveAs:
    push rsi
    push rdi 
    push rdx 
    push rax 
; rdi : file name; rsi : file permission


    mov rsi , saveAsDirectoryEnter
    call printString

    mov rax, 0
    mov rdi, 0
    mov rsi, saveAsDirectory
    mov rdx, 1000
    syscall
    mov byte [rsi+rax-1], 0



    mov rsi , saveAsDirectory
    call openFile

    cmp rax , 0
    jl saveAsCreateFile

    mov rdi , saveAsDirectory
    mov rsi ,O_RDWR
    mov rsi , fileExists
    call printString
    call newLine

    pop rax 
    pop rdx 
    pop rdi
    pop rsi
    ret

saveAsCreateFile:

    call createFile
   



; rdi : file descriptor ; rsi : buffer ; rdx : length

    mov rdi , rax 
    mov rsi , currentFileText
    mov rdx , [FileTextLen]
    call writeFile

    call closeFile
    
    pop rax 
    pop rdx 
    pop rdi
    pop rsi
    ret



ShowFile:
    push rsi
    mov rsi , currentFileText
    call printString
    call newLine
    pop rsi
    ret


ShowProperties:
    push rsi
    mov rsi , numberOfChar
    call printString
    mov rax , qword[charNumber]
    call writeNum
    call newLine


    mov rsi , numberOfWord
    call printString
    mov rax , qword[wordNumber]
    call writeNum
    call newLine
    

    mov rsi , numberOfLine
    call printString
    mov rax , qword[lineNumber]
    call writeNum
    call newLine
    pop rsi

    
    ret



SearchPhrsAndReplace: 
  enter 16,0
    
    %define relpacingWordLen qword[rbp - 8]
    %define searchingWordLen qword[rbp - 16]


    push rax 
    push rdi
    push rsi
    push rbx 
    push rcx


    mov rsi , enterSearchingWord
    call printString

    mov rax, 0
    mov rdi, 0
    mov rsi, searchingWord
    mov rdx, 1000
    syscall
    mov byte [rsi+rax-1], 0


    dec rax
    mov searchingWordLen , rax 


    mov rsi , enterReplacingWord
    call printString
    
    mov rax, 0
    mov rdi, 0
    mov rsi, replacingWord
    mov rdx, 1000
    syscall
    mov byte [rsi+rax-1], 0

    dec rax
    mov relpacingWordLen , rax 



    mov r13 , currentFileText
    add r13 , [FileTextLen] 
    sub r13 , rax 

    mov rsi ,currentFileText

    dec rsi

phrsWhile:
    inc rsi
    mov r13 , currentFileText
    add r13 , [FileTextLen] 
    sub r13 , searchingWordLen 
    cmp rsi , r13
    ja endSearchPhrsAndReplace
    
    mov rcx , 0
SameCheckWhile:
    cmp rcx , searchingWordLen
    jge theSamePhrs


    xor rdx  , rdx

    mov r12 , searchingWord
    mov al ,[rsi + rcx]

    mov bl , [r12 + rcx]
    cmp al, bl


    jne phrsWhile

    inc rcx 
    jmp SameCheckWhile


theSamePhrs:

    mov r9 , searchingWordLen

    mov al , '-'
    call putc
    mov al , '>'
    call putc


    mov rax, 1
    mov rdi, 1
    mov rdx, r9
    syscall

    mov al , '<'
    call putc
    mov al , '-'
    call putc


    push rsi 

    add rsi , r9
    push r9
    mov r9 , 10

    mov rax, 1
    mov rdi, 1
    mov rdx, r9
    syscall

    pop r9




    call newLine
    mov rsi , EnterToReplace
    call printString
    pop rsi

    call readNum
    cmp rax , 0 


    jne phrsWhile

    push rcx
    push rsi 

    push rbx 

    mov r10 , searchingWordLen 
    add r10 , rsi 
    mov rbx , currentFileText
    sub r10 , rbx

    pop rbx 

  
    mov r9 , searchingWordLen 
    cmp r9 , relpacingWordLen
    je ReplaceThephrs
    ja ReplacephrsIsLonger


    mov rsi , currentFileText
    add rsi , [FileTextLen]
    inc rsi
    mov rdi , currentFileText
    add rdi , [FileTextLen]
    sub rdi , searchingWordLen
    add rdi , relpacingWordLen
    add rdi , 1
    std

    mov rcx , [FileTextLen]
    sub rcx, r10
    add rcx , 2
    rep movsb 

    pop rsi 
    pop rcx 
    
    jmp ReplaceThephrs

ReplacephrsIsLonger:
    push r8 
    push rbx 

    mov r8 , rsi
    mov rbx , currentFileText
    sub r8 , rbx


    mov rsi , currentFileText
    add rsi , r10 
    mov rdi , currentFileText
    add rdi , r8
    add rdi , relpacingWordLen
    cld
    mov rcx , [FileTextLen]
    sub rcx, r10
    rep movsb


    pop rbx
    pop r8
    
    pop rsi 
    pop rcx 

ReplaceThephrs:


    push rdi 
    push rsi 
    push r8
    push rcx
    push rbx 

    mov r8 , rsi
    mov rbx , currentFileText

    sub r8 , rbx


    mov rdi , currentFileText
    add rdi , r8
    mov rsi , replacingWord
    mov rcx , relpacingWordLen
    cld
    rep movsb  



    mov rbx , relpacingWordLen

    add [FileTextLen] , rbx
    sub [FileTextLen] , r9

    mov rbx , currentFileText
    add rbx , [FileTextLen]

    mov byte[rbx] , 0


    

    pop rbx 

    pop rcx
    pop r8
    pop rsi 
    pop rdi 
  
    jmp phrsWhile


  

endSearchPhrsAndReplace:
   %undef relpacingWordLen
   %undef searchingWordLen

    pop rcx
    pop rbx 
    pop rsi
    pop rdi
    pop rax

    leave
    
    ret











SearchWordAndReplace: 
    enter 8,0
    
    %define relpacingWordLen qword[rbp - 8]

    push rax 
    push rdi
    push rsi
    push rbx 
    push rcx


    mov rsi , enterSearchingWord
    call printString

    mov rax, 0
    mov rdi, 0
    mov rsi, searchingWord
    mov rdx, 1000
    syscall
    mov byte [rsi+rax-1], 0




    mov rsi , enterReplacingWord
    call printString
    
    mov rax, 0
    mov rdi, 0
    mov rsi, replacingWord
    mov rdx, 1000
    syscall
    mov byte [rsi+rax-1], 0

    dec rax
    mov relpacingWordLen , rax 


    mov rsi, searchingWord


    push rax
    mov rax , currentFileText
    push rax 
    mov rax, searchingWord
    push rax
    call wordCounter

    pop rax


    mov rsi , numberOfResualt
    call printString

    mov rsi , searchResualt
    mov  rax , qword[rsi]
    call writeNum
    call newLine

    mov rcx , rax
    imul rcx , 2


PrintResualtWhileRepl:
    
    mov rsi, searchResualt
    cmp rcx , 0
    jle endSearchWordAndReplace

    mov rax , rcx 
    xor rdi , rdi
    shr rax , 1
    call writeNum
    call newLine

    mov  r9 , qword[rsi+rcx*8]
    dec rcx
    


    mov  r8 , qword[rsi+rcx*8]
    dec rcx


    mov rsi , currentFileText
    mov r10 , r9
    sub r9 , r8
    add rsi , r8

    mov al , '-'
    call putc
    mov al , '>'
    call putc

    push rax 
    push rdi 
    push rdx 
    push rcx

    mov rax, 1
    mov rdi, 1
    mov rdx, r9
    syscall

    mov al , '<'
    call putc
    mov al , '-'
    call putc



    add rsi , r9
    push r9
    mov r9 , 10

    mov rax, 1
    mov rdi, 1
    mov rdx, r9
    syscall

    pop r9

    pop rcx
    pop rax 
    pop rdi 
    pop rdx

    call newLine
    mov rsi , EnterToReplace
    call printString
    call readNum

    cmp rax , 0 
    jne PrintResualtWhileRepl
    push rcx

  

    cmp r9 , relpacingWordLen
    je ReplaceTheWord
    ja ReplaceWordIsLonger


    mov rsi , currentFileText
    add rsi , [FileTextLen]
    inc rsi
    mov rdi , currentFileText
    add rdi , [FileTextLen]
    sub rdi , r9
    add rdi , relpacingWordLen
    add rdi , 1
    std

    mov rcx , [FileTextLen]
    sub rcx, r10
    add rcx , 2
    rep movsb 

  


    jmp ReplaceTheWord

ReplaceWordIsLonger:

    mov rsi , currentFileText
    add rsi , r10 
    mov rdi , currentFileText
    add rdi , r8
    add rdi , relpacingWordLen
    cld
    mov rcx , [FileTextLen]
    sub rcx, r10
    rep movsb 

ReplaceTheWord:

    mov rdi , currentFileText
    add rdi , r8
    mov rsi , replacingWord
    mov rcx , relpacingWordLen
    cld
    rep movsb  



    push rbx 
    mov rbx , relpacingWordLen

    add [FileTextLen] , rbx
    sub [FileTextLen] , r9

    mov rbx , currentFileText
    add rbx , [FileTextLen]

    mov byte[rbx] , 0


    

    pop rbx 

    pop rcx

  
    jmp PrintResualtWhileRepl

endSearchWordAndReplace:
    %undef relpacingWordLen
    pop rcx
    pop rbx 
    pop rsi
    pop rdi
    pop rax

    leave
    
    ret



SearchWord: 
    push rax 
    push rdi
    push rsi
    push rbx 
    push rcx


    mov rsi , enterSearchingWord
    call printString

    mov rax, 0
    mov rdi, 0
    mov rsi, searchingWord
    mov rdx, 1000
    syscall
    mov byte [rsi+rax-1], 0




    mov rsi, searchingWord


    push rax
    mov rax , currentFileText
    push rax 
    mov rax, searchingWord
    push rax
    call wordCounter

    pop rax


    mov rsi , numberOfResualt
    call printString

    push r8

    mov rsi , searchResualt
    mov  rax , qword[rsi]
    mov r8 , rax 
    
    imul r8 , 2


    call writeNum
    call newLine

    mov rcx , 1



PrintResualtWhile:
    mov rsi, searchResualt
    cmp rcx , r8
    ja searchWordEnd
    
    mov  rax , qword[rsi+rcx*8]
    call writeNum
    inc rcx
    
    mov al , ' '
    call putc
    mov al , '-'
    call putc
    mov al , ' '
    call putc

    mov  rax , qword[rsi+rcx*8]
    call writeNum
    call newLine
    inc rcx


    jmp PrintResualtWhile

searchWordEnd:
    
    pop r8
    pop rcx
    pop rbx 
    pop rsi
    pop rdi
    pop rax

    ret








AppendFile:
    push rsi
    push rax


    mov rsi , enterWhatToAppend
    call printString

    mov rax, 0
    mov rdi, 0
    mov rsi, temp_bufff
    mov rdx, 1000
    syscall
    mov byte [rsi+rax-1], 0

    mov rcx , rax 
    mov rdi , currentFileText
    add rdi , [FileTextLen]
    add [FileTextLen] , rcx

    cld

    mov rsi , temp_bufff

    rep movsb

    mov rsi , currentFileName 
    add rsi , [FileTextLen]
    dec rsi 
    dec qword[FileTextLen]
    mov byte [rsi] , 0 
    call ShowFile


    pop rax
    pop rsi

    ret



RemoveFromEnd:
    push rsi
    push rbx
    push rax 

    mov rsi  , removeCharNumber
    call printString

    call readNum

    add [FileTextLen] , rbx
    sub [FileTextLen] , rax 

    mov rbx , currentFileText
    add rbx , [FileTextLen]

    mov byte[rbx] , 0

    pop rax 
    pop rbx 
    pop rsi

    ret









openAndReadFile:
    enter 8,0
    
    %define currentFD qword[rbp - 8]
    %define fileAddress qword[rbp+16]



        push fileAddress
        push file_extention
        call strEndsWith

        cmp     rax,    0
        je      endOfOpenAndReadFile

        mov rsi , onReding
        call printString
        mov rsi , fileAddress
        call printString 
        call newLine



        mov rdi , fileAddress 
        call openFile

        mov currentFD  ,rax 

        ;rdi : file descriptor ; rsi : buffer ; rdx : length

        mov rdi , rax 
        mov rsi , currentFileText
        mov rdx , 1000
        call readFile


        xor r8 , r8
        xor r9 , r8
        xor r10 , r10
        xor r11 , r11
        xor r13,r13 ; flag for seeing char


        dec r11
ProCounter:
        inc r11
        mov r12 , currentFileText
        cmp byte[r12 + r11] , 0
        je endProCounter

        cmp byte[r12 + r11] , ' '
        jne NOTW
        add r9 , r13
        xor r13,r13
        jmp ProCounter

NOTW:
        cmp byte[r12 + r11] , NL
        jne NOTL
        add r9 , r13
        add r10,r13
        xor r13,r13
        jmp ProCounter

NOTL:
        mov r13, 1
        inc r8

        jmp ProCounter


endProCounter:
        add r9 , r13
        add r10,r13
        mov [wordNumber] , r9
        mov [charNumber] , r8
        mov [lineNumber] , r10
        jmp      endOfOpenAndReadFile







endOfOpenAndReadFile:
    mov rdi , currentFD
    call closeFile
    %undef currentFD  
    %undef fileAddress  
    leave
    ret 8



wordCounter:
    enter 24,0
    
    %define counter qword[rbp - 24]
    %define wordLen qword[rbp - 16]
    %define textLen qword[rbp - 8]
    %define textAddress qword[rbp+24]
    %define the_word qword[rbp+16]

    push r8 
    push r9
    push r10
    push r11
    push r12
    push r13
    push rsi 
    push rdi 
    push rax
    push rcx 
    push rbx
    push rdx

    xor r13, r13
    inc r13
    mov counter , 0

    mov rdi , textAddress
    call GetStrlen
    mov textLen , rdx 

    mov rdi , the_word
    call GetStrlen
    mov wordLen , rdx





    xor rsi ,rsi
    xor rdi , rdi
    dec rdi




rsiWhile:
 

    inc rdi ; end of a word on string
    mov rsi , rdi ; first of a word on string
    mov r11 , textAddress
    cmp byte[r11 + rsi] , ' '
    je rsiWhile
    cmp byte[r11 + rsi] , NL
    je rsiWhile
    cmp byte[r11 + rsi] , 0
    je endOWfordCounter

rdiWhile:
    inc rdi 
    cmp byte[r11+ rdi] , ' '
    je theWordPart
    
    
    cmp byte[r11+ rdi] , NL
    je theWordPart
    
    cmp byte[r11+ rdi] , 0
    je theWordPart
    

    jmp rdiWhile
theWordPart:
    mov r8 , rdi 
    sub r8 , rsi
    cmp r8 , wordLen
    jne rsiWhile


    mov rcx , rsi
    xor r9 , r9

CheckEqual:
    ; cmp byte[r11+rcx] , 0
    ; je endOWfordCounter

    cmp rcx , rdi 
    jl insideChecker
    push r9
    mov r10  , counter
    inc r10 
    mov counter , r10

    mov r9 , searchResualt
    mov [r9] , r10

    mov [r9 + r13*8] , rsi
    inc r13
    mov [r9 + r13*8] , rdi 
    inc r13
    mov qword[r9 + r13*8] , 0 
    

    pop r9
    jmp rsiWhile




insideChecker:
    mov r12 , the_word
    mov al ,[r11 + rcx]
    cmp al, [r12+r9]
    jne rsiWhile
    inc rcx
    inc r9

    jmp CheckEqual









endOWfordCounter:
    mov rax , counter
    mov [globalWordCounter] ,rax


    pop rdx
    pop rbx
    pop rcx 
    pop rax
    pop rdi 
    pop rsi 
    pop r13
    pop r12
    pop r11
    pop r10
    pop r9
    pop r8


    %undef counter  
    %undef wordLen  
    %undef textLen  
    %undef textAddress  
    %undef the_word  
    leave
    ret 16

concate:
    enter 0,0
    %define param_first qword[rbp+32]
    %define param_second qword[rbp+24]
    %define param_dest qword[rbp+16]
    push r8
    push r9
    push rsi
    push rdi

    mov rdi, param_first
    call GetStrlen
    mov r8, rdx
    mov rdi, param_second
    call GetStrlen
    mov r9, rdx

    mov rcx, r8
    mov rsi, param_first
    mov rdi, param_dest
    cld
    rep movsb

    mov rcx, r9
    mov rsi, param_second
    rep movsb

    mov BYTE[rdi], 0

    pop  rdi
    pop  rsi
    pop  r9
    pop  r8
    %undef param_first  
    %undef param_second 
    %undef local_concatad 
    leave
    ret 24










%ifndef SYS_EQUAL
%define SYS_EQUAL
    sys_read     equ     0
    sys_write    equ     1
    sys_open     equ     2
    sys_close    equ     3
    
    sys_lseek    equ     8
    sys_create   equ     85
    sys_unlink   equ     87
      

    sys_mkdir       equ 83
    sys_makenewdir  equ 0q777


    sys_mmap     equ     9
    sys_mumap    equ     11
    sys_brk      equ     12
    
     
    sys_exit     equ     60
    
    stdin        equ     0
    stdout       equ     1
    stderr       equ     3

 
	PROT_NONE	  equ   0x0
    PROT_READ     equ   0x1
    PROT_WRITE    equ   0x2
    MAP_PRIVATE   equ   0x2
    MAP_ANONYMOUS equ   0x20
    
    ;access mode
    O_DIRECTORY equ     0q0200000
    O_RDONLY    equ     0q000000
    O_WRONLY    equ     0q000001
    O_RDWR      equ     0q000002
    O_CREAT     equ     0q000100
    O_APPEND    equ     0q002000


    BEG_FILE_POS    equ     0
    CURR_POS        equ     1
    END_FILE_POS    equ     2
    
; create permission mode
    sys_IRUSR     equ     0q400      ; user read permission
    sys_IWUSR     equ     0q200      ; user write permission

    NL            equ   0xA
    Space         equ   0x20

%endif

; Read a signed number from keybord and return in rax and write it to consol as a string
; using syscall
%ifndef NOWZARI_IN_OUT
%define NOWZARI_IN_OUT

; %include "./sys_equal.asm"
;----------------------------------------------------
newLine:
   push   rax
   mov    rax, NL
   call   putc
   pop    rax
   ret
;---------------------------------------------------------
putc:	

   push   rcx
   push   rdx
   push   rsi
   push   rdi 
   push   r11 

   push   ax
   mov    rsi, rsp    ; points to our char
   mov    rdx, 1      ; how many characters to print
   mov    rax, sys_write
   mov    rdi, stdout 
   syscall
   pop    ax

   pop    r11
   pop    rdi
   pop    rsi
   pop    rdx
   pop    rcx
   ret
;---------------------------------------------------------
writeNum:
   push   rax
   push   rbx
   push   rcx
   push   rdx

   sub    rdx, rdx
   mov    rbx, 10 
   sub    rcx, rcx
   cmp    rax, 0
   jge    wAgain
   push   rax 
   mov    al, '-'
   call   putc
   pop    rax
   neg    rax  

wAgain:
   cmp    rax, 9	
   jle    cEnd
   div    rbx
   push   rdx
   inc    rcx
   sub    rdx, rdx
   jmp    wAgain

cEnd:
   add    al, 0x30
   call   putc
   dec    rcx
   jl     wEnd
   pop    rax
   jmp    cEnd
wEnd:
   pop    rdx
   pop    rcx
   pop    rbx
   pop    rax
   ret

;---------------------------------------------------------
getc:
   push   rcx
   push   rdx
   push   rsi
   push   rdi 
   push   r11 

 
   sub    rsp, 1
   mov    rsi, rsp
   mov    rdx, 1
   mov    rax, sys_read
   mov    rdi, stdin
   syscall
   mov    al, [rsi]
   add    rsp, 1

   pop    r11
   pop    rdi
   pop    rsi
   pop    rdx
   pop    rcx

   ret
;---------------------------------------------------------

readNum:
   push   rcx
   push   rbx
   push   rdx

   mov    bl,0
   mov    rdx, 0
rAgain:
   xor    rax, rax
   call   getc
   cmp    al, '-'
   jne    sAgain
   mov    bl,1  
   jmp    rAgain
sAgain:
   cmp    al, NL
   je     rEnd
   cmp    al, ' ' ;Space
   je     rEnd
   sub    rax, 0x30
   imul   rdx, 10
   add    rdx,  rax
   xor    rax, rax
   call   getc
   jmp    sAgain
rEnd:
   mov    rax, rdx 
   cmp    bl, 0
   je     sEnd
   neg    rax 
sEnd:  
   pop    rdx
   pop    rbx
   pop    rcx
   ret

;-------------------------------------------
printString:
   push    rax
   push    rcx
   push    rsi
   push    rdx
   push    rdi

   mov     rdi, rsi
   call    GetStrlen
   mov     rax, sys_write  
   mov     rdi, stdout
   syscall 
   
   pop     rdi
   pop     rdx
   pop     rsi
   pop     rcx
   pop     rax
   ret
;-------------------------------------------
; rdi : zero terminated string start 
GetStrlen:
   push    rbx
   push    rcx
   push    rax  

   xor     rcx, rcx
   not     rcx
   xor     rax, rax
   cld
   repne   scasb
   not     rcx
   lea     rdx, [rcx -1]  ; length in rdx

   pop     rax
   pop     rcx
   pop     rbx
   ret
;-------------------------------------------



%endif

; %include "./common/p_generals.asm"
%define P_FUNC_PARAM_INDEX rbp+16

; %include "./common/p_io.asm"
%ifndef P_IO
%define P_IO
; %include "./common/p_memory_tools.asm"
%ifndef P_MEMORY_TOOLS
%define P_MEMORY_TOOLS
; %include "./sys_equal.asm"
; %include "./p_generals.asm"

Pmalloc: ;(int64 size) -> int64 address
    enter   0,  0
    push    rsi
    push    r10
    push    rcx

    mov     rax,    sys_mmap
    mov     rsi,    [P_FUNC_PARAM_INDEX]
    mov     rdx,    PROT_READ | PROT_WRITE
    mov     r10,    MAP_ANONYMOUS | MAP_PRIVATE
    syscall

    
    PmallocEnd:
        pop     rcx
        pop     r10
        pop     rsi
        leave
        ret 8
    

Pfree: ;(int64 ptr, int64 size) -> void
    enter   0, 0
    push    rsi
    mov     rax,    sys_mumap
    mov     rdi,    [P_FUNC_PARAM_INDEX+8];  ptr
    mov     rsi,    [P_FUNC_PARAM_INDEX];    size
    syscall
    pop     rsi
    leave
    ret     16

PMemcpy: ;(8B dest, 8B src, 8B bytes)
    enter   0,  0
    %define param_dest  qword[P_FUNC_PARAM_INDEX+16]
    %define param_src   qword[P_FUNC_PARAM_INDEX+8]
    %define param_bytes qword[P_FUNC_PARAM_INDEX]
    push    rsi
    push    rdi
    push    rcx
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    cld
    mov     rsi,    param_src
    mov     rdi,    param_dest
    mov     rcx,    param_bytes
    shr     rcx,    3; /8
    rep     movsq
   
    mov     rcx,    param_bytes
    and     rcx,    7;
    rep     movsb
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    pop     rcx
    pop     rdi
    pop     rsi
    %undef  param_dest
    %undef  param_src
    %undef  param_bytes
    leave
    ret     24


%endif
readln: ;(void) -> rax(address of the string)
    enter   8,  0
    %define local_arr   qword[rbp-8]
    push    rsi
    push    rdi
    push    rcx
    ;;;;;;;;;;;;;;;;;;
    xor     rax,    rax
    xor     rcx,    rcx
    readln_firstWhile:
        call    getc
        cmp     rax,    10
        je      readln_doMalloc
        inc     rcx; count
        dec     rsp
        mov     byte[rsp],  al
        jmp     readln_firstWhile

    readln_doMalloc:
        push    rcx
        call    Pmalloc
        mov     local_arr,  rax
    
    
    mov     rdi,    local_arr
    add     rdi,    rcx
    dec     rdi
    readln_secondWhile:
        mov     al,     [rsp]
        mov     [rdi],  al
        dec     rdi 
        inc     rsp
        loop    readln_secondWhile

    mov     rax,    local_arr
    ;;;;;;;;;;;;;;;;;;
    pop    rcx
    pop    rdi
    pop    rsi
    %undef local_arr
    leave
    ret 

%endif

; %include "./common/P_string_tools.asm"
%ifndef P_STRING_TOOLS
%define P_STRING_TOOLS
; %include "./in_out.asm"
; %include "./p_memory_tools.asm"

section .stringToolsConstants
    one         dq          1
    zero        dq          0

section .text

strEndsWith: ;(8B str, 8B ending_str)
    enter       0,  0
    %define     param_str       qword[P_FUNC_PARAM_INDEX+8]
    %define     param_end_str   qword[P_FUNC_PARAM_INDEX]
    push    r10
    push    r11 
    push    rsi
    push    rdi
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    mov     rdi,    param_str
    call    GetStrlen
    mov     r10,    rdx


    mov     rdi,    param_end_str
    call    GetStrlen
    mov     r11,    rdx 

    xor     rax,    rax
    cmp     r10,    r11 
    jb      strEndsWith_end
    
    mov     rcx,    r11 
    mov     rsi,    param_str    
    add     rsi,    r10
    dec     rsi

    mov     rdi,    param_end_str
    add     rdi,    r11 
    dec     rdi

    std 
    repe    cmpsb
    cmove   rax,    [one]
    cmovne   rax,    [zero]

  
    strEndsWith_end:
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    pop     rdi
    pop     rsi
    pop     r11 
    pop     r10
    %undef      param_str
    %undef      param_end_str
    leave   
    ret     16


concatString: ;(8B first, 8B second)
    enter   24,  0
    %define param_first         qword[P_FUNC_PARAM_INDEX+8]
    %define param_second        qword[P_FUNC_PARAM_INDEX]
    %define local_first_size    qword[rbp-8]
    %define local_second_size   qword[rbp-16]
    %define local_result        qword[rbp-24]
    push    rdx
    push    rdi
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    mov     rdi,    param_first
    call    GetStrlen
    mov     local_first_size,   rdx
    mov     rdi,    param_second
    call    GetStrlen
    mov     local_second_size,  rdx
    add     rdx,    local_first_size
    push    rdx
    call    Pmalloc
    mov     local_result,       rax
    push    local_result
    push    param_first
    push    local_first_size
    call    PMemcpy

    push    local_result
    mov     rax,    local_first_size
    add     [rsp],  rax
    push    param_second
    push    local_second_size
    call    PMemcpy

    mov     rax,    local_result
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    pop     rdi
    pop     rdx
    %undef  local_second_size
    %undef  local_first_size
    %undef  param_first
    %undef  param_second
    leave
    ret     16


%endif

; %include "./common/file-in-out.asm"
%ifndef NOWZARI_FILE_IN_OUT
%define NOWZARI_FILE_IN_OUT
; %include "./in_out.asm"
;----------------------------------------------------

section .text


;----------------------------------------------------
; rdi : file name; rsi : file permission
createFile:
    mov r13 , 0
    mov     rax, sys_create
    mov     rsi, sys_IRUSR | sys_IWUSR 
    syscall
    cmp     rax, -1   ; file descriptor in rax
    jle     createerror
    mov     rsi, suces_create           
    call    printString
    ret
createerror:
    cmp r13 , 1 
    je createerrorEnd
    mov r13 , 1
    mov     rsi, error_create
    call    printString

    call GiveDir


    mov rdi , saveAsDirectory
    mov rsi ,O_RDWR

    call createFile
createerrorEnd:

    ret



GiveDir:
    push rsi 
    push rdi
    push rcx
    push rdx

    mov rdi , saveAsDirectory
    call GetStrlen
    mov rcx , rdx

    mov rsi , saveAsDirectory
    mov rdi , saveAsDirectoryPath
    inc rdi
    cld
    rep movsb

    mov rdi , saveAsDirectoryPath
    inc rdi
GiveDirWhile:
    cmp byte[rdi] , 0
    je GiveDirWhileEnd

    cmp byte[rdi] , '/'
    jne GiveDirWhileContinue

    mov rsi , saveAsDirectoryPath
    call printString
    call newLine

    push rsi
    call makeDir

GiveDirWhileContinue:



    mov al , [rdi]
    mov byte[rdi] , 0
    dec rdi
    mov byte[rdi ] , al



    inc rdi
    inc rdi
    jmp GiveDirWhile


GiveDirWhileEnd:
    mov byte[rdi] , 0
    pop rdx 
    pop rcx
    pop rdi
    pop rsi
    ret



;----------------------------------------------------
; rdi : file name; rsi : file access mode 
; rdx: file permission, do not need
openFile:
    mov     rax, sys_open
    mov     rsi, O_RDWR     
    syscall
    cmp     rax, -1   ; file descriptor in rax
    jle     openerror
    mov     rsi, suces_open
    call    printString
    ret
openerror:
    mov     rsi, error_open
    call    printString
    call writeNum
    call newLine
    ret
;----------------------------------------------------
; rdi point to file name
appendFile:
    mov     rax, sys_open
    mov     rsi, O_RDWR | O_APPEND
    syscall
    cmp     rax, -1     ; file descriptor in rax
    jle     appenderror
    mov     rsi, suces_append
    call    printString
    ret
appenderror:
    mov     rsi, error_append
    call    printString
    ret
;----------------------------------------------------
; rdi : file descriptor ; rsi : buffer ; rdx : length
writeFile:
    mov     rax, sys_write
    syscall
    cmp     rax, -1         ; number of written byte
    jle     writeerror
    mov     rsi, suces_write
    call    printString
    ret
writeerror:
    mov     rsi, error_write
    call    printString
    ret
;----------------------------------------------------
; rdi : file descriptor ; rsi : buffer ; rdx : length
readFile:
    mov     rax, sys_read
    syscall
    cmp     rax, -1           ; number of read byte
    jle     readerror
    mov     byte [rsi+rax], 0 ; add a  zero 
    mov [FileTextLen], rax
    mov     rsi, suces_read
    call    printString
    ret
readerror:
    mov     rsi, error_read
    call    printString
    ret
;----------------------------------------------------
; rdi : file descriptor
closeFile:
    mov     rax, sys_close
    syscall
    cmp     rax, -1      ; 0 successful
    jle     closeerror
    mov     rsi, suces_close
    call    printString
    ret
closeerror:
    mov     rsi, error_close
    call    printString
    ret

;----------------------------------------------------
; rdi : file name
deleteFile:
    mov     rax, sys_unlink
    syscall
    cmp     rax, -1      ; 0 successful
    jle     deleterror
    mov     rsi, suces_delete
    call    printString
    ret
deleterror:
    mov     rsi, error_delete
    call    printString
    ret
;----------------------------------------------------
; rdi : file descriptor ; rsi: offset ; rdx : whence
seekFile:
    mov     rax, sys_lseek
    syscall
    cmp     rax, -1
    jle     seekerror
    mov     rsi, suces_seek
    call    printString
    ret
seekerror:
    mov     rsi, error_seek
    call    printString
    ret

;----------------------------------------------------
%endif









openDir: ;(8B dirname)
    enter   0,  0
    %define param_dirname   qword[P_FUNC_PARAM_INDEX]
    push    rdi
    push    rsi

    mov     rax,    sys_open
    mov     rdi,    param_dirname
    mov     rsi,    O_DIRECTORY
    syscall
    cmp     rax,    -1
    jle     openDir_error
    mov     rsi,    suces_open_dir
    call    printString
    jmp     openDir_end

    openDir_error:
        mov     rsi,    error_open_dir
        call    printString
        
    openDir_end:
        %undef  param_dirname
        pop     rsi
        pop     rdi
        leave
        ret     8

makeDir: ;(8B dirname)
    enter   0,  0
    %define param_dirname   qword[P_FUNC_PARAM_INDEX]
    
    push    rdi
    push    rsi 

    mov     rax,    sys_mkdir
    mov     rdi,    param_dirname
    mov     rsi,    sys_makenewdir
    xor     rdx,    rdx

    syscall
    cmp     rax,    -1
    jle     makeDir_Error
    mov     rsi,    suces_create_dir
    call    printString
    jmp     makeDir_end

    makeDir_Error:
        mov     rsi,   error_create_dir
        call    printString
    makeDir_end:
        %undef  param_dirname
        pop     rsi
        pop     rdi
        leave
        ret     8
