@;=                                                          	     	=
@;=== RSI_timer1.s: rutinas para escalar los elementos (sprites)	  ===
@;=                                                           	    	=
@;=== Programador tarea 2F: xxx.xxx@estudiants.urv.cat				  ===
@;=                                                       	        	=

.include "candy2_incl.i"


@;-- .data. variables (globales) inicializadas ---
.data
		.global timer1_on
	timer1_on:	.byte	0 			@;1 -> timer1 en marcha, 0 -> apagado
		.align 1
	divFreq1: .hword	1			@;divisor de frecuencia para timer 1


@;-- .bss. variables (globales) no inicializadas ---
.bss
	escSen: .space	1				@;sentido de escalado (0-> dec, 1-> inc)
	escNum: .space	1				@;número de variaciones del factor
		.align 1
	escFac: .space	2				@;factor actual de escalado


@;-- .text. código de las rutinas ---
.text	
		.align 2
		.arm


@;TAREA 2Fb;
@;activa_timer1(init); rutina para activar el timer 1, inicializando el sentido
@;	de escalado según el parámetro init.
@;	Parámetros:
@;		R0 = init;  valor a trasladar a la variable global escSen (0/1)
	.global activa_timer1
activa_timer1:
		push {lr}
		
		
		pop {pc}


@;TAREA 2Fc;
@;desactiva_timer1(); rutina para desactivar el timer 1.
	.global desactiva_timer1
desactiva_timer1:
		push {lr}
		
		
		pop {pc}



@;TAREA 2Fd;
@;rsi_timer1(); rutina de Servicio de Interrupciones del timer 1: incrementa el
@;	número de escalados y, si es inferior a 32, actualiza factor de escalado
@;	actual según el código de la variable global escSen; cuando llega al máximo
@;	desactiva el timer1.
	.global rsi_timer1
rsi_timer1:
		push {lr}
		
		
		pop {pc}



.end
