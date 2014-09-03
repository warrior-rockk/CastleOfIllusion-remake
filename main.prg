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
	plataforma(190,190,50);
		
	//Bucle principal
	Loop
		   
		//salimos el juego
		If(key(_esc)) 
			WGE_Quit();
		End;
		
		Frame;
	End;

End; //Fin del main


//TODO: Calcular nivel inferior al que seria muerte segun tama�o mapeado
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
float friction;				//Friccion local
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
		
		//friccion local
		grounded ? friction = floorFriction : friction = airFriction;
		
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
		
		//lanzamos comprobacion con procesos caja
		repeat
			//obtenemos siguiente colision
			colID = get_id(TYPE caja);
			
			dir = colCheckProcess(id,colID);
			
			//aplicamos la direccion de la colision
			applyDirCollision(ID,dir,&grounded);
		
		until (colID == 0);
	
		//lanzamos comprobacion con procesos plataforma
		repeat
			//obtenemos siguiente colision
			colID = get_id(TYPE plataforma);
			
			dir = colCheckProcess(id,colID);
			
			//aplicamos la direccion de la colision
			applyDirCollision(ID,dir,&grounded);
			
			if (colID <> 0)
				if (dir == COLDOWN)
					idPlatform = colID;
					fY += 1;
				else
					idPlatform = 0;
				end;
			end;
			
		until (colID == 0);
		
		//Actualizar velocidades
		if (grounded)
			vY = 0;
			jumping = false;
		end;
		
		fX += vX;
		fY += vY;
		
		//Escalamos la posicion de floats en enteros
		//si la diferencia entre el float y el entero es una unidad
		if (abs(fX-x) >= 1 ) 
			//redondeamos el valor a entero
			x = round(fX);
		end;
		y = fY;
		
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