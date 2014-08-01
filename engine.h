// ========================================================================
//  Warcom Game Engine
//  Motor para juegos plataformas 2D
//  21/07/14
//
//  Definiciones globales del engine
// ========================================================================

//Defines del engine
#define WGE_ENGINE							//Utilizando WGE engine
#define bit_cmp(a,b) 	( (a & b) == b )	//Funcion comparar bit
#define MAXOBJPARAMS   	9					//Numero de parametros objetos

//Numero de tiles fuera de la pantalla. 
//Si la resolucion no es multiplo del tamaño del tile,es aconsejable usar 
//al menos 2 tiles OffScreen. Si es multiplo, con 1 es suficiente
#define TILESXOFFSCREEN 1					//Tiles fuera de la pantalla en X
#define TILESYOFFSCREEN 2					//Tiles fuera de la pantalla en Y

//Defines del modo debug
#define CURSORCOLOR 	100			//Color del cursor de debugMode
#define DEBUGINFOX  	10			//Posicion X de la informacion de debug
#define DEBUGINFOY  	176			//Posicion Y de la informacion de debug
#define MAXDEBUGINFO	10			//Maximo lineas informacion de debug

//Teclas 
#define	CKUP 	  _UP 
#define	CKDOWN	  _DOWN 
#define	CKLEFT    _LEFT 
#define	CKRIGHT	  _RIGHT 
#define	CKBT1	  _ALT 
#define	CKBT2	  _SPACE

//Profundidades
#define ZPLAYER		-1		//Profundidad del player
#define ZMAP     	1  		//Profundidad del mapeado

//Direccion colision
#define COLUP		1
#define COLDOWN		2
#define COLIZQ		3
#define COLDER   	4

//Constantes del motor
const
	//Pantalla
	cNumFPS     = 60;  					//Frames por segundo
	cResX 		= 640;					//Resolucion Horizontal Pantalla
	cResY 		= 480;  				//Resolucion Vertical Pantalla
	cGameScroll = 0;    				//Numero Scroll
	cGameRegion = 1;    				//Numero Region Pantalla Juego
	cRegionX 	= 0;					//Region Horizontal Pantalla de juego (Representacion Mapeado) 
	cRegionY 	= 0;					//Region Vertical Pantalla de juego (Representacion Mapeado)
	cRegionW 	= cResX;				//Region Horizontal Pantalla de juego (Representacion Mapeado) 
	cRegionH 	= cResY;				//Region Vertical Pantalla de juego (Representacion Mapeado)	
	
	//Mapeado
	cTileSize   = 64;   				//Tamaño tiles (Ancho y alto iguales)
	cHalfTSize = cTileSize >> 1; 		//Mitad del tamaño tile (util para todo el proyecto)
End;

//Data Types

//Objeto
Type objeto         			//Tipo de Dato de objeto
	byte tipo;      			//Tipo del objeto
	int grafico;    			//Grafico
	int x0;         			//Posicion X
	int y0;         			//Posicion Y
	int angulo;     			//Angulo
	int param[MaxObjParams];	//Parametros del objeto
	byte dibujado;				//Flag de si ha sido dibujado (sectorizacion)
End;

//Punto
Type point						//Tipo de dato punto
	int x;						//Posicion X
	int y;						//Posicion Y
End;

//Path
Type path						//Tipo de dato path
	int numPuntos;				//Numero de puntos
	point* punto;	     		//Array Dinamico de puntos
end;

//Tile
Type tile
	byte tileGraph; 			//Imagen del tile
	byte tileCode;      		//Codigo del tile	
end;

//Variables Globales
Global
	int FrameCount;				//Contador de Frames Global
	byte debugMode;				//Modo debug del engine
	struct level        		//Estructura de un nivel
		int playerX0;			//Posicion inicial X
		int playerY0;			//Posicion inicial Y
		int numObjects; 		//Numero objetos
		int numPaths;			//Numero de trackings (paths de objetos)
		int numTiles;       	//Numero de tiles que componen el mapa del nivel
		int numTilesX;      	//Tamaño horizontal en tiles del mapa 
		int numTilesY;			//Tamaño vertical en tiles del mapa
	End;	
	objeto* objetos;			//Array Dinamico de objetos
	path* paths;				//Array Dinamico de paths
	tile** tileMap;  	        //Matriz Dinamica del mapa de tiles del nivel
	idPlayer; 					//Identificador del proceso del jugador
End;

//Variables locales
Local
	float vX		= 0;     	//Velocidad X
	float vY		= 0;     	//Velocidad Y
	float fX		= 0;		//Posicion x coma flotante
	float fY		= 0;		//Posicion y coma flotante
	float alto		= 0;   		//Altura en pixeles del proceso
	float ancho		= 0;   		//Ancho en pixeles del proceso
	int   estado 	= 0;   		//Estado de la entidad
End;



//Includes del engine
include "engine.prg";