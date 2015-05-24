// ========================================================================
//  Warcom Game Engine
//  Motor para juegos plataformas 2D
//  22/08/14
//
//  Procesos Objetos
// ========================================================================

//Proceso objeto generico
//Sera el padre del objeto concreto para tratarlo como unico para colisiones,etc..
Process object(int objectType,int _graph,int _x0,int _y0,int _ancho,int _alto,int _axisAlign,int _flags,int _props)
private
	object idObject;		//id del objeto que se crea
	
	byte    inRegion;	   //flag de objeto en region
	byte    outRegion;     //flag de objeto fuera de la region

begin
	//el objeto padre tiene prioridad superior a los hijos
	priority = cObjectPrior;
	
	this.state = INITIAL_STATE;
	
	loop
		//si se reinicia, se actualiza flags region
		if (this.state == INITIAL_STATE)
			inRegion  = checkInRegion(_x0,_y0,this.ancho,this.alto,CHECKREGION_ALL);
			outRegion = true;
			//eliminamos el objeto para crearlo de nuevo
			if (exists(idObject))
				signal(idObject,s_kill_tree);
			end;
		end;
		
		//si existe el objeto
		if (exists(idObject))
			
			//desaparece al salir de la region del juego y no es persistente
			if (outRegion && !isBitSet(idObject.this.props,PERSISTENT)) 
				//eliminamos el objeto
				signal(idObject,s_kill);	
				log("Se elimina el objeto "+idObject,DEBUG_OBJECTS);
				//bajamos flags
				inRegion = false;
				outRegion = false;
				//la region se comprueba con las coordenadas iniciales
				x = _x0;
				y = _y0;
			else
				outRegion = false;
			end;

		else
			//si no existe objeto, el padre no es colisionable
			setBit(this.props,NO_COLLISION);
			
			//la region se comprueba con las coordenadas iniciales
			x = _x0;
			y = _y0;
			
			//creamos el objeto si entra en la region
			if (inRegion && outRegion )
				//creamos el tipo de objeto
				switch (objectType)
					case OBJ_SOLIDITEM:
						idObject = solidItem(_graph,_x0,_y0,_ancho,_alto,_axisAlign,_flags,_props);
					end;
					case OBJ_ITEM:
						idObject = item(_x0,_y0,_ancho,_alto,_axisAlign,_flags,_props);
					end;
					case OBJ_BUTTON:
						idObject = button(_graph,_x0,_y0,_ancho,_alto,_axisAlign,_flags,_props);
					end;
					case OBJ_DOORBUTTON:
						idObject = doorButton(_graph,_x0,_y0,_ancho,_alto,_axisAlign,_flags,_props);
					end;
					case OBJ_KEY:
						idObject = solidItem(_graph,_x0,_y0,_ancho,_alto,_axisAlign,_flags,_props | OBJ_IS_KEY | PERSISTENT | OBJ_PICKABLE);
					end;
					case OBJ_DOORKEY:
						idObject = keyDoor(_graph,_x0,_y0,_ancho,_alto,_axisAlign,_flags,_props);
					end;
				end;
				log("Se crea el objeto "+idObject,DEBUG_OBJECTS);
				
				outRegion = false;
			end;
		end;
		
		//Comprobamos si entra en la region
		if (checkInRegion(x,y,this.ancho,this.alto,CHECKREGION_ALL) && !inRegion)
			inRegion = true;
		end;
		
		//Comprobamos si sale de la region
		if (!checkInRegion(x,y,this.ancho+cObjectMargin,this.alto+cObjectMargin,CHECKREGION_ALL))
			outRegion = true;
		end;
			
		frame;
	end;
end;

//Proceso solidItem
process solidItem(int _graph,int x,int y,int _ancho,int _alto,int _axisAlign,int _flags,int _props)
private
	byte grounded;		//Flag de en suelo
	float friction;		//Friccion local
	
	entity colID;		//Entidad con la que colisiona
	int colDir;			//Direccion de la colision
	byte collided;		//flag de colisionado
	
	int appearingTime;	//Tiempo apareciendo si es invisible
	
	int i;				//Variables auxiliares
