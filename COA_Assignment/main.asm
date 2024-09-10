INCLUDE Irvine32.inc
.386
.model flat,stdcall
.stack 4096
ExitProcess proto,dwExitCode:dword


.data
;==============================COMMON USED
;------------------------------------------DISPLAY MESSAGES
    dash_count      DWORD 30    ; Define the number of dashes to print
    dash            BYTE '-'    ; Define the dash character

;==============================LOGIN
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

;==============================SELECT FOOD
;------------------------------------------DISPLAY MESSAGES
    menuTitle       BYTE "Select a meal:", 0
    foodA           BYTE "A - Food A", 0
    foodB           BYTE "B - Food B", 0
    sideDishTitle   BYTE "Select a side dish:", 0
    noSideDish      BYTE "1 - No side dish", 0
    setWithA        BYTE "2 - Set with A", 0
    setWithB        BYTE "3 - Set with B", 0
    setWithAB       BYTE "4 - Set with A + B", 0
    selectionPrompt BYTE ">> Selection: ", 0
    invalidInputMsg BYTE "Invalid selection, please try again.", 0
    resultMsg       BYTE "You selected: ", 0
    foodAMsg        BYTE "Food A", 0
    foodBMsg        BYTE "Food B", 0
    noSideDishMsg   BYTE "No side dish", 0
    sideAOnlyMsg    BYTE "Set with A", 0
    sideBOnlyMsg    BYTE "Set with B", 0
    sideABMsg       BYTE "Set with A + B", 0
;------------------------------------------VARIABLES
    mealChoice      BYTE ?
    sideDishChoice  DWORD ?


.code
main PROC
;==============================MAIN
;------------------------------------------LOGIN PAGE
login:
    ; Prompt input username display
    mov edx, OFFSET usernamePrompt
    call WriteString
    
    ; Read username input
    mov edx, OFFSET username
    mov ecx, 20  ; Max length of input
    call ReadString
    
    ; Prompt password username display
    mov edx, OFFSET passwordPrompt
    call WriteString
    
    ; Read password input
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

;------------------------------------------LOGIN SUCCESS
    ; If both match, login successful & start ordering program
    mov edx, OFFSET successMsg
    call WriteString
    call selectFoodPage 

;------------------------------------------LOGIN FAILURE
loginFailed:
    ; Display failure message
    mov edx, OFFSET failMsg
    call WriteString

;==============================SELECT FOOD PAGE
;------------------------------------------MAIN FUNCTION
selectFoodPage PROC
    ; display Mealmenu and get valid selection
    call DisplayMealMenu
    call GetValidMealSelection

    ; display SideDishMenu and get valid selection
    call DisplaySideDishMenu
    call GetValidSideDishSelection

    exit
selectFoodPage ENDP

;------------------------------------------DISPLAY FOOD MENU
DisplayMealMenu PROC
    call print_dash ; call function to print 30 dashes
    call Crlf

    ; display menu title and food option
    mov edx, OFFSET menuTitle
    call WriteString
    call Crlf
    mov edx, OFFSET foodA
    call WriteString
    call Crlf
    mov edx, OFFSET foodB
    call WriteString
    call Crlf
    mov edx, OFFSET selectionPrompt ;get a selection from user
    call WriteString

    ret
DisplayMealMenu ENDP

;------------------------------------------DISPLAY SIDE DISH MENU
DisplaySideDishMenu PROC
    ; display sidedish title and set option
    mov edx, OFFSET sideDishTitle
    call WriteString
    call Crlf
    mov edx, OFFSET noSideDish
    call WriteString
    call Crlf
    mov edx, OFFSET setWithA
    call WriteString
    call Crlf
    mov edx, OFFSET setWithB
    call WriteString
    call Crlf
    mov edx, OFFSET setWithAB
    call WriteString
    call Crlf
    mov edx, OFFSET selectionPrompt ;get a selection from user
    call WriteString

    ret
DisplaySideDishMenu ENDP

;------------------------------------------FOOD MENU (mealchoice) INPUT & VALIDATION
GetValidMealSelection PROC
    ; loop until user input valid selection
    mov ecx, 1      ; initialize count of loop (count loop is 1)
GetValidMealLoop:
        call ReadChar   
        mov mealChoice, al

        ; check the user input is valid or not
        cmp mealChoice, 'A'
        je SelectFoodA
        cmp mealChoice, 'B'
        je SelectFoodB

        ; if user input is invalid
        mov edx, OFFSET invalidInputMsg
        call WriteString
        call Crlf
        call DisplayMealMenu

        mov ecx, 1      ; set count loop by 1 again when input is invalid
        jmp GetValidMealLoop

;------------------------------------------DISPLAY MESSAGE IF mealchoice = 'A'
SelectFoodA:
    mov edx, OFFSET resultMsg
    call WriteString
    mov edx, OFFSET foodAMsg
    call WriteString
    call Crlf
    ret

;------------------------------------------DISPLAY MESSAGE IF mealchoice = 'B'
SelectFoodB:
    mov edx, OFFSET resultMsg
    call WriteString
    mov edx, OFFSET foodBMsg
    call WriteString
    call Crlf
    ret
GetValidMealSelection ENDP

;------------------------------------------SIDE DISH MENU (sideDishchoice) INPUT & VALIDATION
GetValidSideDishSelection PROC
    ; loop until user input valid selection
    mov ecx, 1          ; initialize count of loop (count loop is 1)
GetValidSideDishLoop:
        call ReadInt
        mov sideDishChoice, eax

        ; check the user input is valid or not
        cmp sideDishChoice, 1
        je NoSideDishSelected
        cmp sideDishChoice, 2
        je SideDishASelected
        cmp sideDishChoice, 3
        je SideDishBSelected
        cmp sideDishChoice, 4
        je SideDishABSelected

        ; if user input is invalid
        mov edx, OFFSET invalidInputMsg
        call WriteString
        call Crlf
        call DisplaySideDishMenu

        mov ecx, 1          ; set count loop by 1 again when input is invalid
        jmp GetValidSideDishLoop

;------------------------------------------DISPLAY MESSAGE IF sideDishchoice = 1
NoSideDishSelected:
    mov edx, OFFSET resultMsg
    call WriteString
    mov edx, OFFSET noSideDishMsg
    call WriteString
    call Crlf
    ret

;------------------------------------------DISPLAY MESSAGE IF sideDishchoice = 2
SideDishASelected:
    mov edx, OFFSET resultMsg
    call WriteString
    mov edx, OFFSET sideAOnlyMsg
    call WriteString
    call Crlf
    ret

;------------------------------------------DISPLAY MESSAGE IF sideDishchoice = 3
SideDishBSelected:
    mov edx, OFFSET resultMsg
    call WriteString
    mov edx, OFFSET sideBOnlyMsg
    call WriteString
    call Crlf
    ret

;------------------------------------------DISPLAY MESSAGE IF sideDishchoice = 4
SideDishABSelected:
    mov edx, OFFSET resultMsg
    call WriteString
    mov edx, OFFSET sideABMsg
    call WriteString
    call Crlf
    ret
GetValidSideDishSelection ENDP

print_dash PROC
    ; Set up the loop counter and character
    mov al, dash                ; Load the dash character into AL
    mov ecx, dash_count         ; Load the dash count into ECX

print_loop:
    call WriteChar              ; Call WriteChar to print the character
    loop print_loop             ; Decrement ECX and loop until ECX reaches 0
    ret                         ; Return to the calling procedure
print_dash ENDP

;==============================CUSTOM STRING COMPARISON FUNCTION
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
