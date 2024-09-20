INCLUDE Irvine32.inc
includelib kernel32.lib      ; Additional library for Windows API functions

.model flat, stdcall
ExitProcess proto, dwExitCode:dword
.stack 4096

SetConsoleOutputCP PROTO :DWORD   ; For printing character with ASCII code beyond regular range

.data
;==============================VARIABLES
;------------------------------------------CONSTANTS
    FOOD_PRICE          DWORD 850, 1000             ; Prices for Food A (RM8.50), Food B (RM10.00) in cents
    SIDEDISH_PRICE      DWORD 0, 120, 240, 300      ; Prices for No Addon (RM0.00), Side A (RM1.20), Side B (RM2.40), Side A+B ($RM.00) in cents
    TAKEAWAY_CHARGE     DWORD 20                    ; Extra charges for takeaway (RM0.20) in cent
    PROMO_CODE          BYTE "eat2024", 0           ; Enter promo code to get discount (Case-sensitive)
    DISCOUNT_PERCENT    DWORD 10                    ; Discount percentage (10%) as a whole number
    BACK_CMD            BYTE "-111", 0              ; Command to go back
    TERMINATE_CMD       BYTE ">admin:terminate", 0  ; Secret command for admin to terminate the program entirely
;------------------------------------------COMMONLY USED
    dashAmount          DWORD 60
    dash                BYTE '-'
    inputYN             BYTE 2 DUP(?)   
    displayPriceStr     BYTE 9 DUP(0)
    isProgramLooping    BYTE 1                      ; bool
;------------------------------------------REGISTRATION/LOGIN
    backtoRegister      BYTE 0                      ; bool
    username            BYTE 20 DUP(?)              ; Buffer for input username
    password            BYTE 20 DUP(?)              ; Buffer for input password
    registerUsername    BYTE 20 DUP(?)              ; Buffer for username, 20 characters max
    registerPassword    BYTE 20 DUP(?)              ; Buffer for password, 20 characters max
    registeredUsername  BYTE 20 DUP(?)              ; Buffer for registered username
    registeredPassword  BYTE 20 DUP(?)              ; Buffer for registered password 
;------------------------------------------ENTER CUSTOMER INFO
    inputCustName       BYTE 129 DUP(?)            ; Buffer to hold input (128 characters + null terminator)
    inputDT             BYTE 2 DUP(?)              ; DineIn / TakeAway
    inputPromoCode      BYTE 10 DUP(?)             ; Buffer for promo code input (maximum 10 characters)
;------------------------------------------SELECT FOOD
    inputOrder          BYTE 2 DUP(?)              ; Define a buffer of 2 bytes (for user input)
    inputConfirmOrder   BYTE 2 DUP(?) 
    inputContOrder      BYTE 2 DUP(?)
    mealChoice          BYTE ?
    sideDishChoice      BYTE ?
;------------------------------------------CALCULATION
;~~~ORDER LIST
    foodList            BYTE 64 DUP(0)
    sideList            BYTE 64 DUP(0)
    priceList           DWORD 64 DUP(0)
    orderListLen        DWORD 0
    loopNo              DWORD 0
    loopIndex           DWORD 0
;~~~PRICE CALCULATION
    usingPromo          BYTE 0                     ; bool
    isTakeAway          BYTE 0                     ; bool
    currFoodPrice       DWORD 0
    totalPrice          DWORD 0
    totalTakeAway       DWORD 0
    discountedPrice     DWORD 0
    finalPrice          DWORD 0
;~~~INVOICE 
    foodStrLen          DWORD 0
    priceStrLen         DWORD 0
    gapSpace            BYTE "."
    invoiceNo           DWORD 0

;==============================DISPLAY MESSAGES
;------------------------------------------COMMONLY USED
    welcomeMsg          BYTE "--------------Welcome to Pan-tastic Mee House!--------------", 13, 10, 0
    invalidYN           BYTE "    INVALID INPUT: Please enter 'Y' or 'N'.", 13, 10, 0
    enterToContMsg      BYTE 13, 13, 10, "Enter anything to continue...", 0
