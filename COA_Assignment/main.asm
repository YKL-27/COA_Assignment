INCLUDE Irvine32.inc

.data
;------------------------------------------DISPLAY MESSAGES
usernamePrompt  BYTE "Enter username: ", 0
passwordPrompt  BYTE "Enter password: ", 0
successMsg      BYTE "Login successful!", 0
failMsg         BYTE "Invalid username or password!", 0
;------------------------------------------VARIABLES
username        BYTE 20 DUP(0)   
password        BYTE 20 DUP(0)   
correctUsername BYTE "user123", 0  
correctPassword BYTE "pass123", 0 

.code
main PROC
    login:
        ; Display the username prompt
        mov edx, OFFSET usernamePrompt
        call WriteString
    
        ; Read username input
        mov edx, OFFSET username
        mov ecx, 20  ; Max length of input
        call ReadString
    
        ; Display the password prompt
        mov edx, OFFSET passwordPrompt
        call WriteString
    
        ; Read the password input
        mov edx, OFFSET password
        mov ecx, 20  
        call ReadString

        ; Compare the entered username with the correct username
        mov esi, OFFSET username
        mov edi, OFFSET correctUsername
        call StrCompareCustom
        cmp eax, 0
        jne loginFailed 
    
        ; Compare the entered password with the correct one
        mov esi, OFFSET password
        mov edi, OFFSET correctPassword
        call StrCompareCustom
        cmp eax, 0
        jne loginFailed 

        ; If both match, login successful
        mov edx, OFFSET successMsg
        call WriteString
        jmp endProgram

    loginFailed:
        ; Display failure message
        mov edx, OFFSET failMsg
        call WriteString

    endProgram:
        ; Exit program
        call WaitMsg
        exit

    ; Custom string comparison function
    StrCompareCustom PROC
        ; Compares two strings pointed by ESI and EDI
        ; Returns 0 if strings are equal, 1 otherwise
    
        push esi    ; 
        push edi
    compareLoop:
        mov al, [esi]    
        mov bl, [edi]    
        cmp al, bl     
        jne notEqual     
        test al, al       
        je equal         
        inc esi         
        inc edi
        jmp compareLoop  

    notEqual:
        mov eax, 1       
        jmp done

    equal:
        mov eax, 0       

    done:
        pop edi          
        pop esi
        ret

    StrCompareCustom ENDP
    invoke ExitProcess,0
main ENDP
END main
