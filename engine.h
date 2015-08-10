// ========================================================================
//  Warcom Game Engine
//  Motor para juegos plataformas 2D
//  21/07/14
//
//  Definiciones del engine
// ========================================================================

//Defines del engine
#define WGE_ENGINE												//Utilizando WGE engine
#define DYNAMIC_MEM												//Usando memoria dinámica
#define isBitSet(a,b) 	( (a & b) == b )						//Funcion comparar bit
#define setBit(a,b)     ( a |= b )								//Setear un bit
#define unsetBit(a,b)   ( a &=~ b )								//Quitar un bit
#define isType(a,b)     (a.reserved.process_type == b) 			//Funcion para comprobar tipo proceso
#define getType(a)      (a.reserved.process_type)				//devuelve el tipo de un proceso
#define tickClock(a)    ((clockCounter % a) == 0 && clockTick)	//Funcion que devuelve flanco de numero de frames especificados
#define tick100ms       ((clockCounter % (cNumFPS/10)) == 0 && clockTick) //Flanco de 100ms

//Estado del juego
#define	SPLASH			0
#define MENU			1
#define LOADLEVEL   	2
#define PLAYLEVEL   	3
#define RESTARTLEVEL	5
#define LEVELENDED  	6
#define GAMEOVER        7
#define CONTINUEGAME    8
#define ATTRACTMODE     9
#define TUTORIAL        10
#define INTRO           11
#define MENU_CONFIG     12
#define MENU_CONTROLS   13
#define MENU_KEYS       14
#define MENU_BUTTONS    15
#define LANG_SEL        16
#define PRELUDE         17
#define LEVEL_SELECT    18
#define INITLEVEL		19
#define RESTARTGAME     20

//Codigo del tile
//bits del 0 al 4 del mapa de tiles
//				Tipo 0: No Solido
//				Tipo 1: Solido
//				Tipo 2: Zona Boss
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
//				Tipo 16: Detencion Scroll Y
//				Tipo 17: AutoScroll a Derechas
//				Tipo 18: AutoScroll a Izquierdas
//				Tipo 19: Stop AutoScroll
//              ..31
#define NO_SOLID      		0
#define SOLID         		1
#define BOSS_ZONE     		2
#define STAIRS        		5
#define TOP_STAIRS    		6
#define WATER               8
#define SOLID_ON_FALL 		9
#define NO_SCROLL_R   		12
#define NO_SCROLL_L   		13
#define SLOPE_135     		14
#define SLOPE_45      		15
#define NO_SCROLL_Y   		16
#define AUTOSCROLL_R  		17
#define AUTOSCROLL_L  		18
#define AUTOSCROLL_STOP 	19

//Propiedades de tile
//bit 7:Opacidad del tile.0:el tile es cuadrado 1:el tile tiene transparencia
//bit 6:Profundidad Z del tile.1:Delante del personaje.0.Detras
//bit 5:Transparencia del tile.0:el tile es opaco.1:el tile es semitransparente
#define BIT_TILE_SHAPE 		128
#define BIT_TILE_DELANTE 	64
#define BIT_TILE_ALPHA      32

//Direccion transicion entre Rooms
#define ROOM_TRANSITION_DOWN 	1
#define ROOM_TRANSITION_UP   	2
#define ROOM_TRANSITION_LEFT  	3
#define ROOM_TRANSITION_RIGHT   4

//Propiedades globales de las entidades
#define NO_COLLISION            1		//No colisiona con otros procesos
#define NO_PHYSICS              2       //No le afecta las fisicas
#define PERSISTENT              4       //No desaparece al salir de la region

//efectos de sonido generales
#define PAUSE_SND				0
#define TIMESCORE_SND           1
#define STOPSCORE_SND			2
#define COUNTDOWN_SND           3
#define MENU_SND                4

//musicas generales
#define DEAD_MUS				0
#define END_LEVEL_MUS           1
#define BOSS_MUS				3
#define INTRO_MUS               4

//parametros del checkInRegion
#define CHECKREGION_ALL         0		//Comprueba en toda la region
#define CHECKREGION_DOWN        1		//Comprueba si sale de la region por abajo

//estados de un proceso Bennu
#define STATUS_NOEXISTS			0	// The specified process does not exist.
#define STATUS_DEAD				1	// The specified process is dead.
#define STATUS_ALIVE			2	// The specified process is alive.
#define STATUS_SLEEPING			3	// The specified process is sleeping.
#define STATUS_FROZEN			4	// The specified process is frozen.

//modos de video
#define MODE_WINDOW				0
#define	MODE_2XSCALE			1
#define MODE_FULLSCREEN			2