;------------------------------------------COMPANY LOGO
    logoImg1            BYTE  "                       ⢀⣤⣦⣤⣤⣤⣤⣤⣶⣶⡄                ", 13, 10, 0
    logoImg2            BYTE  "                       ⣸⡿⠛⢻⠛⢻⠛⢻⣿⡟⠁                ", 13, 10, 0
    logoImg3            BYTE  "                      ⢀⣿⡇ ⡿ ⣼ ⢸⣿⡅                 ", 13, 10, 0
    logoImg4            BYTE  "                      ⠘⣿⡇ ⣿ ⢹ ⢸⣿⡇           ⢀⣀⣠⣤⣤⡀", 13, 10, 0
    logoImg5            BYTE  "                       ⠸⣿⡀⠸⡆⠘⣇ ⢿⣷    ⣀⣠⣤⣶⣶⣾⣿⠿⠿⠛⠋⢻⡆", 13, 10, 0
    logoImg6            BYTE  "                        ⣿⡇ ⣿ ⢿⣄⣸⣿⣦⣤⣴⠿⠿⠛⠛⠉⠁⢀⣀⣀⣀⣄⣤⣼⣿", 13, 10, 0
    logoImg7            BYTE  "                       ⢀⣿⡇ ⡿ ⣼⣿⣿⣯⣿⣦⣤⣤⣶⣶⣶⣿⢿⠿⠟⠿⠛⠛⠛⠛⠋", 13, 10, 0
    logoImg8            BYTE  "                       ⢸⣿⠁⣸⠃⢠⡟⢻⣿⣿⣿⣿⣿⣭⣭⣭⣵⣶⣤⣀⣄⣠⣤⣤⣴⣶⣦", 13, 10, 0
    logoImg9            BYTE  "                      ⢠⣿⡇ ⣿ ⣸ ⢸⣿⣶⣦⣤⣤⣄⣀⣀⣀  ⠉⠈⠉⠈⠉⠉⢽⣿", 13, 10, 0
    logoImg10           BYTE  "                     ⣀⣸⣿⡇ ⣿ ⢸ ⢸⣿⡿⣿⣿⣿⣿⡟⠛⠻⠿⠿⠿⣿⣶⣶⣶⣶⣿⣿", 13, 10, 0
    logoImg11           BYTE  "                ⢀⣤⣶⣿⡿⣿⣿⣿⣷ ⠹⡆⠘⣇⠈⣿⡟⠛⠛⠛⠾⣿⡳⣄      ⠈⠉⠉⠁", 13, 10, 0
    logoImg12           BYTE  "               ⣰⣿⢟⡭⠒⢀⣐⣲⣿⣿⡇ ⣷ ⢿ ⢸⣏⣈⣁⣉⣳⣬⣻⣿⣷⣀        ", 13, 10, 0
    logoImg13           BYTE  "           ⣀⣤⣾⣿⡿⠟⠛⠛⠿⣿⣋⣡⠤⢺⡇ ⡿ ⣼ ⢸⣿⠟⠋⣉⢉⡉⣉⠙⠻⢿⣯⣿⣦⣄    ", 13, 10, 0
    logoImg14           BYTE  "         ⢠⣾⡿⢋⣽⠋⣠⠊⣉⠉⢲⣈⣿⣧⣶⣿⠁⢠⣇⣠⣯⣀⣾⠧⠖⣁⣠⣤⣤⣤⣭⣷⣄⠙⢿⡙⢿⣷⡀  ", 13, 10, 0
    logoImg15           BYTE  "         ⢸⣿⣄⠸⣧⣼⣁⡎⣠⡾⠛⣉ ⠄⣈⣉⠻⢿⣋⠁⠌⣉⠻⣧⡾⢋⡡⠔⠒⠒⠢⢌⣻⣶⣾⠇⣸⣿⡇  ", 13, 10, 0
    logoImg16           BYTE  "         ⣹⣿⣿⣷⣦⣍⣛⠻⠿⠶⢾⣤⣤⣦⣤⣬⣷⣬⣿⣦⣤⣬⣷⣼⣿⣧⣴⣾⠿⠿⠿⢛⣛⣩⣴⣾⣿⣿⡇  ", 13, 10, 0
    logoImg17           BYTE  "         ⣸⣿⣟⡾⣽⣻⢿⡿⣷⣶⣦⣤⣤⣤⣬⣭⣉⣍⣉⣉⣩⣩⣭⣭⣤⣤⣤⣴⣶⣶⣿⡿⣿⣟⣿⣽⣿⣿⡇  ", 13, 10, 0
    logoImg18           BYTE  "         ⢸⣿⡍⠉⠛⠛⠿⠽⣷⣯⣿⣽⣻⣻⣟⢿⣻⢿⡿⣿⣟⣿⣻⢟⣿⣻⢯⣿⣽⣾⣷⠿⠗⠛⠉⠁⢸⣿⡇  ", 13, 10, 0
    logoImg19           BYTE  "         ⠘⣿⣧       ⠈⠉⠉⠉⠉⠛⠙⠛⠛⠛⠛⠋⠛⠋⠉⠉⠉⠉⠁       ⣿⡿   ", 13, 10, 0
    logoImg20           BYTE  "          ⠹⣿⣆        ⣴⣿⣷          ⣴⣿⣦⡀      ⣼⣿⠇   ", 13, 10, 0
    logoImg21           BYTE  "           ⠹⣿⣆       ⠻⠿⠟   ⠿⣦⣤⠞   ⠻⠿⠟     ⢀⣼⣿⠋    ", 13, 10, 0
    logoImg22           BYTE  "            ⠘⢿⣷⣶⣶⣤⣤⣤⣀⣀⣀⡀⣀ ⡀   ⡀⣀⡀⣀⣀⣀⣠⣤⣤⣴⣶⣶⣿⡿⠃     ", 13, 10, 0
    logoImg23           BYTE  "              ⠙⢿⣿⣾⡙⠯⠿⠽⢿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⠿⠿⠿⠙⢋⣿⣿⡿⠋       ", 13, 10, 0
    logoImg24           BYTE  "                ⠙⠻⢿⣶⣤⣀⣀           ⣀⣀⣤⣾⣿⠿⠋         ", 13, 10, 0
    logoImg25           BYTE  "                   ⠉⠙⠻⠿⠿⠷⣶⣶⣶⣶⣶⣶⣶⠿⠿⠿⠿⠛⠉⠁           ", 13, 10, 0
