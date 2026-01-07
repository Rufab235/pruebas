@;=                                                               		=
@;== candy2_supo.s: rutinas de soporte a la práctia CandyNDS (fase 2) ===
@;=                                                         			=
@;=== Analista-programador: santiago.romani@urv.cat			 		  ===
@;=== Programador tarea 2Ja: xxx.xxx@estudiants.urv.cat				  ===
@;=== Programador tarea 2Jb: yyy.yyy@estudiants.urv.cat				  ===
@;=== Programador tarea 2Jc: zzz.zzz@estudiants.urv.cat				  ===
@;=                                                         	      	=

.include "candy2_incl.i"


@;-- .text. Program code ---
.text	
		.align 2
		.arm


@;busca_elemento(unsigned char fil, unsigned char col);
@;	busca un elemento dentro del vector de elementos, a partir de las
@;	coordenadas de fila y columna del elemento, que se tienen que contrastar
@;	con las coordenadas (px, py) de cada sprite;
@;	devuelve el índice del elemento, o ROWS*COLUMNS si no lo ha encontrado.
@;	Parámetros:
@;		R0 :	fila del elemento
@;		R1 :	columna del elemento
@;	Resultado:
@;		R0 :	índice del elemento encontrado, o ROWS*COLUMNS 
	.global busca_elemento
