// ========================================================================
//  Warcom Game Engine
//  Motor para juegos plataformas 2D
//  21/07/14
// ========================================================================

import "mod_key";
import "mod_map";
import "mod_video";
import "mod_text";
import "mod_scroll";
import "Mod_proc";
import "mod_sound";
import "Mod_screen";
import "Mod_draw";
import "Mod_grproc";
import "Mod_rand";
import "mod_file"; 
import "mod_math";
import "mod_say";
import "mod_debug";
import "mod_string";
import "mod_timers";
import "mod_time";
import "mod_mem";

include "engine.h";      //archivo de definiciones,constantes y variables globales

//Proceso principal
Process main()
Begin
		
	level.playerx0 = 896;
	level.playery0 = 672;
	level.playerx0 =1166;
	level.playery0 =128;
	
	priority = cMainPrior;	
		
	//Iniciamos el engine
	WGE_Init();
	//Iniciamos modo grafico
	WGE_InitScreen();
	//Creamos datos nivel aleatorios
	//WGE_GenLevelData("test\random.dat");
	//Cargamos archivo nivel
	//WGE_LoadLevel("test\random.dat");
	//Creamos un mapa aleatorio
	//WGE_GenRandomMapFile("test\random.bin",12,8);
	//Creamos un mapa con matriz definida
	//WGE_GenMatrixMapFile("test\random.bin");
	//Cargamos el mapeado del nivel
	WGE_LoadMapLevel("test\ToyLand.bin","test\tiles.fpg");
	//Iniciamos Scroll
	WGE_InitScroll();
	//Dibujamos el mapeado
	WGE_DrawMap();
	//Creamos el nivel cargado
	WGE_CreateLevel();
	
	//Creamos el jugador
	//idPlayer = player_no_gravity();
	//caja(672,160);
	//caja(672,160-64);
	player();
	
	//Bucle principal
	Loop
		   
		//salimos el juego
		If(key(_esc)) 
			WGE_Quit();
		End;
		
		Frame;
	End;

End; //Fin del main