;------------------------------------------REGISTER
    registerTitleMsg    BYTE "REGISTER", 13, 10, "  Create an new account to continue", 13, 13, 10, 0
    registerPromptUser  BYTE "  Create a username (up to 20 characters): ", 0
    registerPromptPass  BYTE "  Create a password (up to 20 characters): ", 0
    registrationSuccess BYTE "Registration successful!", 13, 10, 0
    usernameTooShortMsg BYTE "    INVALID INPUT: Username must be between 1 and 20 characters without spaces.", 13, 10, 0
    passwordTooShortMsg BYTE "    INVALID INPUT: Password must be between 1 and 20 characters without spaces.", 13, 10, 0
    terminateMsg        BYTE 13, 13, 10, "Termination Program Entered, closing program...", 13, 10, 0
;------------------------------------------LOGIN
    usernamePrompt      BYTE "Enter username (or -111 to go back): ", 0
    passwordPrompt      BYTE "Enter password:                      ", 0
    successMsg          BYTE "Login successful!", 13, 10, 0 
    failLoginMsg        BYTE "Invalid credentials!", 13, 10, 0 
    startupMsg          BYTE "Launching Food Ordering Program... ", 13, 10, 0
;------------------------------------------ENTER CUSTOMER INFO
;~~~ENTER NAME
    inputNameMsg        BYTE "Enter your name (up to 50 characters or enter -111 to go back to register menu):  ", 0
    backToRegisterMsg   BYTE "Returning to registration, enter any key to continue...", 13, 10, 0
    errorNameMsg        BYTE "Invalid input. Please enter a valid name or -111 to go back.", 13, 10, 0
    invalidCharMsg      BYTE "    INVALID INPUT: Name contain invalid character.", 13, 10, 0
    nameBlankMsg        BYTE "    INVALID INPUT: No name was entered.", 13, 10, 0
    strTooLongMsg       BYTE "    INVALID INPUT: Name exceed 50 characters long.", 13, 10, 0
;~~~ENTER MODE
    dineOrTakeMsg       BYTE "Dine-in or Takeaway? Enter 'D' or 'T':  ", 0
    invalidDineTakeMsg  BYTE "    INVALID INPUT: Please enter 'D' or 'T'.", 13, 10, 0
;~~~ENTER PROMO CODE (OPTIONAL)
    promoMsg            BYTE "Do you have promo code to enter? (Y = Yes): ", 0
    promoCodeMsg        BYTE "Promo Code: ", 0
    invalidPromoCodeMsg BYTE "Invalid promo code. Do you wish to retry? (Y = Yes): ", 0
    promoSuccessMsg     BYTE "Promo Code used successfully!", 0

;------------------------------------------SELECT FOOD
;~~~SELECT MEAL
    menuTitle           BYTE "Select A Meal:", 13, 10, 0
    foodA               BYTE "A - Dry Pan Mee                       RM  8.50", 13, 10, 0
    foodB               BYTE "B - Chilli Pan Mee                    RM 10.00", 13, 10, 0
;~~~SELECT ADDON
    sideDishTitle       BYTE "Select An Add-On:", 13, 10, 0
    noSideDish          BYTE "1 - No add-on", 13, 10, 0
    setWithA            BYTE "2 - Set with Soya Milk                + RM 1.20", 13, 10, 0
    setWithB            BYTE "3 - Set with Dumplings                + RM 2.40", 13, 10, 0
    setWithAB           BYTE "4 - Set with Dumplings & Soya Milk    + RM 3.00", 13, 10, 0
