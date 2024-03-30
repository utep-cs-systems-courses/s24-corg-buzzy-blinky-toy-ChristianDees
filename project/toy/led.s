.arch msp430g2553
    .data

    green_blink_limit:  .byte 5
    red_blink_limit:    .byte 1
    green_blink_count:  .byte 0
    red_blink_count:    .byte 0

    led_second_count:   .byte 0
    led_changes:        .byte 0
    
    .global random_led, button_flag
    random_led:         .byte 0
    button_flag:        .byte 0
    
    .global easter_egg, interrupt_counter
    easter_egg:         .byte 0
    interrupt_counter:  .byte 0
    
    mario_lights:
                        .byte 2
                        .byte 0
                        .byte 2
                        .byte 0
                        .byte 0
                        .byte 2
                        .byte 0
                        .byte 0
                        .byte 1
                        .byte 0
                        .byte 2
                        .byte 0
                        .byte 1
                        .byte 1
                        .byte 0
                        .byte 0
                        .byte 1
                        .byte 0
                        .byte 0
                        .byte 2
                        .byte 0
                        .byte 0
                        .byte 1
                        .byte 0
                        .byte 0
                        .byte 2
                        .byte 0
                        .byte 0
                        .byte 1
                        .byte 0
                        .byte 1
                        .byte 0
                        .byte 1
                        .byte 0
                        .byte 2
                        .byte 0
                        .byte 1
                        .byte 0
                        .byte 2
                        .byte 0
                        .byte 1
                        .byte 0
                        .byte 2
                        .byte 0
                        .byte 1
                        .byte 0
                        .byte 1
                        .byte 0
                        .byte 0
    star_wars_lights:
                        .byte 2
                        .byte 2
                        .byte 0
                        .byte 2
                        .byte 2
                        .byte 0
                        .byte 2
                        .byte 2
                        .byte 0
                        .byte 1
                        .byte 1
                        .byte 0
                        .byte 2
                        .byte 0
                        .byte 1
                        .byte 1
                        .byte 0
                        .byte 2
                        .byte 2
                        .byte 0
                        .byte 1
                        .byte 0
                        .byte 2
                        .byte 2
                        .byte 2
                        .byte 2

    .align 2
    led_seconds:        .word 0
    led_speed:          .word 500

    easter_egg_seconds: .word 0
    interrupt_seconds:  .word 0


    .p2align 1,0                 ; set memory boundary of 2 bytes with padding of zeroes
    .text                        ; says this section of executible is where code is
    .global led_init
    .global green_on
    .global red_on
    .global lights_on
    .global lights_off
    .global blink_four_times
    .global star_wars_led
    .global mario_led
    .global update_vars
    .global dtb_btd
    .global led_game_over
    .global led_game

    .extern P1OUT
    .extern P1DIR

    .extern buzz_seconds
    .extern buzz_second_count
    .extern buzz_changes
    .extern buzz_speed_main
    .extern buzz_speed_quarter
    .extern buzzer_set_period

    .extern random_int_generator
    .extern transition

led_init:
    bis #65, &P1DIR
    mov #lights_off, r0

green_on:
    push #go
    mov #lights_off, r0
go:
    bis #1, &P1OUT
    pop r0

red_on:
    push #ro
    mov #lights_off, r0
ro:
    bis #64, &P1OUT
    pop r0

lights_on:
    push #lon
    mov #lights_off, r0
lon:
    bis #65, &P1OUT
    pop r0

lights_off:
    and #~65, &P1OUT
    pop r0

blink_four_times:
    cmp.b #8, &led_second_count
    jnz bft_else
    mov #4, r12
    call #transition
bft_else:
    inc &led_seconds
    cmp #125, &led_seconds
    jnc end
    mov #0, &led_seconds
    inc.b &led_second_count
    mov #6, r6
    cmp.b &led_second_count, r6
    jc toggle_red
    push #end
    mov #green_on, r0
toggle_red:
    xor #64, &P1OUT
    jmp end
    

star_wars_led:
    cmp.b #26, &led_second_count
    jnz swl_else
    mov #0, r12
    call #transition
swl_else:
    inc &led_seconds
    cmp #60, &led_seconds
    jnc end
    mov #0, &led_seconds
    inc.b &led_second_count
    mov.b &led_second_count, r6
    sub.b #1, r6
    mov.b star_wars_lights(r6), r7
    cmp.b #0, r7
    jz lights_zero
    cmp.b #1, r7
    jz lights_one
    cmp.b #2, r7
    jz lights_two



mario_led:
    cmp.b #49, &led_second_count
    jnz ml_else
    mov #0, r12
    call #transition
