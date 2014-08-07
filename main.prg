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
	WGE_GenMatrixMapFile("test\random.bin");
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


//TODO: Calcular nivel inferior al que seria muerte segun tamaño mapeado
process player_gravity()
private 

byte jumping,		//Flag salto
byte grounded; 		//Flag en suelo
float velMaxX;		//Velocidad Maxima Horizontal
float accelx;		//Aceleracion Maxima Horizontal
float accelY;		//Aceleracion Maxima Vertical
int dir;		//Direccion de la colision

struct tiles_comprobar[8]
	int posx;
	int posy;
end;

int i,j;		//Variables auxiliares

BEGIN
	ancho = 32;
	alto = 32;
	velMaxX = 3.4;
	accelx = 1.2;
	accelY = 12;
	
	region = cGameRegion;
	ctype = c_scroll;
	z = ZPLAYER;
	priority = PLAYERPRIOR;
	
	graph = map_new(ancho,ancho,8);
	drawing_map(0,graph);
	drawing_color(300);
	draw_box(0,0,ancho,alto);
	drawing_color(200);
	draw_fcircle(ancho-8,alto-16,4);
	
	x = level.playerx0;
	y = level.playery0;
	
	fx = x;
	fy = y;
	
	loop
				
		//Control movimiento
		if (key(CKUP)) 
			if(!jumping && grounded) 
				jumping = true;
				grounded = false;
				vY = -accelY;
			end;
		end;
		
		if (key(CKRIGHT)) 
			if (vX < velMaxX) 
				vX+=accelx*(1-friction);
			end;
		end;
		if (key(CKLEFT)) 
			if (vX > -velMaxX) 
				vX-=accelx*(1-friction);
			end;
		end;
		
		//Fisicas
		if (!key(CKLEFT) && !key(CKRIGHT))
			vX *= friction;
		end;
		vY += gravity;
		
		//Colisiones
				 
		//comprobamos 9 tiles alrededor del player
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
		
		grounded = false;
		
		//Recorremos la lista de tiles a comprobar
		//for (i=0;i<9;i++)
			
			//Lanzamos comprobacion de colision con el tile actual
			//dir = colCheckTile(ID,tiles_comprobar[i].posX,tiles_comprobar[i].posY);
			
			dir = colCheckTileTerrain(ID); 
			
			if (dir == COLIZQ || dir == COLDER) 
				vX = 0;
				jumping = false;
			elseif (dir == COLDOWN) 
				grounded = true;
				jumping = false;
			elseif (dir == COLUP) 
				vY = 0;			//Flota por el techo	
				//vY *= -1;		//Rebota hacia abajo con la velocida que subia
				//vY = 2;		//Rebota hacia abajo con valor fijo
			end;
			
		//end;
		
		
		//Actualizar velocidades
		if (grounded)
			vY = 0;
		end;
		
		fx += vX;
		fy += vY;
		
		//Escalamos la posicion de floats en enteros
		if (abs(fx-x)>=1 ) //si la diferencia entre el float y el entero es una unidad
			x = fx;
		end;
		y = fy;

		frame;
end;
end;


process player_no_gravity()
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