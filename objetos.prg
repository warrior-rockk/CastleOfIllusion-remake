// ========================================================================
//  Warcom Game Engine
//  Motor para juegos plataformas 2D
//  22/08/14
//
//  Procesos Objetos
// ========================================================================

//Proceso plataforma generica
//Sera el padre de las plataformas concretas para tratarlo como unico para colisiones,etc..
Process platform(int _platformType,int _graph,int _x0,int _y0,int _ancho,int _alto)
private
	platform idPlatform;	//id de la plataforma hija
	
	byte    inRegion;		//flag de plataforma en region
	byte    outRegion;		//flag de plataforma fuera de region
begin
	priority = cPlatformPrior;
	
	this.state = INITIAL_STATE;
	
	loop
			
		//si se reinicia, se actualiza flags region
		if (this.state == INITIAL_STATE)
			inRegion  = region_in(_x0,_y0,this.ancho,this.alto);
			outRegion = true;
		end;
		
		//si existe el hijo
		if (exists(idPlatform))
			
			//si el proceso tiene la prioridad del player
			if (priority == cPlayerPrior)
				//cambio la del hijo
				idPlatform.priority = cPlatformPrior;		
			else
				idPlatform.priority = cPlatformChildPrior;
			end;
		
			//desaparece al salir de la region del juego
			if (outRegion) 
				//eliminamos el mosntruo
				signal(idPlatform,s_kill);
				log("Se elimina la plataforma "+idPlatform,DEBUG_OBJECTS);
				//bajamos flags
				inRegion = false;
				outRegion = false;
				//la region se comprueba con las coordenadas iniciales
				x = _x0;
				y = _y0;
			end;
			
		else
			//si no existe objeto, el padre no es colisionable
			setBit(this.props,NO_COLLISION);
			
			//la region se comprueba con las coordenadas iniciales
			x = _x0;
			y = _y0;
			
			//creamos el monstruo si entra en la region
			if (inRegion && outRegion) 
				//creamos el tipo de plataforma
				switch (_platformType)
					case PLATF_LINEAR:
						idPlatform = linearPlatform(_graph,_x0,_y0,_ancho,_alto,0.5);
					end;
					case PLATF_TRIGGER:
						idPlatform = triggerPlatform(_graph,_x0,_y0,_ancho,_alto,0.5,1);
					end;
				end;	
				log("Se crea la plataforma "+idPlatform,DEBUG_OBJECTS);
				
				outRegion = false;
			end;
		end;
		
		//Comprobamos si entra en la region
		if (region_in(x,y,this.ancho,this.alto))
			inRegion = true;
		end;
		
		//DE MOMENTO LAS PLATAFORMAS NO DESAPARECEN
		//Comprobamos si sale de la region
		/*if (!region_in(x,y,this.ancho,this.alto))
			outRegion = true;
		end;*/
			
		frame;
	end;
end;

//Proceso plataforma linear
//se mueve linealmente a una velocidad dadas hasta que colisiona y cambia direccion
process linearPlatform(int graph,int startX,int startY,int _ancho,int _alto,float _vX)
private
	int prevX;		//posicion X previa

	int dirX;		//direccion X
	
