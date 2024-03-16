.arch msp430g2553
    .p2align 1,0            ; set memory boundary of 2 bytes with padding of zeroes
    .text                   ; says this section of executible is where code is
    .global ledGameOver     ; global name of function
    .extern P1OUT           ; led output var
    .extern gameOverSeconds ; seconds var
    .extern gameOverCount   ; interrupt count var
    .extern transition      ; state transition function
ledGameOver:
    cmp #4, &gameOverCount ; interrupt count - 4
    jne continueGame               ; if total interrupt counts != 4, continue the game
    mov #0, &gameOverCount ; reset interrupt count to 0
    jmp resetState         ; jump to reset state, ending the game
continueGame:
    inc &gameOverSeconds   ; increment seconds var by 1
    cmp #90, &gameOverSeconds ; 90 - total function calls so far (seconds)
    jl wait                   ; while it has not reached 90/250 seconds, remain static
    xor #64, &P1OUT           ; toggle current red led output on/off
    mov #0, &gameOverSeconds  ; set seconds to 0 once it has reached 90/250
    inc &gameOverCount        ; increment total interrupt count by 1
wait:
    ret                       ; do nothing
resetState:
    mov #0, r12               ; set 0 to register 12
    call #transition          ; calls transition(0), setting state to WAITING
