INCLUDE Irvine32.inc

.data
    ; display food menu message
    dash_count DWORD 30     ; Define the number of dashes to print
    dash BYTE '-'           ; Define the dash character
    menuTitle    BYTE "Select a meal:", 0
    foodA        BYTE "A - Food A", 0
    foodB        BYTE "B - Food B", 0
    sideDishTitle BYTE "Select a side dish:", 0
    noSideDish   BYTE "1 - No side dish", 0
    setWithA     BYTE "2 - Set with A", 0
    setWithB     BYTE "3 - Set with B", 0
    setWithAB    BYTE "4 - Set with A + B", 0
    selectionPrompt BYTE ">> Selection: ", 0
    invalidInputMsg BYTE "Invalid selection, please try again.", 0
    resultMsg    BYTE "You selected: ", 0
    foodAMsg     BYTE "Food A", 0
    foodBMsg     BYTE "Food B", 0
    noSideDishMsg BYTE "No side dish", 0
    sideAOnlyMsg  BYTE "Set with A", 0
    sideBOnlyMsg  BYTE "Set with B", 0
    sideABMsg     BYTE "Set with A + B", 0

    ; user input
    mealChoice   BYTE ?
    sideDishChoice DWORD ?

.code
main PROC
    ; display Mealmenu and get valid selection
    call DisplayMealMenu
    call GetValidMealSelection

    ; display SideDishMenu and get valid selection
    call DisplaySideDishMenu
    call GetValidSideDishSelection

    exit
main ENDP

; function mealmenu
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

; function sidedishmenu
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

; get and check validation mealChoice when user input
GetValidMealSelection PROC
    ; loop until user input valid selection
    mov ecx, 1               ; initialize count of loop (count loop is 1)
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

        mov ecx, 1       ; set count loop by 1 again when input is invalid
        jmp GetValidMealLoop

SelectFoodA:
    ; display message if mealchoice = 'A'
    mov edx, OFFSET resultMsg
    call WriteString
    mov edx, OFFSET foodAMsg
    call WriteString
    call Crlf
    ret

SelectFoodB:
    ; display message if mealchoice = 'B'
    mov edx, OFFSET resultMsg
    call WriteString
    mov edx, OFFSET foodBMsg
    call WriteString
    call Crlf
    ret
GetValidMealSelection ENDP

; get and check validation sideDishChoice when user input
GetValidSideDishSelection PROC
    ; loop until user input valid selection
    mov ecx, 1               ; initialize count of loop (count loop is 1)
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

        mov ecx, 1       ; set count loop by 1 again when input is invalid
        jmp GetValidSideDishLoop

NoSideDishSelected:
    ; display message if sideDishchoice = 1
    mov edx, OFFSET resultMsg
    call WriteString
    mov edx, OFFSET noSideDishMsg
    call WriteString
    call Crlf
    ret

SideDishASelected:
    ; display message if sideDishchoice = 2
    mov edx, OFFSET resultMsg
    call WriteString
    mov edx, OFFSET sideAOnlyMsg
    call WriteString
    call Crlf
    ret

SideDishBSelected:
    ; display message if sideDishchoice = 3
    mov edx, OFFSET resultMsg
    call WriteString
    mov edx, OFFSET sideBOnlyMsg
    call WriteString
    call Crlf
    ret

SideDishABSelected:
    ; display message if sideDishchoice = 4
    mov edx, OFFSET resultMsg
    call WriteString
    mov edx, OFFSET sideABMsg
    call WriteString
    call Crlf
    ret
GetValidSideDishSelection ENDP

print_dash PROC
    ; Set up the loop counter and character
    mov al, dash                   ; Load the dash character into AL
    mov ecx, dash_count            ; Load the dash count into ECX

print_loop:
    call WriteChar                 ; Call WriteChar to print the character
    loop print_loop                ; Decrement ECX and loop until ECX reaches 0
    ret                           ; Return to the calling procedure
print_dash ENDP

END main