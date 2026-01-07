/*------------------------------------------------------------------------------

	$Id: candy2_incl.h $

	Definiciones externas en C para la versión 2 del juego (modo gráfico)

------------------------------------------------------------------------------*/

#include "candy1_incl.h"

// Píxeles por casilla del tablero de juego
#define MTWIDTH	(256/COLUMNS)			// núm. píxeles de ancho (e.g. 32)
#define MTHEIGHT   (192/ROWS)			// núm. píxeles de alto (e.g. 32)

// Dimensiones de las metabaldosas:
#define MTROWS	(MTHEIGHT/8)			// núm. filas metabaldosa (e.g. 4)
#define MTCOLS	(MTWIDTH/8)				// núm. columnas metabaldosa (e.g. 4)
#define MTOTAL	MTROWS*MTCOLS			// núm. total de baldosas simples


// esctructura de datos relativos a un elemento
typedef struct
{
	short	ii;				// número de interrupciones pendientes (0..32)
							// o (-1) si está inactivo
	short	px;				// posición x (0..256)
	short	py;				// posición y (-32..192)
	short	vx;				// velocidad x
	short	vy;				// velocidad y
} elemento;

// esctructura de datos relativos a una gelatina
typedef struct
{
	char			ii;		// número de interrupciones pendientes (0..10)
							// o (-1) si está inactivo
	unsigned char	im;		// índice de metabaldosa (0..7/8..15)
} gelatina;



	// candy2_supo.s //
extern unsigned char busca_elemento(unsigned char fil, unsigned char col);
extern unsigned char crea_elemento(unsigned char tipo, char fil,
										unsigned char col, unsigned char prio);
extern unsigned char elimina_elemento(unsigned char fil, unsigned char col);
extern unsigned char activa_elemento(unsigned char fil, unsigned char col,
											unsigned char f2, unsigned char c2);
extern unsigned char activa_escalado(unsigned char fil, unsigned char col);
extern unsigned char desactiva_escalado(unsigned char fil, unsigned char col);
extern void fija_metabaldosa(u16 *mapbase, unsigned char fil, unsigned char col,
														unsigned char imeta);
//extern void elimina_gelatina(u16 *mapbase, unsigned char fil, unsigned char col);


	// candy2_graf.c //
//extern unsigned char n_sprites;
//extern elemento vect_elem[ROWS*COLUMNS];
//extern gelatina mat_gel[ROWS][COLUMNS];
extern void init_grafA(void);							// 2Aa,2Ba,2Ca,2Da
extern void genera_sprites(char matriz[][COLUMNS]);		// 2Ab
extern void genera_mapa1(char matriz[][COLUMNS]);		// 2Cb
extern void genera_mapa2(char matriz[][COLUMNS]);		// 2Bb
//extern void ajusta_imagen3(unsigned char ibg);		// 2Db


	// RSI_timer0.s //
//extern unsigned char update_spr;
extern unsigned char timer0_on;
extern void rsi_vblank();								// 2Ea,2Ga,2Ha
extern void activa_timer0(unsigned char init);			// 2Eb
//extern void desactiva_timer0();						// 2Ec
extern void rsi_timer0();								// 2Ed


	// RSI_timer1.s //
extern unsigned char timer1_on;
extern void activa_timer1(unsigned char init);			// 2Fb
//extern void desactiva_timer1();						// 2Fc
extern void rsi_timer1();								// 2Fd


	// RSI_timer2.s //
//extern unsigned char update_gel;
extern unsigned char timer2_on;
extern void activa_timer2();							// 2Gb
extern void desactiva_timer2();							// 2Gc
extern void rsi_timer2();								// 2Gd


	// RSI_timer3.s //
//extern unsigned char update_bg3;
extern unsigned char timer3_on;
extern void activa_timer3();							// 2Hb
extern void desactiva_timer3();							// 2Hc
extern void rsi_timer3();								// 2Hd
