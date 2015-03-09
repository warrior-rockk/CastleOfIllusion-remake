// ========================================================================
//  Warcom Game Engine
//  Motor para juegos plataformas 2D
//  22/08/14
//
//  Procesos Objetos
// ========================================================================


//Proceso plataforma movil
//x inicial
//y inicial
//rango de movimiento
process plataforma(int x,int y,int _ancho,int _alto,int graph,int rango)
private
	int startX;
	int startY;
	int prevX;
begin
	region = cGameRegion;
	ctype = c_scroll;
	z = cZObject;
	file = level.fpgObjects;
	
	//igualamos la propiedades publicas a las de parametros
	ancho = _ancho;
	alto = _alto;
	
	//modo debug sin graficos
	if (file<0)
		graph = map_new(ancho,alto,8,0);
		map_clear(0,graph,310);
	end;
	
	//puntos de colision del objeto
	colPoint[LEFT_UP_POINT].x 		= -(ancho>>1);
	colPoint[LEFT_UP_POINT].y 		= 0;
	colPoint[LEFT_UP_POINT].colCode = COLIZQ;
	colPoint[LEFT_UP_POINT].enabled = 1;
	
	colPoint[RIGHT_UP_POINT].x 		= (ancho>>1);
	colPoint[RIGHT_UP_POINT].y 		= 0;
	colPoint[RIGHT_UP_POINT].colCode = COLDER;
	colPoint[RIGHT_UP_POINT].enabled = 1;
	
	fx = x;
	fy = y;
	
	state = IDLE_STATE;
	
	startX = x;
	startY = y;
	
	vX = 0.5;
	vY = 1;
	
	//bucle principal
	loop
		//guardamos estado actual
		prevState = state;
		
		switch (state)
			case IDLE_STATE:
				//estado por defecto
				state = MOVE_RIGHT_STATE; 
			end;
			case MOVE_RIGHT_STATE: //movimiento a derecha
				//movimiento lineal
				fx+=vX; 
				
				//cambio de estado al colisionar
				if (getTileCode(id,RIGHT_UP_POINT) <> NO_SOLID)
					state = MOVE_LEFT_STATE;
				end;
			end;
			case MOVE_LEFT_STATE: //movimiento a izquierda
				//movimiento lineal
				fx-=vX; 
				
				//cambio de estado al colisionar
				if (getTileCode(id,LEFT_UP_POINT) <> NO_SOLID)
					state = MOVE_RIGHT_STATE;
				end;
			end;
			case MOVE_DOWN_STATE: //movimiento a abajo
				//movimiento lineal
				fY+=vY; 
				//si el player esta en plataforma
				if (idPlatform == ID)
					//movemos el player
					idPlayer.fY +=vY;
				end;
				//cambio de estado
				if (fY > startY + rango)
					state = MOVE_UP_STATE;
				end;
			end;
			case MOVE_UP_STATE: //movimiento a arriba
				//movimiento lineal
				fY-=vY; 
				//si el player esta en plataforma
				if (idPlatform == ID)
					//movemos el player
					idPlayer.fY -=vY;
				end;
				//cambio de estado
				if (fY < startY - rango)
					state = MOVE_DOWN_STATE;
				end;
			end;
			case MOVE_FREE_STATE: //movimiento dos ejes
				//movimiento lineal
				fX+=vX;
				fY-=vY;
				//si el player esta en plataforma
				if (idPlatform == ID)
					//movemos el player
					idPlayer.fY -=vY;
				end;
			end;
		end;
		
		//guardamos la posicion actual X
		prevX = x;
		
		//actualizamos posicion
		positionToInt(id);
		
		//si el player esta en plataforma
		if (idPlatform == ID)
			//actualizamos la posicion del player lo que se movio la plataforma
			idPlayer.fX += x - prevX;
		end;
			
		frame;
	end;
	
end;

//Proceso objeto generico
//Sera el padre del objeto concreto para tratarlo como unico para colisiones,etc..
Process object(int objectType,int graph,int x,int y,int _ancho,int _alto,int _props)
private
	object idObject;		//id del objeto que se crea
	int 	_x0;			//X inicial
	int 	_y0;           	//Y inicial
	int     _graph;         //graph inicial
	byte    inRegion;		//flag de objeto en region
	byte    hidded;         //flag de oculto
