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
	//level.playerx0 =1166;
	//level.playery0 =100;
	//level.playerx0 =388;
	//level.playery0 =320;
	//level.playerx0 =408;
	//level.playery0 =640;
	
	//Iniciamos el engine
	WGE_Init();
	
	//Bucle principal
	Loop
		   
		//salimos el juego
		If(key(_esc)) 
			WGE_Quit();
		End;
		
		Frame;
	End;

End; //Fin del main