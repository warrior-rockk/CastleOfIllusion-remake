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

//Teclas (se suprime por variables cuando tenga modificado el keylogger)
#define	K_UP 	  				_UP 
#define	K_DOWN	  				_DOWN 
#define	K_LEFT    				_LEFT 
#define	K_RIGHT	  				_RIGHT 
#define	K_JUMP	  				_L_ALT
#define	K_ACTION_ATACK			_L_CONTROL
#define K_PAUSE         		_SPACE

//Estados de un control
#define E_PRESSED    0
#define E_DOWN       1
#define E_UP         2


//Constantes
const
	ckeyCheckNumber 	= 6;		//Numero de teclas a comprobar
	ckeyLoggerMaxFrames = 1000;		//Numero maximo de frames a grabar
	cendRecordCode      = 128;      //Valor no asociado a tecla que indica fin de grabacion
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
	byte joyUse = 0;								//Seleccion Flanco
	byte joyState[13][1];							//Mapa estados flanco anterior y actual
	byte configuredButtons[7] = 10,11,12,13,3,2,9; //Configuracion de botones
	
	//Keylogger
	byte keyLogger[127];					//Array de teclas del keylogger
	byte controlLogger[6];					//Array de controles del controlLogger
	
	struct keyLoggerRecord					//Grabacion de teclas actual
		int frameTime[ckeyLoggerMaxFrames];	//Marca de tiempo
		byte keyCode[ckeyLoggerMaxFrames];	//Tecla pulsada
	end;
	byte keysCheck[ckeyCheckNumber] =	K_LEFT,	
										K_RIGHT,
										K_UP,
										K_DOWN,
										K_JUMP,
										K_ACTION_ATACK;		//Array de teclas a comprobar
	byte keyLoggerRecording;				//flag de grabando teclas
	byte keyLoggerPlaying;					//flag de reproduciendo teclas
	
End;

//Variables locales
Local
	
End;