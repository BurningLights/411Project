	@ Name: Rahsaan Hall
	.text
	.global main
main:	
	@ will do 23 iterations
	@ of cordic since mantissa of single
	@ precision float is 23 bits
	@ multiply 23 * 4 since each word in the
	@atanh table is 4 bytes and get 92 or 0x5c
	MOV r1, #0x5C
 		
	@ initialize loop counter (i)
	MOV r2, #0x0
	@ This counter will hold i + 1
	@ for shifting
	MOV r0, #1
	
	LDR r12, =zero
	LDR r12, [r12]

	LDR r14,=one
	LDR r14,[r14]
	
	LDR r13,=two
	LDR r13, [r13]



cordic:
	@ exit when i = 92
	CMP r2,r1	
	BEQ exit
	
	LDR r3, =desired
	LDR r3, [r3]
	
	LDR r4, =x
	LDR r4, [r4]
	
	LDR r5, =y
	LDR r5, [r5]

	@ if desired number is greater
	@ than or equal to 0, rotate clockwise,
	@ otherwise counterclockwise
	CMP r3,r12
	BGE clock_rot 	
	
	B counter_rot

@Clock wise rotation
clock_rot:

	@ y >> i+1
	MOV r7,r5,ASR r0
	@ x >> i+1
	MOV r8,r4,ASR r0
	
	@ x + (y >> i+1)
	ADD r4,r4,r7	
	STR r4, x

	@ y + (x >> i+1)
	ADD r5,r5,r8	
	STR r5,y

	@ load atanhtable[i]
 	LDR r9, =atanhTable
	LDR r9, [r9,r2]

	@ z - atanh[i]
	SUB r3,r3,r9	
	STR r3, desired

	@ add 4 to i and 1 to i+1 counters
	ADD r2,r2,#4
	ADD r0,r0,#1
	B cordic

@ Counter clockwise rotation
counter_rot:
	@ y >> i
	MOV r7,r5,ASR r0
	@ x >> i
	MOV r8,r4,ASR r0 

	@ x - (y >> i+1)
	SUB r4,r4,r7	
	STR r4, x

	@ y - (x >> i+1)
	SUB r5,r5,r8	
	STR r5,y

	@ load atanhtable[i]
 	LDR r9, =atanhTable
	LDR r9, [r9,r2]

	@ z + atanh[i]
	ADD r3,r3,r9	
	STR r3, desired

	@ add 4 to i and 1 to i+1 counters
	ADD r2,r2,#4 
	ADD r0,r0,#1
	B cordic
	
	
atanhTable:
	.word 35999
	.word 16738
	.word 8235
	.word 4101
	.word 2048
	.word 1024
	.word 512
	.word 255
	.word 127
	.word 64
	.word 31
	.word 15
	.word 7
	.word 3
	.word 2
	.word 0
	.word 0
	.word 0
	.word 0
	.word 0
	.word 0
	.word 0
	.word 0
	
x:
	.word 79136 @ 1.207534 * 65536
	
y:
	.word 0
	
@ desired is the number to calculate
@ sinh , cosh, and e^x
@ of (in radians) can only be between
@ -1 and 1	

desired:
	.word 57671

zero:
	.word 0
one:
	.word 1
two:
	.word 2
gain:
	.word 65536

exit:

	@ Divide x and y by 2^16 or 65536
	@ since everything is scaled up
	@ by this amount
	LDR r2, =gain
	VLDR.f32 s2,[r2]
	VCVT.f32.s32 s2, s2

	LDR r3, =x
	VLDR.f32 s3, [r3]
	VCVT.f32.s32 s3, s3
	LDR r3,[r3]
	VDIV.f32 s3, s3,s2

	LDR r4, =y
	VLDR.f32 s4, [r4]
	VCVT.f32.s32 s4, s4
	LDR r4, [r4]
	VDIV.f32 s4, s4,s2

	@ e^x = sinh + cosh
	ADD r5, r3, r4
	VMOV.f32 s5, r5
	VCVT.f32.s32 s5, s5
	VDIV.f32 s5, s5, s2
	
	swi 0x11
	.end
