.arch msp430g2553
    .p2align 1,0                 ; set memory boundary of 2 bytes with padding of zeroes
    .text                        ; says this section of executible is where code is
    .global led_game        ; global name of function
    .extern P1OUT                ; led output var
    .extern led_seconds          ; seconds var
    .extern led_second_count     ; interrupt count var
    .extern random_int_generator           ; state transition function
    .extern button_flag
    .extern transition
    .extern led_changes
    .extern green_on
    .extern red_on
    .extern lights_on
    .extern lights_off
    .extern led_changes
    .extern led_speed
    .extern random_led


led_game:
    inc &led_seconds    ; led_seconds++
    cmp &led_speed, &led_seconds  ;led_seconds - led_speed
    jl end; if led_seconds >= led_speed
    cmp.b #0, &led_second_count ;if led_second_count
    jz else
    cmp.b #0, &button_flag    ; if !button flag
    jnz nextIf
    mov #5, r12
    call #transition
    
nextIf:
    cmp.b #16, &led_changes
    jge reset
    inc.b &led_changes

reset:
    mov.b #1, &button_flag
    mov.b #0, &led_second_count
    jmp speed_change

else:
    inc.b &led_second_count    ;led_second_count++
    mov #0, &led_seconds ; led_seconds = 0
    push #change_leds
    mov #random_int_generator, r0

change_leds:
    mov.b r12, &random_led
    cmp.b #1, r12
    jz case_one
    cmp.b #2, r12
    jz case_two
    cmp.b #3, r12
    jz case_three
    cmp.b #4, r12
    jz case_four
    
case_one:
    call #green_on
    jmp speed_change

case_two:
    call #red_on
    jmp speed_change

case_three:
    call #lights_on
    jmp speed_change

case_four:
    call #lights_off
    jmp speed_change

speed_change:
    mov.b #10, r6
    cmp.b &led_changes, r6 ;b-a
    jnc end
    mov.b &led_changes, r6
    and.b #1, r6
    cmp.b #0, r6
    jnz end
    cmp.b #0, &led_changes
    jz end
    mov &led_speed, r6
    rra r6
    rra r6
    rra r6
    sub r6, &led_speed
end:
    ret
