// ========================================================================
//  Warcom Game Engine
//  Motor para juegos plataformas 2D
//  11/02/15
//
//  Definiciones del player
// ========================================================================

//estados del player
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
#define INVISIBLE_STATE         23
#define INITIAL_STATE           24
#define PUSHED_STATE            25
#define FAILPICKED_STATE        26

//efectos de sonido
#define BOUNCE_SND				0
#define DEAD_SND				1
#define HURT_SND				2
#define JUMP_SND				3
#define PICK_SND				4
#define STAIRS_SND				5
#define THROW_SND				6
#define NOPICK_SND				7

Const
	//Fisicas
	cPlayerVelMaxX			= 1.4;			//Velocidad Maxima X Player
	cPlayerWaterVelMaxX		= 0.8;			//Velocidad Maxima X Player en agua
	cPlayerVelMaxXSlopeUp	= 1;            //Velocidad Maxima X Player subiendo rampa
	cPlayerVelMaxXSlopeDown = 2;            //Velocidad Maxima X Player bajando rampa
	cPlayerVelMaxXSloping	= 6;            //Velocidad Maxima X Player resbalando por rampa
	cPlayerAccelX           = 0.4;          //Aceleracion maxima X Player
	cPlayerWaterAccelX      = 0.1;          //Aceleracion maxima X Player
	cPlayerAccelXSlopeUp    = 0.2;      	//Aceleracion maxima X Player subiendo rampa
	cPlayerAccelXSlopeDown  = 0.65;    	    //Aceleracion maxima X Player bajando rampa
	cPlayerAccelXSloping	= 0.15;         //Aceleracion maxima X Player resbalando por rampa
	cPlayerDecelXSlopeUp    = 0.1;			//Factor deceleracion X al subir rampa
	
	cPlayerAccelY			= 2.2;//3;		//Aceleracion Player Y salto
	cPlayerWaterAccelY		= 0.99;			//Aceleracion Player Y salto en agua
	cPlayerExitWaterAccelY	= 3.5;			//Aceleracion Player Y salto salir del agua
	cPlayerVelMaxY          = 10;			//Velocidad Maxima Y Player
	cPlayerWaterVelMaxY     = 1;			//Velocidad Maxima Y Player en agua
	cPlayerVelYStairs       = 1;			//Velocidad movimiento en escalera
	cPlayerAtackBounce      = 2.3;//4;      //Rebote al romper objet/atacar
	cPlayerPowerAtackBounce = 1.02;//1.4;   //Extra de rebote al romper/atacar
	cPlayerPowerJumpFactor  = 0.25;			//Factor de incremento poder salto
	cPlayerWaterJumpFactor  = 0.15;			//Factor de incremento salto en agua
	cPlayerMaxPowerJump     = 16;           //Maximo incremento poder salto
	cPlayerMinVelToIdle     = 0.1;			//Velocidad minima para pasar a reposo
		
	//Personaje
	cPlayerAncho			= 16;			//Ancho del jugador
	cPlayerAlto				= 32;			//Alto del jugador
	cPlayerAltoCrouch		= 16;			//Alto del jugador agachado
	
	cPickingTime			= 20;			//Tiempo retraso para recojer objeto
	cHurtDisabledTime       = 100;			//Tiempo invencible
	
	//Offset Posicion objeto cogido
	cObjectPickedPosX       = 3;						//Offset X posicion player para el objeto cogido
	cObjectPickedPosY       = -(cPlayerAlto>>1);		//Offset Y posicion player para el objeto cogido
	cThrowObjectVelX        = 3;						//Velocidad X lanzamiento objeto
	cThrowObjectVelY        = -3;						//Velocidad Y lanzamiento objeto
	
	cPickCheckObjectWidth   = 2;			//base de comprobacion de cojer objeto
	
	cHurtVelX               = 4;			//desplazamiento X cuando daño
	cHurtVelY               = 4;			//desplazamiento Y cuando daño
end;

Global
	//jugador
	int fpgPlayer;					//Archivo grafico del player
	entity idPlayer;				//Identificador del proceso del jugador
	int idPlatform;				    //Identificador de plataforma sobre la que esta el player
end;

//declaracion de proceso player
Declare Process player()
public
	_entityPublicData this;			//datos publicos de entidad
end
end

//declaracion de proceso muerte player
Declare Process deadPlayer()
public
	_entityPublicData this;			//datos publicos de entidad
end
end