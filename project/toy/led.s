.arch msp430g2553
    .data
    green_blink_limit:  .byte 5 ; initially keep green dim
    red_blink_limit:    .byte 1 ; initially keep red bright
    green_blink_count:  .byte 0 ; total times green blinked
    red_blink_count:    .byte 0 ; total times red blinked
    led_second_count:   .byte 0 ; total seconds passed
    led_changes:        .byte 0 ; total led changes for speeding up
    .global random_led, button_flag
    random_led:         .byte 0 ; random led 1-4
    button_flag:        .byte 0 ; button pressed flag
    .global easter_egg, interrupt_counter, star_wars_lights
    easter_egg:         .byte 0 ; easter egg flag
    interrupt_counter:  .byte 0 ; side button timer
    mario_lights:               ; mario theme lights
                        .byte 2 ; red
                        .byte 0 ; off
                        .byte 2 ; red
                        .byte 0 ; off
                        .byte 0 ; off
                        .byte 2 ; red
                        .byte 0 ; off
                        .byte 0 ; off
                        .byte 1 ; green
                        .byte 0 ; off
                        .byte 2 ; red
                        .byte 0 ; off
                        .byte 1 ; green
                        .byte 1 ; green
                        .byte 0 ; off
                        .byte 0 ; off
                        .byte 1 ; green
                        .byte 0 ; off
                        .byte 0 ; off
                        .byte 2 ; red
                        .byte 0 ; off
                        .byte 0 ; off
                        .byte 1 ; green
                        .byte 0 ; off
                        .byte 0 ; off
                        .byte 2 ; red
                        .byte 0 ; off
                        .byte 0 ; off
                        .byte 1 ; green
                        .byte 0 ; off
                        .byte 1 ; green
                        .byte 0 ; off
                        .byte 1 ; green
                        .byte 0 ; off
                        .byte 2 ; red
                        .byte 0 ; off
                        .byte 1 ; green
                        .byte 0 ; off
                        .byte 2 ; red
                        .byte 0 ; off
                        .byte 1 ; green
                        .byte 0 ; off
                        .byte 2 ; red
                        .byte 0 ; off
                        .byte 1 ; green
                        .byte 0 ; off
                        .byte 1 ; green
                        .byte 0 ; off
                        .byte 0 ; off
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
                        .byte 3
                        .byte 3
                        .byte 0
                        .byte 1
                        .byte 0
                        .byte 2
                        .byte 2
                        .byte 0
                        .byte 3
                        .byte 3
                        .byte 0
                        .byte 1
                        .byte 0
                        .byte 2
                        .byte 2
                        .byte 2
                        .byte 2
    .align 2
    led_seconds:        .word 0     ; counts each interrupt occuring
    led_speed:          .word 500   ; easy level speed
    easter_egg_seconds: .word 0     ; easter egg one counter
    interrupt_seconds:  .word 0     ; easter egg two counter
    .p2align 1,0                 ; set memory boundary of 2 bytes with padding of zeroes
    .text                        ; executable code
    .global led_init             ; global functions
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
    .extern P1OUT                 ; global variables and functions required
    .extern P1DIR
    .extern buzz_seconds
    .extern buzz_second_count
    .extern buzz_changes
    .extern buzz_speed_main
    .extern buzz_speed_quarter
    .extern buzzer_set_period
    .extern random_int_generator
    .extern transition
    

led_init:                   ; initailize leds
    bis #65, &P1DIR         ; P1DIR |= LEDS
    mov #lights_off, r0     ; turn lights off

green_on:                   ; turn green led on
    push #go                ; push green on to stack
    mov #lights_off, r0     ; turn lights off
go:                         ; return after lights off
    bis #1, &P1OUT          ; set P1OUT to green led
    pop r0                  ; return once finished

red_on:                     ; turn red led on
    push #ro                ; push red on to stack
    mov #lights_off, r0     ; turn lights off
