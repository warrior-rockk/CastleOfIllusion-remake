// ========================================================================
//  Warcom Game Engine
//  Motor para juegos plataformas 2D
//  16/09/14
//
//  Proceso jugador principal
// ========================================================================

//TODO: Calcular nivel inferior al que seria muerte segun tama�o mapeado
//		Salto distinto desde escalera
//		Fuerza salto segun pulsacion tecla
//		bloqueo del agacharse si muro en cabeza
process player_gravity()
private 

byte  jumping,				//Flag salto
byte  grounded; 			//Flag en suelo
byte  onStairs;				//Flag de en escaleras
byte  crouched;				//Flag de agachado
byte  on45Slope;			//Flag en pendiente 45 grados
byte  on135Slope;			//Flag en pendiente 135 grados
byte  sloping;              //Resbalando por una pendiente
byte  atacking;             //Flag de atacando
byte  picking;				//Flag de recogiendo
byte  picked;				//Flag de recogido
byte  canmove;				//Flag de movimiento permitido
float velMaxX;				//Velocidad Maxima Horizontal
float accelX;				//Aceleracion Maxima Horizontal
float accelY;				//Aceleracion Maxima Vertical
float friction;				//Friccion local
int	  dir;					//Direccion de la colision
int   colID;				//Proceso con el que se colisiona
int   objectforPickID;		//Proceso de tipo objeto que se colisiona lateralmente
int   pickingCounter; 		//Contador para recojer objeto
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
	accelY 	= cPlayerAccelY;
	
	region = cGameRegion;
	ctype = c_scroll;
	z = cZPlayer;
	priority = cPlayerPrior;
	file = fpg_load("test\player.fpg");
	
	//establecemos el id de player
	idPlayer = id;
	
	//dibujamos el personaje con sus dimensiones
	//debugDrawPlayer();
	
	//definimos los puntos de colision
	//respecto al centro del personaje
	WGE_CreatePlayerColPoints(id);
	
	//Posicion actual del nivel actual
	x = level.playerx0;
	y = level.playery0;
	
	fx = x;
	fy = y;
	
	canmove = true;
	
	loop
		
		
		
		//CONTROL MOVIMIENTO		
		if (canmove)
			
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
			
			if (key(CKBT2)) 
				if (jumping && !picked)
					atacking = true;
				end;
				if (picking)
					picked = true;
				end;
			end;
			
			if (key(CKUP))			
				//si objeto cogido, no podemos ni agacharnos y bajar escaleras
				if (!picked)
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
			end;
			
			if (key(CKDOWN))
				//si objeto cogido, no podemos ni agacharnos y bajar escaleras
				if (!picked)
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
				end;
			else
				crouched = false;
			end;
		
		end; //end del canmove
			
		//FISICAS
		
		//valor friccion local
		if (sloping && (on45Slope || on135Slope))
			friction = 1;
		elseif (grounded)
			friction = floorFriction;
		else
			friction = airFriction;
		end;
		
		//friccion
		if (!key(CKLEFT) && !key(CKRIGHT))
			vX *= friction;
		end;
						
		//gravedad
		if (!onStairs)
			vY += gravity;
		end;
		
		//Cambio velocidades y aceleracion en rampas
		if (cSlopesEnabled)
			
			//Control Rampas
			on135Slope = getTileCode(id,LEFT_DOWN_POINT) == SLOPE_135 || 
						 getTileCode(id,DOWN_L_POINT) == SLOPE_135    || 
						 getTileCode(id,CENTER_DOWN_POINT) == SLOPE_135;
			on45Slope  = getTileCode(id,RIGHT_DOWN_POINT) == SLOPE_45 || 
						 getTileCode(id,DOWN_R_POINT) == SLOPE_45     || 
						 getTileCode(id,CENTER_DOWN_POINT) == SLOPE_45;
			
			//si estoy en una rampa de 45 grados
			if (on45Slope)
				//Subiendola, cambio consignas velocidades
				if (!isBitSet(flags,B_HMIRROR))	
					velMaxX = cPlayerVelMaxXSlopeUp;
					accelx 	= cPlayerAccelXSlopeUp;
					if (vX > velMaxX)
						vX -= cPlayerDecelXSlopeUp;
					end;
				//Bajandola, cambio consignas velocidades
				elseif (isBitSet(flags,B_HMIRROR))
					//si esta atacando,resbala por la rampa
					if ((atacking && key(CKLEFT)) || sloping)
						sloping = true;
						canmove = false;
						friction = 1;
						velMaxX = cPlayerVelMaxXSloping;
						accelx  = cPlayerAccelXSloping;
						vX-=accelx;
					else
						velMaxX = cPlayerVelMaxXSlopeDown;
						accelx 	= cPlayerAccelXSlopeDown;
					end;
				end;
			//si estoy en una rampa de 135 grados
			elseif (on135Slope) 
				//Subiendola, cambio consignas velocidades
				if (isBitSet(flags,B_HMIRROR))	
					velMaxX = cPlayerVelMaxXSlopeUp;
					accelx 	= cPlayerAccelXSlopeUp;
					if (vX < -velMaxX)
						vX += cPlayerDecelXSlopeUp;
					end;
				//Bajandola, cambio consignas velocidades
				elseif (!isBitSet(flags,B_HMIRROR))
					//si esta atacando,resbala por la rampa
					if ((atacking && key(CKRIGHT)) || sloping)
						sloping = true;
						canmove = false;
						friction = 1;
						velMaxX = cPlayerVelMaxXSloping;
						accelx  = cPlayerAccelXSloping;
						vX+=accelx;
					else
						velMaxX = cPlayerVelMaxXSlopeDown;
						accelx  = cPlayerAccelXSlopeDown;
					end;
				end;
			//si no, restauro consignas velocidades
			else
				velMaxX = cPlayerVelMaxX;
				accelX 	= cPlayerAccelX;
				sloping = false;
			end;
		end;
		
		//CONTROL DIMENSIONES
		
		//cambio a agachado
		if (crouched && alto == cPlayerAlto)
			//establecemos altura agachado
			alto = cPlayerAltoCrouch;
			//redibujamos el player (provisional)
			//debugDrawPlayer();
			//actualizamos sus puntos de colision
			WGE_CreatePlayerColPoints(id);
			//corregimos la coordenada Y
			fy = fy+((cPlayerAlto-cPlayerAltoCrouch)>>1);
		elseif (not crouched && alto == cPlayerAltoCrouch)
			//establecemos altura normal
			alto = cPlayerAlto;
			//redibujamos el player (provisional)
			//debugDrawPlayer();
			//actualizamos sus puntos de colision
			WGE_CreatePlayerColPoints(id);
			//corregimos la coordenada Y
			fy = fy-((cPlayerAlto-cPlayerAltoCrouch)>>1);
		end;
		
		//COLISIONES	
		
		//condiciones iniciales pre-colision
		grounded = false;
		canmove = true;
		idPlatform = 0;
		objectforPickID = 0;
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
			
			//comprobamos si colisionamos con un objeto recogible
			if (!picked && (dir == COLDER || dir == COLIZQ)) 
				if (isBitSet(colID.props,PICKABLE))
					objectforPickID = colID; 
				end;
			end;
			
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
			atacking = false;
		end;
		
		fX += vX;
		fY += vY;
		
		positionToInt(id);
		
		
		//recogiendo objetos
		//activacion picking
		if (objectForPickID <> 0)
			//si se cumple el tiempo definido
			if (pickingCounter >= cPickingTime)
				//activamos el picking
				picking = true;
			else
				//cronometro
				if (clockTick)
					pickingCounter++;
				end;
			end;
		else
			pickingCounter = 0;
		end;
		//desactivacion picking
		if (picking && (vX <> 0 || jumping || crouched))
			//si me muevo o salto o me agacho,salgo del picking
			picking = false;
		end;
		
		//CONTROL ESTADO GRAFICO		
		
		//frenada en ataque
		if (!atacking && state == ATACK_STATE)
			state = BREAK_ATACK_STATE;
		end;
		//resto de frenadas
		if (state <> BREAK_ATACK_STATE && state <> BREAK_SLOPING_STATE)
			//estado parado
			if (abs(vX) < 0.1 && abs(vY) < 0.1)
				state = IDLE_STATE;
			end;
			//estados de frenadas al no pulsar movimiento
			if ( abs(vX) > 0.1 && !key(CKRIGHT) && !key(CKLEFT)) 
				//si no esta en rampas o con objeto cogido
				if (!on135Slope && !on45Slope && !picked)
					//frenada cayendo
					if (state == FALL_STATE || state == BREAK_FALL_STATE || state == JUMP_STATE)
						state = BREAK_FALL_STATE;
					elseif (state == SLOPING_STATE)
					//frenada resbalando
						state = BREAK_SLOPING_STATE;
					else
					//frenada normal
						state = BREAK_STATE;
					end;
				else
					//sin estado de frenada
					state = MOVE_STATE;
				end;
			end;
		end;
		
		if (key(CKLEFT))
			state = MOVE_STATE;
			//miramos hacia la izquierda
			flags |= B_HMIRROR;
		end;
		if (key(CKRIGHT))
			state = MOVE_STATE;
			//miramos hacia la derecha
			flags &=~ B_HMIRROR;
		end;
		
		if (!grounded && !jumping)
			state = FALL_STATE;
		end;
		if (jumping)
			state = JUMP_STATE;
		end;
		if (crouched)
			state = CROUCH_STATE;
		end;
		if (onStairs)
			state = ON_STAIRS_STATE;
		end;
		if (onStairs && (key(CKUP) || key(CKDOWN)) )
			state = MOVE_ON_STAIRS_STATE;
		end;
		if (atacking)
			state = ATACK_STATE;
		end;
		if (sloping)
			state = SLOPING_STATE;
		end;
		if (picking && !picked)
			state = PICKING_STATE;
		end;
		if (picked && picking)
			state = PICKED_STATE;
		end;
		
		//gestion del estado
		switch (state)
			case IDLE_STATE:
				if ((on45Slope && !isBitSet(flags,B_HMIRROR)) ||
				    (on135Slope && isBitSet(flags,B_HMIRROR)) )
					WGE_Animate(45,46,40);
				elseif ( (on45Slope && isBitSet(flags,B_HMIRROR)) ||
						(on135Slope && !isBitSet(flags,B_HMIRROR)) )
					WGE_Animate(37,38,40);
				elseif (picked)
					WGE_Animate(22,22,40);
				else
					WGE_Animate(1,2,40);
				end;
			end;
			case MOVE_STATE:
				if ((on45Slope && !isBitSet(flags,B_HMIRROR)) ||
				    (on135Slope && isBitSet(flags,B_HMIRROR)) )
					WGE_Animate(39,44,4);
				elseif ( (on45Slope && isBitSet(flags,B_HMIRROR)) ||
						(on135Slope && !isBitSet(flags,B_HMIRROR)) )
					WGE_Animate(47,52,4);
				elseif (picked)
					WGE_Animate(27,29,4);
				else
					WGE_Animate(3,8,4);
				end;			
			end;
			case FALL_STATE:
				if (picked)
						WGE_Animate(31,31,1);
				else
					WGE_Animate(11,11,1);
				end;
			end;
			case JUMP_STATE:
				if (vY < 0)
					if (picked)
						WGE_Animate(30,30,1);
					else
						WGE_Animate(10,10,1);	
					end;
				else
					if (picked)
						WGE_Animate(31,31,1);
					else
						WGE_Animate(11,11,1);
					end;
				end;
			end;
			case CROUCH_STATE:
				if ((on45Slope && !isBitSet(flags,B_HMIRROR)) ||
				    (on135Slope && isBitSet(flags,B_HMIRROR)) )
					WGE_Animate(53,54,20);
				elseif ( (on45Slope && isBitSet(flags,B_HMIRROR)) ||
						(on135Slope && !isBitSet(flags,B_HMIRROR)) )
					WGE_Animate(55,56,40);
				else
					WGE_Animate(16,17,40);
				end;
			end;
			case BREAK_STATE:
				WGE_Animate(9,9,1);
			end;
			case BREAK_FALL_STATE:
				WGE_Animate(12,12,1);
			end;
			case BREAK_ATACK_STATE:
				if (WGE_Animate(14,15,10))
					state = IDLE_STATE;
				end;
			end;
			case BREAK_SLOPING_STATE:
				if (abs(vX) < 0.5)
					if (WGE_Animate(14,15,10))
						state = IDLE_STATE;
					end;
				else
					WGE_Animate(13,13,1);
				end;
			end;
			case ON_STAIRS_STATE:
				WGE_Animate(18,18,1);
			end
			case MOVE_ON_STAIRS_STATE:
				WGE_Animate(19,20,8);
			end
			case ATACK_STATE:
				WGE_Animate(13,13,1);
			end
			case SLOPING_STATE:
				if (abs(vX) < 0.5)
					if (WGE_Animate(14,15,10))
						state = IDLE_STATE;
					end;
				else
					WGE_Animate(13,13,1);
				end;
			end
			case PICKING_STATE:
				WGE_Animate(25,26,40);
			end;
			case PICKED_STATE:
				if (WGE_Animate(21,22,10))
					state = IDLE_STATE;
					picking = false;
				end;
			end;
			default:
				WGE_Animate(1,2,40);
			end;
		end;
		
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