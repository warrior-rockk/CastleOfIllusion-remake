// ========================================================================
//  Warcom Game Engine
//  Motor para juegos plataformas 2D
//  16/04/15
//
//  Procesos Plataforma
// ========================================================================

//Proceso plataforma generica
//Sera el padre de las plataformas concretas para tratarlo como unico para colisiones,etc..
Process platform(int _platformType,int _graph,int _x0,int _y0,int _ancho,int _alto,int _axisAlign,int _flags,int _props)
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
			//DE MOMENTO LAS PLATAFORMAS SE CREAN SIEMPRE?
			inRegion = true;
			//inRegion  = checkInRegion(_x0,_y0,this.ancho,this.alto,CHECKREGION_ALL);
			outRegion = true;
			//eliminamos la plataforma para crearlo de nuevo
			if (exists(idPlatform))
				signal(idPlatform,s_kill_tree);
			end;
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
		
			//desaparece al salir de la region del juego y no es persistente
			if (outRegion && !isBitSet(idPlatform.this.props,PERSISTENT)) 
				//eliminamos la plataforma
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
			//si no existe plataforma, el padre no es colisionable
			setBit(this.props,NO_COLLISION);
			
			//la region se comprueba con las coordenadas iniciales
			x = _x0;
			y = _y0;
			
			//creamos la plataforma si entra en la region
			if (inRegion && outRegion) 
				//creamos el tipo de plataforma
				switch (_platformType)
					case PLATF_LINEAR:
						idPlatform = linearPlatform(_graph,_x0,_y0,_ancho,_alto,_axisAlign,_flags,_props | PERSISTENT,cPlatformDefaultVel);
					end;
					case PLATF_CLOUD:
						idPlatform = cloudPlatform(_graph,_x0,_y0,_ancho,_alto,_axisAlign,_flags,_props | PERSISTENT);
					end;
					case PLATF_SPRINGBOX:
						idPlatform = springBoxPlatform(_graph,_x0,_y0,_ancho,_alto,_axisAlign,_flags,_props);
					end;
				end;	
				log("Se crea la plataforma "+idPlatform,DEBUG_OBJECTS);
				
				outRegion = false;
			end;
		end;
		
		
		//Comprobamos si entra en la region
		if (checkInRegion(x,y,this.ancho,this.alto,CHECKREGION_ALL))
			inRegion = true;
		end;
		
		//Comprobamos si sale de la region
		if (!checkInRegion(x,y,this.ancho+cPlatformMargin,this.alto+cPlatformMargin,CHECKREGION_ALL))
			outRegion = true;
		end;
			
		frame;
	end;
end;

//Proceso plataforma linear
//se mueve linealmente a una velocidad dadas hasta que colisiona y cambia direccion
process linearPlatform(int graph,int startX,int startY,int _ancho,int _alto,int _axisAlign,int _flags,int _props,float _vX)
private
	int prevX;			//posicion X previa
	int prevY;			//posicion Y previa
	int dirX;			//direccion X
	
	int waitTime;		//tiempo espera
	byte memIdPlatform; 	//memoria de que el player esta en plataforma
	