begin
	
	region = cGameRegion;
	ctype = c_scroll;
	z = cZObject;
	file = level.fpgObjects;
	flags = _flags;
	
	//igualamos la propiedades publicas a las de parametros
	graph  = _graph;
	this.ancho = _ancho;
	this.alto = _alto;
	this.props = _props;
	this.axisAlign = _axisAlign;
	
	//modo debug sin graficos
	if (file<0)
		graph = map_new(this.ancho,this.alto,8,0);
		map_clear(0,graph,rand(200,300));
	end;
	
	this.fX = x;
	this.fY = y;
	
	WGE_CreateObjectColPoints(id);
	
	friction = floorFriction;
	
	this.state = MOVE_STATE;
	
	//ocultamos el grafico si es invisible
	if (isBitSet(this.props,OBJ_INVISIBLE))
		graph = 0;
	end;
	
	//actualizamos al padre con los datos de creacion
	updateObject(id,father);
	
	loop
		//nos actualizamos del padre
		updateObject(father,id);
		
		//FISICAS	
		collided = terrainPhysics(ID,friction,&grounded);
		
		//guardamos estado actual
		this.prevState = this.state;		
		//maquina de estados
		switch (this.state)
			case IDLE_STATE:
				//normalizamos la posicion Y para evitar problemas de colision 
				this.fY = y;
				//podemos centrar los objetos en rejilla del tamaño del mapa de tiles
				//menos real pero mas parecido a master system
				//this.fX = x+(cTileSize>>1)-(x%cTileSize);
				//en estado reposo se desactivan las fisicas
				setBit(this.props,NO_PHYSICS);
				this.vX = 0;
				this.vY = 0;
				//vuelver a ser colisionable por procesos (si no es invisible)
				unSetBit(this.props,NO_COLLISION);
				
				//si es un objeto invisible
				if (isBitSet(this.props,OBJ_INVISIBLE))
					//no es colisionable
					setBit(this.props,NO_COLLISION);
					//Comprobamos si el player nos ataca para aparecer
					if (exists(idPlayer))
						if (colCheckProcess(id,idPlayer,INFOONLY) && idPlayer.this.state == ATACK_STATE)
							this.state = OBJ_APPEARING_STATE;
							graph = _graph;
						end;
					end;
				end;
				
			end;
			case MOVE_STATE:
								
				//mientras se mueve, no es solido
				SetBit(this.props,NO_COLLISION);
				//fisicas activadas
				unSetBit(this.props,NO_PHYSICS);				
				//reseteamos flag boton si lo hubiera seteado el proceso
				if (idButton == father) 
					idButton = 0;
				end;
				
				//lanzamos comprobacion con procesos objeto
				repeat
					//obtenemos siguiente colision
					colID = get_id(TYPE object);
					//si no soy yo mismo (mi padre)
					if (colID <> father.ID) 
						 //aplicamos la direccion de la colision
						applyDirCollision(ID,colCheckProcess(id,colID,BOTHAXIS),&grounded);
					end;
				until (colID == 0);
				
				//cambio de estado		
				if (grounded && abs(this.vX) < cMinVelXToIdle) 
					this.state = IDLE_STATE;
					//desactivamos las fisicas al objeto
					setBit(this.props,NO_PHYSICS);
				end;
				
			end;
			case PICKING_STATE:
				//ponemos el objeto en posicion de recogida
				isBitSet(idPlayer.flags,B_HMIRROR)? this.fX = idPlayer.x-(idPlayer.this.ancho>>1) : this.fX = idPlayer.x+(idPlayer.this.ancho>>1);
				this.fY = idPlayer.y;
				//no es colisionable
				setBit(this.props,NO_COLLISION);
				//tiempo en posicion recogiendolo
				if (WGE_Animate(graph,graph,10,ANIM_ONCE))
					this.state = PICKED_STATE;
				end;
			end;
			case PICKED_STATE:
				//comprobamos si el jugador no muere cuando nos lleva
				if (exists(idPlayer))
					isBitSet(idPlayer.flags,B_HMIRROR) ? this.fX = idPlayer.x-cObjectPickedPosX : this.fX = idPlayer.x+cObjectPickedPosX;
					this.fY = idPlayer.y+cObjectPickedPosY;
					//el objeto se vuelve persistente
					setBit(this.props,PERSISTENT);
					//reseteamos flag boton si lo hubiera seteado el proceso
					if (idButton == father) 
						idButton = 0;
					end;
				else
					this.state = THROWING_STATE;
				end;
			end;
			case THROWING_STATE:	
				//mientras se mueve, no es solido
				setBit(this.props,NO_COLLISION);
				//fisicas activadas
				unSetBit(this.props,NO_PHYSICS);
				//deja de ser persistente
				unSetBit(this.props,PERSISTENT);
				
				//lanzamos comprobacion con procesos objeto
				repeat
					//obtenemos siguiente colision
					colID = get_id(TYPE object);
					//si no soy yo mismo (mi padre)
					if (colID <> father.ID) 
						//obtenemos la direccion de la colision
						colDir = colCheckProcess(id,colID,BOTHAXIS);
						//aplicamos la direccion de la colision
						applyDirCollision(ID,colDir,&grounded);
						//seteamos flag de colisionado
						if (colDir <> NOCOL)
							collided = true;
						end;
						//Comprobacion de colision con botón para pulsarlo
						if (colDir == COLDOWN && isType(colID.son,TYPE button))
							//seteamos el idbutton al objeto padre nuestro
							idbutton = father;
							//centramos el objeto en el boton para que no te puedas subir
							this.fX = colId.this.fX;
						end;
						//Comprobacion de colision con keyDoor para abrirla
						if (colDir <> NOCOL && isBitSet(this.props,OBJ_IS_KEY) && isType(colID.son,TYPE keyDoor))
							//seteamos el idKey al objeto padre nuestro
							idKey = father;
							//rompemos la llave
							setBit(this.props,OBJ_BREAKABLE);
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
					if (colDir <> NOCOL && colID.this.state <> DEAD_STATE)
						collided = true;
						colID.this.state = HURT_STATE;
						//reproducimos sonido
						if (isBitSet(this.props,OBJ_BREAKABLE))
							WGE_PlayEntitySnd(father,objectSound[KILL_SND]);
						else
							WGE_PlayEntitySnd(father,objectSound[KILLSOLID_SND]);
						end;
					end;
					
				until (colID == 0);
				
				//cambio de estado
				
				//si es rompible
				if (isBitSet(this.props,OBJ_BREAKABLE))
					//si colisiona con algo o toca suelo
					if (collided || grounded )
						//actualizamos la posicion para ver la explosion en el sitio
						this.vY = 0;
						this.fX += this.vX;
						this.fY += this.vY;
						positionToInt(id);
						
						//cambiamos de estado
						this.state = DEAD_STATE;
						//reproducimos sonido
						WGE_PlayEntitySnd(father,objectSound[BREAK_SND]);
					end;
				else
					//si no ha colisionado y toca suelo, cambiamos de estado
					if (grounded && abs(this.vX) < cMinVelXToIdle) 
						this.state = IDLE_STATE;
					end;
				end;
				
			end;
			case OBJ_APPEARING_STATE:
				//parpadeo mientras aparece
				if (clockTick)
					isBitSet(flags,B_ABLEND) ? unsetBit(flags,B_ABLEND) : setBit(flags,B_ABLEND);
				end;
				
				//contador de aparecer
				if (appearingTime >= cAppearTime)
					//quitamos la propiedad de invisible
					unsetBit(this.props,OBJ_INVISIBLE);
					//quitamos el additive blend
					unsetBit(flags,B_ABLEND);
					//pasamos a reposo
					this.state = IDLE_STATE;
					appearingTime = 0;
				elseif (clockTick)
					appearingTime++;
				end;
			end;
			case DEAD_STATE:
				//lanzamos animacion explosion objeto
				WGE_Animation(file,2,3,x,y,10,ANIM_ONCE);
				//reseteamos flag boton si lo hubiera seteado el proceso
				if (idButton == father) 
					idButton = 0;
				end;
				
				//si el objeto tiene item dentro, lo lanzamos
				if (isBitSet(this.props,OBJ_ITEM_BIG_COIN) || 
				    isBitSet(this.props,OBJ_ITEM_COIN)     ||
					isBitSet(this.props,OBJ_ITEM_FOOD)     ||
					isBitSet(this.props,OBJ_ITEM_BIG_FOOD) ||
					isBitSet(this.props,OBJ_ITEM_TRIE)     
					)
					//item(x,y,this.ancho,this.alto,this.props);
					object(OBJ_ITEM,0,x,y,16,16,CENTER_AXIS,0,this.props);
					//elimina el padre (items no son remanentes)
					signal(father,s_kill);
				end;
				//matamos el objeto
				signal(id,s_kill);
				//reproducimos sonido
				WGE_PlayEntityStateSnd(id,objectSound[BREAK_SND]);
			end;
		end;
			
		//actualizamos velocidad y posicion
		updateVelPos(id,grounded);
		
		//actualizamos el objeto padre
		if (isType(father,TYPE object))
			updateObject(id,father);		
		end;
		
		//alineacion del eje X del grafico
		alignAxis(id);
		
		frame;
	end;
	
