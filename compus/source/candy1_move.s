@;=                                                         	      	=
@;=== candy1_move: rutinas para contar repeticiones y bajar elementos ===
@;=                                                          			=
@;=== Programador tarea 1E: alejandro.perezz@estudiants.urv.cat				  ===
@;=== Programador tarea 1F: alejandro.perezz@estudiants.urv.cat				  ===
@;=                                                         	      	=



.include "candy1_incl.i"



@;-- .text. código de las rutinas ---
.text	
		.align 2
		.arm
		
	MASK_GEL = 0x07
	EST = 0
	SUD = 1
	OEST = 2
	NORD = 3


@;TAREA 1E;
@; cuenta_repeticiones(*matriz, f, c, ori): rutina para contar el número de
@;	repeticiones del elemento situado en la posición (f,c) de la matriz, 
@;	visitando las siguientes posiciones según indique el parámetro de
@;	orientación ori.
@;	Restricciones:
@;		* solo se tendrán en cuenta los 3 bits de menor peso de los códigos
@;			almacenados en las posiciones de la matriz, de modo que se ignorarán
@;			las marcas de gelatina (+8, +16)
@;		* la primera posición también se tiene en cuenta, de modo que el número
@;			mínimo de repeticiones será 1, es decir, el propio elemento de la
@;			posición inicial
@;	Parámetros:
@;		R0 = dirección base de la matriz
@;		R1 = fila f
@;		R2 = columna c
@;		R3 = orientación ori (0 -> Este, 1 -> Sur, 2 -> Oeste, 3 -> Norte)
@;	Resultado:
@;		R0 = número de repeticiones detectadas (mínimo 1)
	.global cuenta_repeticiones
cuenta_repeticiones:

		push {r1-r6, lr}
		
		ldr r4, =COLUMNS
		mla r5, r4, r1, r2				@; r5 = f * COLUMNS + c
		add r4, r5, r0					@; R4 = matriu[f][c]
		
		ldrb r5, [r4]
		and r5, r5, #MASK_GEL			@; int n = tabla[f][c] & 0x07 ||  R5 = bloc sense gelatina 
		
		mov r6, #1						@; inicialitzar contador (el propio elemento cuenta)		
		
		cmp r3, #EST					@;  if( dir == 0) comprobar si es dirección EST
		bne .L_E1_NO_EST		
		
	.L_E1_bucle_EST:
	
		add r4, #1						@; avanzar al siguiente elemento en dirección EST
		add r2, #1						@; incrementar índice columna		
		
		cmp r2, #COLUMNS				@; si columna >= COLUMNS  (fin de tablero)
		bhs .L_E1_fi_bucle
		
		ldrb r3, [r4]					@; leer valor tabla[f][c]
		and r3, r3, #MASK_GEL			@; aplicar máscara
		
		cmp r3, r5
		bne .L_E1_fi_bucle				@; si es distinto al valor inicial, fin del bucle
		
		add r6, #1						@; si es igual, incrementar contador
		b .L_E1_bucle_EST
	
	.L_E1_NO_EST:
		
		cmp r3, #SUD					@; if (dir == SUR)
		bne .L_E1_NO_SUD
		
	.L_E1_bucle_SUD:
		
		add r4, #COLUMNS				@; avanzar una fila hacia abajo (f++)
		add r1, #1						@; incrementar índice fila
		
		cmp r1, #ROWS					@; comprobar si fila >= ROWS (fin de tablero)
		bhs .L_E1_fi_bucle
		
		ldrb r3, [r4]					@; leer valor tabla[f][c]
		and r3, r3, #MASK_GEL			@; aplicar máscara
		
		cmp r3, r5						@; comparar con valor inicial
		bne .L_E1_fi_bucle				@; si es distinto, fin del bucle
		
		add r6, #1						@; si es igual, incrementar contador		
		b .L_E1_bucle_SUD
		
	.L_E1_NO_SUD:
		
		cmp r3, #OEST					@; if (dir == OESTE)
		bne .L_E1_bucle_NORD			
		
	.L_E1_bucle_OEST:
		
		sub r4, #1						@; retroceder al elemento de la izquierda (c--)
		sub r2, #1						@; decrementar índice columna
		
		cmp r2, #0						@; si columna < 0 (fuera de tablero)
		blt .L_E1_fi_bucle
		
		ldrb r3, [r4]					@; leer valor tabla[f][c]
		and r3, #MASK_GEL
		
		cmp r3, r5						@; comparar con valor inicial
		bne .L_E1_fi_bucle				@; si es distinto, fin del bucle
		
		add r6, #1						@; si es igual, incrementar contador		
		b .L_E1_bucle_OEST
		
	.L_E1_bucle_NORD:
		
		sub r4, #COLUMNS				@; retroceder una fila hacia arriba (f--)
		sub r1, #1						@; decrementar índice fila
		
		cmp r1, #0						@; si fila < 0, fuera de tablero
		blt .L_E1_fi_bucle
		
		ldrb r3, [r4]					@; leer valor tabla[f][c]
		and r3, r3, #MASK_GEL
		
		cmp r5, r3						@; comparar con valor inicial
		bne .L_E1_fi_bucle				@; si es distinto, fin del bucle
		
		add r6, #1						@; si es igual, incrementar contador
		b .L_E1_bucle_NORD
		
	.L_E1_fi_bucle:
		
		mov r0, r6						@; devolver el resultado en r0 (número de repeticiones)
		
		pop {r1-r6, pc}




@;TAREA 1F;
@; baja_elementos(*matriz): rutina para bajar elementos hacia las posiciones
@;	vacías, primero en vertical y después en diagonal; cada llamada a la función
@;	baja múltiples elementos una posición y devuelve cierto (1) si se ha
@;	realizado algún movimiento, o falso (0) si no se ha movido ningún elemento.
@;	Restricciones:
@;		* para las casillas vacías de la primera fila se generarán nuevos
@;			elementos, invocando la rutina mod_random() (ver fichero
@;			'candy1_init.s')
@;	Parámetros:
@;		R0 = dirección base de la matriz de juego
@;	Resultado:
@;		R0 = 1 indica se ha realizado algún movimiento, de modo que pueden
@;				quedar movimientos pendientes; 0 indica que no ha movido nada 
	.global baja_elementos
baja_elementos:
		push {lr}
		
		
		pop {pc}



@;:::RUTINAS DE SOPORTE:::



@; baja_verticales(mat): rutina para bajar elementos hacia las posiciones vacías
@;	en vertical; cada llamada a la función baja múltiples elementos una posición
@;	y devuelve cierto (1) si se ha realizado algún movimiento.
@;	Parámetros:
@;		R4 = dirección base de la matriz de juego
@;	Resultado:
@;		R0 = 1 indica que se ha realizado algún movimiento; 0 indica que no ha
@;				movido nada  
baja_verticales:
		push {lr}
		
		
		pop {pc}


@; baja_laterales(mat): rutina para bajar elementos hacia las posiciones vacías
@;	en diagonal; cada llamada a la función baja múltiples elementos una posición
@;	y devuelve cierto (1) si se ha realizado algún movimiento.
@;	Parámetros:
@;		R4 = dirección base de la matriz de juego
@;	Resultado:
@;		R0 = 1 indica que se ha realizado algún movimiento; 0 indica que no ha
@;				movido nada 
baja_laterales:
		push {lr}
		
		
		pop {pc}


.end