begin
	region = cGameRegion;
	ctype = c_scroll;
	z = cZPlatform;
	file = level.fpgObjects;
	flags = _flags;
	
	//igualamos la propiedades publicas a las de parametros
	this.ancho 		= _ancho;
	this.alto 		= _alto;
	this.vX  		= _vX;
	this.props  	= _props;
	this.axisAlign 	= _axisAlign;
	
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
				//si esta activada la propiedad de esperar al player para mover
				if (isBitSet(this.props,PLATF_WAIT_PLAYER))			
					//muevo cuando sube el player
					if (idPlatform == father)
						memIdPlatform = true;
						//si esta activada la propiedad de caer al subir el player
						if (!isBitSet(this.props,PLATF_FALL_PLAYER))
							//estado mover
							this.state = MOVE_STATE; 
							//direccion segun sentido
							isBitSet(flags,B_HMIRROR) ? dirX = -1 : dirX = 1;
						end;
					end;
					//si esta activada la propiedad de caer al subir el player
					if (isBitSet(this.props,PLATF_FALL_PLAYER) && memIdPlatform)
						//tiempo espera
						if (clockTick)
							waitTime++;
						end;
						//tiempo cumplido
						if (waitTime >= cPlatformWaitTime)
							this.state = DEAD_STATE;
							memIdPlatform = false;
						end;
					end;
				else
					//estado mover
					this.state = MOVE_STATE; 
					//direccion segun sentido
					isBitSet(flags,B_HMIRROR) ? dirX = -1 : dirX = 1;
				end;
			end;
			case MOVE_STATE:
				//cambio de estado al colisionar
				if (getTileCode(id,RIGHT_UP_POINT) <> NO_SOLID && dirX == 1)
					//si esta activada la propiedad de caer al colisionar
					if (isBitSet(this.props,PLATF_FALL_COLLISION))
						this.state = DEAD_STATE;
					else
						//cambio sentido
						dirX = -1;
					end;
				end;
				if (getTileCode(id,LEFT_UP_POINT) <> NO_SOLID && dirX == -1)
					//si esta activada la propiedad de caer al colisionar
					if (isBitSet(this.props,PLATF_FALL_COLLISION))
						this.state = DEAD_STATE;
					else
						//cambio sentido
						dirX = 1;
					end;
				end;
				
				//movimiento lineal
				this.fX+=this.vX*dirX;
				this.fY+=this.vY;
			end;
			case DEAD_STATE:
				//movemos en caida
				this.fY += cPlatformFallVel;
				//si el player esta en plataforma, cae tambien
				if (idPlatform == father)
					idPlayer.this.fY += cPlatformFallVel;
				end;
				//matamos la plataforma cuando se salga de la region
				if (!checkInRegion(x,y,this.ancho,this.alto<<1,CHECKREGION_ALL))
					signal(id,s_kill);
				end;
			end;
		end;
		
		//guardamos la posicion anterior
		prevX = x;
		prevY = y;
		
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

//Proceso plataforma nube
Process cloudPlatform(int _graph,int startX,int startY,int _ancho,int _alto,int _axisAlign,int _flags,int _props)
private
	int prevX;				//posicion X previa
	int prevY;				//posicion Y previa
	
	int numClouds;				//Numero de procesos nube	
	
	int currentStepTime; 	//tiempo actual paso
	int stepTime;
begin
	region = cGameRegion;
	ctype = c_scroll;
	z = cZPlatform;
	file = level.fpgObjects;
	flags = _flags;
	
	//igualamos la propiedades publicas a las de parametros
	this.ancho 		= _ancho;
	this.alto 		= _alto;
	this.vX  		= cPlatformDefaultVel;
	this.props  	= _props;
	this.axisAlign 	= _axisAlign;
	
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
	
	//contamos numero de nubes
	repeat
		numClouds++;
	until( get_id(TYPE cloudPlatform) == 0)
	
	//ajustamos retardo
	stepTime = 30*numClouds;
	
	//bucle principal
	loop
		//nos actualizamos del padre
		updateObject(father,id);
		
		//guardamos estado actual
		this.prevState = this.state;
		
		switch (this.state)
			case IDLE_STATE:
				graph = 0;
				this.fX = startX;
				this.fY = startY;
				setBit(this.props,NO_COLLISION);
				//cambio de paso por tiempo
				if (currentStepTime >= stepTime)
					this.state = MOVE_STATE;
					currentStepTime = 0;
				else
					//contador paso
					if (clockTick)
						currentStepTime++;
					end;
				end;
			end;
			case MOVE_STATE:
				//imagen inicial
				graph = _graph;
				this.vY = -this.vX;
				//movimiento lineal
				this.fX+=this.vX;
				this.fX+=0.5*rand(-1,1);
				this.fY+=this.vY;
				//cambio de grafico a llegar a altura
				if (this.fY <= startY - 20)
					graph = 23;
				end;
				//cambio de paso al llegar a altura
				if (this.fY <= startY - 50)
					this.state = MOVE_RIGHT_STATE;
				end;
			end;
			case MOVE_RIGHT_STATE:
				graph = 24;
				unSetBit(this.props,NO_COLLISION);
				//movimiento lineal
				this.fX+=this.vX;
				//cambio de grafico y propiedades al llegar a posicion
				if (this.fX >= startX + 195)
					graph = 23;
					setBit(this.props,NO_COLLISION);
				end;
				//cambio de paso al llegar a posicion
				if (this.fX >= startX + 210)
					graph = _graph;
					this.state = DEAD_STATE;
				end;
			end;
			case DEAD_STATE:
				graph = _graph;
				//movimiento lineal
				this.fX+=this.vX;
				//cambio de paso al llegar a posicion
				if (this.fX >= startX + 220)
					graph = 0;
					this.state = IDLE_STATE;
				end;
			end;
		end;
		
		//guardamos la posicion anterior
		prevX = x;
		prevY = y;
		
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

