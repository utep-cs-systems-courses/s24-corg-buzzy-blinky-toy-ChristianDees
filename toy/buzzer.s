.arch msp430g2553
    .data
    .global buzz_second_count, buzz_changes, buzz_speed_quarter
    buzz_second_count:  .byte 0
    buzz_changes:       .byte 0
    buzz_toggler:       .byte 0
    .align 2
    .global buzz_seconds, buzz_speed_main
    buzz_seconds:       .word 0
    buzz_speed_main:    .word 500
    buzz_speed_quarter: .word 125
    mario_theme:        .word 6060
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
    .global buzzer_init         ; global functions
    .global buzzer_set_period
    .global mario_buzzer
    .global star_wars_buzzer
    .global buzz_four_times
    .global buzz_once
    .global buzz_game_over
    .extern timerAUpmode        ; global functions and vars required
    .extern P2SEL2
    .extern P2SEL
    .extern P2DIR
    .extern TA0CCR0
    .extern TA0CCR1
    .extern star_wars_lights

buzzer_init:                ; intialize buzzer
    push #buzzer_setup      ; goto buzzer setup
    mov #timerAUpmode, r0   ; call itmerAUpmode()
buzzer_setup:               ; set buzzer bits required
    and #~192, &P2SEL2      ; clear P2SEL2.6 and 7 for pin config
    and #~128, &P2SEL       ; clear P2SEL.7 for config
    bis #64, &P2SEL         ; set P2SEL.6 for timer A output
    mov #64, &P2DIR         ; set P2.6 direction as output for driving buzzer
    pop r0                  ; return once finished

buzzer_set_period:          ; set period (clock is 2MHz)
    mov r12, &TA0CCR0       ; set period of PWM to cycles param
    rra r12                 ; shift cycles
    mov r12, &TA0CCR1       ; sign is on same time it is off
    pop r0                  ; return once finished

mario_buzzer:                   ; play mario theme
    inc &buzz_seconds           ; buzz_seconds++
    cmp #31, &buzz_seconds      ; buzz_seconds - 31
    jnc end                     ; if buzz_seconds < 31, goto end
    mov #0, &buzz_seconds       ; buzz_seconds = 0
    inc.b &buzz_second_count    ; buzz_second_count++
    mov.b &buzz_second_count, r6; temp = buzz_second_count
    sub.b #1, r6                ; temp--
    add r6, r6                  ; 2t
    mov mario_theme(r6), r12    ; mario_theme[temp]
    push #end                   ; goto end once finished
    mov #buzzer_set_period, r0  ; set buzzer period to 0

star_wars_buzzer:               ; plau star wars theme
    inc &buzz_seconds           ; buzz_seconds++
    cmp #60, &buzz_seconds      ; buzz_seconds - 60
    jnc end                     ; if buzz_seconds < 60, goto end
    mov #0, &buzz_seconds       ; buzz_seconds = 0
    inc.b &buzz_second_count    ; buzz_second_count++
    mov.b &buzz_second_count, r6; temp = buzz_second_count
    sub.b #1, r6                ; temp--
    mov.b star_wars_lights(r6), r7; t2 = star_wars_lights[temp]
    cmp.b #0, r7                ; t2 - 0
    jz case_zero                ; if t2 == 0, goto case_zero
    cmp.b #1, r7                ; t2 - 1
    jz case_one                 ; if t2 == 1, goto case_one
    cmp.b #2, r7                ; t2 - 2
    jz case_two                 ; if t2 == 2, goto case_two
    cmp.b #3, r7                ; t2 - 3
    jz case_three               ; if t2 == 3, goto case_three
case_zero:                      ; if t2 == 0
    mov #0, r12                 ; set parameter to 0
    jmp play_note               ; goto play_note
case_one:                       ; if t2 == 1
    mov #5500, r12              ; set parameter to 5500
    jmp play_note               ; goto play_note
case_two:                       ; if t2 == 2
    mov #6500, r12              ; set parameter to 6500
    jmp play_note               ; goto play_note
case_three:                     ; if t2 == 3
    mov #9500, r12              ; set parameter to 9500
    jmp play_note               ; goto play_note
play_note:                      ; set buzzer period to parameter
    push #end                   ; return once finished
    mov #buzzer_set_period, r0  ; buzzer_set_period(current_note)

buzz_four_times:                ; 3 buzzes, 1 high buzz
    inc &buzz_seconds           ; buzz_seconds++
    cmp #125, &buzz_seconds     ; buzz_seconds - 125
    jnc end                     ; if buzz_seconds < 125
    mov #0, &buzz_seconds       ; buzz_seconds = 0
    inc.b &buzz_second_count    ; buzz_second_count++
    xor.b #1, &buzz_toggler     ; turn on/off buzzer
    mov #4545, r12              ; set parameter to 4545
    push #bzft_if_one           ; check if buzzer shouold be on
    mov #buzzer_set_period, r0  ; buzzer_set_period(4545)
