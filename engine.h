// ========================================================================
//  Warcom Game Engine
//  Motor para juegos plataformas 2D
//  21/07/14
//
//  Definiciones del engine
// ========================================================================

//Defines del engine
#define WGE_ENGINE										//Utilizando WGE engine
#define isBitSet(a,b) 	( (a & b) == b )				//Funcion comparar bit
#define setBit(a,b)     ( a |= b )						//Setear un bit
#define unsetBit(a,b)   ( a &=~ b )						//Quitar un bit
#define isType(a,b)     (a.reserved.process_type == b) 	//Funcion para comprobar tipo proceso

//Teclas 
#define	K_UP 	  		_UP 
#define	K_DOWN	  		_DOWN 
#define	K_LEFT    		_LEFT 
#define	K_RIGHT	  		_RIGHT 
#define	K_JUMP	  		_R_SHIFT
#define	K_ACTION_ATACK	_SPACE
#define K_PAUSE         _ENTER

//Estados de tecla
#define KEY_PRESSED    0
#define KEY_DOWN       1
#define KEY_UP         2

//Estado del juego
#define	SPLASH			0
#define MENU			1
#define LOADLEVEL   	2
#define PLAYLEVEL   	3
#define RESTARTLEVEL	5
#define LEVELENDED  	6
#define GAME_OVER       7

//Codigo del tile
//bits del 0 al 4 del mapa de tiles
//				Tipo 0: No Solido
//				Tipo 1: Solido
//				Tipo 2: Rompible
//				Tipo 3: Cinta a derechas
//				Tipo 4: Cinta a izquierdas
//				Tipo 5: Escalera
//				Tipo 6: Base de la escalera
//				Tipo 7: Da�ino
//				Tipo 8: Agua
//				Tipo 9: Suelo no techo (SOLID_ON_FALL)
//				Tipo 10: Sumergido
//				Tipo 11: Sumergido/traspasable
//				Tipo 12: Detencion scroll X der
//				Tipo 13: Detencion scroll X izq
//				Tipo 14: Pendiente 135�
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

//Constantes del motor
const
	//Engine
	cTimeInterval    = 1; 					//Intervalo reloj: cTimeInterval*16ms
	cFadeTime		 = 16;					//Velocidad de los fundidos de pantalla (1..64)
	//Prioridades (orden ejecucion)
	cMainPrior	 	 = 3;
	cPlayerPrior	 = 2;
	cPlatformPrior   = 1;
	cScrollPrior 	 =-1;
	cTilePrior		 =-2;

	//Profundidades
	cZCursor    	 =-4; 		     		//Profundidad del cursor de Debug
	cZMap2	    	 =-3;     				//Profundidad del mapeado encima del player
	cZPlayer		 =-2;					//Profundidad del player
	cZMonster        =-1;
	cZObject         = 1;					//Profundidad de los objetos
	cZMap1 	    	 = 2;					//Profundidad del mapeado tras el player
	
	cMaxObjParams   = 9;					//Numero de parametros objetos
    cSlopesEnabled  = 1;                    //Flag que determina si se usan rampas en el engine
    cHillHeight		= 8;					//Altura maxima de una pendiente (para adaptar al terreno)
	cNumColPoints 	= 10;					//Puntos de colision/deteccion
	cTransLevel      = 128;					//Nivel transparencia Alpha
		
	//Pantalla
	cNumFPS    	 	= 60;  					//Frames por segundo
	cNumFPSDebug 	= 0;					//Frames por segundo en debug (CTRL+F)
	cResX 			= 320;					//Resolucion Horizontal Pantalla
	cResY 			= 300;  				//Resolucion Vertical Pantalla
	cGameScroll 	= 0;    				//Numero Scroll
	cGameRegion 	= 1;    				//Numero Region Pantalla Juego
	cGameRegionX 	= 0;					//Region Horizontal Pantalla de juego (Representacion Mapeado) 
	cGameRegionY 	= 0;					//Region Vertical Pantalla de juego (Representacion Mapeado)
	cGameRegionW 	= cResX;				//Region Horizontal Pantalla de juego (Representacion Mapeado) 
	cGameRegionH 	= 200;					//Region Vertical Pantalla de juego (Representacion Mapeado)	
	//HUD
	cHUDRegion  	= 2;    				//Numero Region informacion juego
	cHUDRegionX 	= 0;					//Region Horizontal informacion juego HUD
	cHUDRegionY 	= cGameRegionH;			//Region Vertical informacion juego HUD
	cHUDRegionW 	= cResX;				//Region Horizontal informacion juego HUD
	cHUDRegionH 	= 100;					//Region Vertical informacion juego HUD
	cHUDscoreX      = 48;					//Posicion X del score en el HUD
	cHUDScoreY      = 18;					//Posicion Y del score en el HUD
	cHUDTriesX      = 0;					//Posicion X de las vidas en el HUD
	cHUDTriesY      = 18;					//Posicion Y de las vidas en el HUD
	cHUDTimeX       = 100;					//Posicion X del tiempo en el HUD
	cHUDTimeY       = 18;					//Posicion Y del tiempo en el HUD
	cHUDLifeX       = 12;
	cHUDLifeY       = 18;
	
	//Numero de tiles fuera de la pantalla. 
	//Si la resolucion no es multiplo del tama�o del tile,es aconsejable usar 
	//al menos 2 tiles OffScreen. Si es multiplo, con 1 es suficiente
	cTilesXOffScreen = 1;					//Tiles fuera de la pantalla en X
	cTilesYOffScreen = 2;					//Tiles fuera de la pantalla en Y
	
	//Mapeado
	cTileSize   = 16;   					//Tama�o tiles (Ancho y alto iguales)
	cHalfTSize = cTileSize >> 1; 			//Mitad del tama�o tile (util para todo el proyecto)
