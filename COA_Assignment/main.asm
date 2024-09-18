INCLUDE Irvine32.inc
    .model flat, stdcall
    ExitProcess proto, dwExitCode:dword
    .stack 4096

.data
;==============================DISPLAY MESSAGES
    enterContMsg        BYTE  "Enter anything to continue...", 0
;------------------------------------------LOGIN
    usernamePrompt      BYTE  "Enter admin username: ", 0
    passwordPrompt      BYTE  "Enter admin password: ", 0
    successMsg          BYTE  "Login successful!", 13, 10, 0 
    startupMsg          BYTE  "Launching Food Ordering Program... ", 13, 10, 0
    failLoginMsg        BYTE  "Invalid credentials!", 13, 10, 0 
;------------------------------------------ENTER CUSTOMER INFO
    welcomeMsg          BYTE  "       Welcome to Pan-tastic Mee House!", 13, 10, 0
;~~~ENTER NAME
    inputNameMsg        BYTE  "Enter your name (up to 50 characters):  ", 0
    invalidCharMsg      BYTE  "    INVALID INPUT: Name contain invalid character.", 13, 10, 0
    nameBlankMsg        BYTE  "    INVALID INPUT: No name was entered.", 13, 10, 0
    strTooLongMsg       BYTE  "    INVALID INPUT: Name exceed 50 characters long.", 13, 10, 0
;~~~ENTER MODE
    dineOrTakeMsg       BYTE  "Dine-in or Takeaway? Enter 'D' or 'T':  ", 0
    invalidDineTakeMsg  BYTE  "    INVALID INPUT: Please enter 'D' or 'T'.", 13, 10, 0
;~~~ENTER PROMO CODE (OPTIONAL)
    promoMsg            BYTE  "Do you have promo code to enter? (Y/N): ", 0
    invalidPromoMsg     BYTE  "    INVALID INPUT: Please enter 'Y' or 'N'.", 13, 10, 0
    promoCodeMsg        BYTE  "Promo Code: ", 0
    invalidPromoCodeMsg BYTE  "Invalid promo code. Do you wish to retry? (Y/N): ", 0
    promoSuccessMsg     BYTE "Promo Code used successfully!", 0

;------------------------------------------SELECT FOOD
;~~~SELECT MEAL
    menuTitle           BYTE  "Select A Meal:", 13, 10, 0
    foodA               BYTE  "A - Pan Mee                           RM  8.50", 13, 10, 0
    foodB               BYTE  "B - Chilli Pan Mee                    RM 10.00", 13, 10, 0
;~~~SELECT ADDON
    sideDishTitle       BYTE  "Select An Add-On:", 13, 10, 0
    noSideDish          BYTE  "1 - No add-on", 13, 10, 0
    setWithA            BYTE  "2 - Set with Soya Milk                + RM 1.20", 13, 10, 0
    setWithB            BYTE  "3 - Set with Dumplings                + RM 2.40", 13, 10, 0
    setWithAB           BYTE  "4 - Set with Dumplings & Soya Milk    + RM 3.00", 13, 10, 0
;~~~SELECTION PROMPT
    selectionPrompt     BYTE  ">> Selection: ", 0
    invalidInputMsg     BYTE  "Invalid selection, please try again.", 13, 10, 0
;~~~SELECTED RESULT
    resultMsg           BYTE  "You selected: ", 13, 10, 0
    setMsg              BYTE  "Set ", 0
    foodAMsg            BYTE  "Pan Mee", 0
    foodBMsg            BYTE  "Chilli Pan Mee", 0
    sideAOnlyMsg        BYTE  " with Soya Milk", 0
    sideBOnlyMsg        BYTE  " with Dumplings", 0
    sideABMsg           BYTE  " with Dumplings & Soya Milk", 0
;~~~CONFIRM ORDER AND LOOP ORDER
    confirmOrderMsg     BYTE  "Do you want to confirm this order (Y/N): ", 0
    contOrderMsg        BYTE  "Do you want to keep ordering? (Y/N): ", 0