//identificadores de los niveles
#define PRELUDE_LEVEL			1
#define TUTORIAL_LEVEL			2
#define LEVEL_SELECT_LEVEL		3
#define TOYLAND_LEVEL			4
#define TOYLAND_2_LEVEL			5
#define WOODS_LEVEL             6
#define CANDYLAND_LEVEL         7

//Estado de los niveles
#define LEVEL_UNCOMPLETED       0
#define LEVEL_COMPLETED         1
#define LEVEL_DOOR_CLOSED       2

//Tipos de fade
#define FADE_SCREEN             1
#define FADE_MUSIC 	            2

//Constantes del motor
const
	//Engine
	cTimeInterval    = 1; 					//Intervalo reloj: cTimeInterval*16ms
	
	//Prioridades (orden ejecucion)
	cMainPrior	 	 	= 6;
	cPlayerPrior	 	= 5;
	cPlatformPrior   	= 4;
	cPlatformChildPrior = 3;
	cObjectPrior     	= 2;
	cMonsterPrior    	= 1;
	cTilePrior		 	=-1;
	cScrollPrior 	 	=-2;
	

	//Profundidades
	cZCursor    	 =-4; 		     		//Profundidad del cursor de Debug
	cZMap2	    	 =-3;     				//Profundidad del mapeado encima del player
	cZPlayer		 =-2;					//Profundidad del player
	cZMonster        =-1;					//Profundidad enemigos
	cZObject         = 1;					//Profundidad de los objetos
	cZPlatform       = 2;					//Profundidad Plataformas
	cZMap1 	    	 = 3;					//Profundidad del mapeado tras el player
	
	//Parametros del engine
	cMaxObjParams   = 9;					//Numero de parametros objetos
    cSlopesEnabled  = 1;                    //Flag que determina si se usan rampas en el engine
    cHillHeight		= 8;					//Altura maxima de una pendiente (para adaptar al terreno)
	cNumColPoints 	= 10;					//Puntos de colision/deteccion
	cTransLevel     = 128;					//Nivel transparencia Alpha
		
	//Pantalla
	cNumFPS    	 	= 60;  					//Frames por segundo
	cNumFPSDebug 	= 0;					//Frames por segundo en debug (CTRL+F)
	cResX 			= 256;					//Resolucion Horizontal Pantalla
	cResY 		    = 192;					//Resolucion Vertical Pantalla	
	cGameScroll 	= 0;    				//Numero Scroll
	cGameRegion 	= 1;    				//Numero Region Pantalla Juego
	cGameRegionX 	= 0;					//Region Horizontal Pantalla de juego (Representacion Mapeado) 
	cGameRegionY 	= 0;					//Region Vertical Pantalla de juego (Representacion Mapeado)
	cGameRegionW 	= cResX;				//Region Horizontal Pantalla de juego (Representacion Mapeado) 
	cGameRegionH 	= 160;					//Region Vertical Pantalla de juego (Representacion Mapeado)	
	cFadeTime		= 3;					//Velocidad de los fundidos de pantalla (1..64)
	cRoomScroll     = true;					//Flag para utilizar el scroll vertical como Master System (transiciones entre "rooms")
	cTilesBetweenRooms  = 2;				//Numero de tiles transicion entre rooms
	cVelRoomTransition  = 2;				//Velocidad transicion entre rooms
	cVelRoomTransFactorX = 0.15; 			//Factor velocidad X transicion entre rooms para el player
	cVelRoomTransFactorY = 0.25;			//Factor velocidad Y transicion entre rooms para el player
	cVelShakeScroll     = 2;				//Velocidad efecto shakeScroll
	cVelAutoScroll      = 0.2;				//Velocidad AutoScroll
	
	//HUD
	cHUDRegion  	= 2;    				//Numero Region informacion juego
	cHUDRegionX 	= 0;					//Region Horizontal informacion juego HUD
	cHUDRegionY 	= cGameRegionH;			//Region Vertical informacion juego HUD
	cHUDRegionW 	= cGameRegionW;			//Region Horizontal informacion juego HUD
	cHUDRegionH 	= 32;//100;				//Region Vertical informacion juego HUD
	cHUDscoreX      = 48;					//Posicion X del score en el HUD
	cHUDScoreY      = 18;					//Posicion Y del score en el HUD
	cHUDTriesX      = 0;					//Posicion X de las vidas en el HUD
	cHUDTriesY      = 18;					//Posicion Y de las vidas en el HUD
	cHUDTimeX       = 100;					//Posicion X del tiempo en el HUD
	cHUDTimeY       = 18;					//Posicion Y del tiempo en el HUD
	cHUDLifeX       = 12;					//Posicion X de la primera estrella de vida
	cHUDLifeY       = 18;					//Posicion X de la primera estrella de vida
	cHUDLifeSize    = 16;					//Tamaño de una estrella de vida
	
	//Numero de tiles fuera de la pantalla. 
	//Si la resolucion no es multiplo del tamaño del tile,es aconsejable usar 
	//al menos 2 tiles OffScreen. Si es multiplo, con 1 es suficiente
	cTilesXOffScreen = 1;					//Tiles fuera de la pantalla en X
	cTilesYOffScreen = 2;					//Tiles fuera de la pantalla en Y
	
	//Mapeado
	cTileSize   = 16;   					//Tamaño tiles (Ancho y alto iguales)
	cHalfTSize = cTileSize >> 1; 			//Mitad del tamaño tile (util para todo el proyecto)
	
	//Entidades
	cBlinkEntityTime  = 2;					//Tiempo de parpadeo general entidades
	
	//General
	cNumLevels        = 7;					//Numero niveles
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
	#ifdef DYNAMIC_MEM
		_point* punto;	     		//Array Dinamico de puntos
	#else
		_point punto[10];	     	//Array Estatico de puntos
	#endif