end;

//proceso item
process item(int x,int y,int _ancho,int _alto,int _axisAlign,int _flags,int _props)
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
	flags = _flags;
	
	//igualamos la propiedades publicas a las de parametros
	this.ancho = _ancho;
	this.alto = _alto;
	this.props = _props;
	this.axisAlign = _axisAlign;
	
	//modo debug sin graficos
	if (file<0)
		graph = map_new(this.ancho,this.alto,8,0);
		map_clear(0,graph,rand(200,300));
	end;
	
	//establecemos posicion y velocidad
	this.fX = x;
	this.fY = y;
	this.vY = cItemVelY;
	
	WGE_CreateObjectColPoints(id);
	
	friction = floorFriction;
	
	this.state = IDLE_STATE;
	
	//ajustamos propiedades fijas de un item
	unSetBit(this.props,OBJ_BREAKABLE);
	unSetBit(this.props,OBJ_PICKABLE);
	unSetBit(this.props,NO_PHYSICS);
	setBit(this.props,NO_COLLISION);
	
	//actualizamos al padre con los datos de creacion
	updateObject(id,father);
	
	loop
		//nos actualizamos del padre
		updateObject(father,id);
		
		//FISICAS	
		collided = terrainPhysics(ID,friction,&grounded);
		
		//guardamos estado actual
		this.prevState = this.state;
		
		//comportamiento item
		switch (this.state)
			case IDLE_STATE:
				if (!isBitSet(this.props,OBJ_ITEM_GEM) && !isBitSet(this.props,OBJ_ITEM_STAR))
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
						this.state = DEAD_STATE;
					end;
				end;
				
				//comprobamos si colisiona con el jugador
				colDir = colCheckProcess(id,idPlayer,INFOONLY);
				//si colisiona, eliminamos el item
				if (colDir <> NOCOL)
					//si no es gema de fin de nivel o si lo es, que tengamos flag de bossKilled
					if (!isBitSet(this.props,OBJ_ITEM_GEM) || game.bossKilled)
						this.state = DEAD_STATE;
						picked = true;
					end;
				end;
				
				//animacion del item
				if (isBitSet(this.props,OBJ_ITEM_COIN))
					WGE_Animate(25,26,20,ANIM_LOOP);
				end;
				if (isBitSet(this.props,OBJ_ITEM_BIG_COIN))
					WGE_Animate(6,7,20,ANIM_LOOP);
				end;
				if (isBitSet(this.props,OBJ_ITEM_FOOD))
					WGE_Animate(31,28,20,ANIM_LOOP);
				end;
				if (isBitSet(this.props,OBJ_ITEM_BIG_FOOD))
					WGE_Animate(28,28,20,ANIM_LOOP);
				end;
				if (isBitSet(this.props,OBJ_ITEM_TRIE))
					WGE_Animate(27,27,20,ANIM_LOOP);
				end;
				if (isBitSet(this.props,OBJ_ITEM_STAR))
					WGE_Animate(11,12,20,ANIM_LOOP);
				end;
				if (isBitSet(this.props,OBJ_ITEM_GEM))
					//si no tenemos flag de bossKilled
					if (!game.bossKilled)
						//item oculto
						graph = 0;
						this.vY = 0;
					else
						WGE_Animate(13,13,10,ANIM_LOOP);
					end;
				end;
			end;
			
			case DEAD_STATE:
				//si ha sido recodido el item
				if (picked)
					//segun el item,realizamos una accion determinada
					if (isBitSet(this.props,OBJ_ITEM_COIN))
						//incrementa puntuacion
						game.score += cSmallCoinScore;
						//reproducimos sonido
						WGE_PlayEntitySnd(father,objectSound[PICKCOIN_SND]);
					end;
					if (isBitSet(this.props,OBJ_ITEM_BIG_COIN))
						//incrementa puntuacion
						game.score += cBigCoinScore;
						//reproducimos sonido
						WGE_PlayEntitySnd(father,objectSound[PICKCOIN_SND]);
					end;
					if (isBitSet(this.props,OBJ_ITEM_FOOD))
						//incrementa 1 energia
						game.playerLife ++;
						//reproducimos sonido
						WGE_PlayEntitySnd(father,objectSound[PICKITEM_SND]);
					end;
					if (isBitSet(this.props,OBJ_ITEM_BIG_FOOD))
						//incrementa toda la energia
						game.playerLife = game.playerMaxLife;
						//reproducimos sonido
						WGE_PlayEntitySnd(father,objectSound[PICKITEM_SND]);
					end;
					if (isBitSet(this.props,OBJ_ITEM_TRIE))
						//incrementa 1 vida
						game.playerTries++;
						//reproducimos sonido
						WGE_PlayEntitySnd(father,objectSound[PICKTRIE_SND]);
					end;
					if (isBitSet(this.props,OBJ_ITEM_STAR))
						//añade una estrella a la vida
						game.playerMaxLife += 1;
						game.playerLife = game.playerMaxLife;
						//reproducimos sonido
						WGE_PlayEntitySnd(father,objectSound[PICKSTAR_SND]);
					end;
					if (isBitSet(this.props,OBJ_ITEM_GEM))
						//fin del nivel actual
						game.endLevel = true;
						game.bossKilled = false;
					end;
				end;
				//elimina el padre (items no son remanentes)
				signal(father,s_kill);
				//elimina el item
				signal(id,s_kill);		
			end;
		end;
		
		//actualizamos velocidad y posicion
		updateVelPos(id,grounded);
		
		//actualizamos el objeto padre
		if (isType(father,TYPE object))
			updateObject(id,father);		
		end;
		
		//alineacion del eje X del grafico
		alignAxis(id);
		
		frame;
	end;
	
