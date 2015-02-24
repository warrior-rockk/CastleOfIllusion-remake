// ========================================================================
//  Warcom Game Engine
//  Motor para juegos plataformas 2D
//  16/09/14
//
//  Proceso jugador principal
// ========================================================================

//proceso jugador
process player()
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
byte  throwing;				//Flag de lanzando
byte  canMove;				//Flag de movimiento permitido
byte  hurt;					//Flag de daño
byte  hurtDisabled;			//Flag de invencible
float velMaxX;				//Velocidad Maxima Horizontal
float accelX;				//Aceleracion Maxima Horizontal
float accelY;				//Aceleracion Maxima Vertical
float friction;				//Friccion local
int	  dir;					//Direccion de la colision
entity colID;				//Proceso con el que se colisiona
entity objectforPickID;		//Proceso de tipo objeto que se colisiona lateralmente
entity memObjectforPickID;  //Memoria de objeto que se colisiona
entity idObjectPicked;		//Identificador del objeto cogido
int   pickingCounter; 		//Contador para recojer objeto
int   hurtDisabledCounter;  //Contador de invencibilidad
struct tiles_comprobar[8]   //Matriz comprobacion colision tiles
	int posx;
	int posy;
end;
int jumpPower;				//Contador incremento salto

int i,j;					//Variables auxiliares
byte trace;     			//Variable debug
 
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
	
	canMove = true;
	
	loop
		
		//CONTROL MOVIMIENTO		
		if (canMove)
			
			//direccion derecha
			if (key(K_RIGHT)) 
				if (vX < velMaxX) 
					vX+=accelx*(1-friction);
				end;
				onStairs = false;
			end;
			
			//direccion izquierda
			if (key(K_LEFT)) 
				if (vX > -velMaxX) 
					vX-=accelx*(1-friction);
				end;
				onStairs = false;
			end;
			
			//boton salto
			if (WGE_Key(K_JUMP,KEY_PRESSED))
				//salto con key_down
				if (WGE_Key(K_JUMP,KEY_DOWN)) 
					if(!jumping && (grounded || onStairs)) 
						jumping = true;
						grounded = false;
						vY = -accelY;
						onStairs = false;
					end;
				end;
				//incremento del poder del salto con pulsacion larga
				if (jumpPower <= cPlayerMaxPowerJump && clockTick)
					vY -= cPlayerPowerJumpFactor;
					jumpPower++;					
				end;
			else
				//reinicio del incremento de poder de salto
				jumpPower = 0;
			end;

		end; //end del canMove
		
		//boton ataque/accion
		if (WGE_Key(K_ACTION_ATACK,KEY_DOWN)) 
			//activar atacando
			if (jumping && !picked)
				atacking = true;
			end;
			//recojer objeto
			if (picking && !picked)
				picked = true;
				//creamos un objeto picked con sus propiedades
				idObjectPicked = pickedObject(memObjectforPickID.file,memObjectforPickID.graph,memObjectforPickID.ancho,memObjectforPickID.alto,memObjectforPickID.props);
				//le quitamos la propiedad de solido
				idObjectPicked.props |= NO_COLLISION; 
				signal(memObjectforPickID,s_kill);
				memObjectforPickID = 0;
			end;
			//lanzar objeto
			if (!picking & picked)
				//lanzamos el objeto
				throwObject(flags,idObjectPicked);
				idObjectPicked = 0;
				//reseteamos flags
				picked = false;
				throwing = true;
			end;
		end;
		
		//direccion arriba/subir escaleras
		if (key(K_UP))			
			//si objeto cogido y permiso mover, no podemos subir escaleras
			if (!picked && canMove)
				//si el centro del objeto esta en tile escaleras
				if (getTileCode(id,CENTER_POINT) == STAIRS || getTileCode(id,CENTER_POINT) == TOP_STAIRS)
					//quitamos velocidades
					vY = 0;
					vX = 0;
					//centramos el objeto en el tile escalera
					fx = x+(cTileSize>>1)-(x%cTileSize);
					//subimos las escaleras
					fY -= cPlayerVelYStairs;
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
		
		//direccion abajo/agacharse/bajar escalera
		if (key(K_DOWN))
			//si objeto cogido y permiso movimiento, no podemos ni agacharnos y bajar escaleras
			if (!picked && canMove)
				//si el centro inferior del objeto esta en tile escaleras
				if (getTileCode(id,CENTER_DOWN_POINT) == TOP_STAIRS || getTileCode(id,CENTER_DOWN_POINT) == STAIRS)
					//si el centro del objeto esta en tile escaleras
					if (getTileCode(id,CENTER_POINT) == TOP_STAIRS || getTileCode(id,CENTER_POINT) == STAIRS)	
						//centramos el objeto en el tile escalera
						fx = x+(cTileSize>>1)-(x%cTileSize);
						//bajamos las escaleras
						fY += cPlayerVelYStairs;
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
		
		//restauramos bit de mover
		canMove = true;
				
		//FISICAS
		
		//valor friccion local
		if (sloping && (on45Slope || on135Slope))
			friction = 1;
		elseif (grounded)
			friction = floorFriction;
		else
			friction = airFriction;
		end;
		
		
		//friccion: La friccion actua cuando no se mueve o esta agachado o dañado
		if ((!key(K_LEFT) && !key(K_RIGHT)) || crouched || hurt)
			vX *= friction;
		end;
						
		//gravedad
		if (!onStairs)
			//limitamos la velocidad Y maxima
			if (abs(vY) < cPlayerVelMaxY) 
				vY += gravity;
			end;
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
					if ((atacking && key(K_LEFT)) || sloping)
						sloping = true;
						canMove = false;
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
					if ((atacking && key(K_RIGHT)) || sloping)
						sloping = true;
						canMove = false;
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
		//si agachado, no puedes moverte
		if (crouched) canMove = false; end;
		
		//COLISIONES	
		
		//condiciones iniciales pre-colision
		grounded = false;
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
			colID = get_id(TYPE object);
			
			//tratamos las colisiones separadas por ejes
			//para poder andar sobre varios procesos corrigiendo la y
			
			//colisiones verticales con procesos
			dir = colCheckProcess(id,colID,VERTICALAXIS);
			//aplicamos la direccion de la colision
			applyDirCollision(ID,dir,&grounded);
			
			//si la colision es inferior
			if (dir == COLDOWN )
				//si estamos atacando y el objeto es rompible
				if ( state == ATACK_STATE && isBitSet(colID.props,BREAKABLE))
					//rebote al atacar
					vY = -cPlayerAtackBounce;
					//si se pulsa ataque se añade incremento en rebote
					if (WGE_Key(K_ACTION_ATACK,KEY_PRESSED))
						vY -= cPlayerPowerAtackBounce;
					end;
					grounded = false;
					//matamos al objeto
					colID.state = DEAD_STATE;
				else
					//corregimos la Y truncamos fY
					y = fY;
					fY = y;
				end;
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
		
		//lanzamos comprobacion con procesos monstruos
		repeat
			
			//obtenemos siguiente colision
			colID = get_id(TYPE monster);
								
			//colisiones ambos ejes con procesos
			dir = colCheckProcess(id,colID,INFOONLY);
				
			//si la colision es inferior y el monster no esta muerto
			
			if (dir == COLDOWN && colID.state != DEAD_STATE )
				//si estamos atacando 
				if ( state == ATACK_STATE)
					//rebote al atacar
					vY = -cPlayerAtackBounce;
					//si se pulsa ataque se añade incremento en rebote
					if (WGE_Key(K_ACTION_ATACK,KEY_PRESSED))
						vY -= cPlayerPowerAtackBounce;
					end;
					grounded = false;
					//enviamos señal de daño
					colID.state = HURT_STATE;
				else
					//el monstruo te daña si no soy invencible y tiene propiedad de dañar
					if (!hurtDisabled && isBitSet(colID.props,HURTPLAYER)) 
						hurt = true;
					end;
				end;
			elseif ( dir != NOCOL) //cualquier otra colision
				//el monstruo te daña si no soy invencible y tiene propiedad de dañar
				if (!hurtDisabled && isBitSet(colID.props,HURTPLAYER)) 
					hurt = true;
				end;
			end;
					
		until (colID == 0);
		
		//lanzamos comprobacion con disparos monstruos
		repeat
			
			//obtenemos siguiente colision
			colID = get_id(TYPE monsterFire);
									
			//colisiones ambos ejes con procesos
			if (colCheckProcess(id,colID,INFOONLY) != NOCOL)
				//el disparo te daña
				if (!hurtDisabled) 
					hurt = true;
				end;
			end;
					
		until (colID == 0);
		
		//Fin colisiones ==============================
		
		//Actualizar velocidades
		if (grounded)
			vY = 0;
			jumping = false;
			atacking = false;
		end;
		
		fX += vX;
		fY += vY;
		
		//actualizar posicion float-int
		positionToInt(id);
		
		//recogiendo objetos
		//activacion picking
		if (objectForPickID <> 0)
			//si se cumple el tiempo definido
			if (pickingCounter >= cPickingTime)
				//activamos el picking
				picking = true;
				memObjectforPickID = objectForPickID;
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
		if (picking && (vX <> 0 || jumping || crouched) && !picked)
			//si me muevo o salto o me agacho,salgo del picking
			picking = false;
			memObjectforPickID = 0;
		end;
		//Mientras recoje, no puede mover
		if (picking && picked)
			canMove = false;
			vX = 0;
		end;
		//mientras lanza, no puede mover
		if (throwing)
			canMove = false;
			vX = 0;
		end;
		
		//invencibilidad
		if (hurtDisabled)
			if (hurtDisabledCounter >= cHurtDisabledTime)
				hurtDisabled = false;
				hurtDisabledCounter = 0;
			elseif (clockTick)
				hurtDisabledCounter++;
			end;
			
			//parpadeo si invencible
			if (clockTick)
				if (isBitSet(idPlayer.flags,B_ABLEND))
					unsetBit(idPlayer.flags,B_ABLEND);
				else	
					setBit(idPlayer.flags,B_ABLEND);
				end;
			end;
		else
			hurtDisabledCounter = 0;
			unsetBit(idPlayer.flags,B_ABLEND);
		end;
		
		//CONTROL ESTADO GRAFICO		
		
		//guardamos estado actual
		prevState = state;
		
		//frenada en ataque
		if (!atacking && state == ATACK_STATE)
			state = BREAK_ATACK_STATE;
		end;
		//resto de frenadas
		if (state <> BREAK_ATACK_STATE && state <> BREAK_SLOPING_STATE)
			//estado parado
			if (abs(vX) < cPlayerMinVelToIdle && abs(vY) < cPlayerMinVelToIdle)
				state = IDLE_STATE;
			end;
			//estados de frenadas al no pulsar movimiento
			if ( abs(vX) > cPlayerMinVelToIdle && !key(K_RIGHT) && !key(K_LEFT)) 
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
		
		if (key(K_LEFT))
			state = MOVE_STATE;
			//miramos hacia la izquierda
			flags |= B_HMIRROR;
		end;
		if (key(K_RIGHT))
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
		if (onStairs && (key(K_UP) || key(K_DOWN)) )
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
		if (throwing)
			state = THROWING_STATE;
		end;
		if (hurt)
			state = HURT_STATE;
			
			//si no somos invencibles
			if (!hurtDisabled)
				//salto hacia atrás
				hurtDisabled = true;				
				isBitSet(flags,B_HMIRROR) ? vX = cHurtVelX : vX = -cHurtVelX;
				vY = -cHurtVelY;
				grounded = false;
				//si teniamos objeto, lo perdemos
				if (picked)
					throwObject(flags,idObjectPicked);
					idObjectPicked = 0;
					//reseteamos flags
					picked = false;
				end;
				//perdemos energia
				game.playerLife--;
			end;	
		end;
		
		//si hay cambio de estado, resetamos contador animacion
		if (prevState <> state)
			log("Proceso: " + id + " pasa de estado " + prevState + " a " + state);
		end;
		
		//gestion del estado
		switch (state)
			case IDLE_STATE:
				if ((on45Slope && !isBitSet(flags,B_HMIRROR)) ||
				    (on135Slope && isBitSet(flags,B_HMIRROR)) )
					WGE_Animate(45,46,40,ANIM_LOOP);
				elseif ( (on45Slope && isBitSet(flags,B_HMIRROR)) ||
						(on135Slope && !isBitSet(flags,B_HMIRROR)) )
					WGE_Animate(37,38,40,ANIM_LOOP);
				elseif (picked)
					WGE_Animate(22,22,40,ANIM_LOOP);
				else
					WGE_Animate(1,2,40,ANIM_LOOP);
				end;
			end;
			case MOVE_STATE:
				if ((on45Slope && !isBitSet(flags,B_HMIRROR)) ||
				    (on135Slope && isBitSet(flags,B_HMIRROR)) )
					WGE_Animate(39,44,4,ANIM_LOOP);
				elseif ( (on45Slope && isBitSet(flags,B_HMIRROR)) ||
						(on135Slope && !isBitSet(flags,B_HMIRROR)) )
					WGE_Animate(47,52,4,ANIM_LOOP);
				elseif (picked)
					WGE_Animate(27,29,4,ANIM_LOOP);
				else
					WGE_Animate(3,8,4,ANIM_LOOP);
				end;			
			end;
			case FALL_STATE:
				if (picked)
					WGE_Animate(31,31,1,ANIM_LOOP);
				else
					WGE_Animate(11,11,1,ANIM_LOOP);
				end;
			end;
			case JUMP_STATE:
				if (vY < 0)
					if (picked)
						WGE_Animate(30,30,1,ANIM_LOOP);
					else
						WGE_Animate(10,10,1,ANIM_LOOP);	
					end;
				else
					if (picked)
						WGE_Animate(31,31,1,ANIM_LOOP);
					else
						WGE_Animate(11,11,1,ANIM_LOOP);
					end;
				end;
			end;
			case CROUCH_STATE:
				if ((on45Slope && !isBitSet(flags,B_HMIRROR)) ||
				    (on135Slope && isBitSet(flags,B_HMIRROR)) )
					WGE_Animate(53,54,20,ANIM_LOOP);
				elseif ( (on45Slope && isBitSet(flags,B_HMIRROR)) ||
						(on135Slope && !isBitSet(flags,B_HMIRROR)) )
					WGE_Animate(55,56,40,ANIM_LOOP);
				else
					WGE_Animate(16,17,40,ANIM_LOOP);
				end;
			end;
			case BREAK_STATE:
				WGE_Animate(9,9,1,ANIM_LOOP);
			end;
			case BREAK_FALL_STATE:
				WGE_Animate(12,12,1,ANIM_LOOP);
			end;
			case BREAK_ATACK_STATE:
				if (WGE_Animate(14,15,10,ANIM_LOOP))
					state = IDLE_STATE;
				end;
			end;
			case BREAK_SLOPING_STATE:
				if (abs(vX) < 0.5)
					if (WGE_Animate(14,15,10,ANIM_ONCE))
						state = IDLE_STATE;
					end;
				else
					WGE_Animate(13,13,1,ANIM_LOOP);
				end;
			end;
			case ON_STAIRS_STATE:
				WGE_Animate(18,18,1,ANIM_LOOP);
			end
			case MOVE_ON_STAIRS_STATE:
				WGE_Animate(19,20,8,ANIM_LOOP);
			end
			case ATACK_STATE:
				WGE_Animate(13,13,1,ANIM_LOOP);
			end
			case SLOPING_STATE:
				if (abs(vX) < 0.5)
					if (WGE_Animate(14,15,10,ANIM_ONCE))
						state = IDLE_STATE;
					end;
				else
					WGE_Animate(13,13,1,ANIM_LOOP);
				end;
			end
			case PICKING_STATE:
				WGE_Animate(25,26,40,ANIM_LOOP);
			end;
			case PICKED_STATE:
				if (WGE_Animate(21,21,10,ANIM_ONCE))
					state = IDLE_STATE;
					picking = false;
				end;
			end;
			case THROWING_STATE:
				if (jumping)
					if (WGE_Animate(24,24,10,ANIM_ONCE))
						state = IDLE_STATE;
						throwing = false;
					end;
				else
					if (WGE_Animate(23,23,10,ANIM_ONCE))
						state = IDLE_STATE;
						throwing = false;
					end;
				end;
			end;
			case HURT_STATE:
				if (WGE_Animate(32,33,15,ANIM_ONCE))					
					state = IDLE_STATE;
					hurt = false;
				end;
			end;
			default:
				WGE_Animate(1,2,40,ANIM_LOOP);
			end;
		end;
		
		frame;
	
	end;
end;

//funcion que lanza el objeto que lleva el player
function throwObject(int playerFlags,entity idObjectPicked)
private
	object idObjectThrowed;		//id del objeto que se lanza
begin
	//creamos objeto con las propiedades del recogido
	idObjectThrowed = object(idObjectPicked.graph,idObjectPicked.x,idObjectPicked.y,idObjectPicked.ancho,idObjectPicked.alto,idObjectPicked.props);
	//matamos el objeto cogido
	signal(idObjectPicked,s_kill);
	//asignamos velocidades al objeto para lanzarlo
	isBitSet(playerFlags,B_HMIRROR) ? idObjectThrowed.vX = cThrowObjectVelX * -1 : idObjectThrowed.vX = cThrowObjectVelX;
	idObjectThrowed.vY = cThrowObjectVelY;
	idObjectThrowed.state = THROWING_STATE;
	idObjectThrowed = 0;
end;

/*
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
*/