INCLUDE Irvine32.inc
.386
.model flat, stdcall
.stack 4096
ExitProcess proto, dwExitCode:dword


.data
;==============================DISPLAY MESSAGES
;------------------------------------------COMMONLY USED
    dashAmount          DWORD 30
    dash                BYTE '-'
    pauseEnter          BYTE 'Press "Enter" key to continue...'
;------------------------------------------LOGIN
    usernamePrompt      BYTE "Enter username: ", 0
    passwordPrompt      BYTE "Enter password: ", 0
    successMsg          BYTE "Login successful!", 0 
    startupMsg          BYTE "Starting "
    failMsg             BYTE "Invalid credentials!", 0 
;------------------------------------------ENTER CUSTOMER INFO
    welcomeMsg          BYTE "Welcome to Our Restaurant", 0
    namePrompt          BYTE "Enter name (up to 25 characters): ", 0
    errorMsg            BYTE "Invalid input! Please enter only letters and spaces and no more than 25 characters.", 0
    retryMsg            BYTE "Please try again: ", 0
    dineInPrompt        BYTE "Dine-in / takeaway (D/T): ", 0
    dineInErrorMsg      BYTE "Invalid choice! Please enter 'D' or 'T'.", 0
;------------------------------------------SELECT FOOD
;~~~SELECT MEAL
    menuTitle           BYTE "Select A Meal:", 0
    foodA               BYTE "A - Pan Mee", 0
    foodB               BYTE "B - Chilli Pan Mee", 0
;~~~SELECT ADDON
    sideDishTitle       BYTE "Select An Add-On:", 0
    noSideDish          BYTE "1 - No add-on (Ala-carte)", 0
    setWithA            BYTE "2 - Set with Soya Milk", 0
    setWithB            BYTE "3 - Set with Dumplings", 0
    setWithAB           BYTE "4 - Set with Dumplings & Soya Milk", 0
;~~~SELECTION PROMPT
    selectionPrompt     BYTE ">> Selection: ", 0
    invalidInputMsg     BYTE "Invalid selection, please try again.", 0
;~~~SELECTED RESULT
    resultMsg           BYTE "You selected: ", 0
    setMsg              BYTE "Set ", 0
    foodAMsg            BYTE "Pan Mee ", 0
    foodBMsg            BYTE "Chilli Pan Mee ", 0
    sideAOnlyMsg        BYTE "with Soya Milk", 0
    sideBOnlyMsg        BYTE "with Dumplings", 0
    sideABMsg           BYTE "with Dumplings & Soya Milk", 0

;==============================VARIABLES
;------------------------------------------CONSTANTS
    CORRECT_USERNAME    BYTE "user123", 0  
    CORRECT_PASSWORD    BYTE "pass123", 0 
    FOOD_PRICE          DWORD 8.50, 10.00
    SIDEDISH_PRICE      DWORD 0.00, 1.20, 2.40, 3.00
    DISCOUNT            DWORD 0.10
;------------------------------------------LOGIN
    username            BYTE 20 DUP(0)   
    password            BYTE 20 DUP(0)   
;------------------------------------------ENTER CUSTOMER INFO
    inputCustName       BYTE 26 DUP(0)  ; 25 characters + NULL terminator
    dineInInput         BYTE ?
;------------------------------------------SELECT FOOD
    inputMeal           BYTE 5 DUP(?)   ; Define a buffer of 5 bytes (for user input)
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
    call Crlf
    call Crlf
    call orderLoop 

    ;------------------------------------------LOGIN FAILURE
    loginFailed:
        mov edx, OFFSET failMsg
        call WriteString
        call Crlf
        call Crlf
        jmp login

;==============================PART 2: ENTER CUSTOMERS' INFO
InputNameLoop PROC
    InputNameLoop ENDP
;==============================PART 3: ORDERING
orderLoop PROC
    call selectFoodPage 
    call orderLoop 
    call ReadChar
    orderLoop ENDP

selectFoodPage PROC
    ; display Mealmenu and get valid selection
    call DisplayMealMenu
    call GetValidMealSelection
    ; display SideDishMenu and get valid selection
    call DisplaySideDishMenu
    call GetValidSideDishSelection
    call displaySelection
    selectFoodPage ENDP