ro:                         ; return after lights off
    bis #64, &P1OUT         ; set P1OUT to red led
    pop r0                  ; return once finished

lights_on:                  ; turn both leds on
    push #lon               ; push lights on to stack
    mov #lights_off, r0     ; turn lights off
lon:                        ; return after lights off
    bis #65, &P1OUT         ; set P1OUT to red and green led
    pop r0                  ; return once finished

lights_off:                 ; turn both leds off
    and #~65, &P1OUT        ; clear P1OUT of bits red and green led
    pop r0                  ; return once finished

blink_four_times:                   ; blink red 3 times, green once
    cmp.b #8, &led_second_count     ; led_second_count - 8
    jnz bft_else                    ; if led_seconds != 8, goto bft_else
    mov #4, r12                     ; set parameter to 4 for duringgame state
    call #transition                ; transition to duringgame state
bft_else:                           ; if led_seconds != 8
    inc &led_seconds                ; led_seconds++
    cmp #125, &led_seconds          ; led_seconds - 125
    jnc end                         ; if led_seconds < 125, goto end
    mov #0, &led_seconds            ; reset led_seconds to 0
    inc.b &led_second_count         ; led_second_count++
    mov #6, r6                      ; temp var for 6
    cmp.b &led_second_count, r6     ; 6 - led_second_count
    jc toggle_red                   ; if led_second_count <= 6, goto toggle_red
    push #end                       ; end once finished
    mov #green_on, r0               ; turn green led on
toggle_red:                         ; if led_second_count <= 6
    xor #64, &P1OUT                 ; flip P1OUT red led on/off
    jmp end                         ; end once finsihed
    
star_wars_led:                      ; blink leds to match star wars theme song
    cmp.b #26, &led_second_count    ; led_second_count - 26
    jnz swl_else                    ; if led_second_count != 26, goto swl_else
    mov #0, r12                     ; set parameter to 0 for waiting state
    call #transition                ; transition to waiting state
swl_else:                           ; if led_second_count != 26
    inc &led_seconds                ; led_seconds++
    cmp #60, &led_seconds           ; led_seconds - 60
    jnc end                         ; if led_seconds < 60, goto end
    mov #0, &led_seconds            ; reset led_seconds to 0
    inc.b &led_second_count         ; led_second_count++
    mov.b &led_second_count, r6     ; index = led_second_count
    sub.b #1, r6                    ; index--
    mov.b star_wars_lights(r6), r7  ; star_wars_lights[index]
    cmp.b #0, r7                    ; star_wars_lights[index] - 0
    jz lights_zero                  ; if star_wars_lights[index] == 0, goto lights_zero
    cmp.b #1, r7                    ; star_wars_lights[index] - 1
    jz lights_one                   ; if star_wars_lights[index] == 1, goto lights_one
    cmp.b #2, r7                    ; star_wars_lights[index] - 2
    jz lights_two                   ; if star_wars_lights[index] == 2, goto lights_two
    cmp.b #3, r7
    jz lights_one

mario_led:                          ; blink leds to match mario theme song
    cmp.b #49, &led_second_count    ; led_second_count - 49
    jnz ml_else                     ; if led_second_count != 49, goto ml_else
    mov #0, r12                     ; set pararmeter to 0 for waiting state
    call #transition                ; transition to waiting state
ml_else:                            ; if led_second_count != 49
    inc &led_seconds                ; led_seconds++
    cmp #31, &led_seconds           ; led_seconds - 31
    jnc end                         ; if led_seconds < 31, goto end
    mov #0, &led_seconds            ; reset led_seconds to 0
    inc.b &led_second_count         ; led_second_count++
    mov.b &led_second_count, r6     ; index = led_second_count
    sub.b #1, r6                    ; index--
    mov.b mario_lights(r6), r7      ; mario_lights[index]
    cmp.b #0, r7                    ; mario_lights[index] - 0
    jz lights_zero                  ; if mario_lights[index] == 0, goto lights_zero
    cmp.b #1, r7                    ; mario_lights[index] - 1
    jz lights_one                   ; if mario_lights[index] == 1, goto lights_one
    cmp.b #2, r7                    ; mario_lights[index] - 2
    jz lights_two                   ; if mario_lights[index] == 2, goto lights_two

