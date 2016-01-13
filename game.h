// ========================================================================
//  Castle of Illusion Remake
//  Remake del COI de Master System en Bennu
//  07/09/15
// ========================================================================

//Estado del juego
#define	SPLASH			0
#define MENU			1
#define LOADLEVEL   	2
#define PLAYLEVEL   	3
#define RESTARTLEVEL	5
#define LEVELENDED  	6
#define GAMEOVER        7
#define CONTINUEGAME    8
#define ATTRACTMODE     9
#define TUTORIAL        10
#define INTRO           11
#define MENU_CONFIG     12
#define MENU_CONTROLS   13
#define MENU_KEYS       14
#define MENU_BUTTONS    15
#define LANG_SEL        16
#define PRELUDE         17
#define LEVEL_SELECT    18
#define INITLEVEL		19
#define RESTARTGAME     20
#define LOADING         21

//efectos de sonido generales
#define PAUSE_SND				0
#define TIMESCORE_SND           1
#define STOPSCORE_SND			2
#define COUNTDOWN_SND           3
#define MENU_SND                4

//musicas generales
#define DEAD_MUS				0
#define END_LEVEL_MUS           1
#define BOSS_MUS				3
#define INTRO_MUS               4

//identificadores de los niveles
#define PRELUDE_LEVEL			1
#define TUTORIAL_LEVEL			2
#define LEVEL_SELECT_LEVEL		3
#define TOYLAND_LEVEL			4
#define TOYLAND_2_LEVEL			5
#define WOODS_LEVEL             6
#define CANDYLAND_LEVEL         7

//Estado de los niveles
#define LEVEL_UNCOMPLETED       0
#define LEVEL_COMPLETED         1
#define LEVEL_DOOR_CLOSED       2

//constantes
const 
	cLoadingDelay = 	5;		//Retardo carga para setear resolucion
end;

//Variables globales
global
		
end;

//definiciones del juego
include "game.prg";