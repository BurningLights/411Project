@ Code adapted from CORDIC implementation by Maximell and pcatkins at
@ https://github.com/Maximell/Cordic/blob/master/cordic_implementations/cordic_assembly.s
	.arch armv4t
	.fpu softvfp
	.eabi_attribute 20, 1
	.eabi_attribute 21, 1
	.eabi_attribute 23, 3
	.eabi_attribute 24, 1
	.eabi_attribute 25, 1
	.eabi_attribute 26, 2
	.eabi_attribute 30, 6
	.eabi_attribute 18, 4
	.file	"cordic_assembly.c"
	.section	.rodata
	.align	2
	.type	local_elem_angle.1122, %object
	.size	local_elem_angle.1122, 56
local_elem_angle.1122:
	@ Values atanh(1/2^i) for i = 1 to 14 in fixed point format (int)x>>16
	.word	35999 @2949120
	.word	16738 @1740967
	.word	8235 @919789
	.word	4101 @466945
	.word	2048 @234379
	.word	1024 @117304
	.word	512 @58666
	.word	256 @29335
	.word	128 @14668
	.word	64 @7334
	.word	32 @3667
	.word	16 @1833
	.word	8 @917
	.word	4 @458
	.text
	.align	2
	.global	cordic_assembly
	.type	cordic_assembly, %function
