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
private
	idActor;
Begin
	
	//Iniciamos el engine
	WGE_Init();
	//Iniciamos modo grafico
	WGE_InitScreen();
	//Iniciamos Scroll
	WGE_InitScroll();
	//Creamos datos nivel aleatorios
	//WGE_GenLevelData("test\random.dat");
	//Cargamos archivo nivel
	//WGE_LoadLevel("test\random.dat");
	//Creamos un mapa aleatorio
	//WGE_GenRandomMapFile("test\random.bin",12,8);
	//Cargamos el mapeado del nivel
	WGE_LoadMapLevel("test\random.bin");
	//donde iria esto??
	idActor = actor();
	WGE_ControlScroll(idActor);
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

process actor()
begin
	ancho = 32;
	alto = 32;
	
	region = cGameRegion;
	ctype = c_scroll;
	z = ZACTOR;
	
	graph = map_new(ancho,ancho,8);
	drawing_map(0,graph);
	drawing_color(300);
	draw_box(0,0,ancho,alto);
	
	x = 10;
	y = 10;
	
	loop
		x+=key(_right)*2;
		x-=key(_left)*2;
		y+=key(_down)*2;
		y-=key(_up)*2;
		frame;
	end;
end;