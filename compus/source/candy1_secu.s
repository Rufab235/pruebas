@;=                                                               		=
@;=== candy1_secu.s: rutinas para detectar y elimnar secuencias 	  ===
@;=                                                             	  	=
@;=== Programador tarea 1C: victor.penades@estudiants.urv.cat				  ===
@;=== Programador tarea 1D: victor.penades@estudiants.urv.cat				  ===
@;=                                                           		   	=



.include "candy1_incl.i"



@;-- .bss. variables (globales) no inicializadas ---
.bss
@; número de secuencia: se utiliza para generar números de secuencia únicos,
@;	(ver rutinas marcar_horizontales() y marcar_verticales()) 
	num_sec:	.space 1



@;-- .text. código de las rutinas ---
.text	
		.align 2
		.arm
	
	HORIZONTAL = 0
	VERTICAL = 1
	
	TRUE = 1
	FALSE = 0
	
	CASILLA_VACIA = 0
	BLOQUE_SOLIDO = 7
	GELATINA_SIMPLE_VACIA = 8
	HUECO = 15
	GELATINA_DOBLE_VACIA = 16
	


@;TAREA 1C;
@; hay_secuencia(*matriz): rutina para detectar si existe, por lo menos, una
@;	secuencia de tres elementos iguales consecutivos, en horizontal o en
@;	vertical, incluyendo elementos en gelatinas simples y dobles.
@;	Restricciones:
@;		* para detectar secuencias se invocará la rutina cuenta_repeticiones()
@;			(ver fichero 'candy1_move.s')
@;	Parámetros:
@;		R0 = dirección base de la matriz de juego
@;	Resultado:
@;		R0 = 1 si hay una secuencia, 0 en otro caso
	.global hay_secuencia
hay_secuencia:
		push {r1-r10, lr}
		
		mov r10, r0							@; R10 = dirección base de la matriz de juego
		mov r4, #COLUMNS					@; R4 = columnas
		mov r5, #ROWS						@; R5 = filas
		mov r2, #0							@; R2 = indice i
		mov r6, r0							@; R6 = posicion de la matriz
		
.L_HY_for1:
		
		mov r3, #0							@; R3 = indice j
		
.L_HY_for2:
		
		
		
		ldrb r7, [r6]						@; R7 = matriz [i][j] (valor matriz)
		cmp r7, #CASILLA_VACIA
		beq .L_HY_ELSE1
		
		cmp r7, #GELATINA_SIMPLE_VACIA
		beq .L_HY_ELSE1
		
		cmp r7, #GELATINA_DOBLE_VACIA
		beq .L_HY_ELSE1
		
		cmp r7, #BLOQUE_SOLIDO
		beq .L_HY_ELSE1
		
		cmp r7, #HUECO						@; Comparaciones IF numeros incorrectos
		beq .L_HY_ELSE1
		
.L_HY_IF1:
		
		sub r8, r4, #2
		cmp r3, r8							@; IF columnas (j<cols-2)
		bhs .L_HY_NOIF2
		
.L_HY_IF2:
		
		mov r0, r10
		mov r1, r2
		mov r2, r3
		mov r3, #HORIZONTAL
		
		bl cuenta_repeticiones
		
		mov r3, r2
		mov r2, r1
		
		mov r9, r0
		cmp r9, #2							@; IF repeticiones > 2
		bls .L_HY_NOIF2
		mov r0, #TRUE							@; devuelve 1 por R0
		b .L_HY_FINAL
		
.L_HY_NOIF2: 
		
		sub r9, r5, #2						@; IF filas (i<filas-2)
		cmp r2, r9
		bhs .L_HY_ELSE1
		
.L_HY_IF3:
		
		mov r0, r10
		mov r1, r2
		mov r2, r3
		mov r3, #VERTICAL
		
		bl cuenta_repeticiones
		
		mov r3, r2
		mov r2, r1
		
		mov r9, r0							@; IF repeticiones > 2
		cmp r9, #2
		bls .L_HY_ELSE1
		mov r0, #TRUE						@; devuelve 1 por R0
		b .L_HY_FINAL
		
.L_HY_ELSE1:
		
		add r6, #1							@; aumenta posición
		
		add r3, #1
		cmp r3, r4							@; aumenta indice j R3 y vuelve al bucle
		blo .L_HY_for2
		
		add r2, #1						
		cmp r2, r5							@; aumenta indice i R2 y vuelve al bucle
		blo .L_HY_for1
		
		
		mov r0, #FALSE						@; devuelve 0 por R0
		