busca_elemento:
		push {r2-r6, lr}
		
		ldr r6, =n_sprites
		ldrb r6, [r6]			@;R6 = número de sprites creados
		mov r2, r1, lsl #5		@;R2 = px (columna * 32)
		mov r3, r0, lsl #5		@;R3 = py (fila * 32)
		mov r0, #0				@;R0 es índice de elementos
		ldr r4, =vect_elem		@;R4 es dirección base del vector elementos
	.Lbe_bucle:
		ldsh r5, [r4, #ELE_II]
		cmp r5, #-1
		beq .Lbe_cont			@;continua si vect_elem[i].ii == -1
		ldsh r5, [r4, #ELE_PX]
		cmp r5, r2
		bne .Lbe_cont			@;continua si vect_elem[i].px != posición px
		ldsh r5, [r4, #ELE_PY]
		cmp r5, r3
		beq .Lbe_finbucle		@;salir si vect_elem[i].py == posición py
		
	.Lbe_cont:
		add r4, #ELE_TAM
		add r0, #1				@;repetir para todos los sprites creados
		cmp r0, r6
		blo .Lbe_bucle
		mov r0, #ROWS*COLUMNS	@;código de no encontrado (>= n_sprites)
		
	.Lbe_finbucle:
		
		pop {r2-r6, pc}
	
	
@;crea_elemento(unsigned char tipo, char fil, unsigned char col,
@;															unsigned char prio);
@;	crea un nuevo elemento de juego, buscando un sprite libre (ii = -1) y
@;	le asigna el índice de baldosa correspondiente al tipo de elemento que
@;	se pasa por parámetro, además de la posición inicial según la fila y
@;	columna en la matriz de juego; para los elementos nuevos que deben aparecer
@;	por encima del tablero, la fila inicial será -1, motivo por el cual la
@;	declaración del parametro 'fil' es 'char' y no 'unsigned char';
@;	devuelve como resultado el índice del sprite/elemento que se ha reservado,
@;	o bien el total de posiciones del tablero de juego (ROWS*COLUMNS)
@;	si no ha encontrado ninguno libre.
@;	Parámetros:
@;		R0 :	tipo de elemento
@;		R1 :	fila del elemento
@;		R2 :	columna del elemento
@;		R3 :	prioridad del elemento
@;	Resultado:
@;		R0 :	índice del elemento encontrado, o ROWS*COLUMNS 
	.global crea_elemento
crea_elemento:
		push {r1-r6, lr}
		
@;	Tarea 2Ja:
		
	@;	unsigned char i = 0;
		
	@;	while ((i < ROWS*COLUMNS) && (vect_elem[i].ii != -1))
	@;		i++;
	@;	if (i < ROWS*COLUMNS)		// si lo ha encontrado
	@;	{							// inicializa sus campos principales
	@;		SPR_crea_sprite(i, 0, 2, 'indice metabaldosa');
	@;		SPR_mueve_sprite(i, vect_elem[i].px, vect_elem[i].py);
	@;		SPR_fija_prioridad(i, prio);
	@;		SPR_muestra_sprite(i);
	@;	}
		mov r4, r0	@; back de tipo de elemento
		mov r0, #0	@;contador/ se necesita para las funciones
		ldr r5, =vect_elem @;direccion base de memoria de elementos
		.bucle:
			ldsh r6, [r5, #ELE_II] @;candy2_incli.i
			cmp r6, #-1
			beq bucle2
			add r5, #ELE_TAM	@;sumar tamaño de vector para pasar al siguiente 
			add r0, #1
			cmp r0, #ROWS*COLUMNS
			blo .bucle
			b .LfiBucle

				bucle2:
				mov r6, #0
				strh r6, [r5, #ELE_II]
				mov r6, r1, lsl #5
				strh r6, [r5, #ELE_PY]		@; pixeles x 32 bits
				mov r6, r2, lsl #5		
				strh r6, [r5, #ELE_PX]
				
				@;SPR_crea_sprite
				sub r6, r4, #1 @; tipo de elemento - 1
				mov r4, #MTOTAL @; núm. total de baldosas simples, no necesitamos r4 porque ya sale del bucle
				mul r3, r4, r6   	@;indice metabaldosa
				mov r1, #0
				mov r2, #2
				bl SPR_crea_sprite
				@;SPR_mueve_sprite
				ldsh r1, [r5, #ELE_PX]
				ldsh r2, [r5, #ELE_PY]
				bl SPR_mueve_sprite
				@;SPR_fija_prioridad(i, prio);
				mov r1, #1
				bl SPR_fija_prioridad
				@;SPR_muestra_sprite(i);
				bl SPR_muestra_sprite
				
		.LfiBucle:
		
		pop {r1-r6,pc}



@;elimina_elemento(unsigned char fil, unsigned char col);
@;	elimina un elemento de juego, a partir de sus coordenadas fila y columna
@;	actuales; si se encuentra dicho elemento, se libera la posición del vector
@;	y se oculta el sprite asociado;
@;	devuelve el índice del elemento eliminado, o bien el total de posiciones
@;	del tablero de juego (ROWS*COLUMNS) si no lo ha encontrado.
@;	Parámetros:
@;		R0 :	fila del elemento
@;		R1 :	columna del elemento
@;	Resultado:
@;		R0 :	índice del elemento encontrado, o ROWS*COLUMNS
	.global elimina_elemento
elimina_elemento:
		push {r1, r3-r4, lr}
		
	@;	unsigned char i = busca_elemento(fil, col);
		bl busca_elemento
		
	@;	if (i < ROWS*COLUMNS)			// si lo ha encontrado
		cmp r0, #ROWS*COLUMNS
		beq .Lee_fin
	@;	{
	@;		vect_elem[i].ii = -1;		// libera la entrada en el vector
		ldr r4, =vect_elem
		mov r3, #ELE_TAM
		mla r4, r0, r3, r4				@;R4 = @vect_elem + i * TAMELEM;
		mov r1, #-1
		strh r1, [r4, #ELE_II]
	@;		SPR_oculta_sprite(i);		// oculta el sprite asociado
		bl SPR_oculta_sprite
	@;	}
	.Lee_fin:
		pop {r1, r3-r4, pc}



@;activa_elemento(unsigned char fil, unsigned char col,
@;											unsigned char f2, unsigned char c2);
@;	activa la animación del movimiento de un elemento/sprite a partir
@;	de sus coordenadas fila y columna actuales, así como la posición
@;	del tablero donde se tiene que mover dicho elemento;
@;	devuelve el índice del elemento activado, o bien el total de posiciones
@;	del tablero de juego (ROWS*COLUMNS) si no lo ha encontrado.
@;	Parámetros:
@;		R0 :	fila del elemento
@;		R1 :	columna del elemento
@;		R2 :	fila destino
@;		R3 :	columna destino
@;	Resultado:
@;		R0 :	índice del elemento encontrado, o ROWS*COLUMNS
	.global activa_elemento
activa_elemento:
		push {lr}
		
@;	Tarea 2Jb:
		
	@;	unsigned char i = busca_elemento(fil, col);
		
	@;	if (i < ROWS*COLUMNS)			// si lo ha encontrado
	@;	{
	@;		vect_elem[i].vx = c2 - col;	// fija la velocidad como la diferencia
	@;		vect_elem[i].vy = f2 - fil;	// de posiciones a desplazarse
	@;		vect_elem[i].ii = 32;		// activa el movimiento (32 interrups.)
	@;	}
		
		pop {pc}



@;activa_escalado(unsigned char fil, unsigned char col);
@;	activa la animación de escalado de un elemento/sprite a partir de sus
@;	sus coordenadas fila y columna actuales;
@;	devuelve el índice del elemento activado, o bien el total de posiciones
@;	del tablero (ROWS*COLUMNS) si no lo ha encontrado.
@;	Parámetros:
@;		R0 :	fila del elemento
@;		R1 :	columna del elemento
@;	Resultado:
@;		R0 :	índice del elemento encontrado, o ROWS*COLUMNS
	.global activa_escalado
activa_escalado:
		push {r1, lr}
		
	@;	unsigned char i = busca_elemento(fil, col);
		bl busca_elemento
		
	@;	if (i < ROWS*COLUMNS)			// si lo ha encontrado
		cmp r0, #ROWS*COLUMNS
	@;	{								// activa escalado del sprite (grupo 0)
	@;		SPR_activa_rotacionEscalado(i, 0);
		movlo r1, #0
		bllo SPR_activa_rotacionEscalado
	@;	}
		
		pop {r1, pc}



@;desactiva_escalado(unsigned char fil, unsigned char col);
@;	desactiva la animación de escalado de un elemento/sprite a partir de sus
@;	coordenadas fila y columna actuales;
@;	devuelve el índice del elemento activado, o bien el total de posiciones
@;	del tablero (ROWS*COLUMNS) si no lo ha encontrado.
@;	Parámetros:
@;		R0 :	fila del elemento
@;		R1 :	columna del elemento
@;	Resultado:
@;		R0 :	índice del elemento encontrado, o ROWS*COLUMNS
	.global desactiva_escalado
desactiva_escalado:
		push {lr}
		
	@;	unsigned char i = busca_elemento(fil, col);
		bl busca_elemento
		
	@;	if (i < ROWS*COLUMNS)			// si lo ha encontrado
		cmp r0, #ROWS*COLUMNS
	@;	{								// desactiva escalado del sprite
	@;		SPR_desactiva_rotacionEscalado(i);
		bllo SPR_desactiva_rotacionEscalado
	@;	}
		
		pop {pc}



@;fija_metabaldosa(u16 *mapbase, unsigned char fil, unsigned char col,
@;														unsigned char imeta);
@;	guarda, en el mapa de baldosas cuya dirección base se pasa por
@;	parámetro, los índices de las baldosas correspondientes a una metabaldosa
@;	de MTROWS x MTCOLS (MTWIDTH x MTHEIGHT píxeles), a partir de la posición
@;	(fil, col) del espacio de juego y del índice de la metabaldosa.
@;	Parámetros:
@;		R0 :	dirección base del mapa de baldosas (mapbase)
@;		R1 :	fila del elemento
@;		R2 :	columna del elemento
@;		R3 :	índice de metabaldosa (imeta)
	.global fija_metabaldosa
fija_metabaldosa:
		push {lr}
		
@;	tarea 2Jc:
		
	@;	i_baldosa = imeta*MTOTAL;
	@;	for (df = 0; df < MTROWS; df++)
	@;	{								// dir. base en mapa de fila actual
	@;		base_fila = mapbase + (fil*MTROWS + df)*32;
	@;		for (dc = 0; dc < MTCOLS; dc++)
	@;		{
	@;			*(base_fila + col*MTCOLS + dc) = i_baldosa;
	@;			i_baldosa++;	
	@;		}
	@;	}
		
		pop {pc}


@;elimina_gelatina(u16 * mapaddr, unsigned char fil, unsigned char col);
@;	elimina una gelatina del tablero de juego, a partir de la dirección base
@;	del mapa de baldosas que contiene las gelatinas y de las coordenadas
@;	de fila y columna de la gelatina a eliminar.
@;	Parámetros:
@;		R0 :	dirección base del mapa de baldosas (mapbase) para gelatinas
@;		R1 :	fila del elemento
@;		R2 :	columna del elemento
	.global elimina_gelatina
elimina_gelatina:
		push {r3-r5, lr}
		
		ldr r4, =mat_gel
		mov r3, #COLUMNS
		mla r5, r1, r3, r2
		mov r3, #GEL_TAM
		mla r4, r5, r3, r4				@;R4 += (fil * COLUMNS + col) * GEL_TAM;
	@;	imeta = mat_gel[fil][col].im;
		ldrb r3, [r4, #GEL_IM]
	@;	if (imeta > 8)
	@;	{								// si código animación gelatina doble
		cmp r3, #8
		blo .Leligel_else
	@;		imeta -= 8;					// pasar a animación gelatina simple
		sub r3, #8
	@;		mat_gel[fil][col].im = imeta
		strb r3, [r4, #GEL_IM]
		b .Leligel_finif
	@;	}
	@;	else
	@;	{								// si código animación gelatina simple
	.Leligel_else:
	@;		mat_gel[fil][col].ii = -1	// desactiva gelatina
		mov r5, #-1
		strb r5, [r4, #GEL_II]
	@;		imeta = 19;					// índice metabaldosa transparente
		mov r3, #19
	@;	}
	.Leligel_finif:
		bl fija_metabaldosa			@;//fija_metabaldosa(mapbase,fil,col,imeta);
		
		pop {r3-r5, pc}

