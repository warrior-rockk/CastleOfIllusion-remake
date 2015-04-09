// ========================================================================
//  Warcom Game Engine
//  Motor para juegos plataformas 2D
//  22/08/14
//
//  Procesos monsters (enemigos)
// ========================================================================

//Proceso monstruo generico
//Sera el padre del monstruo concreto para tratarlo como unico para colisiones,etc..
Process monster(int monsterType,int _x0,int _y0,int _ancho,int _alto,int _axisAlign,int _flags,int _props)
private
	monster idMonster;		//id del mosntruo que se crea
	
	byte    inRegion;		//flag de monstruo en region
	byte    outRegion;		//flag de monstruo fuera de region
begin
	//el objeto padre tiene que tener prioridad superior a los hijos
	priority = cMonsterPrior;
	
	this.state = INITIAL_STATE;
	
	loop
		//si se reinicia, se actualiza flags region
		if (this.state == INITIAL_STATE)
			inRegion  = region_in(_x0,_y0,_ancho,_alto);
			outRegion = true;
		end;
		
		//si existe el monstruo
		if (exists(idMonster))
						
			//desaparece al salir de la region del juego
			if (outRegion) 
				//eliminamos el mosntruo
				signal(idMonster,s_kill);
				log("Se elimina el monstruo "+idMonster,DEBUG_MONSTERS);
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
				//creamos el tipo de monstruo
				switch (monsterType)
					case MONS_CYCLECLOWN:
						idMonster = cycleClown(1,_x0,_y0,_ancho,_alto,_axisAlign,_flags,HURTPLAYER);				
					end;
					case MONS_TOYPLANE:
						idMonster = toyPlane(9,_x0,_y0,_ancho,_alto,_axisAlign,_flags,HURTPLAYER);
					end;
					case MONS_TOYPLANECONTROL:
						idMonster = toyPlaneControl(15,_x0,_y0,_ancho,_alto,_axisAlign,_flags,HURTPLAYER);
					end;
				end;	
				log("Se crea el monstruo "+idMonster,DEBUG_MONSTERS);
				
				outRegion = false;
			end;
		end;
		
		//Comprobamos si entra en la region
		if (region_in(x,y,this.ancho,this.alto))
			inRegion = true;
		end;
		
		//Comprobamos si sale de la region
		if (!region_in(x,y,this.ancho,this.alto))
			outRegion = true;
		end;
			
		frame;
	end;
end;

//Proceso enemigo cycleClown
//Se mueve izquierda a derecha en un rango y dispara cuando el player está cerca
process cycleClown(int graph,int x,int y,int _ancho,int _alto,int _axisAlign,int _flags,int _props)
private
byte grounded;		//flag de en suelo
float friction;		//friccion local

int colID;			//Id de colision
int colDir;			//direccion de la colision
byte collided;		//flag de colision

int _x0;			//X inicial
int xRange;			//Rango de movimiento X
float xVel;			//Velocidad movimiento

byte atack;			//Flag de atacar al enemigo
int atackRangeX;		//Rango en el que ataca
int i;				//Variable auxiliar
begin
	region = cGameRegion;
	ctype = c_scroll;
	z = cZMonster;
	file = level.fpgMonsters;
	flags = _flags;
	
	//igualamos la propiedades publicas a las de parametros
	this.ancho = _ancho;
	this.alto = _alto;
	this.axisAlign = _axisAlign;
	this.props = _props;
	
	//modo debug sin graficos
	if (file<0)
		graph = map_new(this.ancho,this.alto,8,0);
		map_clear(0,graph,rand(200,300));
	end;
	
	this.fX = x;
	this.fY = y;
	
	_x0 = x;
	xRange = 10;
	xVel   = 0.2;
	atackRangeX = 50;
	
	WGE_CreateObjectColPoints(id);
	
	friction = floorFriction;
	
	this.state = MOVE_STATE;
	
	//actualizamos al padre con los datos de creacion
	updateMonster(id,father);
		
	loop
		//nos actualizamos del padre
		updateMonster(father,id);
		
		//FISICAS	
		collided = terrainPhysics(ID,friction,&grounded);
		
		//guardamos estado actual
		this.prevState = this.state;
		
		//maquina de estados
		switch (this.state)
			case IDLE_STATE:
				;
			end;
			case MOVE_STATE: //movimiento en rango
				//cambio de direccion al superar rango
				if (abs(this.fX - _x0) > xRange)
					xVel *= -1;
				end;
				
				//movimiento lineal
				this.vX = xVel;
				
				//animacion movimiento
				WGE_Animate(1,6,5,ANIM_LOOP);	
				
				//si existe el player
				if (idPlayer <> 0 )
					//miramos a su direccion
					if (idPlayer.this.fX > this.fX)
						flags &=~ B_HMIRROR; 
					else
						flags |= B_HMIRROR; 
					end;
					//player en rango ataque
					if (abs(idPlayer.this.fX - this.fX) < atackRangeX && !atack)
						atack = true;
						isBitSet(flags,B_HMIRROR) ? monsterFire(7,x,y-16,-2,-4) : monsterFire(7,x,y-16,2,-4);		
					end;
				end;
				//podemos volver a atacar cuando muere el disparo
				if (!exists(son))
					atack = false;
				end;
			end;
			case HURT_STATE:   
				this.state = DEAD_STATE;
			end;
			case DEAD_STATE:
				graph = 8;
				deadMonster();
				signal(id,s_kill);
			end;
		end;
				
		//actualizamos velocidad y posicion
		updateVelPos(id,grounded);
		
		//actualizamos el monstruo padre
		updateMonster(id,father);
		
		//alineacion del eje X del grafico
		alignAxis(id);
		
		frame;
	end;
	
