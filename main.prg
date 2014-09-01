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
	WGE_GenMatrixMapFile("test\random.bin");
	//Cargamos el mapeado del nivel
	//TODO: carga dinamica comentada. Ver porque falla a veces
	WGE_LoadMapLevel("test\random.bin");
	//Iniciamos Scroll
	WGE_InitScroll();
	//Dibujamos el mapeado
	WGE_DrawMap();
	//Creamos el nivel cargado
	//WGE_CreateLevel();
	
	//Creamos el jugador
	//idPlayer = player_no_gravity();
	//caja(672,160);
	//caja(672,160-64);
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
//		Salto distinto desde escalera
//		Fuerza salto segun pulsacion tecla
process player_gravity()
private 

byte  jumping,				//Flag salto
byte  grounded; 			//Flag en suelo
byte  onStairs;				//Flag de en escaleras
float velMaxX;				//Velocidad Maxima Horizontal
float accelX;				//Aceleracion Maxima Horizontal
float accelY;				//Aceleracion Maxima Vertical
int	  dir;					//Direccion de la colision
int   colID;				//Proceso con el que se colisiona

struct tiles_comprobar[8]
	int posx;
	int posy;
end;

int i,j;		//Variables auxiliares

BEGIN
	ancho = 32;
	alto = 32;
	velMaxX = cPlayerVelMaxX;
	accelx 	= cPlayerAccelX;
	accelY 	= 12;
	
	region = cGameRegion;
	ctype = c_scroll;
	z = cZPlayer;
	priority = cPlayerPrior;
	
	//dibujamos el personaje como una caja
	graph = map_new(ancho,alto,8);
	drawing_map(0,graph);
	drawing_color(300);
	draw_box(0,0,ancho,alto);
	//dibujamos la nariz para diferenciar hacia donde mira
	drawing_color(200);
	draw_fcircle((ancho>>1)+(ancho>>2),(alto>>2),4);
	
	//definimos los puntos de colision
	//respecto al centro del personaje
	WGE_CreatePlayerColPoints(id);
	
	//Posicion actual del nivel actual
	x = level.playerx0;
	y = level.playery0;
	
	fx = x;
	fy = y;
	
	loop
		
		//CONTROL MOVIMIENTO		
		
		if (key(CKRIGHT)) 
			if (vX < velMaxX) 
				vX+=accelx*(1-friction);
			end;
			onStairs = false;
		end;
		
		if (key(CKLEFT)) 
			if (vX > -velMaxX) 
				vX-=accelx*(1-friction);
			end;
			onStairs = false;
		end;
		
		if (key(CKBT1)) 
			if(!jumping && (grounded || onStairs)) 
				jumping = true;
				grounded = false;
				vY = -accelY;
				onStairs = false;
			end;
		end;
		
		if (key(CKUP))			
			//si el centro del objeto esta en tile escaleras
			if (getTileCode(id,CENTER_POINT) == STAIRS || getTileCode(id,CENTER_POINT) == TOP_STAIRS)
				//quitamos velocidades
				vY = 0;
				vX = 0;
				//centramos el objeto en el tile escalera
				fx = x+(cTileSize>>1)-(x%cTileSize);
				//subimos las escaleras
				fY -= 2;
				//Establecemos el flag de escalera
				onStairs = true;
				//desactivamos flag salto
				jumping = false;
			//en caso contrario, si el pie derecho esta en el TOP escalera, sales de ella
			elseif (getTileCode(id,CENTER_DOWN_POINT) == TOP_STAIRS)
				//subimos a la plataforma (tile superior a la escalera)
				fy = (((y/cTileSize)*cTileSize)+cTileSize)-(alto>>1);
				//Quitamos el flag de escalera				
				onStairs = false;
			end;				
		end;
		
		if (key(CKDOWN))
			//si el centro inferior del objeto esta en tile escaleras
			if (getTileCode(id,CENTER_DOWN_POINT) == TOP_STAIRS || getTileCode(id,CENTER_DOWN_POINT) == STAIRS)
				//si el centro del objeto esta en tile escaleras
				if (getTileCode(id,CENTER_POINT) == TOP_STAIRS || getTileCode(id,CENTER_POINT) == STAIRS)	
					//quitamos velocidades
					vY = 0;
					vX = 0;
					//centramos el objeto en el tile escalera
					fx = x+(cTileSize>>1)-(x%cTileSize);
					//bajamos las escaleras
					fY += 2;
					//Establecemos el flag de escalera
					onStairs = true;
					//desactivamos flag salto
					jumping = false;
				//en caso contrario, estamos en la base de la escalera
				else
					//quitamos velocidades
					vY = 0;
					vX = 0;
					//bajamos el objeto a la escalera
					fy += (alto>>1);
					//establecemos el flag escaleras
					onStairs = true;
					//desactivamos flag salto
					jumping = false;
				end;
			end;					
		end;
		
		//FISICAS
		
		//friccion
		if (!key(CKLEFT) && !key(CKRIGHT))
			vX *= friction;
		end;
		
		//gravedad
		if (!onStairs)
			vY += gravity;
		end;
		
		//aceleracion rampas
		if (cSlopesEnabled)
			//si estoy en una rampa de 45 grados
			if (getTileCode(id,CENTER_DOWN_POINT) == SLOPE_45)
				//Subiendola, cambio consignas velocidades
				if (key(CKRIGHT))	
					velMaxX = cPlayerVelMaxXSlopeUp;
					accelx 	= cPlayerAccelXSlopeUp;
					if (vX > velMaxX)
						vX -= cPlayerDecelXSlopeUp;
					end;
				//Bajandola, cambio consignas velocidades
				elseif (key(CKLEFT))
					velMaxX = cPlayerVelMaxXSlopeDown;
					accelx 	= cPlayerAccelXSlopeDown;
				end;
			//si estoy en una rampa de 135 grados
			elseif (getTileCode(id,CENTER_DOWN_POINT) == SLOPE_135)
				//Subiendola, cambio consignas velocidades
				if (key(CKLEFT))	
					velMaxX = cPlayerVelMaxXSlopeUp;
					accelx 	= cPlayerAccelXSlopeUp;
					if (vX < -velMaxX)
						vX += cPlayerDecelXSlopeUp;
					end;
				//Bajandola, cambio consignas velocidades
				elseif (key(CKRIGHT))
					velMaxX = cPlayerVelMaxXSlopeDown;
					accelx  = cPlayerAccelXSlopeDown;
				end;
			//si no, restauro consignas velocidades
			else
				velMaxX = cPlayerVelMaxX;
				accelX 	= cPlayerAccelX;
			end;
		end;
		

		//COLISIONES
				 
		//comprobamos 9 tiles alrededor del player
		/*tiles_comprobar[0].posx = x/cTileSize;
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
		*/
		
		grounded = false;
				
		//Recorremos la lista de tiles a comprobar
		//for (i=0;i<9;i++)
			
			//Lanzamos comprobacion de colision con el tile actual
			//dir = colCheckTile(ID,tiles_comprobar[i].posX,tiles_comprobar[i].posY);
		
		//Recorremos la lista de puntos a comprobar
		for (i=0;i<cNumColPoints;i++)
				
			//lanzamos comprobacion de terreno con los puntos de colision
			dir = colCheckTileTerrain(ID,i);
			
			//aplicamos la direccion de la colision
			applyDirCollision(ID,dir,&grounded);
			
		end;
		
		//TODO: no tengo que repetir las acciones segun colision por ser las
		//mismas que arriba. Pensar algo
		//lanzamos comprobacion con procesos caja
		repeat
			//obtenemos siguiente colision
			colID = get_id(TYPE caja);
			
			dir = colCheckProcess(id,colID);
			
			//aplicamos la direccion de la colision
			applyDirCollision(ID,dir,&grounded);
		
		until (colID == 0);
		

			
		//Actualizar velocidades
		if (grounded)
			vY = 0;
			jumping = false;
		end;
		
		fx += vX;
		fy += vY;
		
		//Escalamos la posicion de floats en enteros
		//si la diferencia entre el float y el entero es una unidad
		if (abs(fx-x) >= 1 ) 
			x = fx;
		end;
		y = fy;
		
		frame;
	
	end;
