@;=                                                               		=
@;=== candy1_comb.s: rutinas para detectar y sugerir combinaciones    ===
@;=                                                               		=
@;=== Programador tarea 1G: adria.montagut@estudiants.urv.cat		  ===
@;=== Programador tarea 1H: adria.montagut@estudiants.urv.cat		  ===
@;=                                                             	 	=



.include "candy1_incl.i"



@;-- .text. código de las rutinas ---
.text	
		.align 2
		.arm



@;TAREA 1G;
@; hay_combinacion(*matriz): rutina para detectar si existe, por lo menos, una
@;	combinación entre dos elementos (diferentes) consecutivos que provoquen
@;	una secuencia válida, incluyendo elementos con gelatinas simples y dobles.
@;	Parámetros:
@;		R0 = dirección base de la matriz de juego
@;	Resultado:
@;		R0 = 1 si hay una secuencia, 0 en otro caso
	.global hay_combinacion
	hay_combinacion:
		push {r1-r8, lr}
		
		mov r4, r0			@; r4 es l'adreça base de la matriu
		mov r6, #0			 
		mov r1, #0			@; r1 es la fila actual
		mov r0, #0			@; guardem 0 en el registre r0 per si no troba cap combinació
	.L_for1:
		mov r2, #0
	.L_for2:
		ldrb r5, [r4, r6]	@; r5=valor[i][j]
		
		tst r5, #0x07		@;comprovem si es una peça movible
		beq .L_seguent
		
		and r8, r5, #0x07	
		cmp r8, #0x07
		beq .L_seguent
		
		mov r8, #COLUMNS-1 	@; r8=ultima columna. Comprovem si podem moure
		cmp r2, r8
		beq .L_comprova_vertical
		
		add r8, r6, #1
		ldrb r7, [r4, r8] 	@; r7=peça dreta
		
		tst r7, #0x07		@;comprovem si r7 es una peça movible
		beq .L_comprova_vertical 
		
		and r8, r7, #0x07
		cmp r8, #0x07
		beq .L_comprova_vertical
		
		strb r7, [r4, r6]	@;Simulem intercanvi horizontal
		add r8, r6, #1
		strb r5, [r4, r8]
		
		bl detecta_orientacion
		
		cmp r0, #6			@;comprovem si hi ha seqüència
		movlt r0, #1
		blt .L_desfer_horiz
		
		
		add r2, #1
		bl detecta_orientacion
		sub r2, #1
		
		cmp r0, #6
		movlt r0, #1
		
	.L_desfer_horiz:
		@;Desfem la simulació d'intercanvi horizontal
		strb r5, [r4, r6] 
		add r8, r6, #1
		strb r7, [r4, r8]
		
		cmp r0, #1
		beq .L_exit
	.L_comprova_vertical:
		
		mov r8, #ROWS-1 	@; r8=ultima fila. Comprovem si podem moure
		cmp r1, r8
		beq .L_seguent
		
		add r8, r6, #COLUMNS
		ldrb r7, [r4, r8]  	@; r7=peça de sota
		
		tst r7, #0x07		@; Comprovem que sigui una peça movible
		beq .L_seguent
		
		and r8, r7, #0x07
		cmp r8, #0x07
		beq .L_seguent
		
		strb r7, [r4, r6]	@; simulem un intercanvi vertical
		add r8, r6, #COLUMNS
		strb r5, [r4, r8]
		
		bl detecta_orientacion
		
		cmp r0, #6			@; Comprovem si hi ha seqüència
		movlt r0, #1
		blt .L_desfer_vert
		
		add r1, r1, #1
		bl detecta_orientacion
		sub r1, r1, #1
		
		cmp r0, #6
		movlt r0, #1		
	.L_desfer_vert:
		@; desfem la simulació d'intercanvi vertical
		strb r5, [r4, r6]
		add r8, r6, #COLUMNS
		strb r7, [r4, r8]
		
		cmp r0, #1
		beq .L_exit
		
	.L_seguent:
		
		cmp r0, #1		@;Comprovem si hem trobat combinació
		beq .L_exit
		
		@; Avancem de columna
		add r6, #1
		add r2, #1
		cmp r2, #COLUMNS
		blo .L_for2
		
		@; Si hem arribat al final de la fila, passem a la següent
		add r1, #1
		cmp r1, #ROWS
		blo .L_for1
		
	.L_exit:
        pop {r1-r8, pc}