;~~~SELECTION PROMPT
    selectionPrompt     BYTE ">> Selection: ", 0
    invalidInputMsg     BYTE "Invalid selection, please try again.", 13, 10, 0
;~~~SELECTED RESULT
    resultMsg           BYTE "You selected: ", 13, 10, 0
    setMsg              BYTE "Set ", 0
    foodAMsg            BYTE "Dry Pan Mee", 0
    foodBMsg            BYTE "Chilli Pan Mee", 0
    sideAOnlyMsg        BYTE " with Soya Milk", 0
    sideBOnlyMsg        BYTE " with Dumplings", 0
    sideABMsg           BYTE " with Dumplings & Soya Milk", 0
;~~~CONFIRM ORDER AND LOOP ORDER
    confirmOrderMsg     BYTE "Do you want to confirm this order (Y = Yes): ", 0
    contOrderMsg        BYTE "Do you want to keep ordering? (Y = Yes)    : ", 0
;~~~INVOICE
    invoiceID           BYTE 0
    orderNo             DWORD 0
    dearMsg             BYTE "Dear ", 0
    receiptMsg          BYTE ", here is your invoice:", 13, 10, 0   
    invoiceBdTop        BYTE "   _____________________________________________________________  ", 13, 10
                        BYTE " / \                                                            \ ", 13, 10
                        BYTE "|   |                                                            |", 13, 10 
                        BYTE " \__|                                                            |", 13, 10, 0
    invoiceBdLeft       BYTE "    |", 0
    invoiceBdRight      BYTE "|", 13, 10, 0
    invoiceBdBottom     BYTE "    |   _________________________________________________________|___", 13, 10
                        BYTE "    |  /                                                            /", 13, 10
                        BYTE "    \_/____________________________________________________________/ ", 13, 10, 0
    addressMsg          BYTE "Pan-tastic Mee House", 13, 10
                        BYTE "Lot 27-1, Jalan Genting Kelang,", 13, 10
                        BYTE "Taman Bunga Raya", 13, 10
                        BYTE "53000 Kuala Lumpur", 13, 10, 0
    receiptHeader       BYTE "Name                                              Price     ", 0
    totalPriceMsg       BYTE "Subtotal:                                         ", 0
    discountedAmountMsg BYTE "Discount:                                         ", 0
    takeawayChargeMsg   BYTE "Take Away Charge:                                 ", 0
    finalPriceMsg       BYTE "Grand Total:                                      ", 0
    RMMsg               BYTE "RM ", 0
    thankYouMsg         BYTE "Thank you, have a nice day :D", 0


.code
main PROC
    ; Initialize once and avoid re-execution
    mainProgram:
        regiLogin:
            mov backtoRegister, 0
            call register
                cmp isProgramLooping, 0
                je terminateProgram
            call login
                cmp isProgramLooping, 0
                je terminateProgram
                mov al, backtoRegister
                cmp al, 1
                je regiLogin
                jmp orderProgram
        orderProgram:
            call init
            call inputCustInfo
                mov al, backtoRegister
                cmp al, 1
                je regiLogin
            call orderLoop
            call calcTotalPrice
            call calcFinalPrice
            call displayInvoice
    jmp mainProgram

    terminateProgram:
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