end;

//Proceso disparo de un monstruo
process monsterFire(int graph,int x,int y,float _vX,float _vY)
begin
	region = cGameRegion;
	ctype = c_scroll;
	z = cZMonster;
	file = level.fpgMonsters;
	
	//igualamos la propiedades publicas a las de parametros
	this.vX = _vX;
	this.vY = _vY;
	
	this.fX = x;
	this.fY = y;
	
	repeat	
			//fisicas
			this.vY += gravity;
			
			this.fX += this.vX;
			this.fY += this.vY;
			positionToInt(id);
			
			frame;
	//morimos al salirnos de la pantalla
	until (out_region(id,cGameRegion));
	
end;

//Proceso enemigo toyPlane
//Se mueve izquierda a derecha hasta tocar pared y no muerte hasta matar el mando a distancia
process toyPlane(int graph,int x,int y,int _ancho,int _alto,int _axisAlign,int _flags,int _props)
private
float friction;		//friccion local
byte grounded;		//flag de en suelo

int colID;			//Id de colision
int colDir;			//direccion de la colision
byte collided;		//flag de colision

float xVel;			//Velocidad movimiento
int hurtedCounter; 	//contador tiempo dañado

int i;				//Variable auxiliar
begin
	region = cGameRegion;
	ctype = c_scroll;
	z = cZMonster;
	file = level.fpgMonsters;
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
	
	isBitSet(flags,B_HMIRROR) ? xVel = -2 : 	xVel   = 2;
	
	WGE_CreateObjectColPoints(id);
	
	friction = floorFriction;
	
	this.state = MOVE_STATE;
	
	//actualizamos el padre con los datos de creación
	updateMonster(id,father);
	
	loop
		//nos actualizamos del padre
		updateMonster(father,id);
		
		//FISICAS	
		collided = terrainPhysics(ID,friction,&grounded);
		
		//guardamos estado actual
		this.prevState = this.state;
		
		//maquina de estados
		switch (this.state)
			case IDLE_STATE: //mirando al frente para cambiar de direcccion
				//detenemos movimiento
				this.vX = 0;
				//pausa con animacion mirando al frente
				if (WGE_Animate(11,11,5,ANIM_ONCE))
					collided = false;
					this.state = MOVE_STATE;
					this.vX = xVel;
				end;
			end;
			case MOVE_STATE: //movimiento de pared a pared
				//dañamos al player
				setBit(this.props,HURTPLAYER);
				//si toca pared, invierte movimiento
				if (collided)
					xVel = xVel * -1;
					collided = false;
					this.state = IDLE_STATE;
				end;
				//actualizamos movimiento
				this.vX = xVel;
				//animacion movimiento
				WGE_Animate(9,10,5,ANIM_LOOP);
				//sentido del grafico
				xVel < 0 ? setBit(flags,B_HMIRROR) : unsetBit(flags,B_HMIRROR);
			end;
			case HURT_STATE: //toque
				//detenemos el movimiento
				this.vX = 0;
				//no dañamos en este estado
				unsetBit(this.props,HURTPLAYER);
				//animacion toque durante 8 animaciones
				if (hurtedCounter < 8)
					if (WGE_Animate(12,14,5,ANIM_LOOP))
						hurtedCounter++;
					end;
				else
					//pasado el tiempo, volvemos a movernos
					hurtedCounter = 0;
					this.state = MOVE_STATE;
					this.vX = xVel;
				end;
			end;
			case DEAD_STATE:
				deadMonster();
				signal(id,s_kill);
			end;
		end;
		
		//no tiene gravedad
		this.vY = 0;
		
		//actualizamos velocidad y posicion
		updateVelPos(id,grounded);
		
		//actualizamos el monstruo padre
		updateMonster(id,father);
		
		//alineacion del eje X del grafico
		alignAxis(id);
		
		frame;
	end;
	