end;

process caja(int x,int y);
private
byte grounded;
int i;
int colID;
begin
	ancho = 16;
	alto = 16;
	
	graph = map_new(ancho,alto,8,0);
	map_clear(0,graph,300);
	
	region = cGameRegion;
	ctype = c_scroll;
	z = cZMap1;
	
	fx = x;
	fy = y;
	
	WGE_CreateObjectColPoints(id);
	
	loop
				
		//FISICAS	
		vX *= friction;
		vY += gravity;
		
		grounded = false;
		
				
		//Recorremos la lista de puntos a comprobar
		for (i=0;i<cNumColPoints;i++)					
			//aplicamos la direccion de la colision
			applyDirCollision(ID,colCheckTileTerrain(ID,i),&grounded);			
		end;
		
		//lanzamos comprobacion con procesos caja
		
		repeat
			//obtenemos siguiente colision
			colID = get_id(TYPE caja);
			if (colID <> ID) 
				//aplicamos la direccion de la colision
				applyDirCollision(ID,colCheckProcess(id,colID),&grounded);
			end;
		until (colID == 0 );
		
		
		//Actualizar velocidades
		if (grounded)
			vY = 0;
		end;
		
		fx += vX;
		fy += vY;
		
		//Escalamos la posicion de floats en enteros
		//si la diferencia entre el float y el entero es una unidad
		if (abs(fx-x) >= 1 ) 
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
	z = cZPlayer;
	
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