;===============================PART 1.1: REGISTER
register PROC
    call ClrScr
    registerUsernameLoop:
        ; Input username during registration
        mov edx, OFFSET registerPromptUser
        call WriteString
        mov edx, OFFSET registerUsername
        mov ecx, 20
        call ReadString

        ; Secret code for admin to terminate program
        mov esi, OFFSET registerUsername 
        mov edi, OFFSET TERMINATE_CMD
        call StrCompare
        cmp eax, 1
        je adminTerminate
        ; Username is valid, proceed to password registration
    
        ; Check for spaces in the username
        lea esi, registerUsername
        call CheckForSpaces
        cmp eax, 1                      ; If space is found, it's invalid
        je invalidUsername

        ; Validate length of entered username
        lea esi, registerUsername
        call StringLength                    ; Get the length of the username
        cmp eax, 0                           ; Username cannot be empty
        je invalidUsername
        cmp eax, 20                          ; Ensure the length is within 20 characters
        ja invalidUsername

        jmp registerPasswordLoop

    invalidUsername:
        ; Display error message and re-prompt the user for a valid username
        mov edx, OFFSET usernameTooShortMsg
        call WriteString
        call Crlf
        jmp registerUsernameLoop
    
    adminTerminate:
        mov edx, OFFSET terminateMsg
        call WriteString
        mov isProgramLooping, 0
        ret

    ; Prompt for password
    registerPasswordLoop:
        mov edx, OFFSET registerPromptPass
        call WriteString
        mov edx, OFFSET registerPassword   ; Store input in registerPassword buffer
        mov ecx, 20                        ; Max length of 20
        call ReadString

        ; Check for spaces in the password
        lea esi, registerPassword
        call CheckForSpaces
        cmp eax, 1                      ; If space is found, it's invalid
        je invalidPassword

        ; Validate length of entered password
        lea esi, registerPassword
        call StringLength                    ; Get the length of the password
        cmp eax, 0                           ; Password cannot be empty
        je invalidPassword
        cmp eax, 20                          ; Ensure the length is within 20 characters
        ja invalidPassword

        ; Password is valid, proceed to complete registration
        jmp storeRegisterData

    invalidPassword:
        ; Display error message and re-prompt the user for a valid password
        mov edx, OFFSET passwordTooShortMsg
        call WriteString
        call Crlf
        call ReadChar
        jmp registerPasswordLoop

    storeRegisterData:
        ; Registration is complete, display success message
        mov edx, OFFSET registrationSuccess
        call WriteString
        call Crlf
        ret
    register ENDP

;----------------------------------------------CHECK FOR SPACES IN STRING
CheckForSpaces PROC
    push esi
    mov eax, 0                  ; Assume no space found

    checkLoop:
        lodsb                       ; Load the next byte into AL
        cmp al, 0                   ; If it's the end of the string (null terminator), exit
        je doneChecking
        cmp al, ' '                 ; Check if the character is a space
        je foundSpace               ; If space is found, set EAX to 1
        jmp checkLoop               ; Otherwise, keep checking

    foundSpace:
        mov eax, 1                  ; Space found, set EAX to 1

    doneChecking:
        pop esi
        ret
    CheckForSpaces ENDP


;==============================PART 1.2: LOGIN
login PROC
    startlogin:
        call ClrScr
        ; Prompt for username
        mov edx, OFFSET usernamePrompt
        call WriteString
        mov edx, OFFSET username
        mov ecx, 20  ; Max length of input
        call ReadString

        ; Secret code for admin to terminate program
        mov esi, OFFSET username 
        mov edi, OFFSET TERMINATE_CMD
        call StrCompare
        cmp eax, 1
        je adminTerminate

        ; Check if user entered -111 to go back
        lea esi, username
        lea edi, OFFSET BACK_CMD
        call StrCompare
        cmp eax, 0
        je contLogin

        goBackToRegister:               ; Display the message that we're returning to registration
            mov edx, OFFSET backToRegisterMsg
            call WriteString
            mov backtoRegister, 1
            call ReadString
            ret

        adminTerminate:
            mov edx, OFFSET terminateMsg
            call WriteString
            mov isProgramLooping, 0
            ret
    
        contLogin:
            ; Prompt for password
            mov edx, OFFSET passwordPrompt
            call WriteString
            mov edx, OFFSET password
            mov ecx, 20  
            call ReadString
        ; Compare entered username and password with registered credentials
        mov esi, OFFSET username
        mov edi, OFFSET registerUsername
        call StrCompare
        cmp eax, 0
        je loginFailed    ; If username and password match the registered ones, login is successful

        loginEnterPass:
            mov esi, OFFSET password
            mov edi, OFFSET registerPassword
            call StrCompare
        cmp eax, 0
        je loginFailed          ; If username and password match the registered ones, login is successful
        jmp loginSuccess        ; If username doesn't match, fail
        
    loginSuccess:
        ; Display success message
        mov edx, OFFSET successMsg
        call WriteChar
        call Crlf
        ret

    loginFailed:
        ; Display failure message
        mov edx, OFFSET failLoginMsg
        call WriteChar
        call Crlf
        call ReadString
        jmp startlogin
    login ENDP