end;

//proceso boton: cuando alguien setea idButton a distinto de 0, cambiamos de grafico y de estado
process button(int _graph,int x,int y,int _ancho,int _alto,int _axisAlign,int _flags,int _props)
private
	byte grounded;			//flag de en suelo
	float friction;			//friccion local
	
	entity colID;			//entidad con al que colisiona
	int colDir;				//direccion de la colision
	byte collided;			//flag de colisionado
	
	
	int i;					//Var aux
begin
	region = cGameRegion;
	ctype = c_scroll;
	z = cZObject;
	file = level.fpgObjects;
	flags = _flags;
	
	graph = _graph;
	
	//igualamos la propiedades publicas a las de parametros
	this.ancho = _ancho;
	this.alto = _alto;
	this.props = _props;
	this.axisAlign = _axisAlign;
	
	//modo debug sin graficos
	if (file<0)
		graph = map_new(this.ancho,this.alto,8,0);
		map_clear(0,graph,rand(200,300));
	end;
	
	//establecemos posicion y velocidad
	this.fX = x;
	this.fY = y;
		
	WGE_CreateObjectColPoints(id);
	
	friction = floorFriction;
	
	this.state = IDLE_STATE;
	
	//ajustamos propiedades fijas de un boton
	unSetBit(this.props,OBJ_BREAKABLE);
	unSetBit(this.props,OBJ_PICKABLE);
	SetBit(this.props,NO_PHYSICS);
	unSetBit(this.props,NO_COLLISION);
	
	//actualizamos al padre con los datos de creacion
	updateObject(id,father);
	
	loop
		//nos actualizamos del padre
		updateObject(father,id);
		
		//FISICAS	
		collided = terrainPhysics(ID,friction,&grounded);
		
		//guardamos estado actual
		this.prevState = this.state;
		
		//comportamiento item
		switch (this.state)
			case IDLE_STATE:
				//si alguien activa el boton
				if (idButton <> 0)
					//cambiamos su grafico
					graph = _graph + 1;
					//pasamos a estado pulsado
					this.state = PUSHED_STATE;
				end;
			end;
			case PUSHED_STATE:
				//si alguien libera el boton
				if (idButton == 0)
					//grafico inicial
					graph = _graph;
					//pasamos a reposo
					this.state = IDLE_STATE;
				end;				
			end;
		end;
		
		//actualizamos velocidad y posicion
		updateVelPos(id,grounded);
		
		//actualizamos el objeto padre
		if (isType(father,TYPE object))
			updateObject(id,father);		
		end;
		
		//alineacion del eje X del grafico
		alignAxis(id);
		
		frame;
	end;