;~~~INVOICE
    dearMsg             BYTE  "Dear ", 0
    receiptMsg          BYTE  ", here is your receipt:", 13, 10, 0
    RMMsg               BYTE  "RM ", 0
    receiptHeader       BYTE  "Name                                              Price", 0
    totalPriceMsg       BYTE  "Subtotal:                                         ", 0
    discountedAmountMsg BYTE  "Discount:                                         ", 0
    takeawayChargeMsg   BYTE  "Take Away Charge:                                 ", 0
    finalPriceMsg       BYTE  "Grand Total:                                      ", 0
    thankYouMsg         BYTE  "Thank you, have a nice day :D", 0

;==============================VARIABLES
;------------------------------------------CONSTANTS
    ADMIN_USERNAME      BYTE  "user123", 0  
    ADMIN_PASSWORD      BYTE  "pass123", 0 
    PROMO_CODE          BYTE  "eat2024", 0
    FOOD_PRICE          DWORD 850, 1000             ; Prices for Food A (RM8.50), Food B (RM10.00) in cents
    SIDEDISH_PRICE      DWORD 0, 120, 240, 300      ; Prices for No Side (RM0.00), Side A (RM1.20), Side B (RM2.40), Side A+B ($RM.00) in cents
    TAKEAWAY_CHARGE     DWORD 20                    ; Extra charges for takeaway (RM0.20) in cent
    DISCOUNT_PERCENT    DWORD 8                     ; Discount percentage (10%) as a whole number
;------------------------------------------COMMONLY USED
    dashAmount          DWORD 60
    dash                BYTE  '-'
    inputYN             BYTE  2 DUP(?)              ; Y / N
    displayPriceStr     BYTE  9 DUP(0)
    isProgramLooping    BYTE  1                     ; bool
;------------------------------------------LOGIN
    username            BYTE  20 DUP(?)   
    password            BYTE  20 DUP(?)   
;------------------------------------------ENTER CUSTOMER INFO
    inputCustName       BYTE  129 DUP(?)            ; Buffer to hold input (128 characters + null terminator)
    inputDT             BYTE  2 DUP(?)              ; DineIn / TakeAway
    inputPromoCode      BYTE  10 DUP(?)             ; Buffer for promo code input (maximum 10 characters)
;------------------------------------------SELECT FOOD
    inputOrder          BYTE  2 DUP(?)              ; Define a buffer of 2 bytes (for user input)
    inputConfirmOrder   BYTE  2 DUP(?) 
    inputContOrder      BYTE  2 DUP(?)
    mealChoice          BYTE  ?
    sideDishChoice      BYTE  ?
;------------------------------------------CALCULATION
;~~~ORDER LIST
    foodList            BYTE  64 DUP(0)
    sideList            BYTE  64 DUP(0)
    priceList           DWORD 64 DUP(0)
    orderListLen        DWORD 0
    loopNo              DWORD 0
    loopIndex           DWORD 0
;~~~PRICE CALCULATION
    usingPromo          BYTE  0                     ; bool
    isTakeAway          BYTE  0                     ; bool
    currFoodPrice       DWORD 0
    totalPrice          DWORD 0
    totalTakeAway       DWORD 0
    discountedPrice     DWORD 0
    finalPrice          DWORD 0
;~~~INVOICE 
    foodStrLen          DWORD 0
    gapSpace            BYTE  "."
    invoiceNo           DWORD 0

.code
main PROC
    ; Initialize once and avoid re-execution
    call login
    mainProgram:
        call init
        call inputCustInfo
        call orderLoop
        call calcTotalPrice
        call calcFinalPrice
        call displayInvoice
    cmp isProgramLooping, 1
    je mainProgram
    ; Exit cleanly
    invoke ExitProcess, 0