begin
	//el objeto padre tiene prioridad superior a los hijos
	priority = cObjectPrior;
	
	//guardamos la posicion y grafico inicial
	_x0 = x;
	_y0 = y;
	_graph = graph;
	
	//el padre no tiene grafico
	graph = 0;
	
	//reseteamos flags
	inRegion = false;
	hidded   = false;
	
	loop
		//si se reinicia, se baja el flag de en region
		if (state == INITIAL_STATE)
			inRegion = false;
		end;
		
		//si existe el objeto
		if (exists(idObject))
			//si nos mandan reiniciar
			if (state == INITIAL_STATE)
				//eliminamos el objeto existente
				signal(idObject,s_kill);
				hidded = true;
				log("Se reinicia el objeto "+idObject,DEBUG_OBJECTS);
			else
				//actualizamos el hijo
				idObject.state = state;
				idObject.props = props;
				idobject.fx     = fx;
				idobject.fy     = fy;
				idobject.x     = x;
				idobject.y     = y;
				idobject.vx    = vx;
				idobject.vy    = vy;
						
				//desaparece al salir de la region del juego
				if (!region_in(x,y)) 
					log("Se elimina el objeto "+idObject,DEBUG_OBJECTS);
					//eliminamos el objeto
					signal(idObject,s_kill);	
					//marcamos el flag de oculto (pero "vivo")
					hidded = true;
				end;
			end;
		else
			//si no existe objeto, el padre no es colisionable
			setBit(props,NO_COLLISION);
			
			//creamos el objeto si entra en la region y si es persistente
			if (region_in(_x0,_y0) && !inRegion && (!isBitSet(props,NO_PERSISTENT) || hidded)) 
				//creamos el tipo de objeto
				switch (objectType)
					case T_SOLIDITEM:
						idObject = solidItem(_graph,_x0,_y0,_ancho,_alto,_props);
					end;
					case T_ITEM:
						idObject = item(_x0,_y0,_ancho,_alto,_props);
					end;
				end;
				
				//Seteo flags
				inRegion = true;
				hidded = false;
				log("Se crea el objeto "+idObject,DEBUG_OBJECTS);
			end;
			
			//bajamos el flag cuando salgas de la region
			if (!region_in(_x0,_y0))
				inRegion = false;
			end;
		end;
		
		frame;
	end;
end;

//Proceso solidItem
process solidItem(int graph,int x,int y,int _ancho,int _alto,int _props)
private
	byte grounded;		//Flag de en suelo
	float friction;		//Friccion local
	
	entity colID;		//Entidad con la que colisiona
	int colDir;			//Direccion de la colision
	byte collided;		//flag de colisionado
		
	int i;				//Variables auxiliares
