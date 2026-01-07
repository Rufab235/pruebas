@;=                                                          	     	=
@;=== candy1_init.s: rutinas para inicializar la matriz de juego	  ===
@;=                                                           	    	=
@;=== Programador tarea 1A: ruben.falcon@estudiants.urv.cat				  ===
@;=== Programador tarea 1B: ruben.falcon@estudiants.urv.cat			  ===
@;=                                                       	        	=



.include "candy1_incl.i"



@;-- .bss. variables (globales) no inicializadas ---
.bss
		.align 2
@; matrices de recombinación: matrices de soporte para generar una nueva matriz
@;	de juego recombinando los elementos de la matriz original.
	mat_recomb1:	.space ROWS*COLUMNS
	mat_recomb2:	.space ROWS*COLUMNS
	



@;-- .text. código de las rutinas ---
.text	
		.align 2
		.arm



@;TAREA 1A;
@; inicializa_matriz(*matriz, num_mapa): rutina para inicializar la matriz de
@;	juego, primero cargando el mapa de configuración indicado por parámetro (a
@;	obtener de la variable global mapas[][][]) y después cargando las posiciones
@;	libres (valor 0) o las posiciones de gelatina (valores 8 o 16) con valores
@;	aleatorios entre 1 y 6 (+8 o +16, para gelatinas)
@;	Restricciones:
@;		* para obtener elementos de forma aleatoria se invocará la rutina
@;			mod_random()
@;		* para evitar generar secuencias se invocará la rutina
@;			cuenta_repeticiones() (ver fichero 'candy1_move.s')
@;	Parámetros:
@;		R0 = dirección base de la matriz de juego
@;		R1 = número de mapa de configuración

@;  VARIABLE
@; r1 mapa actual (entregat per valor)/poscion y en cuenta repeticiones
@; r2 poscion x en cuenta repeticiones
@; r3 moviento cuenta en y o x (2,3)
@; r4 index matriu
@; r9 guardar matriu
@; r10 guardar 
	.global inicializa_matriz
inicializa_matriz:
		push {r0-r12, lr}				@;guardar registros utilizados + link registe
		mov r9, r0		@; backup de r0
		ldr r4, =mapas
		mov r6, #ROWS*COLUMNS
		mov r8, #COLUMNS
		mla r5, r6, r1, r4 		@; r5 = @mapa[0][0]
		mov r1, #0		@; iniciem index y
		mov r2, #0		@; iniciem index 'x'
		mov r7, #2		@; primer valor a contar en cuenta repeticiones
		.Lfor:
			cmp r1, #ROWS	@; y < final
			bhs .Lendfor
			mla r10, r1, r8, r2  @; r10 =(i*COLUMS)+1
			ldrb r11, [r5, r10] 	@; carregar valor
			strb r11, [r9, r10] @; carreguem valor
			tst r11, #0x07				
			bne .LendifY	@; si el primer 3 bits son 0, posar valor random
			.Lif:
			
				mov r0, #6
				bl mod_random	@; Valor entre 0 y n-1
				add r0, #1	@; Valor entre 1 y n
				orr r0, r11
				strb r0, [r9, r10]
				

			.Lendif:
			.LifX:
				
				cmp r2, #2	@; x<=2 no pot tenir 3 sequüencies
				bls .LifY
				mov r0, r9	@; Tornem la matriu modificada
				mov r3, #2	@; 
				bl cuenta_repeticiones @; r0-matriu, r1- posicio y, r2-posicio x, r3- oest(2) o nord(3) 
				cmp r0, #3
				bhs .Lif
				
			.LendifX:
			.LifY:
				cmp r1, #2
				bls .LendifY
				mov r0, r9	@; Tornem la matriu modificada
				mov r3, #3
				bl cuenta_repeticiones @; r0-matriu, r1- posicio y, r2-posicio x, r3- oest(2) o nord(3) 
				cmp r0, #3
				bhs .Lif
				
			.LendifY:
			add r2, #1		@; x++
			cmp r2, #COLUMNS	
			bne	.Lfor		@; si(x==colums) x=0, y++
			mov r2, #0
			add r1, #1
			b .Lfor	
			
		.Lendfor:
		pop {r0-r12, pc}				@;recuperar registros y retornar al invocador