;==============================INITIALISE: RESET VARAIBLES FOR NEXT CUSTOMER TO ORDER
init PROC
    xor eax, eax

    mov ecx, 129
    mov esi, 0
    clearCustName:
        mov [inputCustName+esi], al
        inc esi
    loop clearCustName

    mov ecx, 10
    mov esi, 0
    clearPromoCode:
        mov [inputPromoCode+esi], al
        inc esi 
    loop clearPromoCode

    mov ecx, 64
    mov esi, 0
    clear64:
        mov[foodList+esi], al
        mov[sideList+esi], al
        mov[priceList+esi], eax
        inc esi 
    loop clear64

    mov orderListLen, eax
    mov loopNo, eax
    mov loopIndex, eax
    mov usingPromo, al
    mov isTakeAway, al
    mov currFoodPrice, eax
    mov totalPrice, eax
    mov totalTakeAway, eax
    mov discountedPrice, eax
    mov finalPrice, eax

    ret
    init ENDP

;==============================PART 1: LOGIN
login PROC
    startlogin:
        call ClrScr
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
        mov edi, OFFSET ADMIN_USERNAME
        call StrCompare
        cmp eax, 0
        jne loginFailed 
    
        ; Compare the entered password with the correct one
        mov esi, OFFSET password
        mov edi, OFFSET ADMIN_PASSWORD
        call StrCompare
        cmp eax, 0
        jne loginFailed 

    ;------------------------------------------LOGIN SUCCESS
    mov edx, OFFSET successMsg
    call WriteString
    call Crlf
    call Crlf
    ret

    ;------------------------------------------LOGIN FAILURE
    loginFailed:
        mov edx, OFFSET failLoginMsg
        call WriteString
        call Crlf
        mov edx, OFFSET enterContMsg
        call WriteString
        call ReadChar
        jmp startlogin
    login ENDP

;==============================PART 2: ENTER CUSTOMERS' INFO
inputCustInfo PROC
    call ClrScr
    mov edx, offset welcomeMsg
    call WriteString
    call printDash

    input_loop_start:
        ; Display input prompt
        call Crlf
        mov edx, OFFSET inputNameMsg
        call WriteString

        ; Read the input string
        mov edx, OFFSET inputCustName
        mov ecx, 129  ; Set the input limit to 128 characters + null terminator
        call ReadString

        ; Check the length of the input
        mov esi, OFFSET inputCustName
        call StringLength        ; Get the length of input string into EAX
        cmp eax, 50              ; Check if length is greater than 50
        jg nameTooLong          
        cmp eax, 0               ; Check if length is 0 or
        jle nameNull           
        jmp check_characters

        nameNull:
            mov edx, OFFSET nameBlankMsg
            call WriteString
            jmp nameInputInvalid     ; Re-prompt to re-enter input

        nameTooLong:
            mov edx, OFFSET strTooLongMsg
            call WriteString
            jmp nameInputInvalid     ; Re-prompt to re-enter input

        check_characters:
            ; Check the characters of the input
            call CheckNameCharacters
            cmp eax, 1               ; EAX == 0 means contain invalid characters
            je nameInputValid        ; If valid, proceed to next step

            ; INVALID characters
            mov edx, OFFSET invalidCharMsg
            call WriteString
            jmp nameInputInvalid     ; Re-prompt to enter input

        nameInputValid:
            ; If name is valid, ask for dining preference
            call dine_or_takeaway_check
            ; If dining preference is valid, ask for promo code
            call promo_code_check
            ; If both checks pass, exit the input loop
            ret

        nameInputInvalid:
            jmp input_loop_start
    inputCustInfo ENDP

; Character check function (Valid characters: A-Z, a-z)
CheckNameCharacters PROC
    mov ecx, 129              ; Set the max length for checking
    mov esi, OFFSET inputCustName
    check_loop:
        mov al, [esi]          ; Load a character from the string
        cmp al, 0              ; Check if it's the null terminator
        je valid_input         ; If null terminator, input is valid

        cmp al, 20h            ; Check if it's a space character
        je valid_character     ; If it's a space, it's valid

        cmp al, 'A'
        jb invalid_input       ; If less than 'A', it's invalid
        cmp al, 'Z'
        jbe valid_character    ; If uppercase letter, it's valid

        cmp al, 'a'
        jb invalid_input       ; If less than 'a', it's invalid
        cmp al, 'z'
        jbe valid_character    ; If lowercase letter, it's valid

        jmp invalid_input      ; Any other character is invalid

        valid_character:
            inc esi                ; Move to the next character
    loop check_loop        ; Continue checking until null terminator

    valid_input:
            mov eax, 1             ; All characters are valid
            ret

    invalid_input:
            mov eax, 0             ; Invalid character found
            ret
    CheckNameCharacters ENDP

