// ========================================================================
//  Warcom Game Engine
//  Motor para juegos plataformas 2D
//  19/03/15
//
//  Definiciones del controles
// ========================================================================

//Controles
#define CTRL_UP					0
#define	CTRL_DOWN	  			1
#define	CTRL_LEFT    			2
#define	CTRL_RIGHT	  		 	3
#define	CTRL_JUMP	  			4
#define	CTRL_ACTION_ATACK		5
#define CTRL_START				6

//Estados de un control
#define E_PRESSED    0
#define E_DOWN       1
#define E_UP         2

//Constantes
const
	cControlCheckNumber 	= 6;		//Numero de controles a comprobar
	cControlLoggerMaxFrames = 1000;		//Numero maximo de frames a grabar
	cendRecordCode     		= 128;      //Valor no asociado a control que indica fin de grabacion
End;

//Data Types

	
//Variables Globales
Global
	//teclas
	byte keyUse = 0;            						//Seleccion Flanco
    byte keyState[127][1];      						//Mapa estados en flanco anterior y actual
	byte configuredKeys[7] = _UP,_DOWN,_LEFT,_RIGHT,
							_L_ALT,_L_CONTROL,_SPACE;	//configuracion de teclas
	
	//joystick
	byte joyUse = 0;									//Seleccion Flanco
	byte joyState[13][1];								//Mapa estados flanco anterior y actual
	byte configuredButtons[7] = 10,11,12,13,3,2,9; 		//Configuracion de botones
	
	//Controls logger
	byte controlLoggerRecording;				//flag de grabando controles
	byte controlLoggerPlaying;					//flag de reproduciendo controles
	byte controlLoggerFinished;					//flag de reproduccion finalizada
	
	byte controlLogger[6][3];					//Array de controles del controlLogger
	
	struct controlLoggerRecord							//Grabacion de teclas actual
		int frameTime[cControlLoggerMaxFrames];			//Marca de tiempo
		byte controlCode[cControlLoggerMaxFrames];		//Tecla pulsada
		byte controlEvent[cControlLoggerMaxFrames];  	//Evento
	end;
	
End;

//Variables locales
Local
	
End;