@;TAREA 1B;
@; recombina_elementos(*matriz): rutina para generar una nueva matriz de juego
@;	mediante la reubicación de los elementos de la matriz original, para crear
@;	nuevas jugadas.
@;	Inicialmente se copiará la matriz original en mat_recomb1[][], para luego ir
@;	escogiendo elementos de forma aleatoria y colocándolos en mat_recomb2[][],
@;	conservando las marcas de gelatina.
@;	Restricciones:
@;		* para obtener elementos de forma aleatoria se invocará la rutina
@;			mod_random()
@;		* para evitar generar secuencias se invocará la rutina
@;			cuenta_repeticiones() (ver fichero 'candy1_move.s')
@;		* para determinar si existen combinaciones en la nueva matriz, se
@;			invocará la rutina hay_combinacion() (ver fichero 'candy1_comb.s')
@;		* se puede asumir que siempre existirá una recombinación sin secuencias
@;			y con posibles combinaciones
@;	Parámetros:
@;		R0 = dirección base de la matriz de juego
	.global recombina_elementos
@;TAREA 1B;
@; recombina_elementos(*matriz): genera una nueva matriz reubicando elementos.
@; Parámetros: R0 = dirección base de la matriz de juego

recombina_elementos:

	push {r4-r12, lr}			@; Protegemos de r4 en adelante para no perder índices
	mov r12, r0					@; r12 = backup de la matriz original (R0)
	mov r9, #COLUMNS			@; Constante para mla
	ldr r10, =mat_recomb1
	ldr r11, =mat_recomb2

	.Lreinicio_total:				@; Etiqueta para reintentar si hay bloqueo
			@; --- PARTE 1: Preparar mat_recomb1 (Solo tipos básicos 1-6 o ceros) ---
			mov r1, #0					@; contador y
		.LforY:
			cmp r1, #ROWS
			bhs .LendforY
			mov r2, #0					@; contador x
			.LforX:
				cmp r2, #COLUMNS
				bhs .LnextY
				mla r3, r1, r9, r2
				ldrb r8, [r12, r3] 			@; Leer original
				
				@; Paso 1: Bloques (7), huecos (15) y vacíos (0, 8, 16) pasan a ser 0
				and r7, r8, #0x07			@; Extraer tipo (bits 0-2)
				cmp r7, #0					@; ¿Es vacío/gelatina vacía?
				beq .Lpon_cero
				cmp r7, #7					@; ¿Es bloque sólido o hueco (bits 0-2 son 111)?
				beq .Lpon_cero
				
				strb r7, [r10, r3]			@; Es un caramelo (1-6): guardar básico en recomb1
				b .LcontX
				.Lpon_cero:
					mov r6, #0
					strb r6, [r10, r3]
				.LcontX:
					add r2, #1
					b .LforX
				.LnextY:
					add r1, #1
					b .LforY
		.LendforY:

			@; --- PARTE 2: Preparar mat_recomb2 (Estructura fija y gelatinas) ---
			mov r6, #0
		.Lprepara2:
			cmp r6, #ROWS*COLUMNS
			bhs .Lreubicacion
			ldrb r7, [r12, r6]
			strb r7, [r11, r6]			@; Copiamos todo para tener bloques y gelatinas
			add r6, #1
			b .Lprepara2

			@; --- PARTE 3: Recorrer y reubicar aleatoriamente ---
		.Lreubicacion:
			mov r1, #0 					@; y
		.LforY2:
			cmp r1, #ROWS
			bhs .Lfinalizar
			mov r2, #0 					@; x
		.LforX2:
			cmp r2, #COLUMNS
			bhs .LnextY2
			mla r5, r1, r9, r2
			ldrb r7, [r12, r5]			@; Valor original
			and r6, r7, #0x07
			
			@; Paso 4: Si es 0, 7, 8, 15 o 16, ignorar posición
			cmp r6, #0
			beq .Lskip
			cmp r6, #7
			beq .Lskip
			
			mov r4, #0					@; Contador de intentos para evitar bucle infinito
		.Lwhile_busca:
			add r4, #1
			cmp r4, #200				@; Si falla mucho, reiniciar todo el proceso
			bhs .Lreinicio_total

			mov r0, #ROWS
			bl mod_random
			mov r7, r0					@; Fila aleatoria en R7 (R4 está ocupado)
			mov r0, #COLUMNS
			bl mod_random
			mla r8, r7, r9, r0			@; r8 = índice aleatorio lineal
			
			ldrb r6, [r10, r8]			@; Leer de mat_recomb1
			cmp r6, #0 					@; ¿Está vacía la posición origen?
			beq .Lwhile_busca			@; Sí, buscar otra
			
			@; Probar el caramelo en mat_recomb2 fusionando con gelatina original
			ldrb r0, [r12, r5]			@; Valor original en matriz juego
			and r0, #0x18				@; Conservar solo bits de gelatina (8, 16)
			orr r0, r6					@; Mezclar con el nuevo caramelo básico
			strb r0, [r11, r5]  		@; Guardar en mat_recomb2
			
			@; Comprobar secuencias
			mov r3, #2					@; Oeste
			mov r0, r11					@; Pasar mat_recomb2
			bl cuenta_repeticiones
			cmp r0, #3
			bhs .Lwhile_busca
			
			mov r3, #3					@; Norte
			mov r0, r11	
			bl cuenta_repeticiones
			cmp r0, #3
			bhs .Lwhile_busca
			
			@; Éxito: quitar caramelo de mat_recomb1 para no reutilizarlo
			mov r0, #0
			strb r0, [r10, r8] 

		.Lskip:
			add r2, #1
			b .LforX2
		.LnextY2:
			add r1, #1
			b .LforY2

	.Lfinalizar:
			@; PASO 8: Copiar el resultado final a la matriz original
			mov r6, #0
	.Lcopy_loop:
		cmp r6, #ROWS*COLUMNS
		bhs .Lexit
		ldrb r7, [r11, r6]
		strb r7, [r12, r6]
		add r6, #1
		b .Lcopy_loop

	.Lexit:
	pop {r4-r12, pc}