begin
	region = cGameRegion;
	ctype = c_scroll;
	z = cZObject;
	file = level.fpgObjects;
	
	//igualamos la propiedades publicas a las de parametros
	ancho = _ancho;
	alto = _alto;
	props = _props;
	
		
	//modo debug sin graficos
	if (file<0)
		graph = map_new(ancho,alto,8,0);
		map_clear(0,graph,rand(200,300));
	end;
	
	fx = x;
	fy = y;
	
	WGE_CreateObjectColPoints(id);
	
	friction = floorFriction;
	
	state = MOVE_STATE;
	
	loop
		
		//FISICAS	
		collided = terrainPhysics(ID,friction,&grounded);
		
		//guardamos estado actual
		prevState = state;		
		//maquina de estados
		switch (state)
			case IDLE_STATE:
				//normalizamos la posicion Y para evitar problemas de colision 
				fY = y;
				//podemos centrar los objetos en rejilla del tama�o del mapa de tiles
				//menos real pero mas parecido a master system
				//fx = x+(cTileSize>>1)-(x%cTileSize);
				//en estado reposo se desactivan las fisicas
				setBit(props,NO_PHYSICS);
				vX = 0;
				vY = 0;
				//vuelver a ser colisionable por procesos
				unSetBit(props,NO_COLLISION);
				
			end;
			case MOVE_STATE:
								
				//mientras se mueve, no es solido
				SetBit(props,NO_COLLISION);
				//fisicas activadas
				unSetBit(props,NO_PHYSICS);				
				
				//lanzamos comprobacion con procesos objeto
				repeat
					//obtenemos siguiente colision
					colID = get_id(TYPE object);
					//si no soy yo mismo
					if (colID <> ID) 
						//aplicamos la direccion de la colision
						applyDirCollision(ID,colCheckProcess(id,colID,BOTHAXIS),&grounded);
					end;
				until (colID == 0);
				
				//cambio de estado		
				if (grounded && abs(vX) < cMinVelXToIdle) 
					state = IDLE_STATE;
					//desactivamos las fisicas al objeto
					setBit(props,NO_PHYSICS);
				end;
				
			end;
			case PICKING_STATE:
				//ponemos el objeto en posicion de recogida
				isBitSet(idPlayer.flags,B_HMIRROR)? fx = idPlayer.x-(idPlayer.ancho>>1) : fx = idPlayer.x+(idPlayer.ancho>>1);
				fy = idPlayer.y;
				//no es colisionable
				setBit(props,NO_COLLISION);
				//tiempo en posicion recogiendolo
				if (WGE_Animate(graph,graph,10,ANIM_ONCE))
					state = PICKED_STATE;
				end;
			end;
			case PICKED_STATE:
				isBitSet(idPlayer.flags,B_HMIRROR) ? fx = idPlayer.x-cObjectPickedPosX : fx = idPlayer.x+cObjectPickedPosX;
				fy = idPlayer.y+cObjectPickedPosY;
			end;
			case THROWING_STATE:	
				//mientras se mueve, no es solido
				setBit(props,NO_COLLISION);
				//fisicas activadas
				unSetBit(props,NO_PHYSICS);
				
				//lanzamos comprobacion con procesos objeto
				repeat
					//obtenemos siguiente colision
					colID = get_id(TYPE object);
					//si no soy yo mismo
					if (colID <> ID) 
						//obtenemos la direccion de la colision
						colDir = colCheckProcess(id,colID,BOTHAXIS);
						//aplicamos la direccion de la colision
						applyDirCollision(ID,colDir,&grounded);
						//seteamos flag de colisionado
						if (colDir <> NOCOL)
							collided = true;
						end;
					end;
				until (colID == 0);
				
				//lanzamos comprobacion con monstruos
				repeat
					//obtenemos siguiente colision
					colID = get_id(TYPE monster);
					//obtenemos la direccion de la colision
					colDir = colCheckProcess(id,colID,INFOONLY);
					
					//seteamos flag de colisionado
					if (colDir <> NOCOL && colID.state <> DEAD_STATE)
						collided = true;
						colID.state = HURT_STATE;
					end;
					
				until (colID == 0);
				
				//cambio de estado
				
				//si es rompible
				if (isBitSet(props,BREAKABLE))
					//si colisiona con algo o toca suelo
					if (collided || grounded )
						//actualizamos la posicion para ver la explosion en el sitio
						vY = 0;
						fx += vX;
						fy += vY;
						positionToInt(id);
						
						//cambiamos de estado
						state = DEAD_STATE;
					end;
				else
					//si no ha colisionado y toca suelo, cambiamos de estado
					if (grounded && abs(vX) < cMinVelXToIdle) 
						state = IDLE_STATE;
					end;
				end;
				
			end;
			case DEAD_STATE:
				//si el objeto tiene item dentro, lo lanzamos
				if (isBitSet(props,ITEM_BIG_COIN) || isBitSet(props,ITEM_STAR))
					item(x,y,ancho,alto,props);
				end;
				//lanzamos animacion explosion objeto
				WGE_Animation(file,2,3,x,y,10,ANIM_ONCE);
				//matamos el objeto
				signal(id,s_kill);
			end;
		end;
			
		//actualizamos velocidad y posicion
		updateVelPos(id,grounded);
		
		//actualizamos el objeto padre
		updateObject(id);		
		
		frame;
	end;
	
end;

//proceso item
process item(int x,int y,int _ancho,int _alto,int _props)
private
	byte grounded;			//flag de en suelo
	float friction;			//friccion local
	
	entity colID;			//entidad con al que colisiona
	int colDir;				//direccion de la colision
	byte collided;			//flag de colisionado
	
	int itemTime;			//Tiempo item antes de desaparecer
	byte picked; 			//flag de item recogido
	
	int i;					//Var aux
