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
byte  longJump,				//Flag de incremento de salto
byte  grounded; 			//Flag en suelo
byte  onStairs;				//Flag de en escaleras
byte  crouched;				//Flag de agachado
byte  on45Slope;			//Flag en pendiente 45 grados
byte  on135Slope;			//Flag en pendiente 135 grados
byte  onWater;				//Flag de en agua
byte  sloping;              //Resbalando por una pendiente
byte  atacking;             //Flag de atacando
byte  picking;				//Flag de recogiendo
byte  picked;				//Flag de recogido
byte  failPick;				//Flag de no recogido
byte  throwing;				//Flag de lanzando
byte  canMove;				//Flag de movimiento permitido
byte  hurt;					//Flag de da�o
byte  hurtDisabled;			//Flag de invencible
byte  dead; 				//Flag de muerto
float velMaxX;				//Velocidad Maxima Horizontal
float accelX;				//Aceleracion Maxima Horizontal
float velMaxY;				//Velocidad Maxima Vertical
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
	this.ancho = cPlayerAncho;
	this.alto =  cPlayerAlto;
	this.axisAlign = DOWN_AXIS;
	
	velMaxX = cPlayerVelMaxX;
	accelx 	= cPlayerAccelX;
	accelY 	= cPlayerAccelY;
	
	region = cGameRegion;
	ctype = c_scroll;
	z = cZPlayer;
	priority = cPlayerPrior;
	file = fpgPlayer;
	
	//establecemos el id de player
	idPlayer = id;
	
	//dibujamos el personaje con sus dimensiones
	//debugDrawPlayer();
	
	//definimos los puntos de colision
	//respecto al centro del personaje
	wgeCreatePlayerColPoints(id);
	
	//Posicion inicial del nivel actual
	x = level.playerx0;
	y = level.playery0;
	
	this.fX = x;
	this.fY = y;
	
	//Orientacion del nivel actual
	flags = level.playerFlags;
	
	canMove = true;
	
	loop
		
		//CONTROL MOVIMIENTO		
		if (canMove)
			
			//direccion derecha
			if (wgeCheckControl(CTRL_RIGHT,E_PRESSED) && !onStairs) 
				if (this.vX < velMaxX) 
					this.vX+=accelx*(1-friction);
				end;
				//onStairs = false;
			end;
			
			//direccion izquierda
			if (wgeCheckControl(CTRL_LEFT,E_PRESSED) && !onStairs) 
				if (this.vX > -velMaxX) 
					this.vX-=accelx*(1-friction);
				end;
				//onStairs = false;
			end;
			
			//boton salto
			if (wgeCheckControl(CTRL_JUMP,E_PRESSED))
				if (onStairs)	//si esta en escalera
					//caemos de la escalera
					onStairs = false;
					longJump = true;
					grounded = false;
				//si esta en el agua
				elseif(onWater)	//si no esta en escalera
					if (wgeCheckControl(CTRL_JUMP,E_DOWN)) 
						jumping = true;
						grounded = false;
						this.vY = -accelY;
					end;
				else
					//salto con E_DOWN
					if (wgeCheckControl(CTRL_JUMP,E_DOWN)) 
						if((!jumping && grounded) || getTileCode(id,CENTER_DOWN_POINT) == WATER)
							jumping = true;
							grounded = false;
							if (getTileCode(id,CENTER_DOWN_POINT) == WATER)
								this.vY = -cPlayerExitWaterAccelY;
							else
								this.vY = -accelY;
							end;
						end;
					end;
					//incremento del poder del salto con pulsacion larga
					if (!longJump && (!grounded || getTileCode(id,CENTER_DOWN_POINT) == WATER) && jumpPower <= cPlayerMaxPowerJump && clockTick)
						this.vY -= cPlayerPowerJumpFactor;
						jumpPower++;					
					end;
				end;
			else
				//salto largo realizado
				longJump = true;
				//reinicio del incremento de poder de salto
				jumpPower = 0;
			end;

		end; //end del canMove
		
		//boton ataque/accion
		if (wgeCheckControl(CTRL_ACTION_ATACK,E_DOWN)) 
			//activar atacando
			if (jumping && !picked)
				atacking = true;
			end;
			//recojer objeto
			if (picking && !picked)
				//comprobamos si podemos cojer el objeto
				if (checkObjectPicking(memObjectforPickID))
					picked = true;
					//cambiamos el estado del objeto a recogiendo
					idObjectPicked = memObjectforPickID;
					idObjectPicked.this.state = PICKING_STATE;
					memObjectforPickID = 0;
				else
					picked = false;
					failPick = true;
				end;
			end;
			//lanzar objeto
			if (!picking & picked)
				//lanzamos el objeto
				throwObject(ID,idObjectPicked);
				idObjectPicked = 0;
				//reseteamos flags
				picked = false;
				throwing = true;
			end;
		end;
		
		//direccion arriba/subir escaleras
		if (wgeCheckControl(CTRL_UP,E_PRESSED))			
			//si objeto cogido y permiso mover, no podemos subir escaleras
			if (!picked && canMove)
				//si el centro del objeto esta en tile escaleras
				if (getTileCode(id,CENTER_POINT) == STAIRS || getTileCode(id,CENTER_POINT) == TOP_STAIRS)
					//quitamos velocidades
					this.vY = 0;
					this.vX = 0;
					//centramos el objeto en el tile escalera
					this.fX = x+(cTileSize>>1)-(x%cTileSize);
					//subimos las escaleras
					this.fY -= cPlayerVelYStairs;
					//Establecemos el flag de escalera
					onStairs = true;
					//desactivamos flag sthis.alto
					jumping = false;
				//en caso contrario, si el pie derecho esta en el TOP escalera, sales de ella
				elseif (getTileCode(id,CENTER_DOWN_POINT) == TOP_STAIRS)
					//subimos a la plataforma (tile superior a la escalera)
					this.fY = (((y/cTileSize)*cTileSize)+cTileSize)-(this.alto>>1);
					//Quitamos el flag de escalera				
					onStairs = false;
				end;				
			end;
		end;
		
		//direccion abajo/agacharse/bajar escalera
		if (wgeCheckControl(CTRL_DOWN,E_PRESSED))
			//si objeto cogido y permiso movimiento, no podemos ni agacharnos y bajar escaleras
			if (!picked && canMove)
				//si el centro inferior del objeto esta en tile escaleras
				if (getTileCode(id,CENTER_DOWN_POINT) == TOP_STAIRS || getTileCode(id,CENTER_DOWN_POINT) == STAIRS)
					//si el centro del objeto esta en tile escaleras
					if (getTileCode(id,CENTER_POINT) == TOP_STAIRS || getTileCode(id,CENTER_POINT) == STAIRS)	
						//centramos el objeto en el tile escalera
						this.fX = x+(cTileSize>>1)-(x%cTileSize);
						//bajamos las escaleras
						this.fY += cPlayerVelYStairs;
					//en caso contrario, estamos en la base de la escalera
					else
						//bajamos el objeto a la escalera
						this.fY += (this.alto>>1);
					end;
					//quitamos velocidades
					this.vY = 0;
					this.vX = 0;
					//Establecemos el flag de escalera
					onStairs = true;
					//desactivamos flag sthis.alto
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
		elseif(onWater)
			friction = waterFriction;
		elseif (grounded)
			friction = floorFriction;
		else
			friction = airFriction;
		end;
		
		
		//friccion: La friccion actua cuando no se mueve o esta agachado o da�ado
		if ((!wgeCheckControl(CTRL_LEFT,E_PRESSED) && !wgeCheckControl(CTRL_RIGHT,E_PRESSED)) || crouched || hurt)
			this.vX *= friction;
		end;
						
		//gravedad
		if (!onStairs)
			//limitamos la velocidad Y maxima
			if (abs(this.vY) < velMaxY) 
				this.vY += gravity;
			end;
		end;
		
		//Cambio velocidades y aceleracion en rampas y agua
		if (cSlopesEnabled)
			
			//Control Rampas
			on135Slope = getTileCode(id,LEFT_DOWN_POINT) == SLOPE_135 || 
						 getTileCode(id,DOWN_L_POINT) == SLOPE_135    || 
						 getTileCode(id,CENTER_DOWN_POINT) == SLOPE_135;
			on45Slope  = getTileCode(id,RIGHT_DOWN_POINT) == SLOPE_45 || 
						 getTileCode(id,DOWN_R_POINT) == SLOPE_45     || 
						 getTileCode(id,CENTER_DOWN_POINT) == SLOPE_45;
			
			onWater    = getTileCode(id,CENTER_POINT) == WATER;
			
			//si estoy en una rampa de 45 grados
			if (on45Slope)
				//Subiendola, cambio consignas velocidades
				if (!isBitSet(flags,B_HMIRROR))	
					velMaxX = cPlayerVelMaxXSlopeUp;
					accelx 	= cPlayerAccelXSlopeUp;
					if (this.vX > velMaxX)
						this.vX -= cPlayerDecelXSlopeUp;
					end;
				//Bajandola, cambio consignas velocidades
				elseif (isBitSet(flags,B_HMIRROR))
					//si esta atacando,resbala por la rampa
					if ((atacking && this.vX < cPlayerMinVelToIdle) || sloping)
						sloping = true;
						canMove = false;
						friction = 1;
						velMaxX = cPlayerVelMaxXSloping;
						accelx  = cPlayerAccelXSloping;
						this.vX-=accelx;
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
					if (this.vX < -velMaxX)
						this.vX += cPlayerDecelXSlopeUp;
					end;
				//Bajandola, cambio consignas velocidades
				elseif (!isBitSet(flags,B_HMIRROR))
					//si esta atacando,resbala por la rampa
					if ((atacking && this.vX > cPlayerMinVelToIdle) || sloping)
						sloping = true;
						canMove = false;
						friction = 1;
						velMaxX = cPlayerVelMaxXSloping;
						accelx  = cPlayerAccelXSloping;
						this.vX+=accelx;
					else
						velMaxX = cPlayerVelMaxXSlopeDown;
						accelx  = cPlayerAccelXSlopeDown;
					end;
				end;
			//si estoy en el agua
			elseif (onWater)
				velMaxX = cPlayerWaterVelMaxX;
				accelX 	= cPlayerWaterAccelX;
				velMaxY = cPlayerWaterVelMaxY;
				accelY 	= cPlayerWaterAccelY;
				//en agua, incrementamos salto
				if (jumping)
					this.vY += -cPlayerWaterJumpFactor;
				end;
				//limitamos la velocidad X actual
				if (abs(this.vX) > velMaxX)
					this.vX = velMaxX * (abs(this.vX)/this.vX);
				end;
				//limitamos la velocidad Y actual
				if (abs(this.vY) > velMaxY)
					this.vY = velMaxY * (abs(this.vY)/this.vY);
				end;
			//si no, restauro consignas velocidades
			else
				velMaxX = cPlayerVelMaxX;
				accelX 	= cPlayerAccelX;
				velMaxY = cPlayerVelMaxY;
				accelY 	= cPlayerAccelY;
				sloping = false;
			end;
		end;
		
		//CONTROL DIMENSIONES
		
		//cambio a agachado
		if (crouched && this.alto == cPlayeralto)
			//establecemos altura agachado
			this.alto = cPlayeraltoCrouch;
			//redibujamos el player (provisional)
			//debugDrawPlayer();
			//actualizamos sus puntos de colision
			wgeCreatePlayerColPoints(id);
			//corregimos la coordenada Y
			this.fY = this.fY+((cPlayeralto-cPlayeraltoCrouch)>>1);
		elseif (not crouched && this.alto == cPlayeraltoCrouch)
			//establecemos altura normal
			this.alto = cPlayeralto;
			//redibujamos el player (provisional)
			//debugDrawPlayer();
			//actualizamos sus puntos de colision
			wgeCreatePlayerColPoints(id);
			//corregimos la coordenada Y
			this.fY = this.fY-((cPlayeralto-cPlayeraltoCrouch)>>1);
		end;
		//si agachado, no puedes moverte
		if (crouched) canMove = false; end;
		
		//COLISIONES	
		
		//condiciones iniciales pre-colision
		grounded = false;
		idPlatform = 0;
		objectforPickID = 0;
		priority = cPlayerPrior;		
		//si habiamos seteado un boton, lo reiniciamos
		if (idButton == ID) 
			idButton = 0;
		end;
		
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
				if ( this.state == ATACK_STATE && isBitSet(colID.this.props,OBJ_BREAKABLE))
					//rebote al atacar
					this.vY = -cPlayerAtackBounce;
					//reproducimos sonido
					wgePlayEntitySnd(id,playerSound[BOUNCE_SND]);
					//si se pulsa ataque se a�ade incremento en rebote
					if (wgeCheckControl(CTRL_ACTION_ATACK,E_PRESSED))
						this.vY -= cPlayerPowerAtackBounce;
					end;
					grounded = false;
					//matamos al objeto
					colID.this.state = DEAD_STATE;
				else
					//seteamos flag idButton si la colision es con un boton
					if (grounded && isType(colID.son,TYPE button))
						idButton = ID;
					end;
				end;
			end;
			
			//colisiones horizontales con procesos
			dir = colCheckProcess(id,colID,HORIZONTALAXIS);
			
			//comprobamos si colisionamos con un objeto recogible y esta en la mitad inferior
			if (!picked && (dir == COLDER || dir == COLIZQ)) 
				if (isBitSet(colID.this.props,OBJ_PICKABLE) && colID.y >= y)
					objectforPickID = colID; 
				end;
			end;
			
			//aplicamos la direccion de la colision
			applyDirCollision(ID,dir,&grounded);
			
		until (colID == 0);
		
		//lanzamos comprobacion con procesos plataforma
		repeat
			//obtenemos siguiente colision
			colID = get_id(TYPE platform);
			
			//si existe plataforma
			if (colID <> 0)
				
				//tratamos las colisiones separadas por ejes
				//para poder andar sobre varios procesos corrigiendo la y
				
				//colisiones verticales con procesos
				if (!isBitSet(colID.this.props,PLATF_ONE_WAY_COLL))
					dir = colCheckProcess(id,colID,VERTICALAXIS);
					//aplicamos la direccion de la colision
					applyDirCollision(ID,dir,&grounded);
				else
					//si tiene la propiedad ONE_WAY, comprobamos colision sin corregir
					dir = colCheckProcess(id,colID,INFOONLY);
					//si es inferior y estoy cayendo en ella
					if (dir == COLDOWN && this.vY > 0)
						//recalculamos corrigiendo
						dir = colCheckProcess(id,colID,VERTICALAXIS);
						//aplicamos la direccion de la colision
						applyDirCollision(ID,dir,&grounded);
					end;
				end;

				//y estoy encima de ella
				if (dir==COLDOWN && grounded)
					//seteamos idPlatform
					idPlatform = colID;
					//cambiamos prioridades
					priority = cPlatformChildPrior;
					colID.priority = cPlayerPrior;
				else
					colID.priority = cPlatformPrior;
				end;
				
				//Comprobamos las colisiones horizontales si no tiene la propiedad ONE_WAY
				if (!isBitSet(colID.this.props,PLATF_ONE_WAY_COLL))	
					//colisiones horizontales con procesos
					dir = colCheckProcess(id,colID,HORIZONTALAXIS);
					//aplicamos la direccion de la colision si esta en la plataforma
					if (idPlatform == 0)
						applyDirCollision(ID,dir,&grounded);
					end;
				end;
			
			end;
		until (colID == 0);
		
		//lanzamos comprobacion con procesos monstruos
		repeat
			
			//obtenemos siguiente colision
			colID = get_id(TYPE monster);
								
			//colisiones ambos ejes con procesos
			dir = colCheckProcess(id,colID,INFOONLY);
				
			//si hay colision
			if (dir != NOCOL)
				//si el  monster no esta muerto 
				if (colID.this.state != DEAD_STATE)
					//si estamos atacando y el monstruo se puede da�ar
					if (dir == COLDOWN && this.state == ATACK_STATE && !isBitSet(colId.this.props,MONS_HURTLESS) )
						//rebote al atacar
						this.vY = -cPlayerAtackBounce;
						//reproducimos sonido
						wgePlayEntitySnd(id,playerSound[BOUNCE_SND]);
						//si se pulsa ataque se a�ade incremento en rebote
						if (wgeCheckControl(CTRL_ACTION_ATACK,E_PRESSED))
							this.vY -= cPlayerPowerAtackBounce;
						end;
						grounded = false;
						//enviamos se�al de da�o
						colID.this.state = HURT_STATE;
					//si estamos resbalando y el monstruo se puede da�ar
					elseif (!isBitSet(colId.this.props,MONS_HURTLESS) && colId.this.state <> HURT_STATE &&
						   (this.state == SLOPING_STATE  || this.state == BREAK_SLOPING_STATE) ) 
						//enviamos se�al de da�o
						colID.this.state = HURT_STATE;
						//reproducimos sonido
						wgePlayEntitySnd(id,objectSound[KILLSOLID_SND]);
					//si no, el monstruo te da�a si no soy invencible y tiene propiedad de da�ar
					elseif (!hurtDisabled && !isBitSet(colID.this.props,MONS_HARMLESS)) 
						hurt = true;
					end;
				end;
			end;
			
		until (colID == 0);
		
		//lanzamos comprobacion con disparos monstruos
		repeat
			
			//obtenemos siguiente colision
			colID = get_id(TYPE monsterFire);
									
			//colisiones ambos ejes con procesos
			if (colCheckProcess(id,colID,INFOONLY) != NOCOL)
				//el disparo te da�a
				if (!hurtDisabled) 
					hurt = true;
				end;
			end;
					
		until (colID == 0);
		
		//colision con scroll autom�tico
		if (level.levelflags.autoScrollX)
			//actualizamos la posicion de autoScroll antes de la colision
			scroll[cGameScroll].x0 += scrollfX - scroll[cGameScroll].x0;
						
			//lanzamos comprobacion de colision con el scroll vertical
			if (level.levelflags.autoScrollX == 1)
				dir = colCheckAABB(id,scroll[cGameScroll].x0,scroll[cGameScroll].y0 + (cGameRegionH>>1),1,cGameRegionH,HORIZONTALAXIS);
			else
				dir = colCheckAABB(id,scroll[cGameScroll].x0 + cGameRegionW,scroll[cGameScroll].y0 + (cGameRegionH>>1),1,cGameRegionH,HORIZONTALAXIS);
			end;
			
			//si colisionamos con el scroll y el terreno, morimos aplastados
			if (dir <> NOCOL && getTileCode(id,CENTER_POINT) <> NO_SOLID)
				dead = true;
			end;
		end;
		
		//Fin colisiones ==============================
				
		//Actualizar velocidades
		if (grounded)
			this.vY = 0;
			jumping = false;
			longJump = false;
			atacking = false;
		end;
		
		this.fX += this.vX;
		this.fY += this.vY;
		
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
		if (picking && (this.vX <> 0 || jumping || crouched) && !picked)
			//si me muevo o sthis.alto o me agacho,salgo del picking
			picking = false;
			memObjectforPickID = 0;
		end;
		//Mientras recoje, no puede mover
		if (picking && picked)
			canMove = false;
			this.vX = 0;
		end;
		//mientras lanza, no puede mover
		if (throwing)
			canMove = false;
			this.vX = 0;
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
			blinkEntity(id);
			
		else
			hurtDisabledCounter = 0;
			unsetBit(idPlayer.flags,B_ABLEND);
		end;
		
		//CONTROL ESTADO GRAFICO		
		
		//guardamos estado actual
		this.prevState = this.state;
		
		//frenada en ataque
		if (!atacking && this.state == ATACK_STATE)
			this.state = BREAK_ATACK_STATE;
		end;
		//resto de frenadas
		if (this.state <> BREAK_ATACK_STATE && this.state <> BREAK_SLOPING_STATE)
			//estado parado
			if (abs(this.vX) < cPlayerMinVelToIdle && abs(this.vY) < cPlayerMinVelToIdle)
				this.state = IDLE_STATE;
			end;
			//estados de frenadas al no pulsar movimiento
			if ( abs(this.vX) > cPlayerMinVelToIdle && !wgeCheckControl(CTRL_RIGHT,E_PRESSED) && !wgeCheckControl(CTRL_LEFT,E_PRESSED)) 
				//si no esta en rampas o con objeto cogido
				if (!on135Slope && !on45Slope && !picked)
					//frenada cayendo
					if (this.state == FALL_STATE || this.state == BREAK_FALL_STATE || this.state == JUMP_STATE)
						this.state = BREAK_FALL_STATE;
					elseif (this.state == SLOPING_STATE)
					//frenada resbalando
						this.state = BREAK_SLOPING_STATE;
					else
					//frenada normal
						this.state = BREAK_STATE;
					end;
				else
					//sin estado de frenada
					this.state = MOVE_STATE;
				end;
			end;
		end;
		
		if (wgeCheckControl(CTRL_LEFT,E_PRESSED))
			this.state = MOVE_STATE;
			//miramos hacia la izquierda
			flags |= B_HMIRROR;
		end;
		if (wgeCheckControl(CTRL_RIGHT,E_PRESSED))
			this.state = MOVE_STATE;
			//miramos hacia la derecha
			flags &=~ B_HMIRROR;
		end;
		
		if (!grounded && !jumping)
			this.state = FALL_STATE;
		end;
		if (jumping)
			this.state = JUMP_STATE;
		end;
		if (crouched)
			this.state = CROUCH_STATE;
		end;
		if (atacking)
			this.state = ATACK_STATE;
		end;
		if (onStairs)
			this.state = ON_STAIRS_STATE;
		end;
		if (onStairs && (wgeCheckControl(CTRL_UP,E_PRESSED) || wgeCheckControl(CTRL_DOWN,E_PRESSED)) )
			this.state = MOVE_ON_STAIRS_STATE;
		end;
		if (sloping)
			this.state = SLOPING_STATE;
		end;
		if (picking && !picked)
			this.state = PICKING_STATE;
		end;
		if (picked && picking)
			this.state = PICKED_STATE;
		end;
		if (failPick)
			this.state = FAILPICKED_STATE;
		end;
		if (throwing)
			this.state = THROWING_STATE;
		end;
		if (hurt)
			this.state = HURT_STATE;
			
			//si no somos invencibles
			if (!hurtDisabled)
				//salto hacia atr�s
				hurtDisabled = true;				
				isBitSet(flags,B_HMIRROR) ? this.vX = cHurtVelX : this.vX = -cHurtVelX;
				this.vY = -cHurtVelY;
				grounded = false;
				//si teniamos objeto, lo perdemos
				if (picked)
					throwObject(ID,idObjectPicked);
					idObjectPicked = 0;
					//reseteamos flags
					picked = false;
				end;
				//si estabamos en escalera, no salta hacia atr�s
				if (onStairs)
					onStairs = false;
					this.vX = 0;
				end;
				//perdemos energia
				game.playerLife--;
				
			end;	
		end;
		if (dead)
			this.state = DEAD_STATE;
		end;
		
		//si hay cambio de estado, resetamos contador animacion
		if (this.prevState <> this.state)
			log("Proceso: " + id + " pasa de estado " + this.prevState + " a " + this.state,DEBUG_PLAYER);
		end;
		
		//gestion del estado
		switch (this.state)
			case IDLE_STATE:
				if ((on45Slope && !isBitSet(flags,B_HMIRROR)) ||
				    (on135Slope && isBitSet(flags,B_HMIRROR)) )
					if (picked)
						wgeAnimate(_ANIM_PLY_IDLE_SLOPE_UP_PICK);
					else
						wgeAnimate(_ANIM_PLY_IDLE_SLOPE_UP);
					end;
				elseif ( (on45Slope && isBitSet(flags,B_HMIRROR)) ||
						(on135Slope && !isBitSet(flags,B_HMIRROR)) )
					if (picked)
						wgeAnimate(_ANIM_PLY_IDLE_SLOPE_DOWN_PICK);
					else
						wgeAnimate(_ANIM_PLY_IDLE_SLOPE_DOWN);
					end;
				elseif (picked)
					wgeAnimate(_ANIM_PLY_IDLE_PICK);
				else
					//si la mitad del cuerpo esta en el aire
					if (getTileCode(id,DOWN_R_POINT) <> NOCOL && 
					    getTileCode(id,DOWN_L_POINT) == NOCOL )
						//animacion de tambaleo
						wgeAnimate(_ANIM_PLY_IDLE_BORDER);
						unSetBit(flags,B_HMIRROR);
					elseif (getTileCode(id,DOWN_L_POINT) <> NOCOL && 
					        getTileCode(id,DOWN_R_POINT) == NOCOL )
						//animacion de tambaleo
						wgeAnimate(_ANIM_PLY_IDLE_BORDER);
						SetBit(flags,B_HMIRROR);
					else
						wgeAnimate(_ANIM_PLY_IDLE);
					end;
				end;
			end;
			case MOVE_STATE:
				if ((on45Slope && !isBitSet(flags,B_HMIRROR)) ||
				    (on135Slope && isBitSet(flags,B_HMIRROR)) )
					if (picked)
						wgeAnimate(_ANIM_PLY_MOVE_SLOPE_UP_PICK);
					else
						wgeAnimate(_ANIM_PLY_MOVE_SLOPE_UP);
					end;
				elseif ( (on45Slope && isBitSet(flags,B_HMIRROR)) ||
						(on135Slope && !isBitSet(flags,B_HMIRROR)) )
					if (picked)
						wgeAnimate(_ANIM_PLY_MOVE_SLOPE_DOWN_PICK);
					else
						wgeAnimate(_ANIM_PLY_MOVE_SLOPE_DOWN);
					end;
				elseif (picked)
					wgeAnimate(_ANIM_PLY_MOVE_PICK);
				else
					wgeAnimate(_ANIM_PLY_MOVE);
				end;			
			end;
			case FALL_STATE:
				if (picked)
					wgeAnimate(_ANIM_PLY_FALL_PICK);
				elseif (onWater)
					wgeAnimate(_ANIM_PLY_SWIM);
				else
					wgeAnimate(_ANIM_PLY_FALL);
				end;
			end;
			case JUMP_STATE:
				//subiendo
				if (this.vY <= 0)
					//reproducimos sonido estado
					if (this.prevState <> THROWING_STATE)
						wgePlayEntityStateSnd(id,playerSound[JUMP_SND]);	
					end;
					
					if (picked)
						wgeAnimate(_ANIM_PLY_JUMP_UP_PICK);
					elseif (onWater)
						wgeAnimate(_ANIM_PLY_SWIM);
					else
						wgeAnimate(_ANIM_PLY_JUMP_UP);	
					end;
				//bajando
				else
					if (picked)
						wgeAnimate(_ANIM_PLY_JUMP_DOWN_PICK);
					elseif (onWater)
						wgeAnimate(_ANIM_PLY_SWIM);
					else
						wgeAnimate(_ANIM_PLY_JUMP_DOWN);
					end;
				end;
			end;
			case CROUCH_STATE:
				if ((on45Slope && !isBitSet(flags,B_HMIRROR)) ||
				    (on135Slope && isBitSet(flags,B_HMIRROR)) )
					wgeAnimate(_ANIM_PLY_CROUCH_SLOPE_UP);
				elseif ( (on45Slope && isBitSet(flags,B_HMIRROR)) ||
						(on135Slope && !isBitSet(flags,B_HMIRROR)) )
					wgeAnimate(_ANIM_PLY_CROUCH_SLOPE_DOWN);
				else
					wgeAnimate(_ANIM_PLY_CROUCH);
				end;
			end;
			case BREAK_STATE:
				wgeAnimate(_ANIM_PLY_BREAK);
			end;
			case BREAK_FALL_STATE:
				wgeAnimate(_ANIM_PLY_FALL);
			end;
			case BREAK_ATACK_STATE:
				if (wgeAnimate(_ANIM_PLY_BREAK_ATACK))
					this.state = IDLE_STATE;
				end;
			end;
			case BREAK_SLOPING_STATE:
				if (abs(this.vX) < 0.5)
					if (wgeAnimate(_ANIM_PLY_BREAK_SLOPING_END))
						this.state = IDLE_STATE;
					end;
				else
					wgeAnimate(_ANIM_PLY_BREAK_SLOPING);
				end;
			end;
			case ON_STAIRS_STATE:
				wgeAnimate(_ANIM_PLY_ON_STAIRS);
			end
			case MOVE_ON_STAIRS_STATE:
				//reproducimos sonido estado
				wgePlayEntityStateSnd(id,playerSound[STAIRS_SND]);
				
				if (wgeAnimate(_ANIM_PLY_MOVE_ON_STAIRS))
					//reproducimos sonido en cada loop
					wgePlayEntitySnd(id,playerSound[STAIRS_SND]);
				end;
			end
			case ATACK_STATE:
				wgeAnimate(_ANIM_PLY_ATACK);
			end
			case SLOPING_STATE:
				if (abs(this.vX) < 0.5)
					if (wgeAnimate(_ANIM_PLY_BREAK_SLOPING_END))
						this.state = IDLE_STATE;
					end;
				else
					wgeAnimate(_ANIM_PLY_BREAK_SLOPING);
				end;
			end
			case PICKING_STATE:
				wgeAnimate(_ANIM_PLY_PICKING);
			end;
			case PICKED_STATE:
				//reproducimos sonido estado
				wgePlayEntityStateSnd(id,playerSound[PICK_SND]);
				
				if (wgeAnimate(_ANIM_PLY_PICKED))
					this.state = IDLE_STATE;
					picking = false;
				end;
			end;
			case FAILPICKED_STATE:
				if (wgeAnimate(_ANIM_PLY_FAILPICKED))
					this.state = PICKING_STATE;
					failPick = false;
				end;
				//reproducimos sonido
				wgePlayEntityStateSnd(id,playerSound[NOPICK_SND]);
			end;
			case THROWING_STATE:
				//reproducimos sonido estado
				wgePlayEntityStateSnd(id,playerSound[THROW_SND]);
				
				if (jumping)
					if (wgeAnimate(_ANIM_PLY_THROWING_JUMP))
						this.state = IDLE_STATE;
						throwing = false;
					end;
				else
					if (wgeAnimate(_ANIM_PLY_THROWING))
						this.state = IDLE_STATE;
						throwing = false;
					end;
				end;
			end;
			case HURT_STATE:
				//reproducimos sonido estado
				wgePlayEntityStateSnd(id,playerSound[HURT_SND]);
				
				if (wgeAnimate(_ANIM_PLY_HURT))					
					this.state = IDLE_STATE;
					hurt = false;
				end;
			end;
			case DEAD_STATE:
				//el wgeLoop lee este estado
			end;
			default:
				wgeAnimate(_ANIM_PLY_IDLE);
			end;
		end;
		
		//alineacion del eje X del grafico
		alignAxis(id);
		
		frame;
	
	end;