onexit:
	//al eliminar el boton, reseteamos el flag
	idButton = 0;
end;

//proceso puerta con boton: cuando alguien setea idbutton distinto de 0, ocultamos los bloques de 
//puerta en orden de posicion Y y temporizado. Operacion inversa para cerrarla.
process doorButton(int _graph,int x,int y,int _ancho,int _alto,int _axisAlign,int _flags,int _props)
private
	byte grounded;			//flag de en suelo
	float friction;			//friccion local
	
	entity colID;			//entidad con al que colisiona
	int colDir;				//direccion de la colision
	byte collided;			//flag de colisionado
	
	int doorTime;			//Tiempo de apertura/cierre
	entity doorID;			//Id de los objetos puerta que puedan existir
	byte openDoor;			//Flag de abrir
	int i;					//Var aux
begin
	region = cGameRegion;
	ctype = c_scroll;
	z = cZObject;
	file = level.fpgObjects;
	flags = _flags;
	
	graph = _graph;
	
	//igualamos la propiedades publicas a las de parametros
	this.ancho = _ancho;
	this.alto = _alto;
	this.props = _props;
	this.axisAlign = _axisAlign;
	
	//modo debug sin graficos
	if (file<0)
		graph = map_new(this.ancho,this.alto,8,0);
		map_clear(0,graph,rand(200,300));
	end;
	
	//establecemos posicion y velocidad
	this.fX = x;
	this.fY = y;
		
	WGE_CreateObjectColPoints(id);
	
	friction = floorFriction;
	
	//seteamos estado segun idButton
	idButton == 0 ? this.state = IDLE_STATE : this.state = PUSHED_STATE;
		
	//ajustamos propiedades fijas de un doorbutton
	unSetBit(this.props,OBJ_BREAKABLE);
	unSetBit(this.props,OBJ_PICKABLE);
	SetBit(this.props,NO_PHYSICS);
	unSetBit(this.props,NO_COLLISION);
	
	//actualizamos al padre con los datos de creacion
	updateObject(id,father);
	
	loop
		//nos actualizamos del padre
		updateObject(father,id);
		
		//guardamos estado actual
		this.prevState = this.state;
		
		//comportamiento item
		switch (this.state)
			case IDLE_STATE:
				//la puerta es solida
				unSetBit(this.props,NO_COLLISION);
				//grafico inicial
				graph = _graph;
								
				//si se pulsa boton
				if (idButton <> 0 )
					//seteamos flag de apertura
					openDoor = true;
					//comprobamos las demas puertas para abrir secuencial segun altura
					repeat
						doorID = get_id(TYPE doorButton);
						if (doorID <> 0)
							//si hay alguna puerta superior que no se ha abierto, reseteamos apertura
							if (doorID.y < y && doorID.this.state <> PUSHED_STATE)
								openDoor = false;
							end;
						end;
					until (doorID == 0);
					//si tenemos apertura
					if (openDoor)
						//tiempo apertura
						if (clockTick)
							doorTime++;
						end;
						//tiempo cumplido
						if (doorTime >= cDoorTime)
							//movemos los objetos puerta hacia arriba un tile
							repeat
								doorID = get_id(TYPE doorButton);
								if (doorID <> 0 )
									doorID = doorID.father;
									doorID.this.fY -= cTileSize;
								end;
							until (doorID == 0);
							//cambiamos estado
							this.state = PUSHED_STATE;
							//reproducimos sonido
							WGE_PlayEntityStateSnd(id,objectSound[DOOR_SND]);
						end;
					end;
				end;
			end;
			case PUSHED_STATE:
				//hacemos la puerta no solida
				SetBit(this.props,NO_COLLISION);
				//le quitamos grafico
				graph = 0;
				//reproducimos sonido
				WGE_PlayEntityStateSnd(id,objectSound[DOOR_SND]);
				
				//si se suelta el boton
				if (idButton == 0 )
					//reseteamos el flag de apertura
					openDoor = false;
					//comprobamos las demas puertas para abrir en secuencia segun altura
					repeat
						doorID = get_id(TYPE doorButton);
						if (doorID <> 0)
							//si hay alguna puerta por debajo que no se ha cerrado, reseteamos el cierre
							if (doorID.y > y && doorID.this.state <> IDLE_STATE)
								openDoor = true;
							end;
						end;
					until (doorID == 0);
					//flag de cerrar
					if (!openDoor)
						//tiempo apertura
						if (clockTick)
							doorTime--;
						end;
						//tiempo cumplido
						if (doorTime <= 0)
							//movemos los objetos puerta hacia abajo un tile
							repeat
								doorID = get_id(TYPE doorButton);
								if (doorID <> 0 )
									doorID = doorID.father;
									doorID.this.fY += cTileSize;
								end;
							until (doorID == 0);
							//grafico inicial
							graph = _graph;
							//cambiamos de estado
							this.state = IDLE_STATE;
							//reproducimos sonido
							WGE_PlayEntityStateSnd(id,objectSound[DOOR_SND]);
						end;
					end;
				end;
			end;
		end;
		
		//actualizamos velocidad y posicion
		updateVelPos(id,grounded);
		
		//actualizamos el objeto padre
		if (isType(father,TYPE object))
			updateObject(id,father);		
		end;
		
		//alineacion del eje X del grafico
		alignAxis(id);
		
		frame;
	end;
	