End;

//Data Types

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
	int maxFPS;					//FPS Maximo
	int minFPS; 				//FPS M�nimo
	byte ClockTick;				//Flanco Tiempo
	int clockCounter;			//Contador Reloj
	//juego
	struct game
		int state;              //estado del juego
		byte paused;			//Flag de pausa
		byte endLevel;			//Flag de fin de nivel
		int numLevel;			//Nivel actual
		int playerLife;			//vida del jugador
		int playerMaxLife;      //vida maxima del jugador
		int playerTries;		//vidas del jugador
		int score;				//puntuaci�n
		int levelTime;			//tiempo actual nivel
	end;
	int fpgGame;				//archivo de graficos globales
	//debug
	byte debugMode;				//Modo debug del engine
	//nivel y mapeado
	struct level        		//Estructura de un nivel
		int playerX0;			//Posicion inicial X
		int playerY0;			//Posicion inicial Y
		int numObjects; 		//Numero objetos
		int numPaths;			//Numero de trackings (paths de objetos)
		byte numTiles;       	//Numero de tiles que componen el mapa del nivel
		byte numTilesX;      	//Tama�o horizontal en tiles del mapa 
		byte numTilesY;			//Tama�o vertical en tiles del mapa
		int fpgTiles;			//Identificador del archivo de graficos del tile
		int fpgObjects;			//Identificador del archivo de graficos de los objetos del nivel
		int fpgMonsters;		//Identificador del archivo de graficos de los monstruos del nivel
	End;
	//archivos de los niveles
	struct levelFiles[10]
		string MapFile;			//archivo binario del mapa
		string DataFile;		//archivo binario datos del nivel
		string TileFile;		//archivo grafico de los tiles del mapa
	end;
	_path* paths;				//Array Dinamico de paths
	_tile** tileMap;  	        //Matriz Dinamica del mapa de tiles del nivel
	byte mapUsesAlpha;				//Bit que indica que el mapa usa propiedad alpha (relentiza la carga)
	//Fisicas
	float gravity 			= 0.3;		//Aceleracion gravedad
	float floorFriction 	= 0.85;		//Friccion suelo
	float airFriction 		= 0.85;		//Friccion aire
	//Borrar
	int mapBox; 
	int mapTriangle135;
	int mapTriangle45;
	int mapStairs;
	int mapSolidOnFall;
	//teclas
	byte keyUse = 0;             //Seleccion Flanco
    byte keyState[127][1];       //Mapa estados en flanco anterior y actual
End;

//Variables locales
Local
	
End;

//Declaracion de proceso entidad. 
//Plantilla de variables publicas para asociar a variables
//generales que usan publicas sin conocer el tipo exacto del proceso
Declare Process entity()
public
	float vX			= 0;     	//Velocidad X
	float vY			= 0;     	//Velocidad Y
	float fX			= 0;		//Posicion x coma flotante
	float fY			= 0;		//Posicion y coma flotante
	int   alto			= 0;   		//Altura en pixeles del proceso
	int   ancho			= 0;   		//Ancho en pixeles del proceso
	int   axisAlign     = 0;		//Alineacion del eje del grafico respecto caja colision
	int   state 		= 0;   		//Estado de la entidad
	int   prevState     = 0;		//Estado anterior
	byte  props			= 0;		//Propiedades de la entidad
	struct colPoint[cNumColPoints] 	//Puntos deteccion colision de un objeto
		int x;						//Offset X a sumar a la posicion del objeto
		int y;						//Offset Y a sumar a la posicion del objeto
		int colCode;				//Codigo del punto de colision
		int enabled;			//Habilitacion del punto de colision
	end;
	int frameCount;					//Contador frames animacion
end
end

//Declaracion de proceso Tile
Declare Process pTile(int i,int j)
public
	float vX			= 0;     	//Velocidad X
	float vY			= 0;     	//Velocidad Y
	float fX			= 0;		//Posicion x coma flotante
	float fY			= 0;		//Posicion y coma flotante
	int   alto			= 0;   		//Altura en pixeles del proceso
	int   ancho			= 0;   		//Ancho en pixeles del proceso
	int   axisAlign     = 0;		//Alineacion del eje del grafico respecto caja colision
	int   state 		= 0;   		//Estado de la entidad
	int   prevState     = 0;		//Estado anterior
	byte  props			= 0;		//Propiedades de la entidad
	struct colPoint[cNumColPoints] 	//Puntos deteccion colision de un objeto
		int x;						//Offset X a sumar a la posicion del objeto
		int y;						//Offset Y a sumar a la posicion del objeto
		int colCode;				//Codigo del punto de colision
		int enabled;			//Habilitacion del punto de colision
	end;
	int frameCount;					//Contador frames animacion
end
end

//definiciones del engine
include "debug.h";			//funciones debug
include "player.h";       	//Proceso jugador
include "collisions.h"      //Funciones de colision
include "animation.h"      	//Funciones de animacion
include "objetos.h"        	//Funciones de objetos
include "monsters.h"		//Funciones de monstruos

//Codigo del engine
include "engine.prg";		//Core principal de engine
include "debug.prg";		//Funciones de debug
include "player.prg";       //Proceso jugador
include "collisions.prg";	//Funciones de colision
include "objetos.prg"		//Procesos objetos
include "monsters.prg"		//Procesos monstruos
include "animation.prg"		//Funciones de animacion