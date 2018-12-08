.data
.balign 4
   string:  .asciz "\n A[%d] = : %d"
.balign 4
   A:       .skip 512  @ 128*4
.balign 4
   N:  .word 128

/* CODE SECTION */
.text
.balign 4
.global main
.extern printf
.extern rand

main:
    push    {ip,lr}     @ This is needed to return to the Operating System

    @@@  This bloc of code uses R4,R5,  R0,R1,R2,R3 are used for the call to random
    mov r5,#0           @ Initialize 128 elements in the array
    ldr r4,=A           @ when taken out the array will either be empty or not created in a way that it can be used 
loop1:
    ldr r0,=N           @ when taken out N will not be initialized and thus it will end up being infinite loop or never start to begin with 
    ldr r0,[r0]
    cmp r5, r0
    bge end1            @when taken out there will be endless loop. 
    bl      rand        @when taken out the numbers are no longer random; same number
    and r0,r0,#255      @when taken out the  numbers are 0
    str r0, [r4], #4
    add r5, r5, #1
    b loop1                  /* Go to the beginning of the loop */
end1:

    mov r5,#0           @ Print out the array
    ldr r4,=A
loop2:
    ldr r0,=N
    ldr r0,[r0]
    cmp r5, r0
    beq end2               @when taken out = infinite loop 
    push {r0,r1,r2,r3,r4}  @ we can save and restore the registers on the stack!!
    ldr r0,=string
    mov r1,r5
    ldr r2,[r4],#4
    bl printf
    pop {r0,r1,r2,r3,r4}   @ when taken out wouldnt print out properly or at all
    add r5, r5, #1

    b loop2                  /* Go to the beginning of the loop */ @when taken out it would stop abruptly, send error
end2:


    mov     r0,#0

    pop     {ip, pc}    @ This is the return to the operating system