lights_zero:                        ; case for 1
    push #end                       ; end once lights are off
    mov #lights_off, r0             ; turn lights off
lights_one:                         ; case for 2
    push #end                       ; end once green led is on
    mov #green_on, r0               ; turn green led on
lights_two:                         ; case for 3
    push #end                       ; end once red led is on
    mov #red_on, r0                 ; turn red led on

update_vars:                        ; update all variables
    push #reset_vars                ; go to reset vars once lights are off
    mov #lights_off, r0             ; turn lights off
reset_vars:                         ; reset all variables
    mov.b #5, &green_blink_limit    ; green_blink_limit = 5
    mov.b #1, &red_blink_limit      ; red_blink_limit = 1
    mov.b #0, &green_blink_count    ; green_blink_count = 0
    mov.b #0, &red_blink_count      ; red_blink_count = 0
    mov #0, &led_seconds            ; led_seconds = 0
    mov.b #0, &led_second_count     ; led_second_count = 0
    mov.b #0, &led_changes          ; led_changes = 0
    mov #500, &led_speed            ; led_speed = 500
    mov.b #0, &button_flag          ; button_flag = 0
    mov.b #0, &easter_egg           ; easter_egg = 0
    mov #0, &easter_egg_seconds     ; easter_egg_seconds = 0
    mov.b #0, &interrupt_counter    ; interrupt_counter = 0
    mov #0, &interrupt_seconds      ; interrupt_seconds = 0
    mov #0, &buzz_seconds           ; buzz_seconds = 0
    mov.b #0, &buzz_second_count    ; buzz_second_Count = 0
    mov.b #0, &buzz_changes         ; buzz_changes = 0
    mov #500, &buzz_speed_main      ; buzz_speed_main = 500
    mov #125, &buzz_speed_quarter   ; buzz_speed_quarter = 125
    mov #0, r12                     ; set parameter to 0
    push #end                       ; goto end once buzzer is reset
    mov #buzzer_set_period, r0      ; buzzer_set_period(0)

dtb_btd:                            ; green starts dim, goes bright, opposite for red
    cmp.b #0, &interrupt_counter    ; interrupt_counter - 0
    jz if_egg                       ; if interrupt_counter == 0, goto if_egg
    inc &interrupt_seconds          ; interrupt_seconds++
if_egg:                             ; check for second easter egg
    cmp.b #0, &easter_egg           ; easter_egg - 0
    jz if_egg_three                 ; if easter_egg == 0, goto if_egg_three
    inc &easter_egg_seconds         ; easter_egg_seconds++
if_egg_three:                       ; check if button held down
    cmp.b #3, &led_second_count     ; led_second_count - 3
    jnz if_egg_two                  ; if led_second_count != 3, goto if_egg_two
    mov #1, r12                     ; set parameter to 1 for easteregg state
    call #transition                ; transition(easteregg)
if_egg_two:                         ; check if clicked twice
    cmp.b #2, &interrupt_counter    ; interrupt_counter - 2
    jnz if_pregame                  ; if interrupt_counter != 2, goto if_pregame
    mov #70, r6                     ; temp = 70
    cmp &interrupt_seconds, r6      ;  70 - interrupt_seconds
    jnc dtb_btd_else                ; if interrupt_seconds > 70, goto dtb_btd_else
    mov #2, r12                     ; set parameter to 2 for secondeasteregg state
    call #transition                ; transition(secondeasteregg)