begin
	region = cGameRegion;
	ctype = c_scroll;
	z = cZObject;
	file = level.fpgObjects;
		
	//igualamos la propiedades publicas a las de parametros
	this.ancho 	= _ancho;
	this.alto 	= _alto;
	this.vX  	= _vX;
	
	//modo debug sin graficos
	if (file<0)
		graph = map_new(this.ancho,this.alto,8,0);
		map_clear(0,graph,310);
	end;
	
	//puntos de colision del objeto
	this.colPoint[LEFT_UP_POINT].x 		= -(this.ancho>>1);
	this.colPoint[LEFT_UP_POINT].y 		= 0;
	this.colPoint[LEFT_UP_POINT].colCode = COLIZQ;
	this.colPoint[LEFT_UP_POINT].enabled = 1;
	
	this.colPoint[RIGHT_UP_POINT].x 		= (this.ancho>>1);
	this.colPoint[RIGHT_UP_POINT].y 		= 0;
	this.colPoint[RIGHT_UP_POINT].colCode = COLDER;
	this.colPoint[RIGHT_UP_POINT].enabled = 1;
	
	x = startX;
	y = startY;
	
	this.fX = x;
	this.fY = y;
	
	this.state = IDLE_STATE;
	
	//actualizamos al padre con los datos de creacion
	updateObject(id,father);	
	
	//bucle principal
	loop
		//nos actualizamos del padre
		updateObject(father,id);
		
		//guardamos estado actual
		this.prevState = this.state;
		
		switch (this.state)
			case IDLE_STATE:
				//estado por defecto
				this.state = MOVE_STATE; 
				//direccion por defecto
				dirX = 1;
			end;
			case MOVE_STATE:
				//cambio de estado al colisionar
				if (getTileCode(id,RIGHT_UP_POINT) <> NO_SOLID)
					dirX = -1;
				end;
				if (getTileCode(id,LEFT_UP_POINT) <> NO_SOLID)
					dirX = 1;
				end;
				
				//movimiento lineal
				this.fX+=this.vX*dirX;
				this.fY+=this.vY;
			end;
		end;
		
		//guardamos la posicion actual X
		prevX = x;
		
		//actualizamos posicion
		positionToInt(id);
		
		//actualizamos el objeto padre
		updateObject(id,father);		
				
		//si el player esta en plataforma
		if (idPlatform == father)
			//actualizamos la posicion del player lo que se movio la plataforma
			idPlayer.this.fX += x - prevX;
		end;
			
		frame;
	end;
	
end;

//Proceso plataforma linear
//se mueve linealmente a una velocidad dadas hasta que colisiona y cambia direccion
process triggerPlatform(int graph,int startX,int startY,int _ancho,int _alto,float _vX,int deadDir)
private
	int prevX;		//posicion X previa
	int dirX;		//direccion X
	
begin
	region = cGameRegion;
	ctype = c_scroll;
	z = cZObject;
	file = level.fpgObjects;
		
	//igualamos la propiedades publicas a las de parametros
	this.ancho 	= _ancho;
	this.alto 	= _alto;
	this.vX  	= _vX;
	
	//modo debug sin graficos
	if (file<0)
		graph = map_new(this.ancho,this.alto,8,0);
		map_clear(0,graph,310);
	end;
	
	//puntos de colision del objeto
	this.colPoint[LEFT_UP_POINT].x 		= -(this.ancho>>1);
	this.colPoint[LEFT_UP_POINT].y 		= 0;
	this.colPoint[LEFT_UP_POINT].colCode = COLIZQ;
	this.colPoint[LEFT_UP_POINT].enabled = 1;
	
	this.colPoint[RIGHT_UP_POINT].x 		= (this.ancho>>1);
	this.colPoint[RIGHT_UP_POINT].y 		= 0;
	this.colPoint[RIGHT_UP_POINT].colCode = COLDER;
	this.colPoint[RIGHT_UP_POINT].enabled = 1;
	
	x = startX;
	y = startY;
	
	this.fX = x;
	this.fY = y;
	
	this.state = IDLE_STATE;
		
	//actualizamos al padre con los datos de creacion
	updateObject(id,father);
		
	//bucle principal
	loop
		//nos actualizamos del padre
		updateObject(father,id);
		
		//guardamos estado actual
		this.prevState = this.state;
		
		switch (this.state)
			case IDLE_STATE:
				//muevo cuando sube el player
				if (idPlatform == father)
					//estado por defecto
					this.state = MOVE_STATE; 
					//direccion por defecto
					dirX = -1;
				end;
			end;
			case MOVE_STATE:
				//cambio de estado al colisionar
				if (getTileCode(id,RIGHT_UP_POINT) <> NO_SOLID)
					dirX = -1;
				end;
				if (getTileCode(id,LEFT_UP_POINT) <> NO_SOLID)
					dirX = 1;
				end;
				
				//movimiento lineal
				this.fX+=this.vX*dirX;
				this.fY+=this.vY;
				
				if (dirX == deadDir)
					this.state = DEAD_STATE;
				end;
			end;
			case DEAD_STATE:
				this.fY +=0.5;
				if (region_out(id,cGameRegion))
					signal(id,s_kill);
				end;
			end;
		end;
		
		//guardamos la posicion actual
		prevX = x;
				
		//actualizamos posicion
		positionToInt(id);
		
		//actualizamos el objeto padre
		updateObject(id,father);		
				
		//si el player esta en plataforma
		if (idPlatform == father)
			//actualizamos la posicion del player lo que se movio la plataforma
			idPlayer.this.fX += x - prevX;
			idPlayer.this.fY += 0.5;
		end;
	
		frame;
	end;
	