end;

//funcion que lanza el objeto que lleva el player
function throwObject(entity idProcess,idObjectPicked)
private
	object idObjectThrowed;		//id del objeto que se lanza
	int objectX;				//posicion X del objeto que se creamos
	int objectY;				//posicion Y del objeto que se creamos
	int dir;                    //direccion del lanzamiento
begin
	//obtenemos direccion segun flags proceso
	isBitSet(idProcess.flags,B_HMIRROR) ? dir =  -1 : dir = 1;
	
	//definimos posicion del objeto a crear segun velocidad X del player y propiedad objeto
	if (abs(idProcess.this.vX) < cPlayerMinVelToIdle && !isBitSet(idObjectPicked.this.props,OBJ_BREAKABLE))
	    objectX = idObjectPicked.x+((idProcess.this.ancho)*dir);
		objectY = idObjectPicked.y;
	else
		objectX = idObjectPicked.x;
		objectY = idObjectPicked.y;
	end;
	
	//Actualizamos su posicion para lanzarlo
	idObjectPicked.this.fX = objectX;
	idObjectPicked.this.fY = objectY;
		
		
	idObjectThrowed = idObjectPicked.id;
	
	//asignamos velocidades al objeto para lanzarlo
	if (abs(idProcess.this.vX) < cPlayerMinVelToIdle && !isBitSet(idObjectPicked.this.props,OBJ_BREAKABLE))
		//lo dejamos caer
		idObjectThrowed.this.vX = 0;
		idObjectThrowed.this.vY = 0;
	else
		idObjectThrowed.this.vX = cThrowObjectVelX * dir;
		idObjectThrowed.this.vY = cThrowObjectVelY;
	end;
	
	//cambiamos el estado del objeto para lanzarlo
	idObjectThrowed.this.state = THROWING_STATE;
	unsetBit(idObjectThrowed.this.props,NO_PHYSICS);
	setBit(idObjectThrowed.this.props,NO_COLLISION);
	idObjectThrowed = 0;
