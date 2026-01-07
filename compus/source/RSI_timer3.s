@;=                                                          	     	=
@;=== RSI_timer3.s: rutinas para desplazar el fondo 3 (imagen bitmap) ===
@;=                                                           	    	=
@;=== Programador tarea 2H: xxx.xxx@estudiants.urv.cat				  ===
@;=                                                       	        	=

.include "candy2_incl.i"


@;-- .data. variables (globales) inicializadas ---
.data
		.global update_bg3
	update_bg3:	.byte	0			@;1 -> actualizar fondo 3
		.global timer3_on
	timer3_on:	.byte	0 			@;1 -> timer3 en marcha, 0 -> apagado
	sentidBG3X:	.byte	0			@;sentido desplazamiento (0-> inc / 1-> dec)
		.align 1
		.global offsetBG3X
	offsetBG3X: .hword	0			@;desplazamiento vertical fondo 3
	divFreq3: .hword	1			@;divisor de frecuencia para timer 3
	


@;-- .text. código de las rutinas ---
.text	
		.align 2
		.arm


@;TAREA 2Hb;
@;activa_timer3(); rutina para activar el timer 3.
	.global activa_timer3
activa_timer3:
		push {lr}
		
		
		pop {pc}


@;TAREA 2Hc;
@;desactiva_timer3(); rutina para desactivar el timer 3.
	.global desactiva_timer3
desactiva_timer3:
		push {lr}
		
		
		pop {pc}



@;TAREA 2Hd;
@;rsi_timer3(); rutina de Servicio de Interrupciones del timer 3: detecta el
@;	sentido de movimiento del fondo gráfico según el valor de sentidBG3X,
@;	actualiza su posición (incrementa o decrementa) en offsetBG3X y activa
@;	una variable global update_bg3 para que la RSI de VBlank actualice la
@;	posición de dicho fondo.
	.global rsi_timer3
rsi_timer3:
		push {lr}
		
		
		pop {pc}



.end