end;

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
			inRegion  = region_in(_x0,_y0,this.ancho,this.alto);
			outRegion = true;
		end;
		
		//si existe el objeto
		if (exists(idObject))
			
			//desaparece al salir de la region del juego
			if (outRegion) 
				//eliminamos el objeto
				signal(idObject,s_kill);	
				log("Se elimina el objeto "+idObject,DEBUG_OBJECTS);
				//bajamos flags
				inRegion = false;
				outRegion = false;
				//la region se comprueba con las coordenadas iniciales
				x = _x0;
				y = _y0;
			end;

		else
			//si no existe objeto, el padre no es colisionable
			setBit(this.props,NO_COLLISION);
			
			//la region se comprueba con las coordenadas iniciales
			x = _x0;
			y = _y0;
			
			//creamos el objeto si entra en la region y si es persistente
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
						idObject = solidItem(_graph,_x0,_y0,_ancho,_alto,_axisAlign,_flags,_props | IS_KEY | NO_PERSISTENT | PICKABLE);
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
		if (region_in(x,y,this.ancho,this.alto) && !inRegion)
			inRegion = true;
		end;
		
		//Comprobamos si sale de la region
		if (!region_in(x,y,this.ancho,this.alto))
			outRegion = true;
		end;
			
		frame;
	end;
end;