cordic_assembly:
	@ All numbers used for x, y, and z in this program are 32-bit fixed-point numbers,
	@ with 16 bits before and 16 bits after the decimal point.
	@ Function supports interworking.
	@ args = 0, pretend = 0, frame = 40
	@ frame_needed = 1, uses_anonymous_args = 0
	@ link register save eliminated.
	@ Save the frame pointer on the stack and decrement the stack pointer
	str	fp, [sp, #-4]!
	@ Save the current stack pointer as the new frame pointer
	add	fp, sp, #0
	@ Make 44 bytes of local storage space on the stack
	sub	sp, sp, #44
	@ Save registers r0 through r3 at the very top of the stack
	@ fp - 32 contains a pointer to the initial x value
	@ fp - 36 contains a pointer to the initial y value
	@ fp - 40 contains a pointer to the angle value to calculate cosh, sinh, and exp for
	@ fp - 44 contains a pointer to the CORDIC mode (rotation or vector)
	str	r0, [fp, #-32]
	str	r1, [fp, #-36]
	str	r2, [fp, #-40]
	str	r3, [fp, #-44]
	@ Load the starting x value into r3 from the pointer
	ldr	r3, [fp, #-32]
	ldr	r3, [r3, #0]
	@ fp - 12 stores the current x value
	str	r3, [fp, #-12]
	@ Load the starting y value into r3 from the pointer
	ldr	r3, [fp, #-36]
	ldr	r3, [r3, #0]
	@ fp - 24 stores the current y value
	str	r3, [fp, #-24]
	@ Load the starting angle value into r3 from the pointer
	ldr	r3, [fp, #-40]
	ldr	r3, [r3, #0]
	@ fp - 28 contains the current angle value
	str	r3, [fp, #-28]
	@ Load the CORDIC mode into r3
	ldr	r3, [fp, #-44]
	@ A value of 0 means rotational CORDIC mode
	@ In vectoring mode skip down to .L2
	@ For rotational mode, do the below code and then go on to .L3
	cmp	r3, #0
	bne	.L2
	@ For rotational mode, make a pointer to the angle value,
	@ since rotational mode is based on the target angle
	sub	r3, fp, #28
	str	r3, [fp, #-20]
	b	.L3
.L2:
	@ For vectoring mode, make a pointer to the y value,
	@ since vectoring mode is based on the target y value
	sub	r3, fp, #24
	str	r3, [fp, #-20]
	@ fp - 20 contains a pointer to the target value
.L3:
	@ Load the current x value into r3 and shift it left by 16 to convert it
	@ to fixed point value. Then, store it back into fp - 12
	ldr	r3, [fp, #-12]
	mov	r3, r3, asl #16
	str	r3, [fp, #-12]
	@ Load the current y value into r3 and shift it left by 16 to convert it
	@ to fixed point value. Then, store it back into fp - 24	
	ldr	r3, [fp, #-24]
	mov	r3, r3, asl #16
	str	r3, [fp, #-24]
	@ Load the current angle value into r3 and shift it left by 16 to convert it
	@ to fixed point value. Then, store it back into fp - 28
	ldr	r3, [fp, #-28]
	mov	r3, r3, asl #16
	str	r3, [fp, #-28]
	@ Move 0 into r3, to be the starting value of the loop counter
	@ fp - 8 containst the current loop counter
	mov	r3, #0
	str	r3, [fp, #-8]
	@ Go directly to .L4 to start the for loop
	b	.L4
.L9:
	ldr	r3, [fp, #-12]
	str	r3, [fp, #-16]
	ldr	r3, [fp, #-20]
	ldr	r3, [r3, #0]
	cmp	r3, #0
	bge	.L5
	ldr	r3, [fp, #-44]
	cmp	r3, #0
	beq	.L6
.L5:
	ldr	r3, [fp, #-20]
	ldr	r3, [r3, #0]
	cmp	r3, #0
	blt	.L7
	ldr	r3, [fp, #-44]
	cmp	r3, #0
	beq	.L7
.L6:
	ldr	r2, [fp, #-24]
	ldr	r3, [fp, #-8]
	mov	r2, r2, asr r3
	ldr	r3, [fp, #-12]
	add	r3, r3, r2
	str	r3, [fp, #-12]
	ldr	r1, [fp, #-24]
	ldr	r2, [fp, #-16]
	ldr	r3, [fp, #-8]
	mov	r3, r2, asr r3
	rsb	r3, r3, r1
	str	r3, [fp, #-24]
	ldr	r2, [fp, #-8]
	ldr	r3, .L11
	ldr	r2, [r3, r2, asl #2]
	ldr	r3, [fp, #-28]
	add	r3, r2, r3
	str	r3, [fp, #-28]
	b	.L8
.L7:
	ldr	r2, [fp, #-24]
	ldr	r3, [fp, #-8]
	mov	r2, r2, asr r3
	ldr	r3, [fp, #-12]
	rsb	r3, r2, r3
	str	r3, [fp, #-12]
	ldr	r2, [fp, #-16]
	ldr	r3, [fp, #-8]
	mov	r2, r2, asr r3
	ldr	r3, [fp, #-24]
	add	r3, r2, r3
	str	r3, [fp, #-24]
	ldr	r1, [fp, #-28]
	ldr	r2, [fp, #-8]
	ldr	r3, .L11
	ldr	r3, [r3, r2, asl #2]
	rsb	r3, r3, r1
	str	r3, [fp, #-28]
.L8:
	ldr	r3, [fp, #-8]
	add	r3, r3, #1
	str	r3, [fp, #-8]
.L4:
	@ Retrieve the current loop counter from fp - 8. There will be 14 iterations of the loop,
	@ so go to .L9, the loop body, if it is less than or equal to 13
	ldr	r3, [fp, #-8]
	cmp	r3, #13
	ble	.L9
	@ Done with the number of iterations, so continue to wrap-up
	ldr	r2, [fp, #-32]
	ldr	r3, [fp, #-12]
	str	r3, [r2, #0]
	ldr	r2, [fp, #-24]
	ldr	r3, [fp, #-36]
	str	r2, [r3, #0]
	ldr	r2, [fp, #-28]
	ldr	r3, [fp, #-40]
	str	r2, [r3, #0]
	add	sp, fp, #0
	ldmfd	sp!, {fp}
	bx	lr
.L12:
	.align	2
.L11:
	.word	local_elem_angle.1122
	.size	cordic_assembly, .-cordic_assembly
	.ident	"GCC: (Sourcery G++ Lite 2008q3-72) 4.3.2"
	.section	.note.GNU-stack,"",%progbits