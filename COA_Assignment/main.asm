Include Irvine32.inc
.386
.model flat,stdcall
.stack 4096
ExitProcess proto,dwExitCode:dword

.data
;------------------------------------------DISPLAY MESSAGES


;------------------------------------------VARIABLES

.code
main proc
    login:
    page1:
    page2:
    page3:
    
    invoke ExitProcess,0
main endp
end main