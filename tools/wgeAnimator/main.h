// ========================================================================
//  wgeAnimator
//  Definiciones generales
//  12/04/16
//
//  Warcom soft.
// ========================================================================

//Definiciones
#define tickClock(a)    ((clockCounter % a) == 0 && clockTick)	//Funcion que devuelve flanco de numero de frames especificados

//constantes
Const
	cResX 			= 320;
	cResY 			= 240;
	cFps 			= 60;
	cClockTimer 	= 0;					//numero de timer para el reloj
	cTimeInterval   = 1; 					//Intervalo reloj: cTimeInterval*16ms
    //cTimeInterval   = 1.66;				//Modo nuevo: Intervalo reloj: (1/fps)*100 (100 = 1 seg)
	
	cGameRegion 	= 1;    				//Numero Region Pantalla Juego
	
	//Profundidades
	cZCursor    	 =-4; 		     		//Profundidad del cursor de Debug
	cZMap2	    	 =-3;     				//Profundidad del mapeado encima del player
	cZPlayer		 =-2;					//Profundidad del player
	cZMonster        =-1;					//Profundidad enemigos
	cZObject         = 1;					//Profundidad de los objetos
	cZPlatform       = 2;					//Profundidad Plataformas
	cZMap1 	    	 = 3;					//Profundidad del mapeado tras el player
	
	cNumColPoints 	= 10;					//Puntos de colision/deteccion
	
	//Posicion de la animacion
	cAnimationX	    = cResX >> 1;
	cAnimationY	    = cResY >> 2;
	
	//gui
	cWindowWidth	= 300;
	cWindowHeight   = 100;
	cWindowX		= 10;
	cWindowY        = cResY >> 1;
	cWindowMarginX  = 10;
	cWindowMarginY  = 25;
	
	cMarginX		= 30;
	cMarginY		= 20;
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

//Animaciones de tiles
Type _TileAnimation
	byte numFrames;        		//numero de frames totales de la animacion
	byte actualFrame;			//frame actual de reproduccion
	byte tileCode;				//Codigo del tile cuando es animacion
	
	byte* frameGraph;   	//array dinamico del grafico del frame
	byte* frameTime;   		//array dinamico de duracion del frame
	
end;

//globales
Global
	byte clockTick;				//Flanco Tiempo
	int	clockCounter;			//Contador Reloj
	struct tileAnimations
		byte 			numAnimations;			//Numero de animaciones
		_tileAnimation* tileAnimTable; 			//Array dinamico de animaciones de tile
	end;
	
	//gui
	int frVentana;
	int editValue[4];
	//datos animacion
	struct animationData
		int startFrame = 1;
		int endFrame   = 2;
		int animSpeed  = 10;
		int animMode   = 0;
	end;
end;

//Declaracion de proceso entidad. 
//Plantilla de variables publicas para asociar a variables
//generales que usan publicas sin conocer el tipo exacto del proceso
Declare Process entity()
public
	_entityPublicData this;			//datos publicos de entidad
end
end

//declaracion de proceso dibujo animacion
Declare Process animationDraw()
public
	_entityPublicData this;			//datos publicos de entidad
end
end