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
;~~~ENTER NAME
    inputMsg            BYTE "Enter name (up to 128 characters):     ", 0
    errorMsg            BYTE "Invalid input. Too long or invalid character.", 0
    tooLongMsg          BYTE "Input too long. Max length is 128 characters.", 0
    largeLenMsg         BYTE "Length between 50 and 128 characters. Number of characters entered: ", 0
    reenterMsg          BYTE "Please re-enter", 0
;~~~ENTER MODE
    dineOrTakeMsg       BYTE "Dine-in or Takeaway? Enter 'D' or 'T': ", 0
    invalidDineTakeMsg  BYTE "Invalid input. Please enter 'D' or 'T'.", 0
;~~~ENTER PROMO CODE (OPTIONAL)
    promoMsg            BYTE "Do you have promo code to enter? (Y/N): ", 0
    invalidPromoMsg     BYTE "Invalid input. Please enter 'Y' or 'N'.", 0
    promoCodeMsg        BYTE "Promo Code: ", 0
    invalidPromoCodeMsg BYTE "Invalid promo code. Do you wish to retry? (Y/N): ", 0
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
    CORRECT_PROMO_CODE  BYTE "eat2024", 0
    FOOD_PRICE          DWORD 8.50, 10.00
    SIDEDISH_PRICE      DWORD 0.00, 1.20, 2.40, 3.00
    DISCOUNT            DWORD 0.10
;------------------------------------------LOGIN
    username            BYTE 20 DUP(0)   
    password            BYTE 20 DUP(0)   
;------------------------------------------ENTER CUSTOMER INFO
    inputCustName       BYTE 129 DUP(0) ; Buffer to hold input (128 characters + null terminator)
    inputDT             BYTE 2 DUP(?)   ; D / T
    inputYN             BYTE 2 DUP(?)   ; Y / N
    inputPromoCode      BYTE 10 DUP(0)  ; Buffer for promo code input (maximum 10 characters)
;------------------------------------------SELECT FOOD
    inputOrder          BYTE 2 DUP(?)   ; Define a buffer of 5 bytes (for user input)
    mealChoice          BYTE ?
    sideDishChoice      DWORD ?
;------------------------------------------CALCULATION
    usingPromo          BYTE 0


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
    call StrCompare
    cmp eax, 0
    jne loginFailed 
    
    ; Compare the entered password with the correct one
    mov esi, OFFSET password
    mov edi, OFFSET CORRECT_PASSWORD
    call StrCompare
    cmp eax, 0
    jne loginFailed 

    ;------------------------------------------LOGIN SUCCESS
    mov edx, OFFSET successMsg
    call WriteString
    call Crlf
    call Crlf
    call inputCustInfoLoop 

    ;------------------------------------------LOGIN FAILURE
    loginFailed:
        mov edx, OFFSET failMsg
        call WriteString
        call Crlf
        call Crlf
        jmp login

;==============================PART 2: ENTER CUSTOMERS' INFO
inputCustInfoLoop PROC
    input_loop_start:
        mov edx, offset welcomeMsg
        call WriteString
        call Crlf
        call printDash
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
        cmp eax, 0       ; EAX == 0 indicates invalid length
        je input_loop_start ; If length check fails, re-enter the loop

        ; Check the characters of the input
        call CheckNameCharacters
        cmp eax, 0       ; EAX == 0 indicates invalid characters
        je input_loop_start ; If character check fails, re-enter the loop

        ; If name is valid, ask for dining preference
        call dine_or_takeaway_check

        ; If dining preference is valid, ask for promo code
        call promo_code_check

        ; If both checks pass, exit the input loop
        jmp done

    done:
        ; End the program
        call WaitMsg
        call Crlf
        call orderLoop
    inputCustInfoLoop ENDP


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
        je valid_input      ; If it's the end, input is valid
        cmp al, 'z'
        jbe check_loop      ; If it's a space character, continue checking
        cmp al, 'A'         
        jb invalid_input    ; If less than 'A', it's invalid
        cmp al, 'Z'         
        jbe check_loop      ; If it's an uppercase letter, continue checking
        cmp al, 'a'
        jb invalid_input    ; If less than 'a', it's invalid
        cmp al, 'z'
        jbe check_loop      ; If it's a lowercase letter, continue checking
        jmp invalid_input   ; Any other characters are invalid

    valid_input:
        ; If input is valid, set return value to 1
        mov eax, 1
        ret

    invalid_input:
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

; Function to check Dine-in or Takeaway input
dine_or_takeaway_check PROC
    dine_input_loop:
        ; Display the dine-in or takeaway prompt
        mov edx, OFFSET dineOrTakeMsg
        call WriteString

        ; Read the input (expecting 1 character)
        mov edx, OFFSET inputDT
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
    mov esi, OFFSET inputDT
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
        call printDash
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
        mov edx, OFFSET inputYN
        mov ecx, 2      ; Read one character plus null terminator
        call ReadString

        ; Check if input is 'Y' or 'N'
        mov al, inputYN
        cmp al, 'Y'
        je promo_code_entry
        cmp al, 'y'
        je promo_code_entry
        jmp no_promo_code
        ; cmp al, 'N'
        ; je no_promo_code
        ; cmp al, 'n'
        ; je no_promo_code

        ; Invalid input, re-enter loop
        ; mov edx, OFFSET invalidPromoMsg
        ; call WriteString
        ; call Crlf
        ; jmp promo_input_loop

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
        ; Read input (expecting Y/N)
        mov edx, OFFSET inputYN
        mov ecx, 2      ; Read one character plus null terminator
        call ReadString
        mov al, inputYN
        cmp al, 'Y'
        je promo_code_loop
        cmp al, 'y'
        je promo_code_loop
        ret

    valid_promo_code:
        ; Promo code is valid, continue
        call Crlf
        ret
    check_promo_code ENDP


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
        mov ecx, DWORD PTR [inputOrder]
        call ReadChar              ; Read a single character input
        mov al, inputOrder          ; Move the character to `al`
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

;------------------------------------------STRING COMPARISON
StrCompare PROC
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

    StrCompare ENDP

invoke ExitProcess, 0
main ENDP
END main