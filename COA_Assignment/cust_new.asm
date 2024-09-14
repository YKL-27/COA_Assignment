INCLUDE Irvine32.inc

.data
    welcomeMsg BYTE "Welcome to Our Restaurant", 0
    dash BYTE "------------------------------", 0  ; Define dash character
    inputMsg      BYTE "Enter name (up to 128 characters):", 0
    errorMsg      BYTE "Invalid input. Too long or invalid character.", 0
    tooLongMsg    BYTE "Input too long. Max length is 128 characters.", 0
    largeLenMsg   BYTE "Length between 50 and 128 characters. Number of characters entered: ", 0
    reenterMsg    BYTE "Please re-enter", 0
    dineOrTakeMsg BYTE "Dine-in or Takeaway? Enter 'D' or 'T':", 0
    invalidDineTakeMsg BYTE "Invalid input. Please enter 'D' or 'T'.", 0
    promoMsg      BYTE "Have promo code or not (Y/N): ", 0
    invalidPromoMsg BYTE "Invalid input. Please enter 'Y' or 'N'.", 0
    promoCodeMsg  BYTE "Promo Code: ", 0
    invalidPromoCodeMsg BYTE "Invalid promo code. Please enter 'eat2024'.", 0
    CORRECT_PROMO_CODE BYTE "eat2024", 0
    inputCustName        BYTE 129 DUP(0)  ; Buffer to hold input (128 characters + null terminator)
    inputPromoCode   BYTE 10 DUP(0)   ; Buffer for promo code input (maximum 10 characters)

.code
main PROC
inputCustInfoLoop PROC:

    mov edx, offset welcomeMsg
    call WriteString
    call Crlf
    call print_dash
    call Crlf

    ; Display input prompt
    mov edx, OFFSET inputMsg
    call WriteString

    ; Read the input string
    mov edx, OFFSET inputCustName
    mov ecx, 129  ; Set the input limit to 128 characters + null terminator
    call ReadString

    ; Check the length of the input
    call CheckCustNameLength
    cmp eax, 1
    call inputCustInfoLoop    ; If length check fails, re-enter the loop

    ; Check the characters of the input
    call CheckNameCharacters
    cmp eax, 1
    call inputCustInfoLoop    ; If character check fails, re-enter the loop

    ; If name is valid, ask for dining preference
    call dine_or_takeaway_check

    ; If dining preference is valid, ask for promo code
    call promo_code_check

    ; If both checks pass, exit the input loop
    jmp done

done:
    ; End the program
    call WaitMsg
    exit
inputCustInfoLoop ENDP
main ENDP


; Function to check Dine-in or Takeaway input
dine_or_takeaway_check PROC
    dine_input_loop:
        ; Display the dine-in or takeaway prompt
        mov edx, OFFSET dineOrTakeMsg
        call WriteString

        ; Read the input (expecting 1 character)
        mov edx, OFFSET inputCustName
        mov ecx, 2      ; Read only one character plus null terminator
        call ReadString

        ; Check if the input is 'T', 't', 'D', or 'd'
        call CheckDineTake

        cmp eax, 1
        jne dine_input_loop  ; If invalid, re-enter the loop

    ret
dine_or_takeaway_check ENDP


; Check if input is 'D', 'd', 'T', or 't'
CheckDineTake PROC
    mov esi, OFFSET inputCustName
    lodsb           ; Load the first character from the buffer into AL

    ; Check for 'D', 'd', 'T', 't'
    cmp al, 'D'
    je validDTInput
    cmp al, 'd'
    je validDTInput
    cmp al, 'T'
    je validDTInput
    cmp al, 't'
    je validDTInput

invalidDTInput:
    ; If input is invalid, output invalid message
    call print_dash
    call Crlf
    mov edx, OFFSET invalidDineTakeMsg
    call WriteString
    call Crlf
    mov eax, 0      ; Set return value to 0 (invalid)
    ret

validDTInput:
    mov eax, 1      ; Set return value to 1 (valid)
    ret
CheckDineTake ENDP


; Promo code check function
promo_code_check PROC
    promo_input_loop:
        ; Display promo code query
        mov edx, OFFSET promoMsg
        call WriteString

        ; Read input (expecting Y/N)
        mov edx, OFFSET inputCustName
        mov ecx, 2      ; Read one character plus null terminator
        call ReadString

        ; Check if input is 'Y' or 'N'
        mov al, inputCustName
        cmp al, 'Y'
        je promo_code_entry
        cmp al, 'y'
        je promo_code_entry
        cmp al, 'N'
        je no_promo_code
        cmp al, 'n'
        je no_promo_code

        ; Invalid input, re-enter loop
        mov edx, OFFSET invalidPromoMsg
        call WriteString
        call Crlf
        jmp promo_input_loop

    promo_code_entry:
        ; Ask for promo code
        call check_promo_code
        

    no_promo_code:
        ; No promo code, continue
    ret
