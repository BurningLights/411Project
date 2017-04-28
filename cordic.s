@ Code adapted from CORDIC implementation by Maximell and pcatkins at
@ https://github.com/Maximell/Cordic/blob/master/cordic_implementations/cordic_assembly.s
	.section .data
XVal:
	.word 1
YVal:
	.word 0
angle:
	.word 0
exponential:
	.word 0

	.section	.rodata
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
main:
	@ Put the pointer to x in r0, the pointer to y in r1, the pointer to
	@ the angle in r3, and the value 0 for rotational CORDIC in r4
	ldr r0, XVal
	ldr r1, YVal
	ldr r2, angle
	mov r3, #0
	@ Call the cordic_assembly Function
	@ The resulting x value is cosh(angle) and the y value is sinh(angle)
	bl cordic_assembly
	@ Load the cosh and sinh values into r0 and r1 to compute exp(angle)
	ldr r0, XVal
	ldr r0, [r0]
	ldr r1, YVal
	ldr r1, [r1]
	@ Compute exp(angle) and store it in exponential
	add r0, r0, r1
	ldr r1, exponential
	str r0, [r1]
	@ Exit
	b .L12
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
	@ fp - 20 contains a pointer to the target value, which is the value
	@ that controls the direction of rotation
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
	@ Load the current x value into r3, and store it in a temporary location at
	@ fp - 16, so the old value can be accessed later
	ldr	r3, [fp, #-12]
	str	r3, [fp, #-16]
	@ Load the target value into r3 using the pointer in fp - 20
	ldr	r3, [fp, #-20]
	ldr	r3, [r3, #0]
	@ If the target value is >= 0, then go to L5 to determine which direction
	@ the next rotation should be
	cmp	r3, #0
	bge	.L5
	@ The target is less than 0, so load the CORDIC mode into r3 to determine which way to rotate
	ldr	r3, [fp, #-44]
	@ If the mode is 0, which is rotational mode, go to .L6 to do addition
	cmp	r3, #0
	beq	.L6
	@ The mode is 1, which is vectoring mode, so fall into .L5 to determine which way to rotate
.L5:
	@ Load the target value into r3 using the pointer in fp - 20
	ldr	r3, [fp, #-20]
	ldr	r3, [r3, #0]
	@ If the target value is less than 0, go to .L7 to do subtraction
	cmp	r3, #0
	blt	.L7
	@ Load the CORDIC mode into r3. If it is zero, which is rotational mode,
	@ go to .L7 to do subtraction
	ldr	r3, [fp, #-44]
	cmp	r3, #0
	beq	.L7
	@ If the CORDIC mode is 1 (vectoring mode), fall into .L6 to do addition
.L6:
	@ Load the current y value into r2 and the loop counter into r3
	ldr	r2, [fp, #-24]
	ldr	r3, [fp, #-8]
	@ Add one to r3 because the loop counter goes from 0 - 13 and
	@ the exponents for hyperbolic CORDIC operations go from 1 - 14
	add r3, r3, #1
	@ Compute x = x + (y >> loop counter)
	mov	r2, r2, asr r3
	ldr	r3, [fp, #-12]
	add	r3, r3, r2
	str	r3, [fp, #-12]
	@ Load the current y value into r1, the old x value into r2, and the
	@ loop counter into r3
	ldr	r1, [fp, #-24]
	ldr	r2, [fp, #-16]
	ldr	r3, [fp, #-8]
	@ Add one to r3 because the loop counter goes from 0 - 13 and
	@ the exponents for hyperbolic CORDIC operations go from 1 - 14
	add r3, r3, #1
	@ Compute y = y + (x >> loop counter)
	mov	r3, r2, asr r3
	add	r3, r3, r1
	str	r3, [fp, #-24]
	@ Load the current loop counter into r2
	ldr	r2, [fp, #-8]
	@ Load the address of the lookup table into r3
	ldr	r3, .L11
	@ Load the current value from the arctanh lookup table into r2
	ldr	r2, [r3, r2, asl #2]
	@ Compute angle = angle + lookup[loop counter]
	ldr	r3, [fp, #-28]
	add	r3, r2, r3
	str	r3, [fp, #-28]
	@ Go to .L8 to increment the loop counter
	b	.L8
.L7:
	@ Load the current y value into r2 and the loop counter into r3
	ldr	r2, [fp, #-24]
	ldr	r3, [fp, #-8]
	@ Add one to r3 because the loop counter goes from 0 - 13 and
	@ the exponents for hyperbolic CORDIC operations go from 1 - 14
	add r3, r3, #1
	@ Compute x = x - (y >> loop counter)
	mov	r2, r2, asr r3
	ldr	r3, [fp, #-12]
	rsb	r3, r3, r2
	str	r3, [fp, #-12]
	@ Load the current y value into r1, the old x value into r2, and the
	@ loop counter into r3
	ldr	r1, [fp, #-24]
	ldr	r2, [fp, #-16]
	ldr	r3, [fp, #-8]
	@ Add one to r3 because the loop counter goes from 0 - 13 and
	@ the exponents for hyperbolic CORDIC operations go from 1 - 14
	add r3, r3, #1
	@ Compute y = y - (x >> loop counter)
	mov	r3, r2, asr r3
	rsb	r3, r3, r1
	str	r3, [fp, #-24]
	@ Load the current loop counter into r2
	ldr	r2, [fp, #-8]
	@ Load the address of the lookup table into r3
	ldr	r3, .L11
	@ Load the current value from the arctanh lookup table into r2
	ldr	r2, [r3, r2, asl #2]
	@ Compute angle = angle - lookup[loop counter]
	ldr	r3, [fp, #-28]
	rsb	r3, r2, r3
	str	r3, [fp, #-28]
	@ Fall through to .L8 to increment the loop counter
.L8:
	@ Load the loop counter into r3, increment it, and store it back
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
	@ Load the pointer to the x value in memory into r2 and the final x value into r3.
	@ Store the final x value back into memory
	ldr	r2, [fp, #-32]
	ldr	r3, [fp, #-12]
	str	r3, [r2, #0]
	@ Load the pointer to the y value in memory into r3 and the final y value into r2.
	@ Store the final y value back into memory	
	ldr	r2, [fp, #-24]
	ldr	r3, [fp, #-36]
	str	r2, [r3, #0]
	@ Load the pointer to the angle value in memory into r3 and the final angle value into r2.
	@ Store the final angle value back into memory
	ldr	r2, [fp, #-28]
	ldr	r3, [fp, #-40]
	str	r2, [r3, #0]
	@ Set the stack pointer back to the frame pointer, to eliminate the local storage
	add	sp, fp, #0
	@ Pop the previous frame pointer back off of the stack
	ldmfd	sp!, {fp}
	@ Jump back to where the function was called from
	bx	lr
.L12:
	.align	2
.L11:
	.word	local_elem_angle.1122