@;TAREA 1H;
@; sugiere_combinacion(*matriz, *psug): rutina para detectar una combinación
@;	entre dos elementos (diferentes) consecutivos que provoquen una secuencia
@;	válida, incluyendo elementos con gelatinas simples y dobles, y devolver
@;	las coordenadas de las tres posiciones de la combinación (por referencia).
@;	Restricciones:
@;		* se asume que existe por lo menos una combinación en la matriz
@;			 (se puede verificar con la rutina hay_combinacion() antes de
@;			  llamar a esta rutina)
@;		* la combinación sugerida tiene que ser escogida aleatoriamente de
@;			 entre todas las posibles, es decir, no tiene que ser siempre
@;			 la primera empezando por el principio de la matriz (o por el final)
@;		* para obtener posiciones aleatorias, se invocará la rutina mod_random()
@;			 (ver fichero 'candy1_init.s')
@;	Parámetros:
@;		R0 = dirección base de la matriz de juego
@;		R1 = dirección del vector de posiciones (unsigned char *), donde se
@;				guardarán las coordenadas (x1,y1,x2,y2,x3,y3), consecutivamente.
	.global sugiere_combinacion
sugiere_combinacion:
		push {r0-r12, lr}
        
        mov r7, r0          @; r7 = matriu
        mov r3, r1          @; r5 és el vector
        
        mov r4, #ROWS
        mov r5, #COLUMNS
        
        @; Fila aleatoria
        mov r0, r4
        bl mod_random
        mov r1, r0
        
        @; Columna aleatoria
        mov r0, r5
        bl mod_random
        mov r2, r0
		
        @; Guardem la posició inicial
        mov r10, r1
        mov r11, r2
        
	.Lfor:
        @; Càrreguem posició aleatòria
        mla r6, r1, r5, r2  @; r6 = (f * COLUMNS) + c
        ldrb r8, [r7, r6]   @; r8 = element_actual
        
        tst r8, #0x07       @; Comprovem si es una peça movible
        beq .L_next
        
        and r10, r8, #0x07
        cmp r10, #0x07
        beq .L_next
        
        and r10, r9, #0x07
		
        cmp r2, #COLUMNS-1
        beq .L_prova_vertical
        
        add r8, r8, #1
        ldrb r9, [r4, r8]
        sub r8, r8, #1
		
        tst r9, #0x07
        beq .L_prova_vertical
        
        and r11, r9, #0x07
        cmp r11, #0x07
        beq .L_prova_vertical
        
        and r11, r9, #0x07
		
        cmp r10, r11
        beq .L_next
        
		@;Guardem posició inicial
        ldrb r0, [r4, r8]
        add r8, r8, #1
        ldrb r3, [r4, r8]
        sub r8, r8, #1
		
		@; Fem intercanvi entre les peces
        strb r3, [r4, r8]
        add r8, r8, #1
        strb r0, [r4, r8]
        sub r8, r8, #1
		
        @; Comprovem (f, c)
        mov r12, #0
        bl detecta_orientacion
        cmp r0, #6
        mov r3, r0
        bne .Lnulintercanvi2
		
        @; Comprovem (f, c+1)
        add r2, #1
        mov r12, #1
        bl detecta_orientacion
        mov r3, r0
        sub r2, #1
        
	.Lnulintercanvi2:
        @; Desfem l'intercanvi
        strb r0, [r4, r8]   @; Restaurem elem_original_actual
        add r8, r8, #1
        strb r3, [r4, r8]   @; Restaurem elem_original_vei
        sub r8, r8, #1
        cmp r3, #6          @; Comprovem el c.ori guardat a r3
        bne .Lcombinacio    @; Si NO és 6, hem trobat combinació
        
	.L_prova_vertical:   
        cmp r1, #ROWS-1
        beq .L_next
		
        add r8, r8, r7
        ldrb r9, [r4, r8]
		
        tst r9, #0x07       @; Comprovem que sigui una peça movible
        beq .L_next
        
        and r11, r9, #0x07
        cmp r11, #0x07
        beq .L_next
		
        and r11, r9, #0x07
		
        @; Comprovem que siguin de diferent tipus
        cmp r10, r11
        beq .L_next
        
        @; Guardem elements originals
        sub r8, r8, r7
        ldrb r0, [r4, r8]
        add r8, r8, r7
        ldrb r3, [r4, r8]
		
        @; Intercanviem posicions
        strb r0, [r4, r8]
        sub r8, r8, r7
        strb r3, [r4, r8]
		
       
        mov r12, #2
        bl detecta_orientacion
        mov r3, r0
        cmp r0, #6
        bne .Lnulintercanvi
		

        add r1, #1
        mov r12, #3
        bl detecta_orientacion
        mov r3, r0
        sub r1, #1
        
	.Lnulintercanvi:
        strb r0, [r4, r8]
        add r8, r8, r7
        strb r3, [r4, r8]
        
        cmp r3, #6
        bne .Lcombinacio
	.L_next:
        add r2, #1          @; c++
        cmp r2, r7          @; cmp c, COLUMNS
        bne .Lfi_bucle
        
        mov r2, #0
        add r1, #1
        cmp r1, r6          @; cmp f, ROWS
        bne .Lfi_bucle
        
        mov r1, #0
        
	.Lfi_bucle:
        cmp r1, r10
        bne .Lfor 
        cmp r2, r11
        bne .Lfor
        
        b .Lfi_sugiere
        
	.Lcombinacio:
        mov r0, r5          @; Vector
        mov r4, r12			@; Posició inicial
        
        bl genera_posiciones 
        
	.Lfi_sugiere:
		
		
		pop {r0-r12,pc}




