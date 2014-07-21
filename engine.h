// ========================================================================
//  Warcom Game Engine
//  Motor para juegos plataformas 2D
//  21/07/14
//
//  Definiciones globales del engine
// ========================================================================

//Defines del engine
#define WGE_Engine
#define bit_cmp(a,b) ( (a & b) == b )
#define MaxObjParams  9

//Teclas 
#define	cKUp 	  _UP 
#define	cKDown	  _DOWN 
#define	cKLeft	  _LEFT 
#define	cKRight	  _RIGHT 
#define	cKBt1	  _ALT 
#define	cKBt2	  _SPACE
	
//Constantes del motor
const
	//Pantalla
	cNumFPS     = 60;   //Frames por segundo
	cResX 		= 320;	//Resolucion Horizontal Pantalla
	cResY 		= 240;  //Resolucion Vertical Pantalla
	cGameScroll = 0;    //Numero Scroll
	cGameRegion = 1;    //Numero Region Pantalla Juego
	cRegionX1 	= 0;	//Region Horizontal Pantalla de juego (Representacion Mapeado) 
	cRegionY1 	= 0;	//Region Vertical Pantalla de juego (Representacion Mapeado)
	cRegionX2 	= 320;	//Region Horizontal Pantalla de juego (Representacion Mapeado) 
	cRegionY2 	= 240;	//Region Vertical Pantalla de juego (Representacion Mapeado)
	
	//Mapeado
	cTileSize   = 16;   //Tamaño tiles (Ancho y alto iguales)
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
	byte tileGraph; 				//Imagen del tile
	byte tileCode;      		//Codigo del tile	
end;

//Variables Globales
Global
	int FrameCount;				//Contador de Frames Global
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