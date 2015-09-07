// ========================================================================
//  Castle of Illusion Remake
//  Remake del COI de Master System en Bennu
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
import "mod_joy";
import "mod_wm";

include "engine.h";      //archivo de definiciones,constantes y variables globales
include "game.h";		 //archivo principal del juego

//Proceso principal
Process main()
Begin
		
	//iniciamos el juego
	gameInit();
	
	//Bucle principal
	Loop
		//salimos el juego
		if(key(_esc)) 
			wgeQuit();
		End;
		
		Frame;
	End;

End; //Fin del main