INCLUDE Irvine32.inc
.386
.stack 4096
ExitProcess proto, dwExitCode:dword

.data
welcomeMsg      BYTE "Welcome to Our Restaurant", 0
dash            BYTE "------------------------------", 0    
namePrompt      BYTE "Enter name (up to 25 characters): ", 0
inputCustName     BYTE 26 DUP(0)                              
errorMsg        BYTE "Invalid input! Please enter only letters and spaces and no more than 25 characters.", 0
retryMsg        BYTE "Please try again: ", 0
dineInPrompt    BYTE "Dine-in / takeaway (D/T): ", 0
dineInErrorMsg  BYTE "Invalid choice! Please enter 'D' or 'T'.", 0
dineInInput     BYTE ?
namelen         BYTE 0

.code
main PROC
    ; Display welcome message
    lea esi, welcomeMsg
    mov edx, esi
    call WriteString
    call Crlf
    call print_dash

    ; Input loop for name
InputNameLoop:
    ; Display the name prompt
    call Crlf
    lea esi, namePrompt
    mov edx, esi
    call WriteString

    ; Read input
    lea edx, inputCustName
    mov ecx, 25  ; 25 characters maximum
    call ReadString

    ; Validate the name
    xor esi, esi              ; Reset index to 0
    mov ecx, 0                ; To count string length

CheckNameLoop:
    mov al, [inputCustName + esi] ; Load current character
    cmp al, 0                   ; Null terminator reached?
    je NameValid                ; Jump to valid if null found

    ; Check if it's a letter (A-Z or a-z) or space
    cmp al, 'A'
    jb InvalidName              ; Below 'A'
    cmp al, 'Z'
    jbe ValidChar               ; Valid if 'A' <= al <= 'Z'

    cmp al, 'a'
    jb InvalidName              ; Below 'a'
    cmp al, 'z'
    jbe ValidChar               ; Valid if 'a' <= al <= 'z'

    cmp al, ' '
    je ValidChar                ; Space is allowed
    
    inc namelen
    cmp namelen, 25
    jbe ValidChar

InvalidName:
    ; Display error message
    call Crlf
    lea edx, errorMsg
    call WriteString
    call Crlf
    lea edx, retryMsg
    call WriteString
    call Crlf

    ; Clear input buffer
    lea edi, inputCustName
    mov ecx, 26
    xor al, al
    rep stosb
    jmp InputNameLoop           ; Restart input loop

ValidChar:
    inc esi                     ; Move to next character
    inc ecx                     ; Count the length
    cmp ecx, 25                 ; Check if length exceeds 25
    ja InvalidName              ; Too long
    jmp CheckNameLoop           ; Continue checking

NameValid:
    ; Dine-in/takeaway prompt
    call Crlf
    lea esi, dineInPrompt
    mov edx, esi
    call WriteString

    ; Input loop for dine-in/takeaway choice
InputDineInLoop:
    call ReadChar
    mov dineInInput, al

    ; Validate dine-in/takeaway choice
    cmp dineInInput, 'D'
    je DineInValid
    cmp dineInInput, 'd'
    je DineInValid
    cmp dineInInput, 'T'
    je DineInValid
    cmp dineInInput, 't'
    je DineInValid

DineInInvalid:
    ; Invalid choice handling
    call Crlf
    lea edx, dineInErrorMsg
    call WriteString
    call Crlf
    jmp InputDineInLoop

DineInValid:
    ; Final separator
    call Crlf
    call print_dash

    ; Exit program
    INVOKE ExitProcess, 0

print_dash PROC
    lea esi, dash
    mov edx, esi
    call WriteString
    ret
print_dash ENDP

main ENDP
END main
