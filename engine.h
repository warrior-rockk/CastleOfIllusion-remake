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

//Teclas 
#define	CKUP 	  _UP 
#define	CKDOWN	  _DOWN 
#define	CKLEFT    _LEFT 
#define	CKRIGHT	  _RIGHT 
#define	CKBT1	  _R_SHIFT
#define	CKBT2	  _SPACE

//Modos funcion colCheckVectorY
#define FROMCOLLISION    0					//Comprobar pixeles para salir de la colision
#define TOCOLLISION      1					//Comprobar pixeles hasta llegar a la colision

//Modos funcion colCheckProcess
#define BOTHAXIS			0					//Ambos ejes
#define HORIZONTALAXIS		1					//Eje Horizontal
#define VERTICALAXIS		2					//Eje Vertical

//Direccion colision
#define NOCOL		0
#define COLUP		1
#define COLDOWN		2
#define COLIZQ		3
#define COLDER   	4
#define COLCENTER   5

//Puntos de colision
//los puntos laterales deben estar primero de los inferiores/superiores
//para el buen funcionamiento de la deteccion de obstaculos
#define RIGHT_UP_POINT		0
#define RIGHT_DOWN_POINT	1
#define LEFT_UP_POINT		2
#define LEFT_DOWN_POINT		3
#define DOWN_L_POINT		4
#define DOWN_R_POINT		5
#define UP_L_POINT			6
#define UP_R_POINT			7
#define CENTER_POINT		8
#define CENTER_DOWN_POINT	9

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
#define STAIRS        5
#define TOP_STAIRS    6
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

//estados objeto
#define IDLE_STATE			0
#define MOVE_STATE          1

//Constantes del motor
const
	//Engine
	//Prioridades (orden ejecucion)
	cMainPrior	 	 = 3;
	cPlayerPrior	 = 2;
	cPlatformPrior   = 1;
	cScrollPrior 	 =-1;
	cTilePrior		 =-2;

	//Profundidades
	cZCursor    	 =-3; 		     		//Profundidad del cursor de Debug
	cZMap2	    	 =-2;     				//Profundidad del mapeado encima del player
	cZPlayer		 =-1;					//Profundidad del player
	cZObject         = 1;					//Profundidad de los objetos
	cZMap1 	    	 = 2;					//Profundidad del mapeado tras el player
	
	cMaxObjParams   = 9;					//Numero de parametros objetos
    cSlopesEnabled  = 1;                    //Flag que determina si se usan rampas en el engine
    cHillHeight		= 8;					//Altura maxima de una pendiente (para adaptar al terreno)
	cNumColPoints 	= 10;					//Puntos de colision/deteccion
	cTransLevel      = 128;					//Nivel transparencia Alpha
		
	//Debug		
	cCursorColor 	= 100;					//Color del cursor de debugMode
	cDebugInfoX  	= 10;					//Posicion X de la informacion de debug
	cDebugInfoY  	= 210;					//Posicion Y de la informacion de debug
	cMaxDebugInfo	= 10;					//Maximo lineas informacion de debug

	//Pantalla
	cNumFPS    	 	= 60;  					//Frames por segundo
	cNumFPSDebug 	= 0;					//Frames por segundo en debug (CTRL+F)
	cResX 			= 320;					//Resolucion Horizontal Pantalla
	cResY 			= 300;  				//Resolucion Vertical Pantalla
	cGameScroll 	= 0;    				//Numero Scroll
	cGameRegion 	= 1;    				//Numero Region Pantalla Juego
	cRegionX 		= 0;					//Region Horizontal Pantalla de juego (Representacion Mapeado) 
	cRegionY 		= 0;					//Region Vertical Pantalla de juego (Representacion Mapeado)
	cRegionW 		= cResX;				//Region Horizontal Pantalla de juego (Representacion Mapeado) 
	cRegionH 		= 200;				//Region Vertical Pantalla de juego (Representacion Mapeado)	
	
	//Numero de tiles fuera de la pantalla. 
	//Si la resolucion no es multiplo del tamaño del tile,es aconsejable usar 
	//al menos 2 tiles OffScreen. Si es multiplo, con 1 es suficiente
	cTilesXOffScreen = 1;					//Tiles fuera de la pantalla en X
	cTilesYOffScreen = 2;					//Tiles fuera de la pantalla en Y
	
	//Mapeado
	cTileSize   = 16;   					//Tamaño tiles (Ancho y alto iguales)
	cHalfTSize = cTileSize >> 1; 			//Mitad del tamaño tile (util para todo el proyecto)
	
	//Fisicas
	cPlayerVelMaxX			= 3.4;			//Velocidad Maxima Player
	cPlayerVelMaxXSlopeUp	= 2;            //Velocidad Maxima Player subiendo rampa
	cPlayerVelMaxXSlopeDown = 5;            //Velocidad Maxima Player bajando rampa
	cPlayerAccelX           = 1.2;          //Aceleracion maxima Player
	cPlayerAccelXSlopeUp    = 0.2;          //Aceleracion maxima Player subiendo rampa
	cPlayerAccelXSlopeDown  = 1.4;          //Aceleracion maxima Player bajando rampa
	cPlayerDecelXSlopeUp    = 0.1;			//Factor deceleracion al subir rampa