end;

//proceso de muerte del jugador
process deadPlayer()
begin
	region = cGameRegion;
	ctype = c_scroll;
	z = cZPlayer;
	file = fpgPlayer;
	
	this.fX = idPlayer.x;
	this.fY = idPlayer.y;
	
	this.vX = 0;
	this.vY = -4;
	
	graph = 34;
	
	repeat	
			//fisicas
			this.vY += gravity;
			
			this.fX += this.vX;
			this.fY += this.vY;
			positionToInt(id);
			
			wgeAnimate(_ANIM_PLY_DEAD);
			
			frame;
	//morimos al salirnos de la pantalla
	until (out_region(id,cGameRegion));
end;
	
//funcion que comprueba si se puede cojer un objeto comprobando si el objeto a cojer
//no tiene otro objeto encima
function int checkObjectPicking(entity pickingObject)
private
	entity colID;		//Id del objeto a comprobar
	int dir;			//Direccion de la colision
	
	int canPick;		//Flag que determina si el objeto se puede cojer
begin
	//seteamos la variable
	canPick = true;
	
	//comprobamos si hay algun objeto encima del que queremos recojer
	repeat
		colID = get_id(TYPE object);
		if (colID <> 0 && colID <> pickingObject)
			//comprobamos la colision de cada objeto con la base superior del objeto a cojer
			dir = colCheckAABB(colID,pickingObject.x,pickingObject.y-(pickingObject.this.alto>>1),pickingObject.this.ancho,cPickCheckObjectWidth,INFOONLY);
			if (dir == COLDOWN)
				canPick = false;
			end;
		end;
	until (colID == 0);
	
	//devolvemos la comprobacion
	return canPick;
end;