.L_HY_FINAL:
		
		pop {r1-r10, pc}


@;TAREA 1D;
@; elimina_secuencias(*matriz, *marcas): rutina para eliminar todas las
@;	secuencias de 3 o más elementos repetidos consecutivamente en horizontal,
@;	vertical o cruzados, así como para reducir el nivel de gelatina en caso
@;	de que alguna casilla se encuentre en dicho modo; 
@;	además, la rutina marca todos los conjuntos de secuencias sobre una matriz
@;	de marcas que se pasa por referencia, utilizando un identificador único para
@;	cada conjunto de secuencias (el resto de las posiciones se inicializan a 0). 
@;	Parámetros:
@;		R0 = dirección base de la matriz de juego
@;		R1 = dirección de la matriz de marcas
	.global elimina_secuencias
elimina_secuencias:
		push {r0-r10, lr}
		
		mov r4, #COLUMNS					@; R4 = columnas
		mov r5, #ROWS						@; R5 = filas
		
		mov r2, #0							@; R2 = indice i
		
		mov r10, r0							@; R10 = dirección base de la matriz de juego
		mov r7, r1							@; R7 = posicion de la matriz_marcas
		
.L_ES_for1:
		
		mov r3, #0							@; R3 = indice j
.L_ES_for2:	
		
		mov r9, #0
		strb r9, [r7]						@; ponemos toda la matriz_marcas a 0
		
		add r7, #1							@; aumenta posición
		add r3, #1
		cmp r3, r4							@; aumenta indice j R3 y vuelve al bucle
		blo .L_ES_for2
		
		add r2, #1						
		cmp r2, r5							@; aumenta indice i R2 y vuelve al bucle
		blo .L_ES_for1
		
		bl marca_horizontales
		bl marca_verticales
		
		mov r2, #0							@; R2 = indice i a 0 para nuevo bucle
		
		mov r6, r10							@; R6 = posicion de la matriz
		mov r7, r1							@; R7 = posicion de la matriz_marcas
		
.L_ES_for3:
		
		mov r3, #0							@; R3 = indice j a 0 para nuevo bucle
.L_ES_for4:	
		
		ldrb r8, [r7]						@; R8 = matriz_marcas[i][j]
		cmp r8, #0							@; if (matriz_marcas[i][j] != 0)
		beq .L_ES_ELSE1
		
		ldrb r8, [r6]						@; R8 = matriz[i][j]
		cmp r8, #1
		blo .L_ES_ELSEIF
		
		cmp r8, #14							@; IF (num>=1) && (num<=14)		
		bhi .L_ES_ELSEIF
		
		mov r9, #0
		strb r9, [r6]						@; ponemos el valor de la matriz a casilla vacía (a 0)
		b .L_ES_ELSE1
		
		
.L_ES_ELSEIF:
		
		cmp r8, #17
		blo .L_ES_ELSE1							@; @; IF (num>=17) && (num<=22)	
		
		cmp r8, #22
		bhi	.L_ES_ELSE1
		
		mov r9, #8
		strb r9, [r6]						@; ponemos el valor de la matriz a gelatina simple vacía (a 8)
		
.L_ES_ELSE1:
		
		add r6, #1							@; aumenta posición matriz
		add r7, #1							@; aumenta posición matriz_marcas
		
		add r3, #1
		cmp r3, r4							@; aumenta indice j R3 y vuelve al bucle
		blo .L_ES_for4
		
		add r2, #1						
		cmp r2, r5							@; aumenta indice i R2 y vuelve al bucle
		blo .L_ES_for3
		
		pop {r0-r10, pc}


	
@;:::RUTINAS DE SOPORTE:::



@; marca_horizontales(mat): rutina para marcar todas las secuencias de 3 o más
@;	elementos repetidos consecutivamente en horizontal, con un número identifi-
@;	cativo diferente para cada secuencia, que empezará siempre por 1 y se irá
@;	incrementando para cada nueva secuencia, y cuyo último valor se guardará en
@;	la variable global num_sec; las marcas se guardarán en la matriz que se
@;	pasa por parámetro mat[][] (por referencia).
@;	Restricciones:
@;		* se supone que la matriz mat[][] está toda a ceros
@;		* para detectar secuencias se invocará la rutina cuenta_repeticiones()
@;			(ver fichero 'candy1_move.s')
@;	Parámetros:
@;		R0 = dirección base de la matriz de juego
@;		R1 = dirección de la matriz de marcas
marca_horizontales:
		push {r0-r10, lr}
		
		mov r10, r0							@; R10 = dirección base de la matriz de juego
		mov r4, #COLUMNS					@; R4 = columnas
		mov r5, #ROWS						@; R5 = filas
		
		mov r2, #0							@; R2 = indice i
		mov r8, #1							@; R8 = marca
		
		mov r6, r0							@; R6 = posicion de la matriz
		mov r7, r1							@; R7 = posicion de la matriz_marcas
		
