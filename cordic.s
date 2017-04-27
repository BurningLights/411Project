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
	.word	2949120
	.word	1740967
	.word	919789
	.word	466945
	.word	234379
	.word	117304
	.word	58666
	.word	29335
	.word	14668
	.word	7334
	.word	3667
	.word	1833
	.word	917
	.word	458
	.text
	.align	2
	.global	cordic_assembly
	.type	cordic_assembly, %function
cordic_assembly:
	@ Function supports interworking.
	@ args = 0, pretend = 0, frame = 40
	@ frame_needed = 1, uses_anonymous_args = 0
	@ link register save eliminated.
	str	fp, [sp, #-4]!
	add	fp, sp, #0
	sub	sp, sp, #44
	str	r0, [fp, #-32]
	str	r1, [fp, #-36]
	str	r2, [fp, #-40]
	str	r3, [fp, #-44]
	ldr	r3, [fp, #-32]
	ldr	r3, [r3, #0]
	str	r3, [fp, #-12]
	ldr	r3, [fp, #-36]
	ldr	r3, [r3, #0]
	str	r3, [fp, #-24]
	ldr	r3, [fp, #-40]
	ldr	r3, [r3, #0]
	str	r3, [fp, #-28]
	ldr	r3, [fp, #-44]
	cmp	r3, #0
	bne	.L2
	sub	r3, fp, #28
	str	r3, [fp, #-20]
	b	.L3
.L2:
	sub	r3, fp, #24
	str	r3, [fp, #-20]
.L3:
	ldr	r3, [fp, #-12]
	mov	r3, r3, asl #16
	str	r3, [fp, #-12]
	ldr	r3, [fp, #-24]
	mov	r3, r3, asl #16
	str	r3, [fp, #-24]
	ldr	r3, [fp, #-28]
	mov	r3, r3, asl #16
	str	r3, [fp, #-28]
	mov	r3, #0
	str	r3, [fp, #-8]
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
	ldr	r3, [fp, #-8]
	cmp	r3, #13
	ble	.L9
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