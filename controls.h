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
#define CTRL_ANY				7
#define CTRL_KEY_ANY            8
#define CTRL_BUTTON_ANY         9

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
	int lastKeyEvent;									//Ultima tecla pulsado
	int lastButtonEvent;								//Ultimo boton pulsado
	//teclas
	byte keyUse = 0;            						//Seleccion Flanco
    byte keyState[127][1];      						//Mapa estados en flanco anterior y actual
	byte configuredKeys[7] = _UP,_DOWN,_LEFT,_RIGHT,
							_Z,_X,_ENTER;	//configuracion de teclas
	
	//joystick
	byte joyUse = 0;									//Seleccion Flanco
	byte joyState[13][1];								//Mapa estados flanco anterior y actual
	byte configuredButtons[7] = 10,11,12,13,3,2,9; 		//Configuracion de botones
	
	//Controls logger
	byte controlLoggerRecording;				//flag de grabando controles
	
	byte controlLoggerPlaying;					//flag de reproduciendo controles
	byte controlLoggerFinished;					//flag de reproduccion finalizada
	int controlPlayingFrame;					//numero de frame reproducido actual
	byte StopControlPlaying;					//flag para detener la reproduccion
	
	byte controlLogger[6][3];					//Array de controles del controlLogger
	
	struct controlLoggerRecord							//Grabacion de teclas actual
		int frameTime[cControlLoggerMaxFrames];			//Marca de tiempo
		byte controlCode[cControlLoggerMaxFrames];		//Tecla pulsada
		byte controlEvent[cControlLoggerMaxFrames];  	//Evento
	end;
	
	//string teclas
	string keyStrings[100] = "","ESC","1","2","3","4","5","6","7","8","9","0","MINUS","PLUS","BACKSPACE","TAB","Q","W","E","R","T","Y","U","I","O","P","L_BRACHET","R_BRACHET","ENTER","CONTROL","A","S","D","F","G","H","J","K","L","SEMICOLON","APOSTROPHE","WAVE","L_SHIFT","BACKSLASH","Z","X","C","V","B","N","M","COMMA","POINT","SLASH","R_SHIFT","PRN_SCR","ALT","SPACE","CAPS_LOCK","F1","F2","F3","F4","F5","F6","F7","F8","F9","F10","NUM_LOCK","SCROLL_LOCK","HOME","UP","PGUP","C_MINUS","LEFT","C_CENTER","RIGHT","C_PLUS","END","DOWN","PGDN","INS","DEL","","","","F11","F12","LESS","EQUALS","GREATER","ASTERISK","R_ALT","R_CONTROL","L_ALT","L_CONTROL","MENU","L_WINDOWS","R_WINDOWS";
	//string joyPad
	string joyStrings[13] = "BT1","BT2","BT3","BT4","BT5","BT6","BT7","BT8","BT9","BT10","J_UP","J_DOWN","J_LEFT","J_RIGHT";
	//string controles
	string controlStrings[6] = "UP","DOWN","LEFT","RIGHT","JUMP","ACTION_ATACK","START";
End;