.L_MH_for1:
		
		mov r3, #0							@; R3 = indice j
.L_MH_for2:	
		
		ldrb r9, [r7]
		cmp r9, #0							@; IF (matriz_marcas[i][j] == 0)
		bne .L_MH_ELSE1
		
		ldrb r9, [r6]
		cmp r9, #CASILLA_VACIA
		beq .L_MH_ELSE1
		
		cmp r9, #GELATINA_SIMPLE_VACIA		@; IF ((matriz[i][j] != 0) && (matriz[i][j] != 8) && (matriz[i][j] != 16) && (matriz[i][j] != 7) && (matriz[i][j] != 15))
		beq .L_MH_ELSE1
		
		cmp r9, #GELATINA_DOBLE_VACIA
		beq .L_MH_ELSE1
		
		cmp r9, #BLOQUE_SOLIDO
		beq .L_MH_ELSE1
		
		cmp r9, #HUECO
		beq .L_MH_ELSE1
		
		sub r9, r4, #2						@; IF (j<cols-2)
		cmp r3, r9
		bhs .L_MH_ELSE1
		
		mov r0, r10
		mov r1, r2
		mov r2, r3
		mov r3, #HORIZONTAL
		
		bl cuenta_repeticiones
		
		mov r3, r2
		mov r2, r1
		
		cmp r0, #2							@; IF (repeticiones > 2)
		bls .L_MH_ELSE1
		
		mov r1, #0							@; R1 = k
		
.L_MH_WHILE:
		
		add r9, r7, r1
		strb r8, [r9]						@; matriz_marcas[i][j+k] = marca
		
		add r1, #1							@; aumenta k
		cmp r1, r0
		blo .L_MH_WHILE							@; bucle while (k<repeticiones)
		
		add r8, #1							@; aumenta marca
		
.L_MH_ELSE1:
		
		add r6, #1							@; aumenta posición matriz
		add r7, #1							@; aumenta posición matriz_marcas
		
		add r3, #1
		cmp r3, r4							@; aumenta indice j R3 y vuelve al bucle
		blo .L_MH_for2
		
		add r2, #1						
		cmp r2, r5							@; aumenta indice i R2 y vuelve al bucle
		blo .L_MH_for1
		
		
		pop {r0-r10, pc}



@; marca_verticales(mat): rutina para marcar todas las secuencias de 3 o más
@;	elementos repetidos consecutivamente en vertical, con un número identifi-
@;	cativo diferente para cada secuencia, que seguirá al último valor almacenado
@;	en la variable global num_sec; las marcas se guardarán en la matriz que se
@;	pasa por parámetro mat[][] (por referencia);
@;	sin embargo, habrá que preservar los identificadores de las secuencias
@;	horizontales que intersecten con las secuencias verticales, que se habrán
@;	almacenado en la matriz de referencia con la rutina anterior.
@;	Restricciones:
@;		* se supone que la matriz mat[][] está marcada con los identificadores
@;			de las secuencias horizontales
@;		* la variable num_sec contendrá el siguiente identificador (>=1)
@;		* para detectar secuencias se invocará la rutina cuenta_repeticiones()
@;			(ver fichero 'candy1_move.s')
@;	Parámetros:
@;		R0 = dirección base de la matriz de juego
@;		R1 = dirección de la matriz de marcas
marca_verticales:
		push {r0-r12, lr}
		
		mov r12, r0							@; R12 = dirección base de la matriz de juego
		mov r4, #COLUMNS					@; R4 = columnas
		mov r5, #ROWS						@; R5 = filas
		
		mov r2, #0							@; R2 = indice i
		mov r8, #0							@; R8 = marca
		
		mov r6, r0							@; R6 = posicion de la matriz
		mov r7, r1							@; R7 = posicion de la matriz_marcas
		
		
.L_MV_for1:
		
		mov r3, #0							@; R3 = indice j
		
