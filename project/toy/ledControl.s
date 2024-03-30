.arch msp430g2553
    .p2align 1,0                 ; set memory boundary of 2 bytes with padding of zeroes
    .text                        ; says this section of executible is where code is
    .global led_init
    .global green_on          ; global name of function
    .global red_on
    .global lights_on
    .global lights_off
    .global blink_four_times
    .global star_wars_led
    .global mario_led
    .global update_vars
    .global dtb_btd
    .extern P1OUT                ; led output var
    .extern P1DIR
    .extern star_wars_lights
    .extern mario_lights

    .extern green_blink_limit
    .extern red_blink_limit
    .extern green_blink_count
    .extern red_blink_count

    .extern led_seconds
    .extern led_second_count
    .extern led_changes
    .extern led_speed

    .extern buzz_seconds
    .extern buzz_second_count
    .extern buzz_changes
    .extern buzz_speed_main
    .extern buzz_speed_quarter
    .extern buzzer_set_period

    .extern button_flag

    .extern easter_egg
    .extern easter_egg_seconds

    .extern interrupt_counter
    .extern interrupt_seconds
    

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



end:
    ret
