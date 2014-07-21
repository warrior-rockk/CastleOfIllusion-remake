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
import "mod_mem";

include "engine.h";      //archivo de definiciones y variables globales

//Proceso principal
Process main()
Begin
	
	//Iniciamos modo grafico
	WGE_InitScreen();
	//Iniciamos Scroll
	WGE_InitScroll();
	//Cargamos archivo nivel
	WGE_LoadLevel("test\testLevel.dat");
	//Cargamos el mapeado del nivel
	WGE_LoadMapLevel("test\testMap.bin");
	//Dibujamos el mapeado
	WGE_DrawMap();
	//Creamos el nivel cargado
	//WGE_CreateLevel();
	
	//Bucle principal
	Loop
		   
		//salimos el juego
		If(key(_esc)) 
			WGE_Quit();
		End;
		
		Frame;
	End;

End; //Fin del main