.L_MV_for2:
		
		ldrb r9, [r7]
		cmp r8, r9							@; IF (marca < matriz_marcas[i][j])
		bhs .L_MV_ELSE1
		
		mov r8, r9							@; asignamos en marca el valor de matriz_marcas[i][j]
		
		
.L_MV_ELSE1:
		
		add r7, #1							@; aumenta posición matriz_marcas
		
		add r3, #1
		cmp r3, r4							@; aumenta indice j R3 y vuelve al bucle
		blo .L_MV_for2
		
		add r2, #1						
		cmp r2, r5							@; aumenta indice i R2 y vuelve al bucle
		blo .L_MV_for1
		
		
		
		add r8, #1							@; aumentamos 1 en marca por si hay que marcar una nueva combinación
		mov r2, #0							@; R2 = indice i
		
		mov r7, r1							@; R7 = devuelve posicion inicial de la matriz_marcas
		
.L_MV_for3:
		
		mov r3, #0							@; R3 = indice j
.L_MV_for4:	
		
		ldrb r9, [r6]
		cmp r9, #CASILLA_VACIA
		beq .L_MV_ELSE2
		
		cmp r9, #GELATINA_SIMPLE_VACIA		@; IF ((matriz[i][j] != 0) && (matriz[i][j] != 8) && (matriz[i][j] != 16) && (matriz[i][j] != 7) && (matriz[i][j] != 15))
		beq .L_MV_ELSE2
		
		cmp r9, #GELATINA_DOBLE_VACIA
		beq .L_MV_ELSE2
		
		cmp r9, #BLOQUE_SOLIDO
		beq .L_MV_ELSE2
		
		cmp r9, #HUECO
		beq .L_MV_ELSE2
		
		sub r9, r5, #2						@; IF (j<filas-2)
		cmp r2, r9
		bhs .L_MV_ELSE2
		
		mov r0, r12
		mov r1, r2
		mov r2, r3
		mov r3, #VERTICAL
		
		bl cuenta_repeticiones
		
		mov r3, r2
		mov r2, r1
		
		cmp r0, #2							@; IF (repeticiones > 2)
		bls .L_MV_ELSE2
		
		mov r1, #0							@; R1 = k
		mov r10, #FALSE						@; R10 = combinada = false
		
.L_MV_WHILE:
		mul r9, r1, r4
		add r9, r7, r9
		ldrb r11, [r9]						@; R11 = num_comb = matriz_marcas[i+k][j]
		cmp r11, #0							@; IF (matriz_marcas[i+k][j] != 0)
		beq .L_MV_NOIF
		
		mov r10, #1							@; combinada = true					
		
.L_MV_NOIF:
		
		add r1, #1							@; aumenta k
		cmp r1, r0
		bhs .L_MV_FIN_WHILE							
		cmp r10, #0							@; bucle (k<repeticiones && !combinada)
		beq .L_MV_WHILE
		
.L_MV_FIN_WHILE:
		
		cmp r10, #0
		beq .L_MV_ELSEIF							@; IF (combinada)
		
		mov r1, #0							@; reseteamos k a 0
.L_MV_WHILE2:
		
		mul r9, r1, r4
		add r9, r7, r9
		strb r11, [r9]						@; introducimos el número de combinada en la matriz de marcas
		add r1, #1							@; aumenta k
		
		cmp r1, r0
		blo .L_MV_WHILE2							@; bucle (k<repeticiones)
		
		b .L_MV_ELSE2
		
.L_MV_ELSEIF:
		
		mov r1, #0							@; reseteamos k a 0
.L_MV_WHILE3:
		
		mul r9, r1, r4
		add r9, r7, r9
		strb r8, [r9]						@; introducimos el número de nueva marca en la matriz de marcas
		add r1, #1							@; aumenta k
		
		cmp r1, r0
		blo .L_MV_WHILE3							@; bucle (k<repeticiones)
		
		add r8, #1							@; aumenta marca
		
.L_MV_ELSE2:
		
		add r6, #1							@; aumenta posición matriz
		add r7, #1							@; aumenta posición matriz_marcas
		
		add r3, #1
		cmp r3, r4							@; aumenta indice j R3 y vuelve al bucle
		blo .L_MV_for4
		
		add r2, #1						
		cmp r2, r5							@; aumenta indice i R2 y vuelve al bucle
		blo .L_MV_for3
		
		
		pop {r0-r12, pc}



.end