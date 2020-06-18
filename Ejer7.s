        .set    GPBASE,   0x3F200000
        .set    GPFSEL0,        0x00
        .set    GPSET0,         0x1c
        .set    GPCLR0,         0x28
		.set	GPLEV0,		0x34
		.set    STBASE,   0x3F003000
        .set    STCLO,          0x04
 
.text	
	mov 	r3, #0b11010011
	msr	cpsr_c, r3
	mov 	sp, #0x8000000	@ Inicializ. pila en modo SVC
        ldr     r0, =GPBASE
	/* guia bits           xx999888777666555444333222111000*/
        mov   	r1, #0b00000000000000000001000000000000
        str	r1, [r0, #GPFSEL0]  @ Configura GPIO 4, 2 y 3	
	/* guia bits           10987654321098765432109876543210*/
        mov   	r1, #0b00000000000000000000000000010000
	ldr	r3, =STBASE	@ r3 es un parametro de sonido (dir base ST)
	
bucle:	
	ldr	r1, [r0, #GPLEV0]
	ands	r2, r1, #0b00000000000000000000000000000100
	beq	pulsador1
	ands	r2, r1, #0b00000000000000000000000000001000
	beq	pulsador2
	b 	bucle

pulsador1:	
	/* guia bits           10987654321098765432109876543210*/
        mov   	r1, #0b00000000000000000000000000010000
	ldr	r4, =1908	@ r4 es un parametro de sonido (periodo/2)
	str    	r1, [r0, #GPSET0]
	bl     	sonido		@ Salta a rutina de sonido
        str     r1, [r0, #GPCLR0]
        bl     	sonido 		@ Salta a rutina de sonido
	ldr	r1, [r0, #GPLEV0]
	ands	r2, r1, #0b00000000000000000000000000000100
	beq	pulsador2
	b 	pulsador1
pulsador2:
	/* guia bits           10987654321098765432109876543210*/
        mov   	r1, #0b00000000000000000000000000010000
	ldr	r4, =1278	@ r4 es un parametro de sonido (periodo/2)
	str    	r1, [r0, #GPSET0]
	bl     	sonido		@ Salta a rutina de sonido
	str     r1, [r0, #GPCLR0]
        bl     	sonido 		@ Salta a rutina de sonido
	ldr	r1, [r0, #GPLEV0]
	ands	r2, r1, #0b00000000000000000000000000001000
	beq	pulsador1
	b 	pulsador2

/* rutina que espera r1 microsegundos */
sonido: 
	push	{r0,r1}
        ldr     r0, [r3, #STCLO]  @ Lee contador en r4
        add    	r0, r4    	  @ r4= r4 + perido/2
ret1: 	ldr     r1, [r3, #STCLO]
        cmp	r1, r0            @ Leemos CLO hasta alcanzar
        blo     ret1              @ el valor de r4
	pop	{r0,r1}
        bx      lr

