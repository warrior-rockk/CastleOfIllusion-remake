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
		
	level.playerx0 = 120;
	level.playery0 = 0;
	priority = MAINPRIOR;	
	
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
	//debug;
	WGE_LoadMapLevel("test\random.bin");
	//Iniciamos Scroll
	WGE_InitScroll();
	//Dibujamos el mapeado
	WGE_DrawMap();
	//Creamos el nivel cargado
	//WGE_CreateLevel();
	
	//Creamos el jugador
	//idPlayer = player();
	idPlayer = player_gravity();
	
	//Bucle principal
	Loop
		   
		//salimos el juego
		If(key(_esc)) 
			WGE_Quit();
		End;
		
		Frame;
	End;

End; //Fin del main

process player()
begin
	ancho = 32;
	alto = 32;
	
	region = cGameRegion;
	ctype = c_scroll;
	z = ZPLAYER;
	
	graph = map_new(ancho,ancho,8);
	drawing_map(0,graph);
	drawing_color(300);
	draw_box(0,0,ancho,alto);
	
	x = level.playerx0;
	y = level.playery0;
	
	loop
		x+=key(_right)*2;
		x-=key(_left)*2;
		y+=key(_down)*2;
		y-=key(_up)*2;
		frame;
	end;
end;

process player_gravity()
private 
int i,j;
int dir;
float velX,velY,friction,gravity,c_vel;
int jumping,grounded;
struct tiles_comprobar[8]
	int posx;
	int posy;
end;
BEGIN
	ancho = 32;
	alto = 32;
	
	region = cGameRegion;
	ctype = c_scroll;
	z = ZPLAYER;
	priority = PLAYERPRIOR;
	
	graph = map_new(ancho,ancho,8);
	drawing_map(0,graph);
	drawing_color(300);
	draw_box(0,0,ancho,alto);
	
	x = level.playerx0;
	y = level.playery0;
	
	if (debugMode)
		flags = B_ABLEND;
	else
		flags = 0;
	end;
	

	c_vel = 3.4;
	friction = 0.8;
	gravity  = 0.3;
	
	fx = x;
	fy = y;
	
	loop
	
		//hero controls
		if (key(_up)) 
			if(!jumping && grounded) 
				jumping = true;
				grounded = false;
				vY = -c_vel*2;
			end;
		end;
		
		if (key(_right)) 
			if (vX < c_vel) 
				vX++;
			end;
		end;
		if (key(_left)) 
			if (vX > -c_vel) 
				vX--;
			end;
		end;
		
		//physics
		vX *= friction;
		vY += gravity;
		
		//collisions
		grounded = false;
		 
		//comprobamos 9 tiles alrededor del actor
		tiles_comprobar[0].posx = x/cTileSize;
		tiles_comprobar[0].posy = y/cTileSize;
		
		tiles_comprobar[1].posx = x/cTileSize;
		tiles_comprobar[1].posy = (y/cTileSize)+1;
		
		tiles_comprobar[2].posx = x/cTileSize;
		tiles_comprobar[2].posy = (y/cTileSize)-1;
		
		tiles_comprobar[3].posx = (x/cTileSize)+1;
		tiles_comprobar[3].posy = y/cTileSize;
		
		tiles_comprobar[4].posx = (x/cTileSize)-1;
		tiles_comprobar[4].posy = y/cTileSize;
		
		tiles_comprobar[5].posx = (x/cTileSize)+1;
		tiles_comprobar[5].posy = (y/cTileSize)+1;
		
		tiles_comprobar[6].posx = (x/cTileSize)-1;
		tiles_comprobar[6].posy = (y/cTileSize)+1;
		
		tiles_comprobar[7].posx = (x/cTileSize)+1;
		tiles_comprobar[7].posy = (y/cTileSize)-1;
		
		tiles_comprobar[8].posx = (x/cTileSize)-1;
		tiles_comprobar[8].posy = (y/cTileSize)-1;
		
		for (i=0;i<9;i++)
			//si existe el tile en el mapeado
			if (tiles_comprobar[i].posy<level.numTilesY && tiles_comprobar[i].posx<level.numTilesX 
			     && tiles_comprobar[i].posy>=0 && tiles_comprobar[i].posx>=0)
				 
				if (tileMap[tiles_comprobar[i].posy][tiles_comprobar[i].posx].tileCode <> 0) //si es tile solido
					dir = colCheckAABB(id,(tiles_comprobar[i].posx*cTileSize)+cHalfTSize,(tiles_comprobar[i].posy*cTileSize)+cHalfTSize,cTileSize,cTileSize);
				else
					dir = 0;
				end;
				
				if (dir == COLIZQ || dir == COLDER) 
					vX = 0;
					jumping = false;
				elseif (dir == COLDOWN) 
					grounded = true;
					jumping = false;
				elseif (dir == COLUP) 
					vY = 0;		
					//velY *= -1;
				end;
			end;
		end;
		
		
		//update c_vels
		if (grounded)
			vY = 0;
		end;
		
		fx += vX;
		fy += vY;
		
		//escalamos la posicion de floats en enteros
		if (abs(fx-x)>=1 ) //si la diferencia entre el float y el entero es una unidad
			x = fx;
		end;
		y = fy;

		frame;
end;
end;