ml_else:
    inc &led_seconds
    cmp #31, &led_seconds
    jnc end
    mov #0, &led_seconds
    inc.b &led_second_count
    mov.b &led_second_count, r6
    sub.b #1, r6
    mov.b mario_lights(r6), r7
    cmp.b #0, r7
    jz lights_zero
    cmp.b #1, r7
    jz lights_one
    cmp.b #2, r7
    jz lights_two


lights_zero:
    push #end
    mov #lights_off, r0
lights_one:
    push #end
    mov #green_on, r0
lights_two:
    push #end
    mov #red_on, r0



update_vars:
    push #reset_vars
    mov #lights_off, r0
reset_vars:
    mov.b #5, &green_blink_limit
    mov.b #1, &red_blink_limit
    mov.b #0, &green_blink_count
    mov.b #0, &red_blink_count
    
    mov #0, &led_seconds
    mov.b #0, &led_second_count
    mov.b #0, &led_changes
    mov #500, &led_speed

    mov.b #0, &button_flag
    
    mov.b #0, &easter_egg
    mov #0, &easter_egg_seconds
    
    mov.b #0, &interrupt_counter
    mov #0, &interrupt_seconds

    mov #0, &buzz_seconds
    mov.b #0, &buzz_second_count
    mov.b #0, &buzz_changes
    mov #500, &buzz_speed_main
    mov #125, &buzz_speed_quarter
    mov #0, r12
    push #end
    mov #buzzer_set_period, r0



dtb_btd:
    cmp.b #0, &interrupt_counter
    jz if_egg
    inc &interrupt_seconds
if_egg:
    cmp.b #0, &easter_egg
    jz if_egg_three
    inc &easter_egg_seconds
if_egg_three:
    cmp.b #3, &led_second_count
    jnz if_egg_two
    mov #1, r12
    call #transition
if_egg_two:
    cmp.b #2, &interrupt_counter
    jnz if_pregame
    mov #70, r6
    cmp &interrupt_seconds, r6
    jnc dtb_btd_else
    mov #2, r12
    call #transition
if_pregame:
    cmp.b #1, &interrupt_counter
    jnz dtb_btd_else
    mov #70, r6
    cmp &interrupt_seconds, r6
    jc dtb_btd_else
    mov #3, r12
    call #transition
dtb_btd_else:
    inc.b &green_blink_count
    cmp.b &green_blink_limit, &green_blink_count
    jnc green_if_two
    mov.b #0, &green_blink_count
    bis #1, &P1OUT
    jmp red_if_one
green_if_two:
    cmp.b &green_blink_limit, &green_blink_count
    jc red_if_one
    and #~1, &P1OUT
red_if_one:
    cmp.b &red_blink_limit, &red_blink_count
    jnc red_if_two
    mov.b #0, &red_blink_count
    bis #64, &P1OUT
    jmp dtb_btd_second_changer
red_if_two:
    cmp.b &red_blink_limit, &red_blink_count
    jc dtb_btd_second_changer
    and #~64, &P1OUT
dtb_btd_second_changer:
    inc.b &red_blink_count
    inc &led_seconds
    cmp #250, &easter_egg_seconds
    jnc dtb_btd_second_changer_two
    inc.b &led_second_count
    mov #0, &easter_egg_seconds
dtb_btd_second_changer_two:
    cmp #250, &led_seconds
    jnc end
    mov #0, &led_seconds
    inc.b &red_blink_limit
    sub.b #1, &green_blink_limit
    mov.b #0, r6
    cmp.b &green_blink_limit, r6
    jnc reset_red_if
    mov.b #5, &green_blink_limit
reset_red_if:
    mov.b #5, r6
    cmp.b &red_blink_limit, r6
    jc end
    mov.b #1, &red_blink_limit
    jmp end



led_game_over:
    cmp.b #4, &led_second_count  ; interrupt count - 4
    jnz continue_game            ; if total interrupt counts != 4, continue the game
    jmp reset_state              ; jump to reset state, ending the game
continue_game:
    inc &led_seconds             ; increment seconds var by 1
    cmp #90, &led_seconds        ; total function calls so far (seconds) - 90
    jl end                      ; while it has not reached 90/250 seconds, remain static
    xor #64, &P1OUT              ; toggle current red led output on/off
    mov #0, &led_seconds         ; set seconds to 0 once it has reached 90/250
    inc.b &led_second_count      ; increment total interrupt count by 1
    jmp end
reset_state:
    mov.b #0, &led_second_count  ; reset interrupt count to 0
    mov #0, &led_seconds         ; reset led_seconds var to 0
    mov #0, r12                  ; set 0 to register 12
    call #transition             ; calls transition(0), setting state to WAITING







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
    jmp end

end:
    ret