End;

//Data Types

//Objeto
Type _objeto         			//Tipo de Dato de objeto
	byte tipo;      			//Tipo del objeto
	int grafico;    			//Grafico
	int x0;         			//Posicion X
	int y0;         			//Posicion Y
	int angulo;     			//Angulo
	int param[cMaxObjParams];	//Parametros del objeto
	byte dibujado;				//Flag de si ha sido dibujado (sectorizacion)
End;

//Punto
Type _point						//Tipo de dato punto
	int x;						//Posicion X
	int y;						//Posicion Y
End;

//Path
Type _path						//Tipo de dato path
	int numPuntos;				//Numero de puntos
	_point* punto;	     		//Array Dinamico de puntos
end;

//Tile
Type _tile
	byte tileGraph; 			//Imagen del tile
	byte tileShape;      		//Propiedad del tile: Forma
	byte tileProf;				//Propiedad del tile: Profundidad
	byte tileAlpha;             //Propiedad del tile: Opacidad
	byte tileCode; 				//Codigo del tile
end;

//Vector
Type _vector						//Tipo dato vector
	_point vStart;				//Punto inicio
	_point vEnd;					//Punto fin
end;
	
//Variables Globales
Global
	//engine
	int FrameCount;				//Contador de Frames Global
	int maxFPS;					//FPS Maximo
	int minFPS; 				//FPS Mínimo

	//debug
	byte debugMode;				//Modo debug del engine
	//nivel y mapeado
	struct level        		//Estructura de un nivel
		int playerX0;			//Posicion inicial X
		int playerY0;			//Posicion inicial Y
		int numObjects; 		//Numero objetos
		int numPaths;			//Numero de trackings (paths de objetos)
		byte numTiles;       	//Numero de tiles que componen el mapa del nivel
		byte numTilesX;      	//Tamaño horizontal en tiles del mapa 
		byte numTilesY;			//Tamaño vertical en tiles del mapa
		int fpgTiles;			//Identificador del archivo de graficos del tile
		int fpgObjects;			//Identificador del archivo de graficos de los objetos del nivel
	End;	
	_objeto* objetos;			//Array Dinamico de objetos
	_path* paths;				//Array Dinamico de paths
	//_tile** tileMap;  	        //Matriz Dinamica del mapa de tiles del nivel
	_tile tileMap[130][130];
	byte mapUsesAlpha;				//Bit que indica que el mapa usa propiedad alpha (relentiza la carga)
	//jugador
	int idPlayer;				//Identificador del proceso del jugador
	int idPlatform;				//Identificador de plataforma sobre la que esta el player
	//Fisicas
	float gravity 			= 0.3;		//Aceleracion gravedad
	float floorFriction 	= 0.9;		//Friccion suelo
	float airFriction 		= 0.95;		//Friccion aire
	//Borrar
	int mapBox; 
	int mapTriangle135;
	int mapTriangle45;
	int mapStairs;
	int mapSolidOnFall;
End;

//Variables locales
Local
	float vX			= 0;     	//Velocidad X
	float vY			= 0;     	//Velocidad Y
	float fX			= 0;		//Posicion x coma flotante
	float fY			= 0;		//Posicion y coma flotante
	int   alto			= 0;   		//Altura en pixeles del proceso
	int   ancho			= 0;   		//Ancho en pixeles del proceso
	int   state 		= 0;   		//Estado de la entidad
	struct colPoint[cNumColPoints] 	//Puntos deteccion colision de un objeto
		int x;						//Offset X a sumar a la posicion del objeto
		int y;						//Offset Y a sumar a la posicion del objeto
		int colCode;				//Codigo del punto de colision
		int enabled;				//Habilitacion del punto de colision
	end;
End;


//Includes del engine
include "engine.prg";		//Core principal de engine
include "player.prg";       //Proceso jugador
include "collisions.prg";	//Funciones de colision
include "debug.prg";		//Funciones de debug
include "objetos.prg"		//Procesos objetos