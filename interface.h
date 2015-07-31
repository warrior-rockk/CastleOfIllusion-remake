//========================================================================
//  Warcom Game Engine
//  Motor para juegos plataformas 2D
//  31/07/15
//
//  Definiciones del interface (gui,textos...)
// ========================================================================

//definiciones

//idiomas del juego
#define ENG_LANG                			0
#define ESP_LANG                			1

//lista de textos
#define INTRO1_TEXT             			0
#define INTRO2_TEXT             			1
#define INTRO3_TEXT             			2
#define MENU_TEXT							3
#define CONFIG_TEXT							4
#define CONFIG_VAL1_TEXT					5
#define CONFIG_VAL2_TEXT					6
#define CONFIG_CONTROLS_TEXT				7
#define CONFIG_CONTROLS_LIST_TEXT			8
#define PRESS_KEY_TEXT						9
#define PRESS_BUTTON_TEXT					10
#define PRESS_START_TEXT					11
#define TUTORIAL1_TEXT						12
#define TUTORIAL2_TEXT						13
#define TUTORIAL3_TEXT						14
#define TUTORIAL4_TEXT						15
#define TUTORIAL5_TEXT						16
#define PAUSE_TEXT							17
#define GAMEOVER_TEXT						18

//Constantes
const
	cNumLanguages	= 2; 			//Numero de idiomas
	cNumGameTexts   = 19;			//Numero de textos
	
	//Cuadros dialogo
	dialogTextMarginX		= 30;			//Margen horizontal texto
	dialogTextMarginY		= 10;			//Margen Vertical texto
	dialogTextPadding 		= 16;			//Separacion vertical lineas
	dialogCursorMarginX 	= 10;			//Margen cursor
End;

//variables globales
Global
	string gameTexts[cNumLanguages-1][cNumGameTexts];	//Tabla de idiomas de textos
end;
	
//declaracion de proceso dialogo
declare process WGE_Dialog(int x,int y,int _width,int _height)
public
	int width;
	int height;
end
end