	.include  "inter.inc"
 .data
 cuenta: .word 0 	@Entre 0 y 5, LED a encender
  /* guia bits           10987654321098765432109876543210*/
secuen: .word	  0b00000000000000000000001000000000
            .word	  0b00000000000000000000010000000000
            .word	  0b00000000000000000000100000000000
            .word	  0b00000000000000100000000000000000
            .word	  0b00000000010000000000000000000000
            .word	  0b00001000000000000000000000000000


.text
/* Agrego vector interrupcion */
        ADDEXC  0x18, irq_handler

/* Inicializo la pila en modos IRQ y SVC */
        mov     r0, #0b11010010   @ Modo IRQ, FIQ&IRQ desact
        msr     cpsr_c, r0
        mov     sp, #0x8000
        mov     r0, #0b11010011   @ Modo SVC, FIQ&IRQ desact
        msr     cpsr_c, r0
        mov     sp, #0x8000000

/* Configuro GPIO 9 como salida */
        ldr     r0, =GPBASE
/* guia bits            xx999888777666555444333222111000*/
        mov   r1, #0b00001000000000000000000000000000
        str     r1, [r0, #GPFSEL0]
	
/* Configuro GPIO 10, 11, 17 como salida */
        ldr     r0, =GPBASE
   /* guia bits           xx999888777666555444333222111000*/
       ldr    r1, =0b00000000001000000000000000001001
        str     r1, [r0, #GPFSEL1]
	
/* Configuro GPIO 22,27 como salida */
        ldr     r0, =GPBASE
   /* guia bits           xx999888777666555444333222111000*/
       ldr    r1, =0b00000000001000000000000001000000
        str     r1, [r0, #GPFSEL2]
	

/* Programo contador C1 para futura interrupcion */
        ldr     r0, =STBASE
        ldr     r1, [r0, #STCLO]
        add     r1, #0x100000     @1 segundos
        str     r1, [r0, #STC1]

/* Habilito interrupciones, local y globalmente */
	
        ldr     r0, =INTBASE
        mov     r1, #0b0010
        str     r1, [r0, #INTENIRQ1]
        mov     r0, #0b01010011   @ Modo SVC, IRQ activo
        msr     cpsr_c, r0
	
/* Repetir para siempre */
bucle:  b       bucle

/* Rutina de tratamiento de interrupción */
irq_handler:
        push    {r0, r1,r2,r3,r4}          @ Salvo registros
	
	ldr     r0, =GPBASE
/* guia bits           10987654321098765432109876543210*/
	ldr     r1, =0b00001000010000100000111000000000
        str     r1, [r0, #GPCLR0] @ Apago todos los LED
	

	ldr r4,=cuenta
	ldr r2,[r4]
	ldr r3,=secuen
	ldr r1, [r3, r2, LSL#2]@Elegimos el siguiente elemento(LED) de la variable secuen
	str r1,[r0,#GPSET0]
	
	/*Actualizamos el valor de cuenta en r4*/
	cmp r2, #5
	ldreq r2,=0 @Si r2 y 5(último LED) son iguales resetea y empieza desde el principio
	addne r2,#1 @Si no son iguales le suma 1
	str r2, [r4]
	
	
	ldr r0, =STBASE
	mov r1, #0b0010
	str r1, [r0,#STCS]

        ldr     r1, [r0, #STCLO]
        add     r1, #0x100000     @1 segundos
        str     r1, [r0, #STC1]    

        pop     {r0, r1,r2,r3,r4}          @ Recupero registros
        subs    pc, lr, #4        @ Salgo de la RTI
	