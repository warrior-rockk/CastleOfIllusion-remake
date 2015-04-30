// ========================================================================
//  Warcom Game Engine
//  Motor para juegos plataformas 2D
//  13/02/15
//
//  Definiciones de las procesos monsters
// ========================================================================

//propiedades de los monstruos
#define MONS_HARMLESS		8			//No Daña al jugador
#define MONS_HURTLESS       16          //No puede ser dañado

//Tipos de monstruo
#define MONS_CYCLECLOWN			0 		//Monstruo CycleClown
#define MONS_TOYPLANE   		1 		//Monstruo ToyPlane
#define MONS_TOYPLANECONTROL   	2 		//Monstruo ToyPlaneControl
#define MONS_CHESSHORSE   	    3 		//Monstruo CheessHorse
#define MONS_BUBBLE				4		//Monstruo Bubble
#define MONS_BALLSCLOWN 		5		//Monstruo BallsClown
#define MONS_MONKEYTOY          6       //Monstruo MonkeyToy
#define MONS_FATGENIUS          7       //Monstruo FatGenius
#define MONS_TOYCAR             8       //Monstruo ToyCar

//enemigo
Type _monster         			//Tipo de Dato de enemigo
	int monsterType;      		//Tipo del enemigo
	int monsterGraph;    		//Grafico
	int monsterX0;    			//Posicion X
	int monsterY0;     			//Posicion Y
	int monsterAncho;		    //Ancho
	int monsterAlto;            //Alto
	int monsterAxisAlign;		//Eje
	int monsterFlags;           //flags
	int monsterProps;           //Propiedades
End;

//Constantes
Const
	//puntuaciones
	cKillMonster            = 10;
	
	//ChessHorse
	cChessHorseIdleCycles 	= 2;	//Ciclos de reposo para salto pequeño
	cChessHorseNumCycles    = 3;	//Ciclos de reposo para salto grande
	cChessHorseSmallMove	= 1;	//Velocidad X movimiento pequeño
	cChessHorseBigMove		= 2;	//Velocidad X movimiento grande
	cChessHorseSmallJump	= 3;	//Velocidad Y movimiento pequeño
	cChessHorseBigJump		= 4;	//Velocidad Y movimiento grande
	
	//Bubble
	cBubbleVel				= 0.5;	//Velocidad burbuja
	cBubbleInvisibleTime    = 5;	//Velocidad invisible
	cBubbleIdleTime         = 60;	//Velocidad reposo
	
	//BallClown
	cBallsClownIdleTime     = 30;  	//Tiempo Reposo
	cBallsClownAtackRange   = 64;	//Rango ataque
	cBallsClownNumBallsMax  = 6; 	//Numero de bolas maximo
	
	//MonkeyToy
	cMonkeyToyIdleTime      = 40;  	//Tiempo Reposo
	
	//FatGenius
	cFatGeniusVel			= 1;   	//Velocidad movimiento
	
	//ToyCar
	cToyCarVel              = 2;	//Velocidad movimiento
end;

Global
	_monster* monsters;			//Array Dinamico de enemigos
end;

//declaracion de proceso monstruo generico
Declare Process monster(int monsterType,int _x0,int _y0,int _ancho,int _alto,int _axisAlign,int _flags,int _props)
public
	_entityPublicData this;			//datos publicos de entidad
end
end

//declaracion de proceso monstruo cycleClown
Declare Process cycleClown(int graph,int x,int y,int _ancho,int _alto,int _axisAlign,int _flags,int _props)
public
	_entityPublicData this;			//datos publicos de entidad
end
end

//declaracion de fuego enemigo (proyectil)
Declare Process monsterFire(int graph,int x,int y,float _vX,float _vY,int _props)
public
	_entityPublicData this;			//datos publicos de entidad
end
end

//Declaracion de enemigo ToyPlane
Declare process toyPlane(int graph,int x,int y,int _ancho,int _alto,int _axisAlign,int _flags,int _props)
public
	_entityPublicData this;			//datos publicos de entidad
end
end

//Declaracion de enemigo ToyPlaneControl
Declare process toyPlaneControl(int graph,int x,int y,int _ancho,int _alto,int _axisAlign,int _flags,int _props)
public
	_entityPublicData this;			//datos publicos de entidad
end
end

//Declaracion de enemigo cheessHorse
Declare process chessHorse(int graph,int x,int y,int _ancho,int _alto,int _axisAlign,int _flags,int _props)
public
	_entityPublicData this;			//datos publicos de entidad
end
end

//Declaracion de enemigo bubble
Declare process bubble(int graph,int startX,int startY,int _ancho,int _alto,int _axisAlign,int _flags,int _props)
public
	_entityPublicData this;			//datos publicos de entidad
end
end

//Declaracion de enemigo ballsClown
Declare process ballsClown(int graph,int x,int y,int _ancho,int _alto,int _axisAlign,int _flags,int _props)
public
	_entityPublicData this;			//datos publicos de entidad
end
end

//Declaracion de enemigo monkeyToy
Declare process monkeyToy(int graph,int x,int y,int _ancho,int _alto,int _axisAlign,int _flags,int _props)
public
	_entityPublicData this;			//datos publicos de entidad
end
end

//Declaracion de enemigo fatGenius
Declare process fatGenius(int graph,int x,int y,int _ancho,int _alto,int _axisAlign,int _flags,int _props)
public
	_entityPublicData this;			//datos publicos de entidad
end
end

//Declaracion de enemigo ToyCar
Declare process toyCar(int graph,int x,int y,int _ancho,int _alto,int _axisAlign,int _flags,int _props)
public
	_entityPublicData this;			//datos publicos de entidad
end
end
//Proceso de muerte generico de enemigo
Declare Process deadMonster()
public
	_entityPublicData this;			//datos publicos de entidad
end
end