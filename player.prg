// ========================================================================
//  Warcom Game Engine
//  Motor para juegos plataformas 2D
//  16/09/14
//
//  Proceso jugador principal
// ========================================================================

//TODO: Calcular nivel inferior al que seria muerte segun tamaño mapeado
//		Salto distinto desde escalera
//		Fuerza salto segun pulsacion tecla
//		bloqueo del agacharse si muro en cabeza
process player_gravity()
private 

byte  jumping,				//Flag salto
byte  grounded; 			//Flag en suelo
byte  onStairs;				//Flag de en escaleras
byte  crouched;				//Flag de agachado
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
	ancho = cPlayerAncho;
	alto = cPlayerAlto;
	velMaxX = cPlayerVelMaxX;
	accelx 	= cPlayerAccelX;
	accelY 	= 12;
	
	region = cGameRegion;
	ctype = c_scroll;
	z = cZPlayer;
	priority = cPlayerPrior;
	
	//establecemos el id de player
	idPlayer = id;
	
	//dibujamos el personaje con sus dimensiones
	debugDrawPlayer();
	
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
					//centramos el objeto en el tile escalera
					fx = x+(cTileSize>>1)-(x%cTileSize);
					//bajamos las escaleras
					fY += 2;
				//en caso contrario, estamos en la base de la escalera
				else
					//bajamos el objeto a la escalera
					fy += (alto>>1);
				end;
				//quitamos velocidades
				vY = 0;
				vX = 0;
				//Establecemos el flag de escalera
				onStairs = true;
				//desactivamos flag salto
				jumping = false;
				//desactivamos flag agachado
				crouched = false;
			else 
				//si no escalera, agacharse si esta en suelo
				crouched = grounded;
				onStairs = false;
			end;
		else
			crouched = false;
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
		
		//CONTROL DIMENSIONES
		
		//cambio a agachado
		if (crouched && alto == cPlayerAlto)
			//establecemos altura agachado
			alto = cPlayerAltoCrouch;
			//redibujamos el player (provisional)
			debugDrawPlayer();
			//actualizamos sus puntos de colision
			WGE_CreatePlayerColPoints(id);
			//corregimos la coordenada Y
			fy = fy+((cPlayerAlto-cPlayerAltoCrouch)>>1);
		elseif (not crouched && alto == cPlayerAltoCrouch)
			//establecemos altura normal
			alto = cPlayerAlto;
			//redibujamos el player (provisional)
			debugDrawPlayer();
			//actualizamos sus puntos de colision
			WGE_CreatePlayerColPoints(id);
			//corregimos la coordenada Y
			fy = fy-((cPlayerAlto-cPlayerAltoCrouch)>>1);
		end;
		
		//COLISIONES	
		
		//condiciones iniciales pre-colision
		grounded = false;
		idPlatform = 0;
		priority = cPlayerPrior;		
		
		//Recorremos la lista de puntos a comprobar
		for (i=0;i<cNumColPoints;i++)
				
			//lanzamos comprobacion de terreno con los puntos de colision
			dir = colCheckTileTerrain(ID,i);
			
			//aplicamos la direccion de la colision
			applyDirCollision(ID,dir,&grounded);
			
		end;
		
		//lanzamos comprobacion con procesos objeto
		repeat
			
			//obtenemos siguiente colision
			colID = get_id(TYPE objeto);
			
			//tratamos las colisiones separadas por ejes
			//para poder andar sobre varios procesos corrigiendo la y
			
			//colisiones verticales con procesos
			dir = colCheckProcess(id,colID,VERTICALAXIS);
			//aplicamos la direccion de la colision
			applyDirCollision(ID,dir,&grounded);
			//corregimos la Y truncamos fY
			if (dir == COLDOWN )
				y = fY;
				fY = y;
			end;
			
			//colisiones horizontales con procesos
			dir = colCheckProcess(id,colID,HORIZONTALAXIS);
			//aplicamos la direccion de la colision
			applyDirCollision(ID,dir,&grounded);
			
		until (colID == 0);
		
		
		//lanzamos comprobacion con procesos plataforma
		repeat
			//obtenemos siguiente colision
			colID = get_id(TYPE plataforma);
			//comprobamos colision en ambos ejes
			dir = colCheckProcess(id,colID,BOTHAXIS);
			
			//aplicamos la direccion de la colision
			applyDirCollision(ID,dir,&grounded);
			
			//si existe plataforma
			if (colID <> 0)
				//y estoy encima de ella
				if (dir<>NOCOL && grounded)
					//seteamos idPlatform
					idPlatform = colID;
					//cambiamos prioridades
					priority = cPlatformPrior;
					colID.priority = cPlayerPrior;
				else
					colID.priority = cPlatformPrior;
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
		
		positionToInt(id);
		
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