end;

//Tile
Type _tile
	byte tileGraph; 			//Imagen del tile
	byte tileShape;      		//Propiedad del tile: Forma
	byte tileProf;				//Propiedad del tile: Profundidad
	byte tileAlpha;             //Propiedad del tile: Opacidad
	byte tileCode; 				//Codigo del tile
	byte NumAnimation;			//Numero de animacion (0: Sin animacion)
	byte refresh;				//flag de actualizar tile
end;

//Animaciones de tiles
Type _TileAnimation
	byte numFrames;        	//numero de frames totales de la animacion
	#ifdef DYNAMIC_MEM
		byte* frameGraph;   	//array dinamico del grafico del frame
	#else
		byte  frameGraph;		//Array estatico del grafico del frame
	#endif
	#ifdef DYNAMIC_MEM
		byte* frameTime;   		//array dinamico de duracion del frame
	#else
		byte  frameTime;		//Array estatico de duracion del frame
	#endif
end;

//Vector
Type _vector						//Tipo dato vector
	_point vStart;				//Punto inicio
	_point vEnd;					//Punto fin
end;

//Datos publicos entidades
Type _entityPublicData
	float vX			= 0;     	//Velocidad X
	float vY			= 0;     	//Velocidad Y
	float fX			= 0;		//Posicion x coma flotante
	float fY			= 0;		//Posicion y coma flotante
	int   alto			= 0;   		//Altura en pixeles del proceso
	int   ancho			= 0;   		//Ancho en pixeles del proceso
	int   axisAlign     = 0;		//Alineacion del eje del grafico respecto caja colision
	int   state 		= 0;   		//Estado de la entidad
	int   prevState     = 0;		//Estado anterior
	int  props			= 0;		//Propiedades de la entidad
	struct colPoint[cNumColPoints] 	//Puntos deteccion colision de un objeto
		int x;						//Offset X a sumar a la posicion del objeto
		int y;						//Offset Y a sumar a la posicion del objeto
		int colCode;				//Codigo del punto de colision
		int enabled;			//Habilitacion del punto de colision
	end;
	int frameCount;					//Contador frames animacion	
end;

//CheckPoint
Type _checkPoint
	_point position;
	int _flags;
