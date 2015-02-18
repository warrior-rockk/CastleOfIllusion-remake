// ========================================================================
//  Warcom Game Engine
//  Motor para juegos plataformas 2D
//  11/02/15
//
//  Definiciones del player
// ========================================================================

//estados
#define IDLE_STATE				0
#define MOVE_STATE          	1
#define MOVE_RIGHT_STATE 		2
#define MOVE_LEFT_STATE  		3
#define MOVE_UP_STATE	 		4
#define MOVE_DOWN_STATE  		5
#define MOVE_FREE_STATE  		6
#define JUMP_STATE		  		7
#define CROUCH_STATE			8
#define BREAK_STATE				9
#define FALL_STATE				10
#define ON_STAIRS_STATE			11
#define MOVE_ON_STAIRS_STATE 	12
#define BREAK_FALL_STATE		13
#define ATACK_STATE				14
#define BREAK_ATACK_STATE		15
#define SLOPING_STATE			16
#define BREAK_SLOPING_STATE		17
#define PICKING_STATE			18
#define PICKED_STATE			19
#define THROWING_STATE			20
#define DEAD_STATE              21
#define HURT_STATE              22

Const
	//Fisicas
	cPlayerVelMaxX			= 3.4;			//Velocidad Maxima X Player
	cPlayerVelMaxXSlopeUp	= 2;            //Velocidad Maxima X Player subiendo rampa
	cPlayerVelMaxXSlopeDown = 3.6;            //Velocidad Maxima X Player bajando rampa
	cPlayerVelMaxXSloping	= 6;            //Velocidad Maxima X Player resbalando por rampa
	cPlayerAccelX           = 0.6;          //Aceleracion maxima X Player
	cPlayerAccelXSlopeUp    = 0.2;         //Aceleracion maxima X Player subiendo rampa
	cPlayerAccelXSlopeDown  = 0.65;         //Aceleracion maxima X Player bajando rampa
	cPlayerAccelXSloping	= 0.15;         //Aceleracion maxima X Player resbalando por rampa
	cPlayerDecelXSlopeUp    = 0.1;			//Factor deceleracion X al subir rampa
	cPlayerAccelY			= 4;			//Aceleracion Player Y salto
	cPlayerVelMaxY          = 10;			//Velocidad Maxima Y Player
	cPlayerAtackBounce      = 4;            //Rebote al romper objet/atacar
	cPlayerPowerAtackBounce = 1.4;          //Extra de rebote al romper/atacar
	cPlayerPowerJumpFactor  = 0.2;			//Factor de incremento poder salto
	cPlayerMaxPowerJump     = 10;           //Maximo incremento poder salto
	
	//Personaje
	cPlayerAncho			= 16;			//Ancho del jugador
	cPlayerAlto				= 32;			//Alto del jugador
	cPlayerAltoCrouch		= 22;			//Alto del jugador agachado
	
	cPickingTime			= 20;			//Tiempo retraso para recojer objeto
	
	//Offset Posicion objeto cogido
	cObjectPickedPosX       = 3;						//Offset X posicion player para el objeto cogido
	cObjectPickedPosY       = -(cPlayerAlto>>1);		//Offset Y posicion player para el objeto cogido
	cThrowObjectVelX        = 3;							//Velocidad X lanzamiento objeto
	cThrowObjectVelY        = -3;						//Velocidad Y lanzamiento objeto
end;

Global
	//jugador
	entity idPlayer;				//Identificador del proceso del jugador
	int idPlatform;				//Identificador de plataforma sobre la que esta el player
	entity idObjectPicked;			//Identificador del objeto cogido
	entity idObjectThrowed;        //Identificador del objeto lanzado
end;

//declaracion de proceso player
Declare Process player()
public
	float vX			= 0;     	//Velocidad X
	float vY			= 0;     	//Velocidad Y
	float fX			= 0;		//Posicion x coma flotante
	float fY			= 0;		//Posicion y coma flotante
	int   alto			= 0;   		//Altura en pixeles del proceso
	int   ancho			= 0;   		//Ancho en pixeles del proceso
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