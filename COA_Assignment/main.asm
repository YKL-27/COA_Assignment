Include Irvine32.inc
.386
.model flat,stdcall
.stack 4096
ExitProcess proto,dwExitCode:dword

.data

.code
main proc

    invoke ExitProcess,0
main endp
end main