end;

//proceso puerta con llave: cuando alguien setea idKey distinto de 0, ocultamos los bloques de 
//puerta en orden de posicion Y y temporizado. 
process keyDoor(int _graph,int x,int y,int _ancho,int _alto,int _axisAlign,int _flags,int _props)
private
	byte grounded;			//flag de en suelo
	float friction;			//friccion local
	
	entity colID;			//entidad con al que colisiona
	int colDir;				//direccion de la colision
	byte collided;			//flag de colisionado
	
	int doorTime;			//Tiempo de apertura/cierre
	entity doorID;			//Id de los objetos puerta que puedan existir
	byte openDoor;			//Flag de abrir
	int i;					//Var aux
begin
	region = cGameRegion;
	ctype = c_scroll;
	z = cZObject;
	file = level.fpgObjects;
	flags = _flags;
	
	graph = _graph;
	
	//igualamos la propiedades publicas a las de parametros
	this.ancho = _ancho;
	this.alto = _alto;
	this.props = _props;
	this.axisAlign = _axisAlign;
	
	//modo debug sin graficos
	if (file<0)
		graph = map_new(this.ancho,this.alto,8,0);
		map_clear(0,graph,rand(200,300));
	end;
	
	//establecemos posicion y velocidad
	this.fX = x;
	this.fY = y;
		
	WGE_CreateObjectColPoints(id);
	
	friction = floorFriction;
	
	this.state = IDLE_STATE;
	
	//ajustamos propiedades fijas de un doorbutton
	unSetBit(this.props,OBJ_BREAKABLE);
	unSetBit(this.props,OBJ_PICKABLE);
	SetBit(this.props,NO_PHYSICS);
	unSetBit(this.props,NO_COLLISION);
		
	//actualizamos al padre con los datos de creacion
	updateObject(id,father);
	
	//reseteamos el flag de idKey
	idKey = 0;
	
	loop
		//nos actualizamos del padre
		updateObject(father,id);
		
		//guardamos estado actual
		this.prevState = this.state;
		
		//comportamiento item
		switch (this.state)
			case IDLE_STATE:
				//la puerta es solida
				unSetBit(this.props,NO_COLLISION);
				//grafico inicial
				graph = _graph;
				//si se activa la llave
				if (idKey <> 0 )
					//seteamos flag de apertura
					openDoor = true;
					//comprobamos las demas puertas para abrir secuencial segun altura
					repeat
						doorID = get_id(TYPE keyDoor);
						if (doorID <> 0)
							//si hay alguna puerta superior que no se ha abierto, reseteamos apertura
							if (doorID.y < y && doorID.this.state <> PUSHED_STATE)
								openDoor = false;
							end;
						end;
					until (doorID == 0);
					//si tenemos apertura
					if (openDoor)
						//tiempo apertura
						if (clockTick)
							doorTime++;
						end;
						//tiempo cumplido
						if (doorTime >= cDoorTime)
							//movemos los objetos puerta hacia arriba un tile
							repeat
								doorID = get_id(TYPE keyDoor);
								if (doorID <> 0 )
									doorID = doorID.father;
									doorID.this.fY -= cTileSize;
								end;
							until (doorID == 0);
							//cambiamos estado
							this.state = PUSHED_STATE;
							//reproducimos sonido
							WGE_PlayEntityStateSnd(id,objectSound[DOOR_SND]);
						end;
					end;
				end;
			end;
			case PUSHED_STATE:
				//eliminamos la puerta
				signal(father,s_kill);
				signal(id,s_kill);				
			end;
		end;
		
		//actualizamos velocidad y posicion
		updateVelPos(id,grounded);
		
		//actualizamos el objeto padre
		if (isType(father,TYPE object))
			updateObject(id,father);		
		end;
		
		//alineacion del eje X del grafico
		alignAxis(id);
		
		frame;
	end;
	
end;

//funcion que actualiza las propiedades de un objeto sobre otro
function updateObject(entity objectA,objectB)
begin
		
	//copiamos las propiedades
	objectB.this.ancho 		= objectA.this.ancho;
	objectB.this.alto 		= objectA.this.alto;
	objectB.this.axisAlign	= objectA.this.axisAlign;
	objectB.this.fX 			= objectA.this.fX;
	objectB.this.fY 			= objectA.this.fY;
	objectB.x  			= objectA.x;
	objectB.y  			= objectA.y;
	objectB.this.vX 			= objectA.this.vX;
	objectB.this.vY 			= objectA.this.vY;
	objectB.this.props 		= objectA.this.props;
	objectB.this.state       = objectA.this.state;
	
end;
