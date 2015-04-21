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
						idPlatform = linearPlatform(_graph,_x0,_y0,_ancho,_alto,_axisAlign,_flags,_props,0.5);
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
process linearPlatform(int graph,int startX,int startY,int _ancho,int _alto,int _axisAlign,int _flags,int _props,float _vX)
private
	int prevX;		//posicion X previa

	int dirX;		//direccion X
	
begin
	region = cGameRegion;
	ctype = c_scroll;
	z = cZObject;
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
				if (isBitSet(this.props,WAIT_PLAYER))			
					//muevo cuando sube el player
					if (idPlatform == father)
						//si esta activada la propiedad de caer al subir el player
						if (isBitSet(this.props,FALL_PLAYER))
							this.state = DEAD_STATE;
						else
							//estado mover
							this.state = MOVE_STATE; 
							//direccion segun sentido
							isBitSet(flags,B_HMIRROR) ? dirX = -1 : dirX = 1;
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
					if (isBitSet(this.props,FALL_COLLISION))
						this.state = DEAD_STATE;
					else
						//cambio sentido
						dirX = -1;
					end;
				end;
				if (getTileCode(id,LEFT_UP_POINT) <> NO_SOLID && dirX == -1)
					//si esta activada la propiedad de caer al colisionar
					if (isBitSet(this.props,FALL_COLLISION))
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
				this.fY +=this.vX;
				if (!region_in(x,y,this.ancho,this.alto<<1))
					signal(id,s_kill);
				end;
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
			idPlayer.this.fY += this.vX;
		end;
			
		frame;
	end;
	
end;