; Function to check Dine-in or Takeaway input
dine_or_takeaway_check PROC
    dine_input_loop:
        call Crlf
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

    ; Check for 'D', 'd'
    cmp al, 'D'
    je validDTInput
    cmp al, 'd'
    je validDTInput

    ; Check for 'T', 't'
    cmp al, 'T'
    je setTakeAway
    cmp al, 't'
    je setTakeAway

    invalidDTInput:
        ; If input is invalid, output invalid message
        mov edx, OFFSET invalidDineTakeMsg
        call WriteString
        call Crlf
        mov eax, 0      ; Set return value to 0 (invalid)
        ret

    setTakeAway:
        ; Set takeaway flag
        mov isTakeAway, 1
        jmp validDTInput

    validDTInput:
        mov eax, 1      ; Set return value to 1 (valid)
        ret
    CheckDineTake ENDP


; Promo code check function
promo_code_check PROC
    promo_input_loop:
        call Crlf
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
        call Crlf
        ; Display promo code prompt
        mov edx, OFFSET promoCodeMsg
        call WriteString

        ; Read promo code input
        mov edx, OFFSET inputPromoCode
        mov ecx, 9      ; Read up to 8 characters plus null terminator
        call ReadString

        ; Compare user input to correct promo code
        mov esi, OFFSET inputPromoCode
        mov edi, OFFSET PROMO_CODE
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
        ; Promo code is valid, display success message
        mov usingPromo, 1
        mov edx, OFFSET promoSuccessMsg   ; Display "Promo Code used successfully"
        call WriteString
        ret
    check_promo_code ENDP


