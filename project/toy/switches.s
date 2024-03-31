.arch msp430g2553
    .p2align 1,0                 ; set memory boundary of 2 bytes with padding of zeroes
    .text                        ; executable code
    .global switch_init
    .global switch_interrupt_handler
    .global switch_update_interrupt_sense_1
    .global switch_update_interrupt_sense_2
    .extern P1IN
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

switch_update_interrupt_sense_1:
    sub #1, r1
    mov.b &P1IN, 0(r1)
    and.b #8, 0(r1)
    bis.b 0(r1), &P1IES
    mov.b &P1IN, 0(r1)
    bis.b #~8, 0(r1)
    and.b 0(r1), &P1IES
    mov.b &P1IN, r12
    jmp restore_stack_suts

switch_update_interrupt_sense_2:
    sub #1, r1
    mov.b &P2IN, 0(r1)
    and.b #15, 0(r1)
    bis.b 0(r1), &P2IES
    mov &P2IN, r12
    jmp restore_stack_suts

restore_stack_suts:
    add #1, r1
    pop r0

switch_init:
    bis.b #8, &P1REN
    bis.b #8, &P1IE
    bis.b #8, &P1OUT
    bic.b #8, &P1DIR
    
    bis.b #15, &P2REN
    bis.b #15, &P2IE
    bis.b #15, &P2OUT
    bic.b #15, &P2DIR
    
    pop r0
    
switch_interrupt_handler:
    push #set_p1val
    mov #switch_update_interrupt_sense_1, r0
set_p1val:
    mov.b r12, r6 ;r6 = p1val
    push #set_p2val
    mov #switch_update_interrupt_sense_2, r0
set_p2val:
    sub #20, r1
    mov.b r12, r7
    mov r6, 0(r1); p1val = 0(r1)
    mov r7, 2(r1); p2val = 2(r1)
    jmp setup_switches
setup_switches:
    
    ; button one
    mov.b 2(r1), r6 ;p2val to r6
    and.b #1, r6  ; r6 and sw1
    cmp.b #0, r6    ; r6-0
    jz sw1
    mov #0, 4(r1)   ; button1 = 0
    
    ; button two
    mov.b 2(r1), r6
    and.b #2, r6
    cmp.b #0, r6
    jz sw2
    mov #0, 6(r1)
    
    ; button three
    mov.b 2(r1), r6
    and.b #4, r6
    cmp.b #0, r6
    jz sw3
    mov #0, 8(r1)

    ; button four
    mov.b 2(r1), r6
    and.b #8, r6
    cmp.b #0, r6
    jz sw4
    mov #0, 10(r1)
    jmp continue_handling
sw1:
    mov #1, 4(r1)   ; button1 = 1
    jmp continue_handling
sw2:
    mov #1, 6(r1)
    jmp continue_handling
sw3:
    mov #1, 8(r1)
    jmp continue_handling
sw4:
    mov #1, 10(r1)
    jmp continue_handling
continue_handling:
    cmp #0, &current_state
    jnz if_during
    mov 0(r1), r6
    and.b #8, r6
    cmp.b #0, r6
    jnz side_pressed_once
    mov.b #1, &easter_egg
    jmp restore_stack_sih
side_pressed_once:
    mov.b 4(r1), r6
    bis.b 6(r1), r6
    bis.b 8(r1), r6
    bis.b 10(r1), r6
    cmp.b #0, r6
    jnz restore_stack_sih
    mov.b #0, &easter_egg
    inc.b &interrupt_counter
    jmp restore_stack_sih
if_during:
    cmp #4, &current_state
    jnz restore_stack_sih
    jmp button_one_if
button_one_if:
    cmp #1, 4(r1)
    jnz button_two_if
    mov.b #1, &button_flag
    cmp.b #1, &random_led
    jnz game_over
    jmp restore_stack_sih
button_two_if:
    cmp #1, 6(r1)
    jnz button_three_if
    mov.b #1, &button_flag
    cmp.b #2, &random_led
    jnz game_over
    jmp restore_stack_sih
button_three_if:
    cmp #1, 8(r1)
    jnz button_four_if
    mov.b #1, &button_flag
    cmp.b #3, &random_led
    jnz game_over
    jmp restore_stack_sih
button_four_if:
    cmp #1, 10(r1)
    jnz restore_stack_sih
    mov.b #1, &button_flag
    cmp.b #4, &random_led
    jnz game_over
    jmp restore_stack_sih
game_over:
    add #20, r1
    mov #5, r12
    push #end
    mov #transition, r0

restore_stack_sih:
    add #20, r1
    pop r0

end:
    ret
