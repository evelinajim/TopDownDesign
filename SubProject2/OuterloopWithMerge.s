// Done iterative mergesort


.data
.balign 4
   string:  .asciz "\n A[%d] = : %d"    @define data + format it. print array 
.balign 4
   string2: .asciz "\n k= %d,left=%d"   @this prints k and left by defining data format to do so
.balign 4
   A:       .skip 512 @128*4            @defines array A
.balign 4
.balign 4
   N:  .word 128                        @defines the number of elements, constant N (128 numbers)
.balign 4
   B:       .skip 512 @128*4            @defines array B

/* CODE SECTION */
.text
.balign 4
.global main
.extern printf
.extern rand

main:
    push    {ip,lr}     @ This is needed to return to the Operating System

    @@@  This block of code is using R4,R5,  R0,R1,R2,R3 are used for the call to random elements
    mov r5,#0           @ Initialize 128 elements in the array. Move 0 to register 5; int r = 0;
    ldr r4,=A           @ Loads r4 with array A
loop1:
    ldr r0,=N           @ this address stores the constant N. Load r0 with N
    ldr r0,[r0]         @ loads r0 with N, the actual value of N is now defined in data section
    cmp r5, r0          @ compare the values in r5 with r0, like i < n
    bge end1            @ if r5 >= r0 then goto end1 to end the loop until the loop has reached N iterations.

    bl      rand        @ else continue the loop. call rand to add random numbers
    and r0,r0,#255      @ To produce a number between 0 to 255, AND the result with 255 
    str r0, [r4], #4    @ Store contents r0 at array A

    add r5, r5, #1      @ add 1 to r5, like: i++
    b loop1                  /* Go to the beginning of the loop */
end1:

@@@@@@@@@@@@@@@@@@ PRINT OUT THE ARRAY @@@@@@@@@@@@@@@@@@
/* specifically prints all the elements in an array of size N */
    mov r5,#0           @ Int i = 0; once again r5 
    ldr r4,=A           @ load r4 with array A
loop2:
    ldr r0,=N           @ this address holds the value of the con. N load r0 with N
    ldr r0,[r0]         @ loads r0 with N, the actual value of N defined in data section
    cmp r5, r0          @ compare. i<n: Has the loop reached N iterations?
    beq end2            @ if yes, goto end2 to end the loop.
    ldr r0,=string      @ else load r0 with &string. (string contains the format of output)
    mov r1,r5           @ r1 = r5
    ldr r2,[r4],#4      @ r4 = &A+4: loads r2 with array A then points to the next element 
    bl printf           @ r0, r1, and r2 are printed to the console according to specified format in the string
    add r5, r5, #1      @ i++: in r5

    b loop2                  /* Go to the beginning of the loop */
end2:
/* Star of the execution of the iterative mergesort */
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@ OUTER LOOP @@@@@@@@@@@@@@@@@@@@@@@@@@

/* This section requests labels for r0-r2 */
@ num,r0
@ k, r1
@ left, r2
        left .req r2
        k    .req r1
        num .req r0