@;:::RUTINAS DE SOPORTE:::

@; genera_posiciones(vect_pos, f, c, ori, cpi): genera las posiciones de 
@;	sugerencia de combinación, a partir de la posición inicial (f,c), el código
@;	de orientación ori y el código de posición inicial cpi, dejando las
@;	coordenadas en el vector vect_pos[].
@;	Restricciones:
@;		* se asume que la posición y orientación pasadas por parámetro se
@;			corresponden con una disposición de posiciones dentro de los
@;			límites de la matriz de juego
@;	Parámetros:
@;		R0 = dirección del vector de posiciones vect_pos[]
@;		R1 = fila inicial f
@;		R2 = columna inicial c
@;		R3 = código de orientación ori:
@;				inicio de secuencia: 0 -> Este, 1 -> Sur, 2 -> Oeste, 3 -> Norte
@;				en medio de secuencia: 4 -> horizontal, 5 -> vertical
@;		R4 = código de posición inicial cpi:
@;				0 -> izquierda, 1 -> derecha, 2 -> arriba, 3 -> abajo
@;	Resultado:
@;		vector de posiciones (x1,y1,x2,y2,x3,y3), devuelto por referencia
genera_posiciones:
		push {r5,r6, lr}
		
		cmp r4, #0
		beq .Lseguentc
		
		cmp r4, #1
		beq .Lanteriorc
		
		cmp r4, #2
		beq .Lseguentf
		
		cmp r4, #3
		beq .Lanteriorf
		
	.Lseguentc:
		add r2, #1
		b .Lguardar
	.Lanteriorc:
		sub r2, #1
		b .Lguardar
	.Lseguentf:
		add r1, #1
		b .Lguardar
	.Lanteriorf:
		sub r1, #1
		
	.Lguardar:
		
		@;Guardar les coordenades de la posicio inicial al vector
		strb r2, [r0]
		add r0, #1
		strb r1, [r0]
		
		cmp r4, #0
		beq .Lini0
		
		cmp r4, #1
		beq .Lini1
		
		cmp r4, #2
		beq .Lini2
		
		cmp r4, #3
		beq .Lini3
		
	.Lini0:
		sub r2, #1 
		b .Lori
	.Lini1:
		add r2, #1
		b .Lori
	.Lini2:
		sub r1, #1
		b .Lori
	.Lini3:
		add r1, #1
	.Lori:
	
		cmp r3, #0
		bne .Lori1
		add r2, #1
		mov r5, r1
		add r6, r2, #1
		b .Lfipos
	.Lori1:
		cmp r3, #1
		bne .Lori2
		add r1, #1
		mov r6, r2
		add r5, r1, #1
		b .Lfipos
	.Lori2:
		cmp r3, #2
		bne .Lori3
		sub r2, #1
		mov r5, r1
		sub r6, r2, #1
		b .Lfipos
	.Lori3:
		cmp r3, #3
		bne .Lori4
		sub r1, #1
		mov r6, r2
		sub r5, r1, #1
		b .Lfipos
	.Lori4:
		cmp r3, #4
		bne .Lori5
		sub r2, #1
		mov r5, r1
		add r6, r2, #2
		b .Lfipos
	.Lori5:
		sub r1, #1
		mov r6, r2
		add r5, r1, #2
		b .Lfipos
	
	.Lfipos:
		@;Guardar les coordenades
		add r0, #1
		strb r2, [r0]  
		add r0, #1
		strb r1, [r0] 
		
		add r0, #1
		strb r6, [r0] 
		add r0, #1
		strb r5, [r0] 
		
		pop {r4-r10, pc}




