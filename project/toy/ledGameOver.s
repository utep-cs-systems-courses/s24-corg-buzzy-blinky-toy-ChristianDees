.arch msp430g2553
    .p2align 1,0               ; set memory boundary of 2 bytes with padding of zeroes
    .text                      ; says this section of executible is where code is
    .global ledGameOver        ; global name of function
    .extern P1OUT              ; led output var
    .extern ledSeconds         ; seconds var
    .extern ledSecondCount     ; interrupt count var
    .extern transition         ; state transition function
ledGameOver:
    cmp.b #4, &ledSecondCount  ; interrupt count - 4
    jnz continueGame           ; if total interrupt counts != 4, continue the game
    jmp resetState             ; jump to reset state, ending the game
continueGame:
    inc &ledSeconds            ; increment seconds var by 1
    cmp #90, &ledSeconds       ; total function calls so far (seconds) - 90
    jl wait                    ; while it has not reached 90/250 seconds, remain static
    xor #64, &P1OUT            ; toggle current red led output on/off
    mov #0, &ledSeconds        ; set seconds to 0 once it has reached 90/250
    add.b #1, &ledSecondCount  ; increment total interrupt count by 1
wait:
    ret                        ; do nothing
resetState:
    mov.b #0, &ledSecondCount  ; reset interrupt count to 0
    mov #0, &ledSeconds        ; reset ledSeconds var to 0
    mov #0, r12                ; set 0 to register 12
    call #transition           ; calls transition(0), setting state to WAITING