push {r0-r12, lr}
	
	mov r9, #COLUMNS	@; R9 = COLUMNS
	ldr r10, =mat_recomb1	@; R10 = @mat_recomb1 (Reserva de elementos base)
	ldr r11, =mat_recomb2	@; R11 = @mat_recomb2 (Matriz destino)
	mov r12, r0				@; R12 = @matriz de juego (R0)
	
.Lstart_recombine:
    mov r7, #0              @; R7 = Contador de fallos (para detectar bucle infinito)

@; 1. Copiar Matriz de Juego (R12) a mat_recomb1 (R10) (Solo códigos base 1-6)
@; 2. Copiar Matriz de Juego (R12) a mat_recomb2 (R11) (Propiedades fijas y gelatinas)
@;    Se integran en el mismo bucle.
	mov r1, #0	@; R1 = contador Y
	.LforY_init:
		cmp r1, #ROWS
		bhs .LendforY_init
		mov r2, #0	@; R2 = contador X
		.LforX_init:
			cmp r2, r9
			bhs .LendforX_init
			mla r3, r1, r9, r2	@; R3 = offset
			ldrb r8, [r12, r3] 	@; R8 = mat_orig[Y][X] (Valor completo)
			
			and r4, r8, #0x07	@; R4 = Código base (1-7)
			
			@; (Paso 1): Preparar R10 (mat_recomb1)
			cmp r4, #0x07		@; Bloque sólido (7)
			beq .Lset_zero_r10
			cmp r4, #0x00		@; Hueco (15), Gelatina vacía (8, 16) o Vacío (0)
			beq .Lset_zero_r10
			
			@; Es Caramelo móvil (1-6)
			strb r4, [r10, r3]	@; R10[offset] = Código base (1-6)
			b .Lcopy_r11
			
		.Lset_zero_r10:
			mov r4, #0
			strb r4, [r10, r3]	@; R10[offset] = 0
			
		.Lcopy_r11:
			@; (Paso 2): Preparar R11 (mat_recomb2)
			strb r8, [r11, r3]	@; R11[offset] = Valor completo (Incluye gelatina, bloques, etc.)
			
			add r2, #1
			b .LforX_init
		.LendforX_init:
		add r1, #1
		b .LforY_init
	.LendforY_init:	@; Fin de la inicialización (Pasos 1 y 2)

