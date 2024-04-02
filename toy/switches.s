.arch msp430g2553
    .p2align 1,0                 ; set memory boundary of 2 bytes with padding of zeroes
    .text                        ; executable code
    .global switch_init          ; global functions
    .global switch_interrupt_handler
    .global switch_update_interrupt_sense_1
    .global switch_update_interrupt_sense_2
    .extern P1IN                 ; required global functions and vars
    .extern P1IES
    .extern P1IES
    .extern P2IN
    .extern P1REN
    .extern P1IE
    .extern P1OUT
    .extern P1DIR
    .extern P2REN
    .extern P2IE
    .extern P2DIR
    .extern current_state
    .extern easter_egg
    .extern interrupt_counter
    .extern button_flag
    .extern transition
    .extern random_led

switch_update_interrupt_sense_1:    ; return change based on switch interrupt in port 1
    sub #1, r1              ; allocate space on stack for local var
    mov.b &P1IN, 0(r1)      ; p1val (local var) = P1IN
    and.b #8, 0(r1)         ; p1val &= sw0
    bis.b 0(r1), &P1IES     ; P1IES |= p1val activate interrupt rising edge
    mov.b &P1IN, 0(r1)      ; p1val (local var) = P1IN
    bis.b #~8, 0(r1)        ; p1val |= ~sw0
    and.b 0(r1), &P1IES     ; P1IES &= p1val activate interrupt falling edge
    mov.b &P1IN, r12        ; return &P1IN
    jmp restore_stack_suts  ; goto free allocated space on stack

switch_update_interrupt_sense_2:    ; return change based on switch interrupt in port 2
    sub #1, r1              ; allocate space on stack for local var
    mov.b &P2IN, 0(r1)      ; p2val (local var) = P2IN
    and.b #15, 0(r1)        ; p2val &= SWITCHES
    bis.b 0(r1), &P2IES     ; P2IES |= p2val
    mov &P2IN, r12          ; return P2IN
    jmp restore_stack_suts  ; goto free allocated space on stack

restore_stack_suts:         ; free allocated space on stack from switch intterrupt senses
    add #1, r1              ; move stack back up 1
    jmp end                 ; return once finished

switch_init:                ; initialize switches
    bis.b #8, &P1REN        ; enable resistors for p1.3
    bis.b #8, &P1IE         ; enable interrupts from p1.3
    bis.b #8, &P1OUT        ; pull-up for p1.3
    bic.b #8, &P1DIR        ; set p1.3 bits for input
    bis.b #15, &P2REN       ; enable resisors for main switches
    bis.b #15, &P2IE        ; enable interrupts from main switches
    bis.b #15, &P2OUT       ; pull-ups for main switches
    bic.b #15, &P2DIR       ; set main switches bits for input
    pop r0
    
switch_interrupt_handler:   ; switch handler
    push #set_p1val         ; goto set_p1val once finished
    mov #switch_update_interrupt_sense_1, r0    ; call function
set_p1val:                  ; setup interrupts for p1.3 and store input
    mov.b r12, r6           ; temp = p1val
    push #set_p2val         ; goto set_p2val once finished
    mov #switch_update_interrupt_sense_2, r0    ; call function
set_p2val:                  ; setup interrupts for switches and store input
    sub #20, r1             ; allocate memory for local vars
    mov.b r12, r7           ; temp = P2IN
    mov r6, 0(r1)           ; p1val = 0(r1)
    mov r7, 2(r1)           ; p2val = 2(r1)
    jmp setup_switches      ; goto setup_switches
setup_switches:             ; setup main switches such that down is 1, up is 0
    mov.b 2(r1), r6         ; temp = p2val
    and.b #1, r6            ; temp = p2val & 1
    cmp.b #0, r6            ; temp - 0
    jz sw1                  ; if temp == 0, goto sw1 (button pressed)
    mov #0, 4(r1)           ; button1 = 0 (button not pressed)
    mov.b 2(r1), r6         ; temp = p2val
    and.b #2, r6            ; temp = p2val & 2
    cmp.b #0, r6            ; temp - 0
    jz sw2                  ; if temp == 0, goto sw2 (button pressed)
    mov #0, 6(r1)           ; button2 = 0 (button not pressed)
    mov.b 2(r1), r6         ; temp = p2val
    and.b #4, r6            ; temp = p2val & 4
    cmp.b #0, r6            ; temp - 0
    jz sw3                  ; if temp == 0, goto s3 (button pressed)
    mov #0, 8(r1)           ; button3 = 0 (button not pressed)
    mov.b 2(r1), r6         ; temp = p2val
    and.b #8, r6            ; temp = p2val & 8
    cmp.b #0, r6            ; temp - 0
    jz sw4                  ; if temp == 0, goto s4 (button pressed)
    mov #0, 10(r1)          ; button4 = 0 (button not pressed)
    jmp continue_handling   ; goto handling button action