if_pregame:                         ; if button only pressed once
    cmp.b #1, &interrupt_counter    ; interrupt_counter - 1
    jnz dtb_btd_else                ; if interrupt_counter != 1, goto dtb_btd_else
    mov #70, r6                     ; temp = 70
    cmp &interrupt_seconds, r6      ; 70 - interrupt_seconds
    jc dtb_btd_else                 ; if interrupt_seconds <= 70, goto dtb_btd_else
    mov #3, r12                     ; set parameter to 3 for pregame state
    call #transition                ; transition(pregame)
dtb_btd_else:                       ; change leds while in waiting state
    inc.b &green_blink_count        ; green_blink_count++
    cmp.b &green_blink_limit, &green_blink_count    ; green_blink_count - green_blink_limit
    jnc green_if_two                ; if green_blink_count < green_blink_limit, goto green_if_two
    mov.b #0, &green_blink_count    ; green_blink_count = 0
    bis #1, &P1OUT                  ; set P1OUT to green led
    jmp red_if_one                  ; goto change red once finished
green_if_two:                       ; check if ready to clear green
    cmp.b &green_blink_limit, &green_blink_count    ; green_blink_count - green_blink_limit
    jc red_if_one                   ; if green_blink_count >= green_blink_limit, goto red_if_one
    and #~1, &P1OUT                 ; clear P1OUT of led green
red_if_one:                         ; check if ready to set red
    cmp.b &red_blink_limit, &red_blink_count        ; red_blink_count - red_blink_limit
    jnc red_if_two                  ; if red_blink_count < red_blink_limit, goto red_if_two
    mov.b #0, &red_blink_count      ; red_blink_count = 0
    bis #64, &P1OUT                 ; set P1OUT to red led
    jmp dtb_btd_second_changer      ; goto second changer once finished
red_if_two:                         ; check if red is ready to be cleared
    cmp.b &red_blink_limit, &red_blink_count        ; red_blink_count - red_blink_limi
    jc dtb_btd_second_changer       ; if red_blink_count >= red_blink_limit, goto dtb_btd_second_changer
    and #~64, &P1OUT                ; clear P1OUT of red led
dtb_btd_second_changer:             ; second changer for once every second for easter egg
    inc.b &red_blink_count          ; red_blink_count++
    inc &led_seconds                ; led_seconds++
    cmp #250, &easter_egg_seconds   ; easter_egg_seconds - 250
    jnc dtb_btd_second_changer_two  ; if easter_egg_seconds < 250, goto dtb_btd_second_changer_two
    inc.b &led_second_count         ; led_second_count++
    mov #0, &easter_egg_seconds     ; easter_egg_seconds = 0
dtb_btd_second_changer_two:         ; second changer for once every second for led
    cmp #250, &led_seconds          ; led_seconds - 250
    jnc end                         ; if led_seconds < 250, goto end
    mov #0, &led_seconds            ; led_seconds = 0
    inc.b &red_blink_limit          ; red_blink_limit++
    sub.b #1, &green_blink_limit    ; green_blink_limit--
    mov.b #0, r6                    ; temp = 0
    cmp.b &green_blink_limit, r6    ; 0 - green_blink_limit
    jnc reset_red_if                ; if green_blink_limit > 0, goto reset_red_if
    mov.b #5, &green_blink_limit    ; green_blink_limit = 5
reset_red_if:                       ; check if red_blink_limit is ready to be reset
    mov.b #5, r6                    ; temp = 5
    cmp.b &red_blink_limit, r6      ; 5 - red_blink_limit
    jc end                          ; if red_blink_limit <= 5, goto end
    mov.b #1, &red_blink_limit      ; red_blink_limit = 1
    jmp end                         ; end once finished

led_game_over:                      ; blink red twice once game is over
    cmp.b #4, &led_second_count     ; led_second_count - 4
    jnz continue_game               ; if led_second_count != 4, goto continue_game
    jmp reset_state                 ; jump to reset state, ending the game
