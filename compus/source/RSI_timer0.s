@;=                                                          	     	=
@;=== RSI_timer0.s: rutinas para mover los elementos (sprites)		  ===
@;=                                                           	    	=
@;=== Programador tarea 2E: xxx.xxx@estudiants.urv.cat				  ===
@;=== Programador tarea 2G: yyy.yyy@estudiants.urv.cat				  ===
@;=== Programador tarea 2H: zzz.zzz@estudiants.urv.cat				  ===
@;=                                                       	        	=

.include "candy2_incl.i"


@;-- .data. variables (globales) inicializadas ---
.data
		.global update_spr
	update_spr:	.byte	0			@;1 -> actualiza sprites
		.global timer0_on
	timer0_on:	.byte	0 			@;1 -> timer0 en marcha, 0 -> apagado
			.align 1
	divFreq0: .hword -5734 			@;divisor de frecuencia inicial para timer 0 freqE=16,384 freqS=2,85	divfreq=freqE/-freqS


@;-- .bss. variables (globales) no inicializadas ---
.bss
		.align 1
	divF0: .space	2			@;divisor de frecuencia actual


@;-- .text. código de las rutinas ---
.text	
		.align 2
		.arm

@;TAREAS 2Ea,2Ga,2Ha;
@;rsi_vblank(); Rutina de Servicio de Interrupciones del retroceso vertical;
@;Tareas 2E,2F: actualiza la posición y forma de todos los sprites
@;Tarea 2G: actualiza las metabaldosas de todas las gelatinas
@;Tarea 2H: actualiza el desplazamiento del fondo 3
	.global rsi_vblank
rsi_vblank:
		push {r0-r4,lr}
		
	@;Tareas 2Ea y 2Fa
		ldr r0, =update_spr
		ldrb r1, [r0]
		cmp r1, #0 @; comprobar que esta activo
		beq .fiRSIE
		mov r3, #0x07000000 @;direccion base
		ldr r2, =n_sprites	@; num max de sprites
		ldr r1, [r3]
		bl SPR_actualiza_sprites
		mov r2, #0
		strb r2, [r0]	@;reiniciar 
		
		.fiRSIE:
	@;Tarea 2Ga
		
		
	@;Tarea 2Ha
		
		
		pop {r0-r4,pc}




@;TAREA 2Eb;
@;activa_timer0(init); rutina para activar el timer 0, inicializando o no el
@;	divisor de frecuencia según el parámetro init.
@;	Parámetros:
@;		R0 = init; si 1, restablecer divisor de frecuencia original divFreq0
	.global activa_timer0
activa_timer0:
		push {r0-r3,lr}
		mov r1, r0
		cmp r1, #0 	@; si init = 0 llavor no toca inicialitzar divG'
		beq .iniciar
		
		ldr r1, =divFreq0
		ldrh r2, [r1]
		ldr r1, =divF0
		strh r2, [r1] @;copiar divFreq0 en divF0
		ldr r1, = 0x04000100	@;dir memoria timer0
		strh r2, [r1]
		
		.iniciar:
		ldr r0, =timer0_on
		mov r1, #1
		strb r1, [r0]
		ldr r0, =0x04000102
		mov r1, #0b11000001 @;bit 7-timer, 6-irqEnable, 1/0- divisor freq reloj en 64 para no desbordar
		strh r1, [r0]
	
		
		pop {r0-r3, pc}


@;TAREA 2Ec;
@;desactiva_timer0(); rutina para desactivar el timer 0.
	.global desactiva_timer0
desactiva_timer0:
		push {r0-r1, lr}
		ldr r0, =0x04000102		@;cargar reg de control
		mov r1, #0b01000001		@;poner el bit 7 a 0 (desactivar)
		strh r1, [r0]			@;guardar el registro
		ldr r0, =timer0_on	
		mov r1, #0	
		strb r1, [r0]			@;guardar 0 en la var timer._on
		pop {r0-r1, pc}
		
		pop {pc}



@;TAREA 2Ed;
@;rsi_timer0(); rutina de Servicio de Interrupciones del timer 0: recorre todas
@;	las posiciones del vector vect_elem y, en el caso que el código de
@;	activación (ii) sea mayor o igual a 0, decrementa dicho código y actualiza
@;	la posición del elemento (px, py) de acuerdo con su velocidad (vx,vy),
@;	además de mover el sprite correspondiente a las nuevas coordenadas.
@;	Si no se ha movido ningún elemento, se desactivará el timer 0. En caso
@;	contrario, el valor del divisor de frecuencia se reducirá para simular
@;  el efecto de aceleración (con un límite).
	.global rsi_timer0
rsi_timer0:
    push {r4-r10, lr}       @; Usamos r4-r10 porque no se pierden tras un 'bl'
    
    mov r4, #0              @; r4 = i
    mov r5, #0              @; r5 = flag "movido" (booleano)
    ldr r6, =n_sprites
    ldrb r6, [r6]           @; r6 = límite n_sprites
    ldr r7, =vect_elem      @; r7 = puntero al elemento actual

	.LwhileTimer0:
		cmp r4, r6
		bhs .LfiWhileRSI0
		
		ldrsb r8, [r7, #0]      @; Cargar 'ii' (offset 0)
		cmp r8, #0
		ble .LnextPosicion      @; Ignorar si ii <= 0
		
		sub r8, r8, #1
		strb r8, [r7, #0]       @; Decrementar y guardar ii
		
		@; Cargar coordenadas y velocidades
		ldrsh r9, [r7, #2]      @; px
		ldrsh r10, [r7, #4]     @; py
		ldrsh r1, [r7, #6]      @; vx
		ldrsh r2, [r7, #8]      @; vy
		
		@; Actualizar posiciones
		add r9, r9, r1          @; px = px + vx
		add r10, r10, r2        @; py = py + vy
		strh r9, [r7, #2]       @; Guardar nueva px
		strh r10, [r7, #4]      @; Guardar nueva py
		
		@; Llamar a función: SPR_mueve_sprite(ID, x, y)
		mov r0, r4              @; R0 = índice del sprite
		mov r1, r9              @; R1 = posición X
		mov r2, r10             @; R2 = posición Y
		bl SPR_mueve_sprite
		
		mov r5, #1              @; Indicamos que algo se ha movido

	.LnextPosicion:
		add r7, r7, #12         @; IMPORTANTE: El salto depende del tamaño de tu struct
		add r4, r4, #1          @; i++
		b .LwhileTimer0

	.LfiWhileRSI0:
		cmp r5, #0
		bleq desactiva_timer0
		beq .LfinalTotal        @; Si no se movió nada, terminamos aquí

		@; --- ACELERACIÓN ---
		ldr r0, =update_spr
		mov r1, #1
		strb r1, [r0]           @; Activar flag de actualización de sprites
		
		ldr r0, =divF0
		ldrh r1, [r0]
		add r1, r1, #50         @; Sumar al valor negativo para acelerar (ej. 50 unidades)
		ldr r2, =0xFE00         @; Límite de velocidad máxima (casi 65535)
		cmp r1, r2
		movhs r1, r2            @; Saturar al límite
		strh r1, [r0]           @; Guardar en variable
		
		ldr r2, =0x04000100     @; REG_TM0D (Registro de datos del Timer)
		strh r1, [r2]           @; Actualizar hardware

	.LfinalTotal:
    pop {r4-r10, pc}


.end