;------------------------------------------DISPLAY FOOD MENU
DisplayMealMenu PROC
    call printDash ; call function to print 30 dashes
    call Crlf

    ; display menu title and food option
    call Crlf
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
    call Crlf
    call Crlf
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
    ; Display the meal selection prompt again
    GetValidMealLoop:
        mov ecx, inputMeal
        call ReadChar              ; Read a single character input
        mov al, inputMeal          ; Move the character to `al`
        cmp al, 0                  ; Check if empty (unlikely with ReadChar)
        je InvalidInput

        ; Validate the input (check if 'A', 'a', 'B', or 'b')
        cmp al, 'A'
        je ValidInput
        cmp al, 'a'
        je ValidInput
        cmp al, 'B'
        je ValidInput
        cmp al, 'b'
        je ValidInput

    InvalidInput:
        ; Handle invalid input
        mov edx, OFFSET invalidInputMsg
        call WriteString
        call Crlf
        jmp GetValidMealLoop        ; Loop again if input is invalid

    ValidInput:
        mov mealChoice, al          ; Store valid input in mealChoice
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
        ret
        cmp sideDishChoice, 2
        ret
        cmp sideDishChoice, 3
        ret
        cmp sideDishChoice, 4
        ret

        ; if user input is invalid
        mov edx, OFFSET invalidInputMsg
        call WriteString
        call Crlf
        call DisplaySideDishMenu
        mov ecx, 1          ; set count loop by 1 again when input is invalid
        jmp GetValidSideDishLoop
    GetValidSideDishSelection ENDP

displaySelection PROC
    ; Print "You selected: "
    mov edx, OFFSET resultMsg
    call WriteString

    cmp sideDishChoice, 1
    je notSetMeal
    ; Display "Set " if it is not ala-carte
        mov edx, OFFSET setMsg
        call WriteString

    notSetMeal:

    ; Check for meal selection and print the corresponding message
    cmp mealChoice, 'A'
    je SelectFoodA
    cmp mealChoice, 'a'
    je SelectFoodA
    cmp mealChoice, 'B'
    je SelectFoodB
    cmp mealChoice, 'b'
    je SelectFoodB

    SelectFoodA:
        ; If mealChoice is 'A' or 'a', print "Pan Mee"
        mov edx, OFFSET foodAMsg
        call WriteString
        jmp DisplayAddon

    SelectFoodB:
        ; If mealChoice is 'B' or 'b', print "Chilli Pan Mee"
        mov edx, OFFSET foodBMsg
        call WriteString
        jmp DisplayAddon

    DisplayAddon:
        ; Check for side dish selection and print corresponding message

        cmp sideDishChoice, 1
        je NoAddon
        cmp sideDishChoice, 2
        je SideDishASelected
        cmp sideDishChoice, 3
        je SideDishBSelected
        cmp sideDishChoice, 4
        je SideDishABSelected

    NoAddon:
        jmp EndDisplay

    SideDishASelected:
        ; If sideDishChoice is 2, print " with Soya Milk"
        mov edx, OFFSET sideAOnlyMsg
        call WriteString
        jmp EndDisplay

    SideDishBSelected:
        ; If sideDishChoice is 3, print " with Dumplings"
        mov edx, OFFSET sideBOnlyMsg
        call WriteString
        jmp EndDisplay

    SideDishABSelected:
        ; If sideDishChoice is 4, print " with Dumplings & Soya Milk"
        mov edx, OFFSET sideABMsg
        call WriteString

    EndDisplay:
        ; Print a newline at the end
        call Crlf
        call Crlf
        call WaitMsg
        ;call FlushInput    ; Flush Enter key from the buffer
        call Crlf
        ret
    displaySelection ENDP
;==============================PART 4: CALCULATIONS
;==============================PART 5: DISPLAY INVOICE (ALL ORDERS)
;==============================CUSTOM FUNCTIONS

FlushInput PROC
    ; Continue reading characters until we find a newline (Enter key)
    FlushLoop:
        call ReadChar           ; Read a single character
        cmp al, 0Dh             ; Compare with newline (Enter key)
        jne FlushLoop           ; Keep reading until Enter is found
    ret
    FlushInput ENDP
;------------------------------------------PRINT PAGE SEPERATION LINE
printDash PROC
    ; Set up the loop counter and character
    mov al, dash                ; Load the dash character into AL
    mov ecx, dashAmount         ; Load the dash count into ECX

    print_loop:
        call WriteChar          ; Call WriteChar to print the character
        loop print_loop         ; Decrement ECX and loop until ECX reaches 0
        ret                     ; Return to the calling procedure
    printDash ENDP

;------------------------------------------STRING COMPARISON (LOGIN)
strCompare PROC
    ; Compares two strings pointed by ESI and EDI
    ; Returns 0 if strings are equal, 1 otherwise
    
    push esi
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
        jmp doneCompare

    equal:
        mov eax, 0       

    doneCompare:
        pop edi          
        pop esi
        ret

    strCompare ENDP

invoke ExitProcess, 0
main ENDP
END main