//Proceso solidItem
process solidItem(int graph,int x,int y,int _ancho,int _alto,int _axisAlign,int _flags,int _props)
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
	
	this.fX = x;
	this.fY = y;
	
	WGE_CreateObjectColPoints(id);
	
	friction = floorFriction;
	
	this.state = MOVE_STATE;
	
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
				//vuelver a ser colisionable por procesos
				unSetBit(this.props,NO_COLLISION);
				
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
				isBitSet(idPlayer.flags,B_HMIRROR) ? this.fX = idPlayer.x-cObjectPickedPosX : this.fX = idPlayer.x+cObjectPickedPosX;
				this.fY = idPlayer.y+cObjectPickedPosY;
				//reseteamos flag boton si lo hubiera seteado el proceso
				if (idButton == father) 
					idButton = 0;
				end;
			end;
			case THROWING_STATE:	
				//mientras se mueve, no es solido
				setBit(this.props,NO_COLLISION);
				//fisicas activadas
				unSetBit(this.props,NO_PHYSICS);
				
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
						if (colDir <> NOCOL && isType(colID.son,TYPE keyDoor))
							//seteamos el idKey al objeto padre nuestro
							idKey = father;
							//rompemos la llave
							this.state = DEAD_STATE;
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
					end;
					
				until (colID == 0);
				
				//cambio de estado
				
				//si es rompible
				if (isBitSet(this.props,BREAKABLE))
					//si colisiona con algo o toca suelo
					if (collided || grounded )
						//actualizamos la posicion para ver la explosion en el sitio
						this.vY = 0;
						this.fX += this.vX;
						this.fY += this.vY;
						positionToInt(id);
						
						//cambiamos de estado
						this.state = DEAD_STATE;
					end;
				else
					//si no ha colisionado y toca suelo, cambiamos de estado
					if (grounded && abs(this.vX) < cMinVelXToIdle) 
						this.state = IDLE_STATE;
					end;
				end;
				
			end;
			case DEAD_STATE:
				//si el objeto tiene item dentro, lo lanzamos
				if (isBitSet(this.props,ITEM_BIG_COIN) || isBitSet(this.props,ITEM_STAR))
					//item(x,y,this.ancho,this.alto,this.props);
					object(OBJ_ITEM,0,x,y,16,16,CENTER_AXIS,0,ITEM_BIG_COIN);
				end;
				//lanzamos animacion explosion objeto
				WGE_Animation(file,2,3,x,y,10,ANIM_ONCE);
				//si el objeto no es persistente
				if (isBitSet(this.props,NO_PERSISTENT))
					//matamos al padre
					signal(father,s_kill);
				end;
				//reseteamos flag boton si lo hubiera seteado el proceso
				if (idButton == father) 
					idButton = 0;
				end;
				//matamos el objeto
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
	unSetBit(this.props,BREAKABLE);
	unSetBit(this.props,PICKABLE);
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
				if (!isBitSet(this.props,ITEM_GEM) && !isBitSet(this.props,ITEM_STAR))
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
					this.state = DEAD_STATE;
					picked = true;
				end;
				
				//animacion del item
				if (isBitSet(this.props,ITEM_BIG_COIN))
					WGE_Animate(6,7,20,ANIM_LOOP);
				end;
				if (isBitSet(this.props,ITEM_STAR))
					WGE_Animate(11,12,20,ANIM_LOOP);
				end;
				if (isBitSet(this.props,ITEM_GEM))
					WGE_Animate(13,13,10,ANIM_LOOP);
				end;
			end;
			
			case DEAD_STATE:
				//si ha sido recodido el item
				if (picked)
					//segun el item,realizamos una accion determinada
					if (isBitSet(this.props,ITEM_BIG_COIN))
						//incrementa puntuacion
						game.score += cBigCoinScore;
					end;
					if (isBitSet(this.props,ITEM_STAR))
						//añade una estrella a la vida
						game.playerMaxLife += 1;
						game.playerLife = game.playerMaxLife;
					end;
					if (isBitSet(this.props,ITEM_GEM))
						//fin del nivel actual
						game.endLevel = true;
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
	unSetBit(this.props,BREAKABLE);
	unSetBit(this.props,PICKABLE);
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
	
	this.state = IDLE_STATE;
	
	//ajustamos propiedades fijas de un doorbutton
	unSetBit(this.props,BREAKABLE);
	unSetBit(this.props,PICKABLE);
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
							//si hay alguna puerta inferior que no se ha abierto, reseteamos apertura
							if (doorID.y > y && doorID.this.state <> PUSHED_STATE)
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
							this.state = PUSHED_STATE;
						end;
					end;
				end;
			end;
			case PUSHED_STATE:
				//hacemos la puerta no solida
				SetBit(this.props,NO_COLLISION);
				//le quitamos grafico
				graph = 0;
				//si se suelta el boton
				if (idButton == 0 )
					//reseteamos el flag de apertura
					openDoor = false;
					//comprobamos las demas puertas para abrir en secuencia segun altura
					repeat
						doorID = get_id(TYPE doorButton);
						if (doorID <> 0)
							//si hay alguna puerta por debajo que no se ha cerrado, reseteamos el cierre
							if (doorID.y < y && doorID.this.state <> IDLE_STATE)
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
							this.state = IDLE_STATE;
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
	unSetBit(this.props,BREAKABLE);
	unSetBit(this.props,PICKABLE);
	SetBit(this.props,NO_PHYSICS);
	unSetBit(this.props,NO_COLLISION);
	setBit(this.props,NO_PERSISTENT);
	
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
							//si hay alguna puerta inferior que no se ha abierto, reseteamos apertura
							if (doorID.y > y && doorID.this.state <> PUSHED_STATE)
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
							this.state = PUSHED_STATE;
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