sw1:                        ; if button1 is pressed
    mov #1, 4(r1)           ; button1 = 1
    jmp continue_handling   ; goto handling button action
sw2:                        ; if button2 is pressed
    mov #1, 6(r1)           ; button2 = 1
    jmp continue_handling   ; goto handling button action
sw3:                        ; if button3 is pressed
    mov #1, 8(r1)           ; button3 = 1
    jmp continue_handling   ; goto handling button action
sw4:                        ; if button 4 is pressed
    mov #1, 10(r1)          ; button4 = 1
    jmp continue_handling   ; goto handling button action
continue_handling:          ; perform action based on button pressed
    cmp #0, &current_state  ; current_state - 0
    jnz if_during           ; if curren_state not in waiting
    mov 0(r1), r6           ; temp = p1val
    and.b #8, r6            ; temp = p1val & sw0
    cmp.b #0, r6            ; temp - 0
    jnz side_pressed_once   ; if temp != 0, goto side_pressed_once
    mov.b #1, &easter_egg   ; easter_egg = 1
    jmp restore_stack_sih   ; restore memory on stack and exit
side_pressed_once:          ; if side button released
    mov.b 4(r1), r6         ; temp = button1
    bis.b 6(r1), r6         ; temp |= button2
    bis.b 8(r1), r6         ; temp |= button3
    bis.b 10(r1), r6        ; temp |= button4
    cmp.b #0, r6            ; temp - 0
    jnz restore_stack_sih   ; if temp != 0, goto to restore_stack_sih
    mov.b #0, &easter_egg   ; easter_egg = 0
    inc.b &interrupt_counter; interrupt_counter++
    jmp restore_stack_sih   ; goto restore_stack_sih
if_during:                  ; check if current state is during game
    cmp #4, &current_state  ; current_state - 4
    jnz restore_stack_sih   ; if current_state != 4, goto restore_stack_sih
    jmp button_one_if       ; goto button_one_if
button_one_if:              ; check if button1 is pressed
    cmp #1, 4(r1)           ; button1 - 1
    jnz button_two_if       ; if button1 != 1, goto button_two_if
    mov.b #1, &button_flag  ; button_flag = 1
    cmp.b #1, &random_led   ; random_led - 1
    jnz game_over           ; if random_led != 1, goto game_over
    jmp restore_stack_sih   ; goto restore_stack_sih
button_two_if:              ; check if button2 pressed
    cmp #1, 6(r1)           ; button2 - 1
    jnz button_three_if     ; if button2 != 1, goto button_three_if
    mov.b #1, &button_flag  ; button_flag = 1
    cmp.b #2, &random_led   ; random_led - 2
    jnz game_over           ; if random_led != 2, goto game_over
    jmp restore_stack_sih   ; goto restore_stack_sih
button_three_if:            ; check if button3 is pressed
    cmp #1, 8(r1)           ; button3 - 1
    jnz button_four_if      ; if button3 != 1, goto button_four_if
    mov.b #1, &button_flag  ; button_flag = 1
    cmp.b #3, &random_led   ; random_led - 3
    jnz game_over           ; if random_led != 3, goto game_over
    jmp restore_stack_sih   ; goto restore_stack_sih
button_four_if:             ; check if button4 is pressed
    cmp #1, 10(r1)          ; button4 - 1
    jnz restore_stack_sih   ; if button4 != 1, goto restore_stack_sih
    mov.b #1, &button_flag  ; button_flag = 1
    cmp.b #4, &random_led   ; random_led - 4
    jnz game_over           ; if random_led != 4, goto game_over
    jmp restore_stack_sih   ; goto restore_stack_sih
game_over:                  ; user entered incorrect answer
    add #20, r1             ; restore allocated space on stack
    mov #5, r12             ; set parameter to 5 for game over state
    push #end               ; goto end once finished
    mov #transition, r0     ; transition(gameover)

restore_stack_sih:          ; restore allocated space on stack
    add #20, r1             ; go back up the stack
    jmp end                 ; end once finished

end:
    ret