@; 3. Recorrer linealmente las posiciones de la matriz de juego (implícito)
@; 4. Si la posición es fija o vacía (0, 8, 16, 7, 15), ignorar
@; 5. Seleccionar una posición aleatoria de mat_recomb1 (valor != 0)
@; 6. Copiar a R11 y comprobar secuencias (reintentar si hay secuencia)
@; 7. Fusionar gelatina y fijar R10[origen] a cero
	
	mov r1, #0 	@; R1 = contador Y (destino)
	.LforY_assign:
		cmp r1, #ROWS
		bhs .LendforY_assign
		mov r2, #0 @; R2 = contador X (destino)
		.LforX_assign:
			cmp r2, r9
			bhs .LendforX_assign
			mla r5, r1, r9, r2	@; R5 = offset destino (Y*COLUMNS + X)
			
			ldrb r7, [r12, r5]	@; R7 = mat_orig[Y][X] (para verificar si es móvil)
			and r6, r7, #0x07	@; R6 = Código base
			
			cmp r6, #0x07		@; Bloque sólido (7)
			beq .Lnext_position
			cmp r6, #0x00		@; Hueco (15), Gelatina Vacía (8, 16) o Vacío (0)
			beq .Lnext_position
			
			@; Posición móvil (Caramelo 1-6) - PASO 5, 6 y 7
			mov r4, #0          @; R4 = Contador de reintentos
			
			.Lwhile_assign:
				add r4, #1
                cmp r4, #100    @; Si falla 100 veces, reinicia todo
                bhi .Lreset_all 

				@; PASO 5: Seleccionar posición aleatoria en R10 (mat_recomb1) con valor != 0
				mov r0, #ROWS
				bl mod_random		@; R0 = Random Y (0-ROWS-1)
				mov r6, r0
				mov r0, #COLUMNS
				bl mod_random		@; R0 = Random X (0-COLUMNS-1)
				mla r3, r9, r6, r0	@; R3 = offset origen
				
				ldrb r8, [r10, r3]	@; R8 = Código base del elemento origen
				cmp r8, #0x00
				beq .Lwhile_assign	@; Si R10[origen] == 0, buscar otra posición
				
				@; R8 es el elemento que vamos a asignar
				
				@; PASO 6: Comprobar Secuencias
				@; Asignar temporalmente R8 (elemento) a R11[destino]
				ldrb r0, [r11, r5]	@; R0 = Gelatina/Bloque de R11 (destino)
				and r0, #0xF8		@; Aislar solo Gelatina
				orr r0, r8			@; R0 = Elemento + Gelatina (Asignación temporal)
				strb r0, [r11, r5]
				
				@; Comprobar Horizontal (Oeste)
				mov r0, r11			@; @mat_recomb2
				mov r1, r1			@; Fila Y
				mov r2, r2			@; Columna X
				mov r3, #2			@; Oeste (2)
				bl cuenta_repeticiones
				cmp r0, #3
				bhs .Lwhile_assign	@; Si cuenta >= 3, rehacer
				
				@; Comprobar Vertical (Norte)
				mov r0, r11
				mov r1, r1
				mov r2, r2
				mov r3, #3			@; Norte (3)
				bl cuenta_repeticiones
				cmp r0, #3
				bhs .Lwhile_assign	@; Si cuenta >= 3, rehacer
				
			@; PASO 7: Éxito
				mov r0, #0
				strb r0, [r10, r3]	@; R10[origen] = 0 (Evitar reutilización)
				
			.Lnext_position:
			add r2, #1
			b .LforX_assign
		.LendforX_assign:
		add r1, #1
		b .LforY_assign
	.LendforY_assign:

    @; Comprobación de combinaciones (OBLIGATORIO)
    mov r0, r12         @; R12 ya fue actualizado en el paso 8
    bl hay_combinacion
    cmp r0, #0
    beq .Lreset_all     @; Si no hay combinación (0), reiniciar todo

