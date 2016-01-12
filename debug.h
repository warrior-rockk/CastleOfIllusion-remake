// ========================================================================
//  Warcom Game Engine
//  Motor para juegos plataformas 2D
//  25/02/15
//
//  Definiciones de debug
// ========================================================================

//Defines generales
//#define USE_DEBUG;										//Utilizando rutinas de debug

//Niveles Debug
#define DEBUG_ENGINE		0
#define	DEBUG_PLAYER		1 
#define	DEBUG_TILES			2
#define DEBUG_MONSTERS      3
#define DEBUG_OBJECTS       4
#define DEBUG_SOUND         5

//Colores Cajas Colision
#define DEBUG_PLAYER_COLOR  	300
#define DEBUG_MONSTER_COLOR  	5
#define DEBUG_OBJECT_COLOR  	255

//Constantes del motor
const
	//Debug		
	cCursorColor 	= 100;					//Color del cursor de debugMode
	cDebugInfoX  	= 10;					//Posicion X de la informacion de debug
	cDebugInfoY  	= 210;					//Posicion Y de la informacion de debug
	cMaxDebugInfo	= 10;					//Maximo lineas informacion de debug

End;

//variables globales
Global
	byte traceEngine 	= 1;		//flag de activacion nivel debug
	byte tracePlayer 	= 1;		//flag de activacion nivel debug
	byte traceTiles	 	= 0;		//flag de activacion nivel debug
	byte traceMonsters 	= 1;		//flag de activacion nivel debug
	byte traceObjects   = 1;		//flag de activacion nivel debug
	byte traceSound		= 1;		//flag de activacion nivel debug
end;