;==============================PART 3: ORDERING
orderLoop PROC
    mov ebx, 0
    ;----------------------------------------------display Mealmenu and get valid selection
    orderLoopStart:
        call ClrScr
        call DisplayMealMenu
        ; Display the meal selection prompt again
        mov edx, OFFSET inputOrder  ; Set the buffer to store the input
        mov ecx, 2                  ; Limit to 1 character + null terminator
        call ReadString              ; Read the string input from the user
        
        ; Get the first character from the input buffer
        mov al, inputOrder           ; Move the first character to AL
        
        ; Validate the input (check if it's 'A', 'a', 'B', or 'b')
        cmp al, 'A'
        je ValidMealInput
        cmp al, 'a'
        je ValidMealInput
        cmp al, 'B'
        je ValidMealInput
        cmp al, 'b'
        je ValidMealInput

    InvalidMealInput:
        ; Handle invalid input
        mov edx, OFFSET invalidInputMsg
        call WriteString
        call Crlf
        jmp orderLoopStart        ; Loop again if input is invalid

    ValidMealInput:
        mov mealChoice, al          ; Store valid input in mealChoice

    ;----------------------------------------------display SideDishMenu and get valid selection
    GetSideDishSelection:
        call Crlf
        call printDash
        call Crlf
        call DisplaySideDishMenu
        ; Display the meal selection prompt again
        mov edx, OFFSET inputOrder  ; Set the buffer to store the input
        mov ecx, 2                  ; Limit to 1 character + null terminator
        call ReadString              ; Read the string input from the user
        ; Get the first character from the input buffer
        mov al, inputOrder           ; Move the first character to AL

        ; Validate the input (check if it's '1', '2', '3', or '4')
        cmp al, '1'
        je ValidSideDishInput
        cmp al, '2'
        je ValidSideDishInput
        cmp al, '3'
        je ValidSideDishInput
        cmp al, '4'
        je ValidSideDishInput

    InvalidSideDishInput:
        mov edx, OFFSET invalidInputMsg
        call WriteString
        call Crlf
        jmp GetSideDishSelection

    ValidSideDishInput:
        mov sideDishChoice, al          ; Store valid input in mealChoice

    ;----------------------------------------------display selection & confirm
    ; Print "You selected: "
    call Crlf
    call printDash
    call Crlf
    mov edx, OFFSET resultMsg
    call WriteString
    call displaySelection
    call Crlf
    call Crlf
    mov edx, OFFSET confirmOrderMsg
    call WriteString
    ; Read input (expecting Y/N)
    mov edx, OFFSET inputYN
    mov ecx, 2      ; Read one character plus null terminator
    call ReadString

    ; Check if input is 'Y' or 'N'
    mov al, inputYN
    cmp al, 'Y'
    je confirmOrder
    cmp al, 'y'
    je confirmOrder
    jmp contOrder

    call DumpMem        ; Dump memory around orderListLen before confirmOrder
    confirmOrder:
        ; Check if the user wants to confirm the order (Y)
        mov al, inputYN
        cmp al, 'Y'
        je storeOrder
        cmp al, 'y'
        je storeOrder
        jmp contOrder  ; If 'N', skip storing and go to next iteration

    storeOrder:
        ; Store the meal choice in the order list
        mov al, mealChoice
        mov [foodList + ebx], al 

        mov al, sideDishChoice
        mov [sideList + ebx], al
        inc ebx

        ; Ensure orderListLen does not exceed 100
        cmp orderListLen, 100
        jae orderListFull    ; Handle full order list scenario

        inc orderListLen      ; Increment order count only when confirmed
        jmp contOrder


    orderListFull:
        ; Handle the case where the order list is full (optional message)
        ; mov edx, OFFSET orderListFullMsg
        ; call WriteString
        ret

    contOrder:
        call Crlf
        mov edx, OFFSET contOrderMsg
        call WriteString
        inc ebx
        ; Read input (expecting Y/N)
        mov edx, OFFSET inputYN
        mov ecx, 2
        call ReadString
        mov al, inputYN
        cmp al, 'Y'
        je orderLoopStart
        cmp al, 'y'
        je orderLoopStart
        ; If 'N' is selected, ensure it exits properly
        ret



    orderLoop ENDP

;------------------------------------------DISPLAY FOOD MENU
DisplayMealMenu PROC

    ; display menu title and food option
    call Crlf
    mov edx, OFFSET menuTitle
    call WriteString
    call Crlf
    mov edx, OFFSET foodA
    call WriteString
    mov edx, OFFSET foodB
    call WriteString
    call Crlf
    mov edx, OFFSET selectionPrompt ; get a selection from user
    call WriteString

    ret
    DisplayMealMenu ENDP

;------------------------------------------DISPLAY SIDE DISH MENU
DisplaySideDishMenu PROC
    ; display sidedish title and set option
    mov edx, OFFSET sideDishTitle
    call WriteString
    mov edx, OFFSET noSideDish
    call WriteString
    mov edx, OFFSET setWithA
    call WriteString
    mov edx, OFFSET setWithB
    call WriteString
    mov edx, OFFSET setWithAB
    call WriteString
    call Crlf
    mov edx, OFFSET selectionPrompt ;get a selection from user
    call WriteString

    ret
    DisplaySideDishMenu ENDP


displaySelection PROC
    call clearBuffer
    mov foodStrLen, 0

    cmp sideDishChoice, '1'
    je notSetMeal
    ; Display "Set " if it is not ala-carte
    mov edx, OFFSET setMsg
    call WriteString
    mov esi, OFFSET setMsg
    call StringLength
    add foodStrLen, eax

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
        mov esi, OFFSET foodAMsg
        call StringLength
        add foodStrLen, eax
        jmp DisplayAddon

    SelectFoodB:
        ; If mealChoice is 'B' or 'b', print "Chilli Pan Mee"
        mov edx, OFFSET foodBMsg
        call WriteString
        mov esi, OFFSET foodBMsg
        call StringLength
        add foodStrLen, eax
        jmp DisplayAddon

    DisplayAddon:
        ; Check for side dish selection and print corresponding message

        cmp sideDishChoice, '1'
        je NoAddon
        cmp sideDishChoice, '2'
        je SideDishASelected
        cmp sideDishChoice, '3'
        je SideDishBSelected
        cmp sideDishChoice, '4'
        je SideDishABSelected

    NoAddon:
        jmp EndDisplay

    SideDishASelected:
        mov edx, OFFSET sideAOnlyMsg
        call WriteString
        mov esi, OFFSET sideAOnlyMsg
        call StringLength
        add foodStrLen, eax
        jmp EndDisplay

    SideDishBSelected:
        mov edx, OFFSET sideBOnlyMsg
        call WriteString
        mov esi, OFFSET sideBOnlyMsg
        call StringLength
        add foodStrLen, eax
        jmp EndDisplay

    SideDishABSelected:
        mov edx, OFFSET sideABMsg
        call WriteString
        mov esi, OFFSET sideABMsg
        call StringLength
        add foodStrLen, eax

    EndDisplay:
        ret
    displaySelection ENDP


;==============================PART 4: CALCULATIONS
calcTotalPrice PROC
    cmp orderListLen, 0         ; Check if orderListLen is 0
    je noOrders                 ; If no orders, skip the calculations

    ; Initialize total price
    mov totalPrice, 0

    ; Loop through each food order to calculate the total price
    mov ecx, orderListLen       ; Set up loop counter based on number of orders
    mov esi, 0                  ; Start from index 0

    calcEachFood:
        mov currFoodPrice, 0
        call getFoodPrice
        call getSidePrice

        ; Store the total price (currFoodPrice) in priceList
        mov eax, currFoodPrice   ; Move currFoodPrice into register
        ;call dumpregs 
        mov edi, esi 
        shl edi, 2 
        mov [priceList + edi], eax 

        add totalPrice, eax      ; Add to total price

        ; Check for takeaway charge
        mov al, isTakeAway
        cmp al, 1
        jne noTakeAwayCharge 

        ; Add takeaway charge if applicable
        mov eax, TAKEAWAY_CHARGE
        add totalTakeAway, eax

        noTakeAwayCharge:
        ; Move to the next order
        add esi, 2                  ; Move to next order index
    loop calcEachFood

    jmp doneCalc

    noOrders:
    doneCalc:
    ret
    calcTotalPrice ENDP

getFoodPrice PROC
    ; Get the price of the food in cents
    mov al, [foodList + esi]
    cmp al, 'A'
    je setFoodAPrice
    cmp al, 'a'
    je setFoodAPrice

    ; Default to food B
    setFoodBPrice:
        mov edi, 4                ; Index for 'B' in FOOD_PRICE array (1000 = 10.00 dollars)
        jmp setFoodPrice

    setFoodAPrice:
        mov edi, 0                ; Index for 'A' in FOOD_PRICE array (850 = 8.50 dollars)

    setFoodPrice:
        mov ebx, [FOOD_PRICE + edi]
        mov currFoodPrice, ebx    ; Store the food price in currFoodPrice (fixed-point cents)
    ret
    getFoodPrice ENDP


getSidePrice PROC
    ; Get the price of the side dish in cents
    mov al, [sideList + esi]     ; Load the side dish choice from sideList
    cmp al, '1'
    je setSideNonePrice           ; No add-on
    
    cmp al, '2'
    je setSideAPrice              ; Soya Milk
    
    cmp al, '3'
    je setSideBPrice              ; Dumplings

    ; Default case (invalid side order or combination of sides)
    setSideABPrice:
        mov edi, 12               ; Set index for Dumplings & Soya Milk (AB)
        jmp setSidePrice

    setSideBPrice:
        mov edi, 8                ; Set index for Dumplings
        jmp setSidePrice

    setSideAPrice:
        mov edi, 4                ; Set index for Soya Milk
        jmp setSidePrice

    setSideNonePrice:
        mov edi, 0                ; No add-on, price is 0
        jmp setSidePrice

    setSidePrice:
        mov ebx, [SIDEDISH_PRICE + edi]   ; Retrieve the price from SIDEDISH_PRICE array
        add currFoodPrice, ebx            ; Add side dish price to the food price
    ret
    getSidePrice ENDP

calcFinalPrice PROC
    ; Initialize final price with the total price
    mov eax, totalPrice
    mov finalPrice, eax

    ; Check if the promo code was used (usingPromo == 1)
    cmp usingPromo, 1
    jne skipDiscount     ; If promo code wasn't used, skip the discount

    ; Apply 10% discount
    mov eax, finalPrice   ; Load the final price
    mov ebx, DISCOUNT_PERCENT
    mul ebx               ; Multiply by discount percentage (in this case, 10)
    
    mov ecx, 100          
    div ecx               ; Divide by 100 to get the discounted amount
    mov discountedPrice, eax  ; Save the discount value
    sub finalPrice, eax    ; Subtract the discount from the final price

    skipDiscount:
        ; Add takeaway charges (if any)
        mov eax, totalTakeAway
        add finalPrice, eax

        ret
    calcFinalPrice ENDP


;==============================PART 5: DISPLAY INVOICE (ALL ORDERS)
displayInvoice PROC
    call ClrScr
    cmp orderListLen, 0         ; Check if orderListLen is 0
    je noInvoice                ; If no orders, skip the calculations

    mov edx, OFFSET dearMsg
    call WriteString
    mov edx, OFFSET inputCustName 
    call WriteString
    mov edx, OFFSET receiptMsg 
    call WriteString
    call Crlf

    call printDash
    mov edx, OFFSET receiptHeader
    call WriteString
    call Crlf
    call printDash

    mov ecx, orderListLen    ; Load the number of orders into ecx
    mov esi, 0               ; Start at the first order
    displayEachOrder:
        push ecx             ; Save the loop counter
        push esi             ; Save the index for this iteration

        call getFood         ; Get food information
        call getSide         ; Get side dish information
        call displaySelection; Display the selected order

        ; Calculate the spacing based on the food name length
        mov eax, foodStrLen   ; Get the length of the food string
        cmp eax, 0            ; If no food string, skip the order
        jz donePrintSpace     ; Jump to done if no food string

        mov ebx, 50           ; Set the max width for display
        sub ebx, eax          ; Calculate spaces to print

        printSpace:
            cmp ebx, 0            ; Check if spaces are left to print
            jz donePrintSpace     ; Exit if none left
            mov al, gapSpace      ; Print space
            call WriteChar
            dec ebx               ; Decrement space count
            jmp printSpace

        donePrintSpace:
            pop esi               ; Restore the index
            push esi
            call getOrderPrice; Display the order price
            call Crlf             ; New line
            pop esi
            add esi, 2           ; Move to the next order (assuming 2-byte entries)
            pop ecx               ; Restore the loop counter
    loop displayEachOrder ; Decrement ecx and loop if non-zero
    call printDash

    mov edx, OFFSET totalPriceMsg
    call WriteString
    mov eax, totalPrice
    call printPriceStr
    call Crlf

    mov edx, OFFSET discountedAmountMsg
    call WriteString
    mov eax, discountedPrice
    call printPriceStr
    call Crlf

    mov edx, OFFSET takeawayChargeMsg
    call WriteString
    mov eax, totalTakeAway
    mov edi, OFFSET totalTakeAway 
    call printPriceStr
    call Crlf

    call printDash
    mov edx, OFFSET finalPriceMsg
    call WriteString
    mov eax, finalPrice
    call printPriceStr
    call Crlf
    call printDash

    call Crlf
    call Crlf
    mov edx, OFFSET thankYouMsg 
    call WriteString

    noInvoice:
    call Crlf
    call Crlf
    call Crlf
    mov edx, OFFSET enterContMsg
    call WriteString
    call ReadChar

    ret
    displayInvoice ENDP

;------------------------------------------DISPLAY FOOD
getFood PROC
    ; Get and display food selection
    mov al, [foodList + esi]       ; Get food selection from list
    mov mealChoice, al
    ret
    getFood ENDP

;------------------------------------------DISPLAY SIDE DISH
getSide PROC
    ; Get and display side dish selection
    mov al, [sideList + esi]
    mov sideDishChoice, al  
    ret
    getSide ENDP

;------------------------------------------DISPLAY PRICE
getOrderPrice PROC
    ; Calculate the correct index in priceList (esi is the order index)

    mov edi, esi             ; edi holds the index in priceList
    shl edi, 2               ; Multiply edi by 4 to scale the index for DWORD access

    mov eax, [priceList + edi]  ; EAX now contains the price in cents
    cmp eax, 0               ; Ensure the price is not zero
    je zeroPrice             ; Handle zero price case separately

    mov edi, OFFSET displayPriceStr  ; Prepare the buffer
    call printPriceStr        ; Convert the integer in EAX to a string and store in buffer
    ret

    zeroPrice:
        ret
    getOrderPrice ENDP


;==============================CUSTOM FUNCTIONS
;------------------------------------------PRINT HORIZONTAL SEPERATION LINE
printDash PROC
    ; Set up the loop counter and character
    mov al, dash                ; Load the dash character into AL
    mov ecx, dashAmount         ; Load the dash count into ECX

    print_loop:
        call WriteChar          ; Call WriteChar to print the character
    loop print_loop             ; Decrement ECX and loop until ECX reaches 0

    call Crlf
    ret                     ; Return to the calling procedure
    printDash ENDP

;------------------------------------------STRING COMPARISON
; INPUT:    ESI & EDI   - the address of the string.
; OUTPUT:   EAX         - 0 = equal, 1 = different
StrCompare PROC
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

;------------------------------------------GET STRING LENGTH
; INPUT:    ESI         - the address of the string.
; OUTPUT:   EAX         - the length of the string.
StringLength PROC
    push esi                  ; Save the original value of ESI
    mov  ecx, 0               ; Initialize ECX to count the characters

    findLength:
        cmp  BYTE PTR [esi], 0    ; Check if the current byte is null (0)
        je   done                 ; If it's null, exit the loop
        inc  esi                  ; Move to the next byte
        inc  ecx                  ; Increment the character counter
        jmp  findLength           ; Repeat the loop

    done:
        mov  eax, ecx             ; Move the string length into EAX
        pop  esi                  ; Restore the original value of ESI
        ret                       ; Return to the caller
    StringLength ENDP

;------------------------------------------PRINT PRICE (NNNN CENT --> RM NN.NN)
; INPUT:    EAX   - INT value (cent).
printPriceStr PROC
    ;display "RM"
    mov edx, OFFSET RMMsg
    call WriteString

    mov edi, OFFSET displayPriceStr  ; Load the address of the displayPriceStr buffer
    add edi, 8                       ; Move to the end of the buffer (leaving space for null terminator)

    ; Null-terminate the string
    mov BYTE PTR [edi], 0
    dec edi                          ; Move back to start filling digits

    ; Convert the cents (two digits) and store them first
    mov ecx, 10                      ; Base 10
    xor edx, edx
    div ecx                          ; EAX = quotient, EDX = remainder
    add dl, '0'                      ; Convert remainder (last digit of cents) to ASCII
    mov [edi], dl
    dec edi
    xor edx, edx
    div ecx                          ; Get the second last digit of cents
    add dl, '0'
    mov [edi], dl
    dec edi

    ; Insert decimal point
    mov BYTE PTR [edi], '.'
    dec edi

    ; Now convert the remaining part (integer portion)
    IntToStrLoop:
        xor edx, edx                 ; Clear EDX for division
        div ecx                      ; EAX / 10, quotient in EAX, remainder in EDX
        add dl, '0'                  ; Convert remainder (digit) to ASCII
        mov [edi], dl                ; Store ASCII character in buffer
        dec edi                      ; Move back to fill the next character

        test eax, eax                ; Check if there are more digits to process
        jnz IntToStrLoop             ; If EAX is not zero, continue

    ; Print the formatted string using WriteString
    inc edi                          ; Move pointer to the start of the string (EDI)
    mov edx, edi                     ; Load the pointer into EDX for WriteString
    call WriteString                 ; Output the formatted price

    ret
    printPriceStr ENDP

;------------------------------------------CLEAR BUFFER
clearBuffer PROC
    mov edi, OFFSET displayPriceStr
    mov ecx, 9
    mov al, 0
    rep stosb
    ret
    clearBuffer ENDP

main ENDP
END main