@; 8. Copiar mat_recomb2 (R11) sobre la matriz de juego (R12/R0)
	mov r1, #0
	.LforY_copy:
		cmp r1, #ROWS
		bhs .LendforY_copy
		mov r2, #0
		.LforX_copy:
			cmp r2, #COLUMNS
			bhs .LendforX_copy
			mla r4, r1, r9, r2
			ldrb r7, [r11, r4]
			strb r7, [r12, r4]
			add r2, #1
			b .LforX_copy
		.LendforX_copy:
		add r1, #1
		b .LforY_copy
	.LendforY_copy:
	pop {r0-r12, pc}

	.Lreset_all:
    add r7, #1          @; Incrementa contador de fallos
    cmp r7, #10         @; Si ha fallado 10 veces (ajustable), asumir bucle infinito
    blt .Lstart_recombine @; Reiniciar todo el proceso (PASO 1)
    
    @; Si llega aquí, significa que hay un fallo crítico y no se puede salir del bucle.
    @; Por la restricción de que "siempre existirá una posible reordenación",
    @; el control de bucle se encarga de este reinicio.
    b .Lstart_recombine @; En un escenario de producción, este salto sería peligroso,
                        @; pero cumple con el requisito de reiniciar.


@;:::RUTINAS DE SOPORTE:::



@; mod_random(n): rutina para obtener un número aleatorio entre 0 y n-1,
@;	utilizando la rutina random()
@;	Restricciones:
@;		* el parámetro n tiene que ser un natural entre 2 y 255, de otro modo,
@;		  la rutina lo ajustará automáticamente a estos valores mínimo y máximo
@;	Parámetros:
@;		R0 = el rango del número aleatorio (n)
@;	Resultado:
@;		R0 = el número aleatorio dentro del rango especificado (0..n-1)
	.global mod_random
mod_random:
		push {r2-r4, lr}
		
		cmp r0, #2				@;compara el rango de entrada con el mÃ­nimo
		movlo r0, #2			@;si menor, fija el rango mÃ­nimo
		cmp r0, #0xFF			@;compara el rango de entrada con el mÃ¡ximo
		movhi r0, #0xFF			@;si mayor, fija el rango mÃ¡ximo
		sub r2, r0, #1			@;R2 = R0-1 (nÃºmero mÃ¡s alto permitido)
		mov r3, #1				@;R3 = mÃ¡scara de bits
	.Lmodran_forbits:
		mov r3, r3, lsl #1
		orr r3, #1				@;inyecta otro bit
		cmp r3, r2				@;genera una mÃ¡scara superior al rango requerido
		blo .Lmodran_forbits
		
	.Lmodran_loop:
		bl random				@;R0 = nÃºmero aleatorio de 32 bits
		and r4, r0, r3			@;filtra los bits de menos peso segÃºn mÃ¡scara
		cmp r4, r2				@;si resultado superior al permitido,
		bhi .Lmodran_loop		@; repite el proceso
		mov r0, r4
		
		pop {r2-r4, pc}



@; random(): rutina para obtener un número aleatorio de 32 bits, a partir de
@;	otro valor aleatorio almacenado en la variable global seed32 (declarada
@;	externamente)
@;	Restricciones:
@;		* el valor anterior de seed32 no puede ser 0
@;	Resultado:
@;		R0 = el nuevo valor aleatorio (también se almacena en seed32)
random:
	push {r1-r5, lr}
		
	ldr r0, =seed32				@;R0 = dirección de la variable seed32
	ldr r1, [r0]				@;R1 = valor actual de seed32
	ldr r2, =0x0019660D
	ldr r3, =0x3C6EF35F
	umull r4, r5, r1, r2
	add r4, r3					@;R5:R4 = nuevo valor aleatorio (64 bits)
	str r4, [r0]				@;guarda los 32 bits bajos en seed32
	mov r0, r5					@;devuelve los 32 bits altos como resultado
		
	pop {r1-r5, pc}	


.end