begin
	region = cGameRegion;
	ctype = c_scroll;
	z = cZObject;
	file = level.fpgObjects;
	
	//igualamos la propiedades publicas a las de parametros
	ancho = _ancho;
	alto = _alto;
	props = _props;
	
	//modo debug sin graficos
	if (file<0)
		graph = map_new(ancho,alto,8,0);
		map_clear(0,graph,rand(200,300));
	end;
	
	//establecemos posicion y velocidad
	fx = x;
	fy = y;
	vY = cItemVelY;
	
	WGE_CreateObjectColPoints(id);
	
	friction = floorFriction;
	
	state = IDLE_STATE;
	
	//ajustamos propiedades fijas de un item
	unSetBit(props,BREAKABLE);
	unSetBit(props,PICKABLE);
	unSetBit(props,NO_PHYSICS);
	setBit(props,NO_COLLISION);
	
	loop
		
		//FISICAS	
		collided = terrainPhysics(ID,friction,&grounded);
		
		//guardamos estado actual
		prevState = state;
		
		//comportamiento item
		switch (state)
			case IDLE_STATE:
				if (!isBitSet(props,ITEM_GEM) || !isBitSet(props,ITEM_STAR))
					//tiempo item
					if ((clockCounter % cNumFps) == 0 && clockTick)
						itemTime++;
					end;
					
					//parpadeo
					if ((itemTime >= (cItemTimeOut - cItemTimeToBlink)) && tickClock(cItemBlinkTime))
						if (isBitSet(flags,B_TRANSLUCENT))
							unsetBit(flags,B_TRANSLUCENT);
						else	
							setBit(flags,B_TRANSLUCENT);
						end;
					end;
					//timeout
					if (itemTime >= cItemTimeOut)
						state = DEAD_STATE;
					end;
				end;
				
				//comprobamos si colisiona con el jugador
				colDir = colCheckProcess(id,idPlayer,INFOONLY);
				//si colisiona, eliminamos el item
				if (colDir <> NOCOL)
					state = DEAD_STATE;
					picked = true;
				end;
				
				//animacion del item
				if (isBitSet(props,ITEM_BIG_COIN))
					WGE_Animate(6,7,20,ANIM_LOOP);
				end;
				if (isBitSet(props,ITEM_STAR))
					WGE_Animate(11,12,20,ANIM_LOOP);
				end;
				if (isBitSet(props,ITEM_GEM))
					WGE_Animate(13,13,10,ANIM_LOOP);
				end;
			end;
			
			case DEAD_STATE:
				//si ha sido recodido el item
				if (picked)
					//segun el item,realizamos una accion determinada
					if (isBitSet(props,ITEM_BIG_COIN))
						//incrementa puntuacion
						game.score += cBigCoinScore;
					end;
					if (isBitSet(props,ITEM_STAR))
						//a�ade una estrella a la vida
						game.playerMaxLife += 1;
						game.playerLife = game.playerMaxLife;
					end;
					if (isBitSet(props,ITEM_GEM))
						//fin del nivel actual
						game.endLevel = true;
					end;
				end;
				//elimina el item
				signal(id,s_kill);
			end;
		end;
		
		//actualizamos velocidad y posicion
		updateVelPos(id,grounded);
		
		//actualizamos el objeto padre
		updateObject(id);
		
		frame;
	end;
	
end;

//funcion que actualiza las propiedades del objeto padre
function updateObject(entity objectSon)
private
	object idFather;	//id del Objeto padre
begin
	//aseguramos que el padre es un objeto
	if (isType(objectSon.father,TYPE object))
		
		//asociamos al padre
		idFather = 	objectSon.father;
		
		//copiamos las propiedades
		idFather.ancho 		= objectSon.ancho;
		idFather.alto 		= objectSon.alto;
		idFather.axisAlign	= objectSon.axisAlign;
		idFather.fX 		= objectSon.fX;
		idFather.fY 		= objectSon.fY;
		idFather.x  		= objectSon.x;
		idFather.y  		= objectSon.y;
		idFather.vX 		= objectSon.vX;
		idFather.vY 		= objectSon.vY;
		idFather.props 		= objectSon.props;
		idFather.state      = objectSon.state;
	end;
end;