INCLUDE Irvine32.inc
.386
.stack 4096
ExitProcess proto, dwExitCode:dword

.data
welcomeMsg BYTE "Welcome"
dash BYTE '-'       ; Define dash character
namePrompt BYTE "Enter name:"
inputBuffer BYTE 26 DUP(0)  ; 25 characters + NULL terminator
errorMsg BYTE "Invalid input! Please enter only letters and spaces."
retryMsg BYTE "Please try again:"
dineInPrompt BYTE "Dine-in / takeaway (D/T):"
dineInErrorMsg BYTE "Invalid choice! Please enter 'D' or 'T'."
dineInInput BYTE ?

.code
main PROC
    ; Display welcome message
    lea esi, welcomeMsg
    mov edx, esi
    call WriteString
    call Crlf

    ; Print dashes
    call print_dash
    call Crlf

    ; Input loop for name
InputNameLoop:
    ; Display the name prompt
    lea esi, namePrompt
    mov edx, esi
    call WriteString

    ; Read input
    mov edx, OFFSET inputBuffer
    mov ecx, 26
    call ReadString

    ; Validate name input
    call ValidateNameInput

    ; Check if input is valid or not
    cmp eax, 0  ; EAX will be 0 if input is valid
    je NameInputValid

    ; If input is invalid, display error message and retry prompt
    mov edx, OFFSET errorMsg
    call WriteString
    call Crlf
    mov edx, OFFSET retryMsg
    call WriteString
    call Crlf

    ; Clear input buffer
    mov edi, OFFSET inputBuffer
    mov ecx, 26
    xor al, al
    rep stosb

    ; Repeat input loop
    jmp InputNameLoop

NameInputValid:
    ; Display the dine-in/takeaway prompt
    lea esi, dineInPrompt
    mov edx, esi
    call WriteString
    

    ; Input loop for dine-in/takeaway choice
InputDineInLoop:
    ; Read dine-in/takeaway choice
    call ReadChar
    mov dineInInput, al

    ; Validate dine-in/takeaway choice
    call ValidateDineInInput

    ; Check if input is valid or not
    cmp eax, 0  ; EAX will be 0 if input is valid
    je DineInInputValid

    ; If input is invalid, display error message and retry prompt
    mov edx, OFFSET dineInErrorMsg
    call WriteString
    call Crlf

    ; Prompt again
    lea esi, dineInPrompt
    mov edx, esi
    call WriteString

    ; Repeat input loop
    jmp InputDineInLoop

DineInInputValid:
    ; You can add code here to process the valid input

    ; Exit program
    INVOKE ExitProcess, 0

main ENDP

print_dash PROC
    mov al, dash
    mov ecx, 30
print_loop:
    mov edx, eax
    call WriteChar
    loop print_loop
    ret
print_dash ENDP

; Validate input for letters and spaces only
ValidateNameInput PROC
    mov esi, OFFSET inputBuffer
    movzx ecx, BYTE PTR [esi]
    mov eax, 0  ; Assume valid input

CheckNameLoop:
    cmp ecx, 0  ; Check if end of string
    je DoneName

    ; Check if character is a letter (A-Z or a-z) or space
    cmp ecx, ' '
    je ContinueName
    cmp ecx, 'A'
    jb InvalidNameInput
    cmp ecx, 'Z'
    jbe ContinueName
    cmp ecx, 'a'
    jb InvalidNameInput
    cmp ecx, 'z'
    jbe ContinueName
    jmp InvalidNameInput

ContinueName:
    inc esi
    movzx ecx, BYTE PTR [esi]
    ; Check if length exceeds 25 characters
    cmp esi, OFFSET inputBuffer + 25
    jae InvalidNameInput
    jmp CheckNameLoop

InvalidNameInput:
    mov eax, 1  ; Set EAX to 1 (invalid input)
    ret

DoneName:
    mov eax, 0  ; Set EAX to 0 (valid input)
    ret
ValidateNameInput ENDP

; Validate input for 'D' or 'T' only
ValidateDineInInput PROC
    cmp dineInInput, 'D'
    je ValidDineIn
    cmp dineInInput, 'T'
    je ValidDineIn

InvalidDineInInput:
    mov eax, 1  ; Set EAX to 1 (invalid input)
    ret

ValidDineIn:
    mov eax, 0  ; Set EAX to 0 (valid input)
    ret
ValidateDineInInput ENDP
END main