@    for (int k=1; k < num; k *= 2 ) {

        mov k,#1

OLoop1: ldr r0,=N       @ put &N into r0
        ldr num,[r0]    @ (* (&N)) into r0 since r0 is num
        cmp k,num
        bge OLoop1e

@        for (int left=0; left+k < num; left += k*2 ) {
        mov left,#0
OLoop2: add r3,left,k   @ left+k < num;
        ldr r0,=N       @ put N into r0 since r0 is num
        ldr num,[r0]    @ load num with N
        cmp r3,num      
        bge OLoop2e     @ ends loop here if false

@@@@@@@@ print out the variables of the loop, k and left to verify the operation
@@@@@@@@ save the registers that printf tweak, bl
@@@@@@@@ stack
        push {r0,r1,r2,r3}      @saves registers into the stack to save their current state
        ldr r0,=string2         @loads string2 into r0 (format of the output)
        bl  printf              @ print values to  console
        pop {r0,r1,r2,r3}       @ restores prior state of register
        
        @@@@@@@@@@@@@@@@@@@@@@@@INNER LOOPS@@@@@@@@@@@@@@@@@@@@@@@@@@
        @ for while loops and the for loop of the iterative MergeSort are defined
        
            @rght = left + k;
            @ rght set at line 81

            
            @requests labels for r3-r4
            rend .req r4
            rght .req r3

            @rend = rght + k;
            add rend,rght,k

            @if (rend > num) rend = num;

            @ rend = (rend>num)?num:rend;
            cmp rend,num        @compare, rend < num
            movgt rend,num

            @requests label for r5-r7
            @m = left; i = left; j = rght; 
            m .req r5
            i .req r6
            j .req r7

            mov m,left
            mov i,left
            mov j,rght

            @while (i < rght && j < rend) {
 while1:    cmp i,rght          @ while (i<rght &&
            bge endWhile1       @ end loop if above is false
            cmp j,rend          @ j < rend)
            bge endWhile1       @ end loop if above is false too
            @    if (a[i] <= a[j]) {
            ldr  r8,=A           @ load r8 with A 

            add  r9,r8,i,lsl #2 @ because i*4 is the integer we want r9 <- &A + 4*i
            ldr  r9,[r9]
            @ ldr  r9,[r8,i,lsl #2]  This used instead to load the value into r9
            add  r10,r8,j,lsl #2
            ldr  r10,[r10]   @ a[j] value goes into r10

            cmp  r9,r10
            @  r9 = (a[i] <= a[j]) r9:r10;
            @more efficient     
            @  b[m] = r9
            @  remember, r9 has a[i], r10 has a[j]
            movgt  r9,r10  @ the else part; r9 is A[i] or A[j]
            addgt  j,j,#1  @ the update in the "else" part; if r9 is A[j], j++
            addle  i,i,#1  @ the update in the "then" part; if r9 is A[i], i++
            ldr    r11,=B
            add    r11,r11,m,lsl #2
            str    r9,[r11]
            add    m,m,#1
            @  b[m] = a[i]; i++;
            @    } else {
            @  b[m] = a[j]; j++;
            @    }
            @    m++;
            @}
            b  while1
    endWhile1:
     @while (i < rght) {
    while2: cmp  i,rght
            bge  while2end
            @    b[m]=a[i];
            ldr  r8,=A
            ldr  r9,[r8,i,lsl #2]
            ldr  r8,=B
            str  r9,[r8,m,lsl #2]
            @    i++; m++;
            add  i,i,#1
            add  m,m,#1
            @}
            b  while2
    while2end:
    @while (j < rend) {
    while3: cmp j,rend
            bge while3end
            @    b[m]=a[j];
            ldr  r8,=A
            ldr  r9,[r8,j,lsl #2]
            ldr  r8,=B
            str  r9,[r8,m,lsl #2]
            @    j++; m++;
            add  j,j,#1
            add  m,m,#1
            @}
            b while3
    while3end:
            mov m,left
    form:   cmp m,rend
            bge formend


            @for (m=left; m < rend; m++) {
            @    a[m] = b[m];
            ldr  r8,=B              @loads B into r8
            ldr  r9,[r8,m,lsl #2]
            ldr  r8,=A              @loads A into r8
            str  r9,[r8,m,lsl #2]
            add m,m,#1              @m++
            @}
            b form
    formend:
        @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
        @ left .req r3
        lsl r3,r1,#1   @ left += k*2
        add r2,r2,r3
        b OLoop2       @returns to Oloop2 
OLoop2e:
        lsl r1,r1,#1
        push {r0,r1,r2,r3}
        ldr r0,=string2
        bl  printf
        pop {r0,r1,r2,r3}
        mov     r0,#0
        b OLoop1        @ returns to Oloop1

@@@@PRINT LOOP 2
loop3:
    ldr r0,=N
    ldr r0,[r0]
    cmp r5, r0
        beq endFunc

    ldr r0,=string
    mov r1,r5
    ldr r2,[r4],#4

    bl printf

    add r5, r5, #1

    b loop3




OLoop1e:
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
    mov r5,#0
    ldr r4,=A
    b loop3

endFunc:
    mov r5,#0           @ Print out the array!!
    ldr r4,=A


    mov     r0,#0

    pop     {ip, pc}    @ This is the return to the operating system