;==============================PART 2: ENTER CUSTOMERS' INFO
inputCustInfo PROC
    call ClrScr
    call Crlf
    call printLogo
    mov edx, offset welcomeMsg
    call WriteString

    input_loop_start:
        ; Display input prompt
        call Crlf
        mov edx, OFFSET inputNameMsg
        call WriteString

        ; Read the input string
        mov edx, OFFSET inputCustName
        mov ecx, 129  ; Set the input limit to 128 characters + null terminator
        call ReadString

        ; Check if user entered -111 to go back
        lea esi, inputCustName
        lea edi, OFFSET BACK_CMD
        call StrCompare
        cmp eax, 0             ; EAX = 0 if strings are equal
        je goBackToRegister     ; Jump to register if user entered '-111'

        ; Check the length of the input
        mov esi, OFFSET inputCustName
        call StringLength        ; Get the length of input string into EAX
        cmp eax, 50              ; Check if length is greater than 50
        jg nameTooLong          
        cmp eax, 0               ; Check if length is 0 or negative
        jle nameNull           
        jmp check_characters

        nameNull:
            mov edx, OFFSET nameBlankMsg
            call WriteString
            jmp nameInputInvalid        ; Re-prompt to re-enter input

        nameTooLong:
            mov edx, OFFSET strTooLongMsg
            call WriteString
            jmp nameInputInvalid        ; Re-prompt to re-enter input
        
        goBackToRegister:               ; Display the message that we're returning to registration
            mov edx, OFFSET backToRegisterMsg
            call WriteString
            mov backtoRegister, 1
            call ReadChar                ; Wait for any input to continue
            ret

        check_characters:
            ; Check the characters of the input
            call CheckNameCharacters
            cmp eax, 1               ; EAX == 1 means valid characters
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
            jmp input_loop_start      ; Loop back to input start
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

        ; Read a single character input
        call ReadString
        mov [inputDT], al          ; Store the input character
        call WriteChar              ; Echo the character (optional)
        call Crlf                   ; Move to the next line

        ; Check if the input is 'T', 't', 'D', or 'd'
        call CheckDineTake

        cmp eax, 1
        jne dine_input_loop          ; If invalid, re-enter the loop

        ret
    dine_or_takeaway_check ENDP
    

; Check if input is 'D', 'd', 'T', or 't'
CheckDineTake PROC
    mov al, [inputDT]             ; Load the input character into AL

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
        mov eax, 0                    ; Set return value to 0 (invalid)
        ret

    setTakeAway:
        ; Set takeaway flag
        mov isTakeAway, 1
        jmp validDTInput

    validDTInput:
        mov eax, 1                    ; Set return value to 1 (valid)
        ret
    CheckDineTake ENDP


