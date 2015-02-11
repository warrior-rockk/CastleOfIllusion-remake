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

Const
	//Fisicas
	cPlayerVelMaxX			= 3.4;			//Velocidad Maxima X Player
	cPlayerVelMaxXSlopeUp	= 2;            //Velocidad Maxima X Player subiendo rampa
	cPlayerVelMaxXSlopeDown = 4;            //Velocidad Maxima X Player bajando rampa
	cPlayerVelMaxXSloping	= 6;            //Velocidad Maxima X Player resbalando por rampa
	cPlayerAccelX           = 1.2;          //Aceleracion maxima X Player
	cPlayerAccelXSlopeUp    = 0.2;          //Aceleracion maxima X Player subiendo rampa
	cPlayerAccelXSlopeDown  = 1.2;          //Aceleracion maxima X Player bajando rampa
	cPlayerAccelXSloping	= 0.15;          //Aceleracion maxima X Player resbalando por rampa
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
	player idPlayer;				//Identificador del proceso del jugador
	int idPlatform;				//Identificador de plataforma sobre la que esta el player
	int idObjectPicked;			//Identificador del objeto cogido
	int idObjectThrowed;        //Identificador del objeto lanzado
end;

declare process player()
public
	int cosa=2;
end
end