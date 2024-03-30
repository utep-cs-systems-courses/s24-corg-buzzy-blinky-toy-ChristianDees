.arch msp430g2553
    .p2align 1,0                 ; set memory boundary of 2 bytes with padding of zeroes
    .text                        ; says this section of executible is where code is
    .global led_game_over        ; global name of function
    .extern P1OUT                ; led output var
    .extern led_seconds          ; seconds var
    .extern led_second_count     ; interrupt count var
    .extern transition           ; state transition function
led_game_over:
    cmp.b #4, &led_second_count  ; interrupt count - 4
    jnz continue_game            ; if total interrupt counts != 4, continue the game
    jmp reset_state              ; jump to reset state, ending the game
continue_game:
    inc &led_seconds             ; increment seconds var by 1
    cmp #90, &led_seconds        ; total function calls so far (seconds) - 90
    jl wait                      ; while it has not reached 90/250 seconds, remain static
    xor #64, &P1OUT              ; toggle current red led output on/off
    mov #0, &led_seconds         ; set seconds to 0 once it has reached 90/250
    inc.b &led_second_count      ; increment total interrupt count by 1
wait:
    ret                          ; do nothing
reset_state:
    mov.b #0, &led_second_count  ; reset interrupt count to 0
    mov #0, &led_seconds         ; reset led_seconds var to 0
    mov #0, r12                  ; set 0 to register 12
    call #transition             ; calls transition(0), setting state to WAITING
    
