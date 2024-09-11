INCLUDE Irvine32.inc
.386
.model flat,stdcall
.stack 4096
ExitProcess proto,dwExitCode:dword


.data
;==============================DISPLAY MESSAGES
;------------------------------------------COMMONLY USED
    dashAmount          DWORD 30
    dash                BYTE '-'
    newLine             BYTE 0Dh, 0Ah, 0
;------------------------------------------LOGIN
    usernamePrompt      BYTE "Enter username: ", 0
    passwordPrompt      BYTE "Enter password: ", 0
    successMsg          BYTE "Login successful!", 0 
    failMsg             BYTE "Invalid username or password!", 0 
;------------------------------------------ENTER CUSTOMER INFO
    welcomeMsg          BYTE "Welcome", 0
    namePrompt          BYTE "Enter name:", 0
    errorMsg            BYTE "Invalid input! Please enter only letters and spaces.", 0
    retryMsg            BYTE "Please try again:", 0
    dineInPrompt        BYTE "Dine-in / takeaway (D/T):", 0
    dineInErrorMsg      BYTE "Invalid choice! Please enter 'D' or 'T'.", 0
;------------------------------------------SELECT FOOD
    menuTitle           BYTE "Select a meal:", 0
    foodA               BYTE "A - Pan Mee", 0
    foodB               BYTE "B - Chilli Pan Mee", 0
    sideDishTitle       BYTE "Select a side dish:", 0
    noSideDish          BYTE "1 - No side dish (Ala-carte)", 0
    setWithA            BYTE "2 - Set with Soya Milk", 0
    setWithB            BYTE "3 - Set with Dumplings", 0
    setWithAB           BYTE "4 - Set with Dumplings & Soya Milk", 0
    selectionPrompt     BYTE ">> Selection: ", 0
    invalidInputMsg     BYTE "Invalid selection, please try again.", 0
    resultMsg           BYTE "You selected: ", 0
    foodAMsg            BYTE "Pan Mee", 0
    foodBMsg            BYTE "Chilli Pan Mee", 0
    noSideDishMsg       BYTE "No side dish", 0
    sideAOnlyMsg        BYTE "Set with Soya Milk", 0
    sideBOnlyMsg        BYTE "Set with Dumplings", 0
    sideABMsg           BYTE "Set with Dumplings & Soya Milk", 0

;==============================VARIABLES
;------------------------------------------CONSTANTS
    CORRECT_USERNAME    BYTE "user123", 0  
    CORRECT_PASSWORD    BYTE "pass123", 0 
    FOOD_PRICE          DWORD 8, 10
    SIDEDISH_PRICE      DWORD 0, 1.5, 2, 3
;------------------------------------------LOGIN
    username            BYTE 20 DUP(0)   
    password            BYTE 20 DUP(0)   
;------------------------------------------ENTER CUSTOMER INFO
    inputBuffer         BYTE 26 DUP(0)  ; 25 characters + NULL terminator
    dineInInput         BYTE ?
;------------------------------------------SELECT FOOD
    mealChoice          BYTE ?
    sideDishChoice      DWORD ?
;------------------------------------------CALCULATION


.code
main PROC
;==============================PART 1: LOGIN
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
    mov edi, OFFSET CORRECT_USERNAME
    call strCompare
    cmp eax, 0
    jne loginFailed 
    
    ; Compare the entered password with the correct one
    mov esi, OFFSET password
    mov edi, OFFSET CORRECT_PASSWORD
    call strCompare
    cmp eax, 0
    jne loginFailed 

    ;------------------------------------------LOGIN SUCCESS
    mov edx, OFFSET successMsg
    call WriteString
    call selectFoodPage 

    ;------------------------------------------LOGIN FAILURE
    loginFailed:
        mov edx, OFFSET failMsg
        call WriteString
        mov dl, 13
        call WriteChar
        jmp login

;==============================PART 2: ENTER CUSTOMERS' INFO
orderLoop PROC
    orderLoop ENDP

;==============================PART 3: SELECT FOOD PAGE
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
    call printDash ; call function to print 30 dashes
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
;==============================PART 3.5: DISPLAY ORDER
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

;==============================PART 4: CALCULATIONS
;==============================PART 5: DISPLAY INVOICE (ALL ORDER)
;==============================CUSTOM FUNCTIONS
;------------------------------------------PRINT PAGE SEPERATION LINE
printDash PROC
    ; Set up the loop counter and character
    mov al, dash                ; Load the dash character into AL
    mov ecx, dashAmount         ; Load the dash count into ECX

    print_loop:
        call WriteChar              ; Call WriteChar to print the character
        loop print_loop             ; Decrement ECX and loop until ECX reaches 0
        ret                         ; Return to the calling procedure
    printDash ENDP

;------------------------------------------STRING COMPARISON (REGISTER)
strCompare PROC
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

    strCompare ENDP

invoke ExitProcess, 0
main ENDP
END main