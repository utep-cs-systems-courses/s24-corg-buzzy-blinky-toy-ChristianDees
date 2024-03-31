.arch msp430g2553
    .data
    .global buzz_second_count, buzz_changes, buzz_speed_quarter
    buzz_second_count:         .byte 0
    buzz_changes:              .byte 0
    buzz_toggler:              .byte 0

    .align 2
    .global buzz_seconds, buzz_speed_main
    buzz_seconds:       .word 0
    buzz_speed_main:    .word 500
    buzz_speed_quarter: .word 125
    mario_theme:
                        .word 6060
                        .word 0
                        .word 6060
                        .word 0
                        .word 0
                        .word 6060
                        .word 0
                        .word 0
                        .word 7640
                        .word 0
                        .word 6060
                        .word 0
                        .word 5100
                        .word 5100
                        .word 0
                        .word 0
                        .word 5100
                        .word 0
                        .word 0
                        .word 7640
                        .word 0
                        .word 0
                        .word 5100
                        .word 0
                        .word 0
                        .word 6060
                        .word 0
                        .word 0
                        .word 4540
                        .word 0
                        .word 4040
                        .word 0
                        .word 4040
                        .word 0
                        .word 4540
                        .word 0
                        .word 5100
                        .word 0
                        .word 6060
                        .word 0
                        .word 5100
                        .word 0
                        .word 4540
                        .word 0
                        .word 5720
                        .word 0
                        .word 5100
                        .word 0
                        .word 0

    .p2align 1,0
    .text
    .global buzzer_init
    .global buzzer_set_period
    .global mario_buzzer
    .global star_wars_buzzer
    .global buzz_four_times
    .global buzz_once
    .global buzz_game_over

    .extern timerAUpmode
    .extern P2SEL2
    .extern P2SEL
    .extern P2DIR
    .extern TA0CCR0
    .extern TA0CCR1

    .extern star_wars_lights
    
buzzer_init:
    push #buzzer_setup
    mov #timerAUpmode, r0
buzzer_setup:
    and #~192, &P2SEL2
    and #~128, &P2SEL
    bis #64, &P2SEL
    mov #64, &P2DIR
    pop r0

buzzer_set_period:
    mov r12, &TA0CCR0
    rra r12
    mov r12, &TA0CCR1
    pop r0

mario_buzzer:                            ; if led_second_count != 49
    inc &buzz_seconds                ; led_seconds++
    cmp #31, &buzz_seconds           ; led_seconds - 31
    jnc end                       ; if led_seconds < 31, goto end
    mov #0, &buzz_seconds            ; reset led_seconds to 0
    inc.b &buzz_second_count         ; led_second_count++
    mov.b &buzz_second_count, r6     ; index = led_second_count
    sub.b #1, r6                    ; index--
    add r6, r6
    mov mario_theme(r6), r12      ; mario_lights[index]
    push #end
    mov #buzzer_set_period, r0

star_wars_buzzer:
    inc &buzz_seconds                ; led_seconds++
    cmp #60, &buzz_seconds           ; led_seconds - 31
    jnc end                         ; if led_seconds < 31, goto end
    mov #0, &buzz_seconds            ; reset led_seconds to 0
    inc.b &buzz_second_count         ; led_second_count++
    mov.b &buzz_second_count, r6     ; index = led_second_count
    sub.b #1, r6                    ; index--
    mov.b star_wars_lights(r6), r7
    cmp.b #0, r7
    jz case_zero
    cmp.b #1, r7
    jz case_one
    cmp.b #2, r7
    jz case_two
    cmp.b #3, r7
    jz case_three
case_zero:
    mov #0, r12
    jmp play_note
case_one:
    mov #5500, r12
    jmp play_note
case_two:
    mov #6500, r12
    jmp play_note
case_three:
    mov #9500, r12
    jmp play_note
play_note:
    push #end
    mov #buzzer_set_period, r0

buzz_four_times:
    inc &buzz_seconds
    cmp #125, &buzz_seconds
    jnc end
    mov #0, &buzz_seconds
    inc.b &buzz_second_count
    xor.b #1, &buzz_toggler
    mov #4545, r12
    push #bzft_if_one
    mov #buzzer_set_period, r0
bzft_if_one:
    cmp.b #0, &buzz_toggler
    jnz bzft_if_two
    mov #0, r12
    push #bzft_if_two
    mov #buzzer_set_period, r0
bzft_if_two:
    cmp.b #7, &buzz_second_count
    jnz end
    mov #2000, r12
    push #end
    mov #buzzer_set_period, r0

buzz_once:
    inc &buzz_seconds
    cmp &buzz_speed_quarter, &buzz_seconds
    jnc end
    mov #0, r12
    push #second_if
    mov #buzzer_set_period, r0
second_if:
    cmp &buzz_speed_main, &buzz_seconds
    jnc end
    cmp.b #0, &buzz_second_count
    jz else
    cmp.b #16, &buzz_changes
    jc reset
    inc.b &buzz_changes
    jmp reset
reset:
    mov.b #0, &buzz_second_count
    jmp if_two
else:
    inc.b &buzz_second_count
    mov #0, &buzz_seconds
    mov #4545, r12
    push #if_two
    mov #buzzer_set_period, r0
if_two:
    mov.b #10, r6
    cmp.b &buzz_changes, r6
    jnc end
    mov.b &buzz_changes, r6
    and.b #1, r6
    cmp.b #0, r6
    jnz end
    cmp.b #0, &buzz_changes
    jz end
    mov &buzz_speed_main, r6
    rra r6
    rra r6
    rra r6
    sub r6, &buzz_speed_main
    mov &buzz_speed_main, r6
    rra r6
    rra r6
    mov r6, &buzz_speed_quarter
    jmp end

buzz_game_over:
   inc &buzz_seconds
    cmp #90, &buzz_seconds
    jnc end
    mov #0, &buzz_seconds
    inc.b &buzz_second_count
    xor.b #1, &buzz_toggler
    mov #8000, r12
    push #bgo_if
    mov #buzzer_set_period, r0
bgo_if:
    cmp.b #0, &buzz_toggler
    jnz bgo_if_two
    mov #0, r12
    push #bgo_if_two
    mov #buzzer_set_period, r0
bgo_if_two:
    cmp.b #3, &buzz_second_count
    jne end
    mov #15000, r12
    push #end
    mov #buzzer_set_period, r0

end:
    ret