continue_game:
    inc &led_seconds                ; led_seconds++
    cmp #90, &led_seconds           ; led_seconds - 90
    jl end                          ; if led_seconds < 90, goto end
    xor #64, &P1OUT                 ; toggle P1OUT red led
    mov #0, &led_seconds            ; led_seconds = 0
    inc.b &led_second_count         ; led_second_count++
    jmp end                         ; end once finished
reset_state:                        ; reset vars used before transitioning
    mov.b #0, &led_second_count     ; led_second_count = 0
    mov #0, &led_seconds            ; led_seconds = 0
    mov #0, r12                     ; set parameter to 0 for waiting state
    call #transition                ; transition(0)

led_game:                                                   ;
    inc &led_seconds                ; led_seconds++
    cmp &led_speed, &led_seconds    ; led_seconds - led_speed
    jl end                          ; if led_seconds < led_speed, goto end
    cmp.b #0, &led_second_count     ; led_second_count - 0
    jz game_else                    ; if led_second_count == 0, goto game_else
    cmp.b #0, &button_flag          ; button_flag - 0
    jnz next_game_if                ; if button_flag == 0, goto next_game_if
    mov #5, r12                     ; set parameter to 5 for gameover state
    call #transition                ; transition(gameover)
next_game_if:                       ; check if led change can increase
    cmp.b #16, &led_changes         ; led_changes - 16
    jc reset_in_game_var            ; if led_changes >= 16, goto reset_in_game_var
    inc.b &led_changes              ; led_changes++
reset_in_game_var:                  ; reset in game vars
    mov.b #0, &button_flag          ; buton_flag = 0
    mov.b #0, &led_second_count     ; led_second_count = 0
    jmp speed_change                ; check if ready to increase speed
game_else:                          ; change leds
    inc.b &led_second_count         ; led_second_count++
    mov #0, &led_seconds            ; led_seconds = 0
    push #change_leds               ; push change_leds func to stack
    mov #random_int_generator, r0   ; get random integer
change_leds:                        ; change leds based on random int
    mov.b r12, &random_led          ; set return value to global var random_led
    cmp.b #1, r12                   ; random_led result - 1
    jz case_one                     ; if random_led = 1, goto case_one
    cmp.b #2, r12                   ; random_led result - 2
    jz case_two                     ; if random_led = 2, goto case_two
    cmp.b #3, r12                   ; random_led result - 3
    jz case_three                   ; if random_led = 3, goto case_three
    cmp.b #4, r12                   ; random_led result - 4
    jz case_four                    ; if random_led = 4, goto case_four
case_one:                           ; case 1
    call #green_on                  ; turn green on
    jmp speed_change                ; goto check if ready to increase speed
case_two:                           ; case 2
    call #red_on                    ; turn red on
    jmp speed_change                ; goto check if ready to increase speed
case_three:                         ; case 3
    call #lights_on                 ; turn lights on
    jmp speed_change                ; goto check if ready to increase speed
case_four:                          ; case 4
    call #lights_off                ; turn lights off
    jmp speed_change                ; goto check if ready to increase speed
speed_change:                       ; check if ready to increase speed
    mov.b #10, r6                   ; temp = 10
    cmp.b &led_changes, r6          ; 10 - led_changes
    jnc end                         ; if led_changes > 10, goto end
    mov.b &led_changes, r6          ; temp = led_changes
    and.b #1, r6                    ; led_changes & 1
    cmp.b #0, r6                    ; (led_changes & 1) - 0
    jnz end                         ; if (led_changes & 1) != 0, goto end
    cmp.b #0, &led_changes          ; led_changes - 0
    jz end                          ; if led_changes == 0, goto end
    mov &led_speed, r6              ; temp = led_speed
    rra r6                          ; led_speed / 2
    rra r6                          ; led_speed / 2
    rra r6                          ; led_speed / 2
    sub r6, &led_speed              ; led_speed -= (led_speed / 8)
    jmp end                         ; goto end once finished
        
end:                                ; go here once done
    ret                             ; do nothing, return
