// ========================================================================
//  Warcom Game Engine
//  Motor para juegos plataformas 2D
//  19/03/15
//
//  Definiciones del controles
// ========================================================================

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
	byte keyUse = 0;            			//Seleccion Flanco
    byte keyState[127][1];      			//Mapa estados en flanco anterior y actual
	byte keyLogger[127];					//Array de teclas del keylogger
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