bzft_if_one:                    ; if buzzer should be off, set frequency 0
    cmp.b #0, &buzz_toggler     ; buzz_toggler - 0
    jnz bzft_if_two             ; if buzz_toggler != 0, goto bzft_if_two
    mov #0, r12                 ; set parameter to 0
    push #bzft_if_two           ; goto bzft_if_two after finished
    mov #buzzer_set_period, r0  ; buzzer_set_period(0)
bzft_if_two:                    ; on fourth buzz, buzz higher pitch
    cmp.b #7, &buzz_second_count; buzz_second_count - 7
    jnz end                     ; if buzz_second_count != 7, goto end
    mov #2000, r12              ; set parameter to 2000
    push #end                   ; goto end once finished
    mov #buzzer_set_period, r0  ; buzzer_set_period(2000)

buzz_once:                      ; buzz once during game every led change
    inc &buzz_seconds           ; buzz_seconds++
    cmp &buzz_speed_quarter, &buzz_seconds  ; buzz_seconds - buzz_speed_quarter
    jnc end                     ; if buzz_seconds < buzz_speed_quarter, goto end
    mov #0, r12                 ; set parameter to 0
    push #second_if             ; goto second_if once finsihed
    mov #buzzer_set_period, r0  ; buzzer_set_period(0)
second_if:                      ; check if buzzer on after set speed
    cmp &buzz_speed_main, &buzz_seconds ; buzz_seconds - buzz_speed_main
    jnc end                     ; if buzz_speed_main < buzz_seconds, goto end
    cmp.b #0, &buzz_second_count; buzz_second_count - 0
    jz else                     ; if buzz_second_count != 1
    cmp.b #16, &buzz_changes    ; buzz_changes - 16
    jc reset                    ; if buzz_changes >= 16
    inc.b &buzz_changes         ; buzz_changes++
    jmp reset                   ; goto reset
reset:                          ; reset vars
    mov.b #0, &buzz_second_count; buzz_second_count = 0
    jmp if_two                  ; goto if_two
else:                           ; if buzz_second_count != 1
    inc.b &buzz_second_count    ; buzz_second_count++
    mov #0, &buzz_seconds       ; buzz_seconds = 0
    mov #4545, r12              ; set parameter to 4545
    push #if_two                ; goto if_two once finished
    mov #buzzer_set_period, r0  ; buzzer_set_period(4545)
if_two:                         ; speed change
    mov.b #10, r6               ; temp = 10
    cmp.b &buzz_changes, r6     ; 10 - buzz_changes
    jnc end                     ; if buzz_changes > 10
    mov.b &buzz_changes, r6     ; temp = buzz_changes
    and.b #1, r6                ; temp = buzz_changes & 1
    cmp.b #0, r6                ; temp - 0
    jnz end                     ; if (buzz_changes & 1) != 0, goto end
    cmp.b #0, &buzz_changes     ; buzz_changes - 0
    jz end                      ; if buzz_changes == 0, goto end
    mov &buzz_speed_main, r6    ; temp = buzz_speed_main
    rra r6                      ; temp / 2
    rra r6                      ; temp / 2
    rra r6                      ; temp / 2
    sub r6, &buzz_speed_main    ; temp -= buzz_speed_main/8
    mov &buzz_speed_main, r6    ; buzz_speed_main = temp
    rra r6                      ; temp / 2
    rra r6                      ; temp /2
    mov r6, &buzz_speed_quarter ; buzz_speed_quarter = buzz_speed_main/2
    jmp end                     ; goto end

buzz_game_over:                 ; buzz 2 times when game ends
   inc &buzz_seconds            ; buzz_seconds++
    cmp #90, &buzz_seconds      ; buzz_seconds - 90
    jnc end                     ; if buzz_seconds < 90
    mov #0, &buzz_seconds       ; buzz_seconds = 0
    inc.b &buzz_second_count    ; buzz_second_count++
    xor.b #1, &buzz_toggler     ; buzz_toggler ^= 1
    mov #8000, r12              ; set parameter to 8000
    push #bgo_if                ; goto bgo_if once finished
    mov #buzzer_set_period, r0  ; buzzer_set_period(8000)
bgo_if:                         ; if buzzer is not on, set frequency to 0
    cmp.b #0, &buzz_toggler     ; buzz_toggler - 0
    jnz bgo_if_two              ; if buzz_toggler != 0, goto bgo_if_two
    mov #0, r12                 ; set parameter to 0
    push #bgo_if_two            ; goto bgo_if_two once finished
    mov #buzzer_set_period, r0  ; buzzer_set_period(0)
bgo_if_two:                     ; on second buzz, make lower pitch
    cmp.b #3, &buzz_second_count; buzz_second_count - 3
    jne end                     ; if buzz_second_count != 3, goto end
    mov #15000, r12             ; set parameter to 15000
    push #end                   ; goto end once finished
    mov #buzzer_set_period, r0  ; buzzer_set_period(0)
    
end:
    ret