end;	

	
//Variables Globales
Global
	//engine
	int maxFPS;					//FPS Maximo
	int minFPS; 				//FPS Mínimo
	byte ClockTick;				//Flanco Tiempo
	int clockCounter;			//Contador Reloj
	float scrollfX;				//Posicion X Float del scroll
	//juego
	struct game
		int state;              		//estado del juego
		byte paused;					//Flag de pausa
		byte endLevel;					//Flag de fin de nivel
		byte boss;						//Flag de jefe
		byte bossKilled;				//Flag de jefe muerto
		int numLevel;					//Nivel actual
		int playerLife;					//vida del jugador
		int playerMaxLife;      		//vida maxima del jugador
		int playerTries;				//vidas del jugador
		int score;						//puntuación
		int actualLevelTime;    		//tiempo actual del nivel
		int levelStatus[cNumLevels];	//estado de los niveles
		byte shakeScroll;				//activar efecto temblor scroll
	end;
	//configuracion
	struct config
		int videoMode;
		int soundVolume;
		int musicVolume;
		int lang;	
	end;
	int fpgGame;				//archivo de graficos globales
	int fntGame;				//fuente general del juego
	//debug
	byte debugMode;				//Modo debug del engine
	//nivel y mapeado
	struct level        		//Estructura de un nivel
		int playerX0;				//Posicion inicial X
		int playerY0;				//Posicion inicial Y
		int playerFlags;			//Orientacion inicial player
		int levelTime;				//Tiempo del nivel
		int numObjects; 			//Numero objetos
		int numMonsters; 			//Numero enemigos
		int numPlatforms; 			//Numero plataformas
		int numPaths;				//Numero de trackings (paths de objetos)
		byte numTiles;       		//Numero de tiles que componen el mapa del nivel
		byte numTilesX;      		//Tamaño horizontal en tiles del mapa 
		byte numTilesY;				//Tamaño vertical en tiles del mapa
		int fpgTiles;				//Identificador del archivo de graficos del tile
		int fpgObjects;				//Identificador del archivo de graficos de los objetos del nivel
		int fpgMonsters;			//Identificador del archivo de graficos de los monstruos del nivel
		struct levelFlags			//Flags de nivel
			byte  autoScrollX;   	//Scroll con movimiento X automático (0:Parado 1:A derechas 2:a Izquierdas)
		end;
		int idMusicLevel;
		int numCheckPoints;			//Numero checkpoints del nivel
		#ifdef DYNAMIC_MEM
			_checkPoint* checkPoints;   //Array dinamico de checkpoints del nivel
		#else
			_checkPoint checkPoints[10]; //Array estatico checkpoints del nivel
		#endif
	End;
	//archivos de los niveles
	struct levelFiles[cNumLevels]
		string MapFile;			//archivo binario del mapa
		string DataFile;		//archivo binario datos del nivel
		string TileFile;		//archivo grafico de los tiles del mapa
		string MusicFile;		//archivo musica del nivel
		float  MusicIntroEnd;	//Posicion en segundos con centesimas del final del intro de la musica	
	end;
	#ifdef DYNAMIC_MEM
		_tile** tileMap;  	        				//Matriz Dinamica del mapa de tiles del nivel
		_path* paths;								//Array Dinamico de paths
		struct tileAnimations
			byte 			numAnimations;			//Numero de animaciones
			_tileAnimation* tileAnimTable; 			//Array dinamico de animaciones de tile
		end;
	#else
		_tile tileMap[1000][1000];					//Matriz Estatica del mapa de tiles del nivel
		_path paths[100];           				//Array Estatico de paths
		struct tileAnimations
			byte 			numAnimations;			//Numero de animaciones
			_tileAnimation 	tileAnimTable[100]; 	//Array estatico de animaciones de tile
		end;		
	#endif
	
	byte mapUsesAlpha;				//Bit que indica que el mapa usa propiedad alpha (relentiza la carga)
	//Fisicas
	float gravity 			= 0.20; //0.25; 	//Aceleracion gravedad
	float floorFriction 	= 0.85;		//Friccion suelo
	float airFriction 		= 0.85;		//Friccion aire
	float maxEntityVelY     = 4.0;		//Velocidad maxima Y global para todas las entidades
	
	//generales
	int idButton;					//Identificador de proceso pulsando boton
	int idKey;						//Identificar de proceso abriendo puerta
	byte stopScrollXL;				//Flag de detencion scroll horizonal derecho
	byte stopScrollXR;				//Flag de detencion scroll horizonal derecho
	byte stopScrollY;				//Flag de detencion scroll vertical
	//Borrar?
	int mapBox; 
	int mapTriangle135;
	int mapTriangle45;
	int mapStairs;
	int mapSolidOnFall;
	int firstRun;					//flag de primer arranque
End;

//Variables locales
Local
	
End;

//Declaracion de proceso entidad. 
//Plantilla de variables publicas para asociar a variables
//generales que usan publicas sin conocer el tipo exacto del proceso
Declare Process entity()
public
	_entityPublicData this;			//datos publicos de entidad
end
end

//Declaracion de proceso Tile
Declare Process pTile(int i,int j)
public
	_entityPublicData this;			//datos publicos de entidad
end
end

//definiciones del engine
include "controls.h";		//funciones controles
include "sound.h";			//funciones sonido
include "debug.h";			//funciones debug
include "player.h";       	//Proceso jugador
include "collisions.h"      //Funciones de colision
include "animation.h"      	//Funciones de animacion
include "objects.h"        	//Funciones de objetos
include "monsters.h"		//Funciones de monstruos
include "platforms.h"		//Funciones de plataformas
include "interface.h"		//Funciones de interface

//Codigo del engine
include "engine.prg";		//Core principal de engine
include "controls.prg";		//funciones de control
include "sound.prg";		//funciones de sonido
include "debug.prg";		//Funciones de debug
include "player.prg";       //Proceso jugador
include "collisions.prg";	//Funciones de colision
include "objects.prg"		//Procesos objetos
include "monsters.prg"		//Procesos monstruos
include "platforms.prg"		//Procesos plataformas
include "animation.prg"		//Funciones de animacion
include "interface.prg"		//Funciones de interface