; Promo code check function
promo_code_check PROC
    promo_input_loop:
        call Crlf
        ; Display promo code query

        mov edx, OFFSET promoMsg
        call inputYesOrNo
        cmp eax, 1
        je promo_code_entry
        cmp eax, 0
        je no_promo_code
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
        cmp eax, 1
        je valid_promo_code

        ; Invalid promo code, re-enter loop
        mov edx, OFFSET invalidPromoCodeMsg
        call WriteString
        ; Read input if no exit
        cmp eax, 0
        je stopEnterPromo
        jmp promo_code_loop

        stopEnterPromo:
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
    call Crlf
    mov edx, OFFSET resultMsg
    call WriteString
    call displaySelection
    call Crlf
    call Crlf

    confirmOrder:
        mov edx, OFFSET confirmOrderMsg
        call inputYesOrNo
        cmp eax, 1
        je storeOrder
        jmp contOrder

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
        ret

    contOrder:
        call Crlf
        mov edx, OFFSET contOrderMsg
        call inputYesOrNo
        cmp eax, 1
        je orderLoopStart
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
        inc esi                  ; Move to next order index
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

    mov edx, OFFSET invoiceBdTop
    call WriteString

    mov edx, OFFSET invoiceBdLeft
    call WriteString
    mov edx, OFFSET receiptHeader
    call WriteString
    mov edx, OFFSET invoiceBdRight
    call WriteString

    mov edx, OFFSET invoiceBdLeft
    call WriteString
    call printDash
    mov edx, OFFSET invoiceBdRight
    call WriteString

    mov ecx, orderListLen       ; Load the number of orders into ecx
    mov esi, 0                  ; Start at the first order
    displayEachOrder:
    mov orderNo, esi
    push ecx                ; Save the loop counter
    

    mov edx, OFFSET invoiceBdLeft
    call WriteString

    call getFood            ; Get food information
    call getSide            ; Get side dish information
    call displaySelection   ; Display the selected order

    ; Calculate the spacing based on the food name length
    mov esi, orderNo
    mov eax, foodStrLen     ; Get the length of the food string
    mov ebx, 50             ; Set the max width for display
    call printSpaceGap

    ; Ensure esi is properly saved and restored around the price procedure
    push eax                ; Save eax before calling the price function
    mov esi, orderNo
    call getOrderPriceThenPrint              ; Restore esi after price retrieval
    pop eax                 ; Restore eax after price retrieval

    ; Calculate the spacing for the price string
    mov esi, orderNo
    mov eax, priceStrLen     ; Get the length of the price string
    mov ebx, 10              ; Set the max width for display
    call printSpaceGap

    mov edx, OFFSET invoiceBdRight
    call WriteString
    pop ecx                ; Restore the loop counter
    mov esi, orderNo
    inc esi
    loop displayEachOrder       ; Loop until all orders are processed

    mov edx, OFFSET invoiceBdLeft
    call WriteString
    call printDash
    mov edx, OFFSET invoiceBdRight
    call WriteString

    mov edx, OFFSET invoiceBdLeft
    call WriteString
    mov edx, OFFSET totalPriceMsg
    call WriteString
    mov eax, totalPrice
    call printPriceStr
    mov eax, priceStrLen     ; Get the length of the price string
    mov ebx, 10              ; Set the max width for display
    call printSpaceGap
    mov edx, OFFSET invoiceBdRight
    call WriteString

    mov edx, OFFSET invoiceBdLeft
    call WriteString
    mov edx, OFFSET discountedAmountMsg
    call WriteString
    mov eax, discountedPrice
    call printPriceStr
    mov eax, priceStrLen     ; Get the length of the price string
    mov ebx, 10              ; Set the max width for display
    call printSpaceGap
    mov edx, OFFSET invoiceBdRight
    call WriteString

    mov edx, OFFSET invoiceBdLeft
    call WriteString
    mov edx, OFFSET takeawayChargeMsg
    call WriteString
    mov eax, totalTakeAway
    mov edi, OFFSET totalTakeAway 
    call printPriceStr
    mov eax, priceStrLen     ; Get the length of the price string
    mov ebx, 10              ; Set the max width for display
    call printSpaceGap
    mov edx, OFFSET invoiceBdRight
    call WriteString

    mov edx, OFFSET invoiceBdLeft
    call WriteString
    call printDash
    mov edx, OFFSET invoiceBdRight
    call WriteString

    mov edx, OFFSET invoiceBdLeft
    call WriteString
    mov edx, OFFSET finalPriceMsg
    call WriteString
    mov eax, finalPrice
    call printPriceStr
    mov eax, priceStrLen     ; Get the length of the price string
    mov ebx, 10              ; Set the max width for display
    call printSpaceGap
    mov edx, OFFSET invoiceBdRight
    call WriteString
    mov edx, OFFSET invoiceBdBottom
    call WriteString

    call Crlf
    call Crlf
    mov edx, OFFSET thankYouMsg 
    call WriteString

    noInvoice:
    mov edx, OFFSET enterToContMsg
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
getOrderPriceThenPrint PROC
    ; Ensure esi is multiplied by 4 (DWORD indexing) before accessing the price
    mov edi, orderNo            ; edi holds the index in priceList
    shl edi, 2              ; Multiply edi by 4 to access DWORD entries in priceList

    mov eax, [priceList + edi]  ; EAX now contains the price in cents
    cmp eax, 0               ; Ensure the price is not zero
    je zeroPrice             ; Handle zero price case separately

    ; Convert price to string and display it
    mov edi, OFFSET displayPriceStr  ; Load the address of the price display buffer
    call printPriceStr        ; Print the price string
    ; Set priceStrLen (length of the price string)
    lea esi, displayPriceStr
    call StringLength         ; Get the length of the price string

    ret

    zeroPrice:
        ; Handle cases where the price is zero
        ret
    getOrderPriceThenPrint ENDP

printSpaceGap PROC
    sub ebx, eax
    printSpace:
        ; EBX holds the number of spaces to print
        cmp ebx, 0            ; Check if there are spaces to print
        jz donePrintSpace     ; Exit if no spaces are left to print

        mov al, " "           ; Load space character
        call WriteChar        ; Print the space
        dec ebx
        jmp printSpace

    donePrintSpace:
        ret
    printSpaceGap ENDP


;==============================CUSTOM FUNCTIONS
;------------------------------------------PRINT NOODLE HOUSE LOGO
printLogo PROC
    ; Set UTF-8 code page
    INVOKE SetConsoleOutputCP, 65001
    mov eax, 65001  ; Set UTF-8 code page
    push eax
    call SetConsoleOutputCP  
    mov edx, offset logoImg1
    call WriteString
    mov edx, offset logoImg2
    call WriteString
    mov edx, offset logoImg3
    call WriteString
    mov edx, offset logoImg4
    call WriteString
    mov edx, offset logoImg5
    call WriteString
    mov edx, offset logoImg6
    call WriteString
    mov edx, offset logoImg7
    call WriteString
    mov edx, offset logoImg8
    call WriteString
    mov edx, offset logoImg9
    call WriteString
    mov edx, offset logoImg10
    call WriteString
    mov edx, offset logoImg11
    call WriteString
    mov edx, offset logoImg12
    call WriteString
    mov edx, offset logoImg13
    call WriteString
    mov edx, offset logoImg14
    call WriteString
    mov edx, offset logoImg15
    call WriteString
    mov edx, offset logoImg16
    call WriteString
    mov edx, offset logoImg17
    call WriteString
    mov edx, offset logoImg18
    call WriteString
    mov edx, offset logoImg19
    call WriteString
    mov edx, offset logoImg20
    call WriteString
    mov edx, offset logoImg21
    call WriteString
    mov edx, offset logoImg22
    call WriteString
    mov edx, offset logoImg23
    call WriteString
    mov edx, offset logoImg24
    call WriteString
    mov edx, offset logoImg25
    call WriteString
    ret
    printLogo ENDP