end;

//Proceso enemigo toyPlaneControl
//Cuando muere, mata a los toyPlane
process toyPlaneControl(int graph,int x,int y,int _ancho,int _alto,int _axisAlign,int _flags,int _props)
private
byte grounded;		//flag de en suelo
monster idToyPlane;	//id de toyPlane activo

int i;				//Variable auxiliar
begin
	region = cGameRegion;
	ctype = c_scroll;
	z = cZMonster;
	file = level.fpgMonsters;
	flags = _flags;
	
	//igualamos la propiedades publicas a las de parametros
	this.ancho = _ancho;
	this.alto = _alto;
	this.axisAlign = _axisAlign;
	this.props = _props;
	
	//modo debug sin graficos
	if (file<0)
		graph = map_new(this.ancho,this.alto,8,0);
		map_clear(0,graph,rand(200,300));
	end;
	
	this.fX = x;
	this.fY = y;
	
	WGE_CreateObjectColPoints(id);
	
	this.state = IDLE_STATE;
	
	//actualizamos el padre con los datos de creación
	updateMonster(id,father);
	
	loop
		//nos actualizamos del padre
		updateMonster(father,id);
			
		//FISICAS	
		terrainPhysics(ID,1,&grounded);
		
		//guardamos estado actual
		this.prevState = this.state;
		
		//maquina de estados
		switch (this.state)
			case IDLE_STATE: 
				WGE_Animate(15,16,30,ANIM_LOOP);
			end;
			case HURT_STATE: //toque
				this.state = DEAD_STATE;
				//matamos todo toyPlane que esté activo
				repeat
					idToyPlane = get_id(TYPE toyPlane);
					if (idToyPlane <> 0 )
						idToyPlane = idToyPlane.father;
						idToyPlane.this.state = DEAD_STATE;
					end;
				until (idToyPlane == 0);
			end;
			case DEAD_STATE:
				graph = 17;
				deadMonster();
				signal(id,s_kill);
			end;
		end;
		
		//actualizamos velocidad y posicion
		updateVelPos(id,grounded);
		
		//actualizamos el monstruo padre
		updateMonster(id,father);
		
		//alineacion del eje X del grafico
		alignAxis(id);
		
		frame;
	end;
	
end;

//proceso de muerte de monstruo
process deadMonster()
begin
	region = cGameRegion;
	ctype = c_scroll;
	z = cZMonster;
	file = level.fpgMonsters;
	
	this.fX = father.x;
	this.fY = father.y;
	graph = father.graph;
	flags = father.flags;
	
	this.vX = 0;
	this.vY = -4;
	
	repeat	
			//fisicas
			this.vY += gravity;
			
			this.fX += this.vX;
			this.fY += this.vY;
			positionToInt(id);
			
			WGE_Animate(graph,graph,1,ANIM_LOOP);
			
			frame;
	//morimos al salirnos de la pantalla
	until (out_region(id,cGameRegion));

end;

//funcion que actualiza las propiedades de un monstruo sobre otro
function updateMonster(entity monsterA,monsterB)
begin
	
	//copiamos las propiedades
	monsterB.this.ancho 		= monsterA.this.ancho;
	monsterB.this.alto 		= monsterA.this.alto;
	monsterB.this.axisAlign	= monsterA.this.axisAlign;
	monsterB.this.fX 		= monsterA.this.fX;
	monsterB.this.fY 		= monsterA.this.fY;
	monsterB.x  		= monsterA.x;
	monsterB.y  		= monsterA.y;
	monsterB.this.vX 		= monsterA.this.vX;
	monsterB.this.vY 		= monsterA.this.vY;
	monsterB.this.props 		= monsterA.this.props;
	monsterB.this.state      = monsterA.this.state;
	
end;