promo_code_check ENDP


; Check promo code validity
check_promo_code PROC
    promo_code_loop:
        ; Display promo code prompt
        mov edx, OFFSET promoCodeMsg
        call WriteString

        ; Read promo code input
        mov edx, OFFSET inputPromoCode
        mov ecx, 9      ; Read up to 8 characters plus null terminator
        call ReadString

        ; Compare user input to correct promo code
        mov esi, OFFSET inputPromoCode
        mov edi, OFFSET CORRECT_PROMO_CODE
        call StrCompare

        ; If promo code is valid (EAX == 0), exit loop
        cmp eax, 0
        je valid_promo_code

        ; Invalid promo code, re-enter loop
        mov edx, OFFSET invalidPromoCodeMsg
        call WriteString
        call Crlf
        jmp promo_code_loop

    valid_promo_code:
        ; Promo code is valid, continue
        call Crlf
        ret
check_promo_code ENDP


; String comparison function
StrCompare PROC
    cmp_str_loop:
        lodsb           ; Load byte from ESI
        scasb           ; Compare with byte from EDI
        jne not_equal   ; If not equal, jump to not_equal
        test al, al     ; Check for null terminator
        jne cmp_str_loop

    ; Strings are equal
    mov eax, 0
    ret

not_equal:
    ; Strings are not equal
    mov eax, 1
    ret
StrCompare ENDP


; Length check function
CheckCustNameLength PROC
    ; Get the string length
    mov eax, OFFSET inputCustName
    call StrLength
    mov ebx, eax  ; Save string length in EBX

    ; Check if input is too long (> 128 characters)
    cmp ebx, 128
    jae invalidNameLength  ; If greater or equal to 128, it's invalid

    ; Check if length is between 50 and 128 characters
    cmp ebx, 50
    jae handleLargeNameInput    ; If length >= 50 but <= 128, show the length and invalid message

    ; Length is valid (between 1 and 50)
    mov eax, 1
    ret

handleLargeNameInput:
    ; Handle input length between 50 and 128 characters
    mov edx, OFFSET largeLenMsg
    call WriteString
    mov eax, ebx        ; Move the string length (in EBX) to EAX
    call WriteDec       ; Print the length of the input
    call Crlf           ; Move to the next line

    ; Print the invalid input message and prompt re-entry
    mov edx, OFFSET errorMsg
    call WriteString
    call Crlf
    mov edx, OFFSET reenterMsg
    call WriteString
    call Crlf           ; Move to the next line

    ; Set return value to 0 (invalid)
    mov eax, 0
    ret

invalidNameLength:
    ; Handle input exceeding the allowed 128 characters
    mov edx, OFFSET tooLongMsg
    call WriteString
    call Crlf           ; Move to the next line
    mov edx, OFFSET reenterMsg
    call WriteString
    call Crlf           ; Move to the next line

    ; Set return value to 0 (invalid)
    mov eax, 0
    ret
CheckCustNameLength ENDP


; Character check function (Valid characters: A-Z, a-z)
CheckNameCharacters PROC
    mov esi, OFFSET inputCustName
check_loop:
    lodsb               ; Load the next character into AL
    cmp al, 0           ; Check if it's the end of the string (null terminator)
    je validDTInput      ; If it's the end, input is valid
    cmp al, 'A'         
    jb invalidDTInput    ; If less than 'A', it's invalid
    cmp al, 'Z'         
    jbe check_loop      ; If it's an uppercase letter, continue checking
    cmp al, 'a'
    jb invalidDTInput    ; If less than 'a', it's invalid
    cmp al, 'z'
    jbe check_loop      ; If it's a lowercase letter, continue checking
    jmp invalidDTInput   ; Any other characters are invalid

validDTInput:
    ; If input is valid, set return value to 1
    mov eax, 1
    ret

invalidDTInput:
    ; Handle invalid characters in the input
    mov edx, OFFSET errorMsg
    call WriteString
    call Crlf           ; Move to the next line
    mov edx, OFFSET reenterMsg
    call WriteString
    call Crlf           ; Move to the next line

    ; Set return value to 0 (invalid)
    mov eax, 0
    ret
CheckNameCharacters ENDP

;=================================================================================
print_dash PROC
    lea esi, dash
    mov edx, esi
    call WriteString
    ret
print_dash ENDP

END main