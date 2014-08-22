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
#define MAXCOLPOINTS    12

#define HILLHEIGHT		5					//Altura maxima de una pendiente (para adaptar al terreno)

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

//Direccion colision
#define COLUP		1
#define COLDOWN		2
#define COLIZQ		3
#define COLDER   	4

//Prioridades (orden ejecucion)
#define MAINPRIOR	 	2
#define PLAYERPRIOR	 	1
#define SCROLLPRIOR 	-1
#define TILEPRIOR		-2

//Profundidades
#define ZCURSOR     -3      //Profundidad del cursor de Debug
#define ZMAP2	    -2      //Profundidad del mapeado encima del personaje
#define ZPLAYER		-1		//Profundidad del player
#define ZMAP1 	     1 		//Profundidad del mapeado tras player

//Codigo del tile
//bits del 0 al 4 del mapa de tiles
//				Tipo 0: No Solido
//				Tipo 1: Solido
//				Tipo 2: Rompible
//				Tipo 3: Cinta a derechas
//				Tipo 4: Cinta a izquierdas
//				Tipo 5: Escalera
//				Tipo 6: Base de la escalera
//				Tipo 7: Dañino
//				Tipo 8: Agua
//				Tipo 9: Suelo no techo (SOLID_ON_FALL)
//				Tipo 10: Sumergido
//				Tipo 11: Sumergido/traspasable
//				Tipo 12: Detencion scroll X der
//				Tipo 13: Detencion scroll X izq
//				Tipo 14: Pendiente 135º
//				Tipo 15: Pendiente 45*
//              ..31
#define NO_SOLID      0
#define SOLID         1
#define SOLID_ON_FALL 9
#define SLOPE_135     14
#define SLOPE_45      15

//Propiedades de tile
//bit 7:Opacidad del tile.0:el tile es cuadrado 1:el tile tiene transparencia
//bit 6:Profundidad Z del tile.1:Delante del personaje.0.Detras
//bit 5:Transparencia del tile.0:el tile es opaco.1:el tile es semitransparente
#define BIT_TILE_SHAPE 		128
#define BIT_TILE_DELANTE 	64
#define BIT_TILE_ALPHA      32

//Nivel transparencia Alpha
#define TRANSLEVEL	128



//Constantes del motor
const
	//Pantalla
	cNumFPS    	 	= 60;  					//Frames por segundo
	cNumFPSDebug 	= 0;					//Frames por segundo en debug (CTRL+F)
	cResX 			= 640;					//Resolucion Horizontal Pantalla
	cResY 			= 480;  				//Resolucion Vertical Pantalla
	cGameScroll 	= 0;    				//Numero Scroll
	cGameRegion 	= 1;    				//Numero Region Pantalla Juego
	cRegionX 		= 0;					//Region Horizontal Pantalla de juego (Representacion Mapeado) 
	cRegionY 		= 0;					//Region Vertical Pantalla de juego (Representacion Mapeado)
	cRegionW 		= cResX;				//Region Horizontal Pantalla de juego (Representacion Mapeado) 
	cRegionH 		= cResY;				//Region Vertical Pantalla de juego (Representacion Mapeado)	
	
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
	int param[MAXOBJPARAMS];	//Parametros del objeto
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
	byte tileShape;      		//Propiedad del tile: Forma
	byte tileProf;				//Propiedad del tile: Profundidad
	byte tileAlpha;             //Propiedad del tile: Opacidad
	byte tileCode; 				//Codigo del tile
end;

//Variables Globales
Global
	//engine
	int FrameCount;				//Contador de Frames Global
	int maxFPS;					//FPS Maximo
	int minFPS; 				//FPS Mínimo
	int gTileSize = cTileSize; 
	//debug
	byte debugMode;				//Modo debug del engine
	//nivel y mapeado
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
	byte mapUsesAlpha;				//Bit que indica que el mapa usa propiedad alpha (relentiza la carga)
	//jugador
	int idPlayer;				//Identificador del proceso del jugador
	//Fisicas
	float gravity 	= 0.3;		//Aceleracion gravedad
	float friction 	= 0.9;		//Friccion
	//Borrar
	int mapBox; 
	int mapTriangle135;
	int mapTriangle45;
End;

//Variables locales
//TODO: alto y ancho no deberian ser float!!
Local
	float vX			= 0;     	//Velocidad X
	float vY			= 0;     	//Velocidad Y
	float fX			= 0;		//Posicion x coma flotante
	float fY			= 0;		//Posicion y coma flotante
	int   alto			= 0;   		//Altura en pixeles del proceso
	int   ancho			= 0;   		//Ancho en pixeles del proceso
	int   estado 		= 0;   		//Estado de la entidad
	int	  numColPoints 	= 0;		//Numero de puntos de colision
	struct colPoint[MAXCOLPOINTS] 		//Puntos deteccion colision
		float x;
		float y;
		int colCode;
		int enabled;
	end;
End;



//Includes del engine
include "engine.prg";