;------------------------------------------PRINT HORIZONTAL SEPERATION LINE
printDash PROC
    ; Set up the loop counter and character
    mov al, dash                ; Load the dash character into AL
    mov ecx, dashAmount         ; Load the dash count into ECX

    print_loop:
        call WriteChar          ; Call WriteChar to print the character
    loop print_loop             ; Decrement ECX and loop until ECX reaches 0

    ret                     ; Return to the calling procedure
    printDash ENDP

;------------------------------------------INPUT YES/NO
; INPUT:    EDX         - the address of the string (prompt).
; OUTPUT:   EAX         - 0 = equal, 1 = different
inputYesOrNo PROC
    loopYN:
        ; Display the prompt and read input (expecting Y/N)
        call WriteString
        push edx  ; Save the edx register

        mov edx, OFFSET inputYN
        mov ecx, 2      ; Expect 1 character plus null terminator
        call ReadString
        ; Now, ensure we are checking only the first character
        mov esi, OFFSET inputYN  ; Load the address of the input buffer
        lodsb                    ; Load the first character into AL from inputYN

        ; Check if AL contains 'Y', 'y', 'N', or 'n'
        cmp al, 'Y'
        je yesEntered
        cmp al, 'y'
        je yesEntered
        cmp al, 'N'
        je noEntered
        cmp al, 'n'
        je noEntered

        ; If not valid, repeat prompt
    repeatYN:
        mov edx, OFFSET invalidYN  ; Invalid input message
        call WriteString
        pop edx  ; Restore the edx register
        call Crlf
        jmp loopYN  ; Repeat the input loop

    yesEntered:
        mov eax, 1  ; Return 1 for Yes
        pop edx     ; Restore edx before returning
        ret

    noEntered:
        mov eax, 0  ; Return 0 for No
        pop edx     ; Restore edx before returning
        ret

    inputYesOrNo ENDP


;------------------------------------------STRING COMPARISON
; INPUT:    ESI & EDI   - the address both strings.
; OUTPUT:   EAX         - 0 = equal, 1 = different
StrCompare PROC
    push esi                 ; Preserve registers
    push edi

    compareLoop:
        mov al, [esi]         ; Load byte from string 1 (input string in esi)
        mov bl, [edi]         ; Load byte from string 2 (comparison string in edi)
        cmp al, bl            ; Compare the characters
        jne notEqual          ; If they are different, jump to notEqual
        test al, al           ; Check if the end of the string is reached (null terminator)
        je equal              ; If both strings are equal up to the null terminator, jump to equal
        inc esi               ; Move to the next character in string 1
        inc edi               ; Move to the next character in string 2
        jmp compareLoop       ; Continue the loop

    notEqual:
        mov eax, 0            ; Set eax to 1 to indicate strings are not equal
        jmp doneCompare

    equal:
        mov eax, 1            ; Set eax to 0 to indicate strings are equal

    doneCompare:
        pop edi               ; Restore registers
        pop esi
        ret                   ; Return with the result in eax

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
    push eax
    mov priceStrLen, 3
    ;display "RM "
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
    add priceStrLen, 3

    ; Now convert the remaining part (integer portion)
    IntToStrLoop:
        xor edx, edx                 ; Clear EDX for division
        div ecx                      ; EAX / 10, quotient in EAX, remainder in EDX
        add dl, '0'                  ; Convert remainder (digit) to ASCII
        inc priceStrLen
        mov [edi], dl                ; Store ASCII character in buffer
        dec edi                      ; Move back to fill the next character

        test eax, eax                ; Check if there are more digits to process
        jnz IntToStrLoop             ; If EAX is not zero, continue

    ; Print the formatted string using WriteString
    inc edi                          ; Move pointer to the start of the string (EDI)
    mov edx, edi                     ; Load the pointer into EDX for WriteString
    call WriteString                 ; Output the formatted price
    pop eax
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