@; detecta_orientacion(f, c, mat): devuelve el código de la primera orientación
@;	en la que detecta una secuencia de 3 o más repeticiones del elemento de la
@;	matriz situado en la posición (f,c).
@;	Restricciones:
@;		* para proporcionar aleatoriedad a la detección de orientaciones en las
@;			que se detectan secuencias, se invocará la rutina mod_random()
@;			(ver fichero 'candy1_init.s')
@;		* para detectar secuencias se invocará la rutina cuenta_repeticiones()
@;			(ver fichero 'candy1_move.s')
@;		* solo se tendrán en cuenta los 3 bits de menor peso de los códigos
@;			almacenados en las posiciones de la matriz, de modo que se ignorarán
@;			las marcas de gelatina (+8, +16)
@;	Parámetros:
@;		R1 = fila f
@;		R2 = columna c
@;		R4 = dirección base de la matriz
@;	Resultado:
@;		R0 = código de orientación;
@;				inicio de secuencia: 0 -> Este, 1 -> Sur, 2 -> Oeste, 3 -> Norte
@;				en medio de secuencia: 4 -> horizontal, 5 -> vertical
@;				sin secuencia: 6 
detecta_orientacion:
		push {r3, r5, lr}
		
		mov r5, #0				@;R5 = índice bucle de orientaciones
		mov r0, #4
		bl mod_random
		mov r3, r0				@;R3 = orientación aleatoria (0..3)
	.Ldetori_for:
		mov r0, r4
		bl cuenta_repeticiones
		cmp r0, #1
		beq .Ldetori_cont		@;no hay inicio de secuencia
		cmp r0, #3
		bhs .Ldetori_fin		@;hay inicio de secuencia
		add r3, #2
		and r3, #3				@;R3 = salta dos orientaciones (módulo 4)
		mov r0, r4
		bl cuenta_repeticiones
		add r3, #2
		and r3, #3				@;restituye orientación (módulo 4)
		cmp r0, #1
		beq .Ldetori_cont		@;no hay continuación de secuencia
		tst r3, #1
		moveq r3, #4			@;detección secuencia horizontal
		beq .Ldetori_fin
	.Ldetori_vert:
		mov r3, #5				@;detección secuencia vertical
		b .Ldetori_fin
	.Ldetori_cont:
		add r3, #1
		and r3, #3				@;R3 = siguiente orientación (módulo 4)
		add r5, #1
		cmp r5, #4
		blo .Ldetori_for		@;repetir 4 veces
		
		mov r3, #6				@;marca de no encontrada
		
	.Ldetori_fin:
		mov r0, r3				@;devuelve orientación o marca de no encontrada
		
		pop {r3, r5, pc}


@; Trozos de código para la práctica CandyNDS (fase 1)


@;=                                                               		=
@;=== candy1_init.s: rutinas para inicializar la matriz de juego	  ===
@;=                                                               		=

	

.end