//Proceso plataforma springBox
Process springBoxPlatform(int _graph,int startX,int startY,int _ancho,int _alto,int _axisAlign,int _flags,int _props)
private
	int prevX;				//posicion X previa
	int prevY;				//posicion Y previa
	
	entity colID;		//Entidad con la que colisiona
	int colDir;			//Direccion de la colision
begin
	region = cGameRegion;
	ctype = c_scroll;
	z = cZPlatform;
	file = level.fpgObjects;
	flags = _flags;
	
	//igualamos la propiedades publicas a las de parametros
	this.ancho 		= _ancho;
	this.alto 		= _alto;
	this.props  	= _props;
	this.axisAlign 	= _axisAlign;
	
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
	
	setBit(this.props,PLATF_ONE_WAY_COLL);
	
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
			case IDLE_STATE: //oculto hasta que no colisione con ningun objeto
				graph = 0;
				this.fY = startY;
				setBit(this.props,NO_COLLISION);
				
				//retardo inicial
				if (WGE_Animate(0,0,20,ANIM_ONCE))
					this.state = MOVE_STATE;
				end;

				//lanzamos comprobacion con procesos objeto
				repeat
					//obtenemos siguiente colision
					colID = get_id(TYPE object);
					if (colCheckProcess(id,colID,INFOONLY) <> NOCOL)
						this.state = IDLE_STATE;
					end;
				until (colID == 0);
			end;
			case MOVE_STATE:
				unSetBit(this.props,NO_COLLISION);
				//grafico estirado
				graph = 29;
				
				//cambio de paso si se sube el player
				if (idPlatform == father)			
					this.state = MOVE_DOWN_STATE;
				end;
			end;
			case MOVE_DOWN_STATE:
				//grafico estirado
				graph = 29;
				
				//movemos el muelle hacia abajo
				this.fY+=cSpringBoxVel;
				
				//cambio de estado al llegar a posicion
				if (this.fY >= startY + 16)
					this.state = PUSHED_STATE;
				end;
			end;
			case PUSHED_STATE:
				//cambio de estado tras espera
				if (WGE_Animate(30,30,20,ANIM_ONCE))
					this.state = MOVE_UP_STATE;
				end;
			end;
			case MOVE_UP_STATE:
				graph = 29;
				
				//movemos muelle hacia arriba
				this.fY-=cSpringBoxVel;
				
				//cambio de estado al llegar a posicion
				if (this.fY <= startY)
					this.state = MOVE_STATE;
					this.fY = startY;
					//impulsamos al player
					if (idPlatform == father)
						idPlayer.this.vY += -cSpringBoxImpulse;
					end;
				end;
			end;
		end;
				
		//guardamos la posicion anterior
		prevX = x;
		prevY = y;
		
		//actualizamos posicion
		positionToInt(id);
		
		//actualizamos el objeto padre
		updateObject(id,father);		
				
		//si el player esta en plataforma
		if (idPlatform == father)
			//actualizamos la posicion del player lo que se movio la plataforma
			idPlayer.this.fX += x - prevX;
			idPlayer.this.fY += y-  prevY;
		end;
			
		frame;
	end;
end;