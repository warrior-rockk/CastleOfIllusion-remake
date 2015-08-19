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
			inRegion  = checkInRegion(_x0,_y0,_ancho,_alto,CHECKREGION_ALL);
			outRegion = true;
			//eliminamos el enemigo para crearlo de nuevo
			if (exists(idMonster))
				signal(idMonster,s_kill_tree);
			end;
		end;
		
		//si existe el monstruo
		if (exists(idMonster))
						
			//desaparece al salir de la region del juego y no es persistente
			if (outRegion && !isBitSet(idMonster.this.props,PERSISTENT)) 
				//eliminamos el monstruo
				signal(idMonster,s_kill);
				log("Se elimina el monstruo "+idMonster,DEBUG_MONSTERS);
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
			
			//creamos el monstruo si entra en la region
			if (inRegion && outRegion) 
				//creamos el tipo de monstruo
				switch (monsterType)
					case MONS_CYCLECLOWN:
						idMonster = cycleClown(1,_x0,_y0,_ancho,_alto,_axisAlign,_flags,_props);				
					end;
					case MONS_TOYPLANE:
						idMonster = toyPlane(9,_x0,_y0,_ancho,_alto,_axisAlign,_flags,_props);
					end;
					case MONS_TOYREMOTECONTROL:
						idMonster = toyRemoteControl(15,_x0,_y0,_ancho,_alto,_axisAlign,_flags,_props);
					end;
					case MONS_CHESSHORSE:
						idMonster = chessHorse(22,_x0,_y0,_ancho,_alto,_axisAlign,_flags,_props);
					end;
					case MONS_BUBBLE:
						idMonster = bubble(20,_x0,_y0,_ancho,_alto,_axisAlign,_flags,_props);
					end;				
					case MONS_BALLSCLOWN:
						idMonster = ballsClown(26,_x0,_y0,_ancho,_alto,_axisAlign,_flags,_props);
					end;
					case MONS_MONKEYTOY:
						idMonster = monkeyToy(28,_x0,_y0,_ancho,_alto,_axisAlign,_flags,_props);
					end;
					case MONS_FATGENIUS:
						idMonster = fatGenius(34,_x0,_y0,_ancho,_alto,_axisAlign,_flags,_props);
					end;
					case MONS_TOYCAR:
						idMonster = toyCar(36,_x0,_y0,_ancho,_alto,_axisAlign,_flags,_props);
					end;
					case MONS_BOSS_CLOWN:
						idMonster = bossClown(40,_x0,_y0,_ancho,_alto,_axisAlign,_flags,_props);
					end;
				end;	
				log("Se crea el monstruo "+idMonster,DEBUG_MONSTERS);
				
				outRegion = false;
			end;
		end;
		
		//Comprobamos si entra en la region
		if (checkInRegion(x,y,this.ancho,this.alto,CHECKREGION_ALL))
			inRegion = true;
		end;
		
		//Comprobamos si sale de la region con un margen
		if (!checkInRegion(x,y,this.ancho+cMonsterMargin,this.alto+cMonsterMargin,CHECKREGION_ALL))
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
	
	wgeCreateObjectColPoints(id);
	
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
				wgeAnimate(1,6,5,ANIM_LOOP);	
				
				//si existe el player
				if (exists(idPlayer) )
					//miramos a su direccion
					if (idPlayer.this.fX > this.fX)
						flags &=~ B_HMIRROR; 
					else
						flags |= B_HMIRROR; 
					end;
					//player en rango ataque
					if (abs(idPlayer.this.fX - this.fX) < atackRangeX && !atack)
						atack = true;
						isBitSet(flags,B_HMIRROR) ? monsterFire(31,x,y-16,-1.2,-4,0) : monsterFire(31,x,y-16,1.2,-4,0);		
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
	
	wgeCreateObjectColPoints(id);
	
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
				if (wgeAnimate(11,11,5,ANIM_ONCE))
					collided = false;
					this.state = MOVE_STATE;
					this.vX = xVel;
				end;
			end;
			case MOVE_STATE: //movimiento de pared a pared
				//dañamos al player
				unSetBit(this.props,MONS_HARMLESS);
				//si toca pared, invierte movimiento
				if (collided)
					xVel = xVel * -1;
					collided = false;
					this.state = IDLE_STATE;
				end;
				//actualizamos movimiento
				this.vX = xVel;
				//animacion movimiento
				wgeAnimate(9,10,5,ANIM_LOOP);
				//sentido del grafico
				xVel < 0 ? setBit(flags,B_HMIRROR) : unsetBit(flags,B_HMIRROR);
			end;
			case HURT_STATE: //toque
				//detenemos el movimiento
				this.vX = 0;
				//no dañamos en este estado
				setBit(this.props,MONS_HARMLESS);
				//animacion toque durante 8 animaciones
				if (hurtedCounter < 8)
					if (wgeAnimate(12,14,5,ANIM_LOOP))
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

//Proceso enemigo toyRemoteControl
//Cuando muere, mata a los toyPlane y toyCar que haya en pantalla
process toyRemoteControl(int graph,int x,int y,int _ancho,int _alto,int _axisAlign,int _flags,int _props)
private
byte grounded;		//flag de en suelo
monster idToy;		//id de toyPlane o toyCar
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
	
	wgeCreateObjectColPoints(id);
	
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
				wgeAnimate(15,16,30,ANIM_LOOP);
			end;
			case HURT_STATE: //toque
				this.state = DEAD_STATE;
				//matamos todo toyPlane que esté activo
				repeat
					idToy = get_id(TYPE toyPlane);
					if (idToy <> 0 )
						idToy = idToy.father;
						idToy.this.state = DEAD_STATE;
					end;
				until (idToy == 0);
				//matamos todo toyCar que esté activo
				repeat
					idToy = get_id(TYPE toyCar);
					if (idToy <> 0 )
						idToy = idToy.father;
						idToy.this.state = DEAD_STATE;
					end;
				until (idToy == 0);
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

//Proceso enemigo chessHorse
//dos saltos pequeños, 1 grande. Rebota en las paredes. Cambia de direccion hacia el player cuando toca suelo
process chessHorse(int graph,int x,int y,int _ancho,int _alto,int _axisAlign,int _flags,int _props)
private
byte grounded;		//flag de en suelo
float friction;		//friccion local

float prevVx;		//Velocidad X previa (para rebotar)
int dir;			//Direccion movimiento
float velX;		    //Velocidad Movimiento

int colID;			//Id de colision
int colDir;			//direccion de la colision
byte collided;		//flag de colision

int idleCount;	//contador de ciclos reposo

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
	
	//direccion inicial del movimiento
	isBitSet(flags,B_HMIRROR) ? dir = -1 : dir = 1;
	
	wgeCreateObjectColPoints(id);
	
	friction = floorFriction;
	
	this.state = IDLE_STATE;
		
	//actualizamos al padre con los datos de creacion
	updateMonster(id,father);
		
	loop
		//nos actualizamos del padre
		updateMonster(father,id);
		
		prevVx = this.vX;
		
		//FISICAS	
		collided = terrainPhysics(ID,friction,&grounded);
		if (collided && !grounded) this.vX = prevVx*-1; end;
		
		//lanzamos comprobacion colision con procesos objeto
		repeat
			//obtenemos siguiente colision
			colID = get_id(TYPE object);
			//aplicamos la direccion de la colision
			applyDirCollision(ID,colCheckProcess(id,colID,BOTHAXIS),&grounded);		
		until (colID == 0);
				
		//guardamos estado actual
		this.prevState = this.state;
		
		//maquina de estados
		switch (this.state)
			case IDLE_STATE:
				//animacion movimiento
				if (wgeAnimate(22,23,20,ANIM_LOOP))
					idleCount++;
					//cada X ciclos de animacion, salto grande
					if (idleCount >= cChessHorseIdleCycles*cChessHorseNumCycles)
						idleCount = 0;
						this.state = MOVE_STATE;
						velX = cChessHorseBigMove*dir;
						this.vY = -cChessHorseBigJump;
						grounded = false;
					elseif (idleCount % cChessHorseIdleCycles == 0)
						this.state = MOVE_STATE;
						velX = cChessHorseSmallMove*dir;
						this.vY = -cChessHorseSmallJump;
						grounded = false;
					end;
				end;
				//perseguir jugador
				if (exists(idPlayer))
					//corregimos direccion
					if (idPlayer.this.fX > this.fX)
						dir = 1; 
					else
						dir = -1; 
					end;
				end;
			end;
			case MOVE_STATE: //movimiento salto
				this.vX = velX;
				
				//grafico salto
				this.vY < 0 ? graph = 22: graph = 23;
								
				//pasamos a reposo cuando toca suelo
				if (grounded)
					this.state = IDLE_STATE;
				end;
			end;
			case HURT_STATE:   
				this.state = DEAD_STATE;
			end;
			case DEAD_STATE:
				graph = 24;
				deadMonster();
				signal(id,s_kill);
			end;
		end;
		
		//ajuste flags segun direccion
		this.vX<=0 ? setBit(flags,B_HMIRROR) : unSetBit(flags,B_HMIRROR);
		
		//actualizamos velocidad y posicion
		updateVelPos(id,grounded);
		
		//actualizamos el monstruo padre
		updateMonster(id,father);
		
		//alineacion del eje X del grafico
		alignAxis(id);
		
		frame;
	end;
	
end;

//Proceso enemigo bubble
//Daña al jugador si lo toca cuando esta formado. Explota con objetos y terreno
process bubble(int graph,int startX,int startY,int _ancho,int _alto,int _axisAlign,int _flags,int _props)
private
float friction;			//friccion local
byte grounded;			//flag de en suelo
	
entity colID;				//Id de colision
int colDir;				//direccion de la colision
byte collided;			//flag de colision
	
int dir;				//Direccion movimiento
int currentStepTime; 	//tiempo actual paso

int createBubble;		//Flag de crear burbuja

int i;				//Variable auxiliar

begin
	region = cGameRegion;
	ctype = c_scroll;
	z = cZMonster;
	file = level.fpgMonsters;
	flags = _flags;
	x = startX;
	y = startY;
	
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
	
	//direccion inicial del movimiento
	isBitSet(flags,B_HMIRROR) ? dir = -1 : dir = 1;
	
	//puntos de colision del objeto
	this.colPoint[LEFT_UP_POINT].x 		= -(this.ancho>>1);
	this.colPoint[LEFT_UP_POINT].y 		= 0;
	this.colPoint[LEFT_UP_POINT].colCode = COLIZQ;
	this.colPoint[LEFT_UP_POINT].enabled = 1;
	
	this.colPoint[RIGHT_UP_POINT].x 		= (this.ancho>>1);
	this.colPoint[RIGHT_UP_POINT].y 		= 0;
	this.colPoint[RIGHT_UP_POINT].colCode = COLDER;
	this.colPoint[RIGHT_UP_POINT].enabled = 1;
	
	friction = floorFriction;
	
	this.state = INVISIBLE_STATE;
	
	//actualizamos el padre con los datos de creación
	updateMonster(id,father);
	
	loop
		//nos actualizamos del padre
		updateMonster(father,id);
		
				
		//guardamos estado actual
		this.prevState = this.state;
		
		//maquina de estados
		switch (this.state)
			case INVISIBLE_STATE:
				graph = 0;
				//no dañamos al player
				SetBit(this.props,MONS_HARMLESS);
				//cambio de paso por tiempo
				if (currentStepTime >= cBubbleIdleTime)
					createBubble = true;
					repeat
						colID = get_id(TYPE bubble);
						if (colID <> 0)
							if (colID.y < y && colID.this.state <> MOVE_STATE)
								createBubble = false;
							end;
						end;
					until (colID == 0);
				else
					//contador paso
					if (clockTick)
						currentStepTime++;
					end;
				end;
				
				if (createBubble)
					this.state = IDLE_STATE;
					currentStepTime = 0;
					createBubble = false;
				end;
			end;
			case IDLE_STATE: //creando burbuja
				//imagen burbuja pequeña
				graph = 20;
				//posicion inicial
				this.fX = startX;
				this.fY = startY;
				//movimiento oscilante
				this.fY+=0.5*rand(-1,1);
				//cambio de paso por tiempo
				if (currentStepTime >= cBubbleIdleTime)
					this.state = MOVE_STATE;
					currentStepTime = 0;
				else
					//contador paso
					if (clockTick)
						currentStepTime++;
					end;
				end;
			end;
			case MOVE_STATE: //movimiento hasta colision
				//imagen burbuja grande
				graph = 19;
				//dañamos al player
				unSetBit(this.props,MONS_HARMLESS);
				//no desaparecemos al salir de la region automaticamente
				setBit(this.props,PERSISTENT);
				
				//actualizamos movimiento
				this.vX = cBubbleVel*dir;
				this.fY = startY;
				
				//si toca pared, explota
				if (getTileCode(id,RIGHT_UP_POINT) <> NO_SOLID && dir == 1)
					this.state = DEAD_STATE;
				end;
				if (getTileCode(id,LEFT_UP_POINT) <> NO_SOLID && dir == -1)
					this.state = DEAD_STATE;
				end;
				
				//Si toca objeto, explota
				repeat
					//obtenemos siguiente colision
					colID = get_id(TYPE object);
					if (colCheckProcess(id,colID,INFOONLY) <> NOCOL)
						this.state = DEAD_STATE;
					end;
				until (colID == 0);
				
				//si se sale de la region, explota antes de que lo elimine monster padre
				if (region_out(id,cGameRegion))
					this.state = DEAD_STATE;
				end;			
				
			end;
			case HURT_STATE:
				this.state = DEAD_STATE;
			end;
			case DEAD_STATE:
				this.vX = 0;
				if (wgeAnimate(21,21,20,ANIM_ONCE))
					//volvemos a ser no persistentes
					unSetBit(this.props,PERSISTENT);
					//volvemos a estado inicial
					this.state = INVISIBLE_STATE;
				end;
				//reproducimos sonido
				wgePlayEntityStateSnd(id,monsterSound[BUBBLE_SND]);
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

//Proceso enemigo ballsClown
//Lanza bolas aleatorias desde el techo alrededor del jugador
process ballsClown(int graph,int x,int y,int _ancho,int _alto,int _axisAlign,int _flags,int _props)
private
byte grounded;		//flag de en suelo
float friction;		//friccion local

int colID;			//Id de colision
int colDir;			//direccion de la colision
byte collided;		//flag de colision

byte atack;			//Flag de atacar al enemigo
int atackRangeX;	//Rango en el que ataca
int atacks;			//numero de bolas ataque

int currentStepTime;//tiempo paso actual

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
	
	wgeCreateObjectColPoints(id);
	
	friction = floorFriction;
	
	this.state = IDLE_STATE;
	
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
				graph = 26;
				//cambio de paso por tiempo
				if (currentStepTime >= cBallsClownIdleTime)
					this.state = ATACK_STATE;
					currentStepTime = 0;
				else
					//contador paso
					if (clockTick)
						currentStepTime++;
					end;
				end;
			end;
			case ATACK_STATE: 
				graph = 25;
							
				//si existe el player
				if (exists(idPlayer) )
					atackRangeX	= idPlayer.x;
				end;	
				
				//lanzamos una bola en el rango de ataque
				if (!atack)
					atack = true;
					monsterFire(rand(31,32),atackRangeX+(cBallsClownAtackRange*rand(-1,1)),0,0,0,0);
					atacks++;
				end;
				//contamos un tiempo aleatorio hasta siguiente bola
				if (currentStepTime >= cBallsClownIdleTime + rand(-20,20))
					atack = false;
					currentStepTime = 0;
				else
					//contador paso
					if (clockTick)
						currentStepTime++;
					end;
				end;
				
				//cambio de estado con bolas maximas
				if (atacks >= cBallsClownNumBallsMax)
					this.state = IDLE_STATE;
					atacks = 0;
					currentStepTime = 0;
				end;
			end;
			case HURT_STATE:   
				this.state = DEAD_STATE;
			end;
			case DEAD_STATE:
				graph = 27;
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

//Proceso enemigo monkeyToy
//Dispara un rayo de vez en cuando
process monkeyToy(int graph,int x,int y,int _ancho,int _alto,int _axisAlign,int _flags,int _props)
private
byte grounded;		//flag de en suelo
float friction;		//friccion local

int collided;		//flag de colision

int atacking;		//flag de atacando
int currentStepTime;
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
	
	wgeCreateObjectColPoints(id);
	
	friction = floorFriction;
	
	this.state = IDLE_STATE;
	
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
				graph = 28;
				//cambio de paso por tiempo
				if (currentStepTime >= cMonkeyToyIdleTime)
					this.state = ATACK_STATE;
					currentStepTime = 0;
				else
					//contador paso
					if (clockTick)
						currentStepTime++;
					end;
				end;
			end;
			case ATACK_STATE: 
				graph = 29;
				
				if (!atacking)
					//lanzamos ataque
					isBitSet(flags,B_HMIRROR) ? monsterFire(30,x,y,2,0,NO_PHYSICS) : monsterFire(30,x,y,-2,0,NO_PHYSICS);		
					atacking = true;
				end;
				
				//podemos volver a atacar cuando muere el disparo
				if (!exists(son))
					atacking = false;
					this.state = IDLE_STATE;
				end;
			end;
			case HURT_STATE:   
				this.state = DEAD_STATE;
			end;
			case DEAD_STATE:
				graph = 33;
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

//Proceso enemigo fatGenius
//Se mueve arriba y abajo y permite rebotar en él. Nunca muere
process fatGenius(int graph,int x,int y,int _ancho,int _alto,int _axisAlign,int _flags,int _props)
private
float friction;		//friccion local
byte grounded;		//flag de en suelo

int colID;			//Id de colision
int colDir;			//direccion de la colision
byte collided;		//flag de colision

int dir;			//direccion movimiento

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
	
	setBit(this.props,NO_PHYSICS);
	dir = 1;
	
	wgeCreateObjectColPoints(id);
	
	friction = floorFriction;
	
	this.state = MOVE_STATE;
	
	//actualizamos el padre con los datos de creación
	updateMonster(id,father);
	
	loop
		//nos actualizamos del padre
		updateMonster(father,id);
		
		//guardamos estado actual
		this.prevState = this.state;
		
		//maquina de estados
		switch (this.state)
			case MOVE_STATE:
				//grafico inicial
				graph = 34;
				//limite superior para cambio sentido
				if ( getTileCode(id,UP_R_POINT) <> NO_SOLID ||
				     getTileCode(id,UP_L_POINT) <> NO_SOLID ||
					 y <= scroll[cGameScroll].y0)
					dir = 1;
				end;
				//limite inferior para cambio sentido
				if ( getTileCode(id,DOWN_R_POINT) <> NO_SOLID ||
				     getTileCode(id,DOWN_L_POINT) <> NO_SOLID ||
					 y >= scroll[cGameScroll].y0+cGameRegionH)
					dir = -1;
				end;		
				//movimiento
				this.vY = cFatGeniusVel * dir;
			end;
			case HURT_STATE: 
				//detenemos el movimiento
				this.vY = 0;
				//tiempo detenido con grafico de toque
				if (wgeAnimate(35,35,40,ANIM_ONCE))
					this.state = MOVE_STATE;
				end;
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

//Proceso enemigo toyCar
//Se mueve izquierda a derecha hasta tocar pared y no muerte hasta matar el mando a distancia
process toyCar(int graph,int x,int y,int _ancho,int _alto,int _axisAlign,int _flags,int _props)
private
float friction;		//friccion local
byte grounded;		//flag de en suelo

int colID;			//Id de colision
int colDir;			//direccion de la colision
byte collided;		//flag de colision

int dir;

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
	
	isBitSet(flags,B_HMIRROR) ? dir = 1: dir = -1;
	
	wgeCreateObjectColPoints(id);
	
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
				if (wgeAnimate(38,38,5,ANIM_ONCE))
					collided = false;
					this.state = MOVE_STATE;
					this.vX = cToyCarVel*dir;
				end;
			end;
			case MOVE_STATE: //movimiento de pared a pared
				//dañamos al player
				unSetBit(this.props,MONS_HARMLESS);
				//si toca pared, invierte movimiento
				if (collided)
					dir *= -1;
					this.state = IDLE_STATE;
				end;
				//actualizamos movimiento
				this.vX = cToyCarVel*dir;
				//animacion movimiento
				wgeAnimate(36,37,10,ANIM_LOOP);
				//sentido del grafico
				dir < 0 ? unSetBit(flags,B_HMIRROR) : SetBit(flags,B_HMIRROR);
			end;
			case HURT_STATE: //toque
				//detenemos el movimiento
				this.vX = 0;
				//no dañamos en este estado
				setBit(this.props,MONS_HARMLESS);
				//animacion toque
				if (wgeAnimate(39,39,100,ANIM_LOOP))			
					//pasado el tiempo, volvemos a movernos
					this.state = MOVE_STATE;
					this.vX = cToyCarVel*dir;
				end;
			end;
			case DEAD_STATE:
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
process monsterFire(int graph,int x,int y,float _vX,float _vY,int _props)
begin
	region = cGameRegion;
	ctype = c_scroll;
	z = cZMonster;
	file = level.fpgMonsters;
	
	//igualamos la propiedades publicas a las de parametros
	this.vX = _vX;
	this.vY = _vY;
	this.props = _props;
	
	this.fX = x;
	this.fY = y;
	
	repeat	
			//fisicas
			if (!isBitSet(this.props,NO_PHYSICS))
				this.vY += gravity;
			end;
			
			//limite velocidad Y
			if (this.vY > maxEntityVelY)
				this.vY = maxEntityVelY;
			end;
			
			this.fX += this.vX;
			this.fY += this.vY;
			positionToInt(id);
			
			frame;
	//morimos al salirnos de la pantalla
	until (out_region(id,cGameRegion));
	
end;

//Proceso enemigo bossClown
//salta hacia el jugador y al tocar suelo tira bolas del techo
process bossClown(int graph,int x,int y,int _ancho,int _alto,int _axisAlign,int _flags,int _props)
private
byte grounded;			//flag de en suelo
float friction;			//friccion local
	
int colID;				//Id de colision
int colDir;				//direccion de la colision
byte collided;			//flag de colision
	
int dir;				//Direccion movimiento
int currentStepTime;	//tiempo paso actual
int currentHurtTime;	//tiempo daño actual
	
int bossLife = 3;		//Vida del boss
	
int i;					//Variable auxiliar
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
	
	//direccion inicial del movimiento
	isBitSet(flags,B_HMIRROR) ? dir = -1 : dir = 1;
	
	wgeCreateObjectColPoints(id);
	
	friction = floorFriction;
	
	this.state = IDLE_STATE;
	graph = 0;
	
	//actualizamos al padre con los datos de creacion
	updateMonster(id,father);
	
	loop
		//nos actualizamos del padre
		updateMonster(father,id);
		
		//FISICAS	
		collided = terrainPhysics(ID,friction,&grounded);
		
		//lanzamos comprobacion colision con procesos objeto
		repeat
			//obtenemos siguiente colision
			colID = get_id(TYPE object);
			//aplicamos la direccion de la colision
			applyDirCollision(ID,colCheckProcess(id,colID,HORIZONTALAXIS),&grounded);		
		until (colID == 0);
		
		//guardamos estado actual
		this.prevState = this.state;
		
		//maquina de estados
		switch (this.state)
			case IDLE_STATE: //animacion de tapa caja abierta
				setBit(this.props,NO_COLLISION);
				
				//tiempo espera
				if (currentHurtTime < cBossClownWaitTime && game.boss)
					currentHurtTime++;	
					graph = 0;
				else
					//animacion puerta que se abre
					if (wgeAnimate(46,48,10,ANIM_ONCE))
						//sale de la caja
						graph = 43;
						this.vY = -cBossClownVelY;
						this.vX = cBossClownVelX;
						grounded = false;
						//es colisionable
						unSetBit(this.props,NO_COLLISION);
						//cambio de paso
						this.state = JUMP_STATE;
						//reiniciamos tiempo
						currentHurtTime = 0;
					end;
				end;				
				
			end;
			case JUMP_STATE: //movimiento salto
				if (!grounded)
					//movimiento
					this.vX = cBossClownVelX*dir;
					//grafico salto
					this.vY < 0 ? graph = 41: graph = 42;
				else
					this.state = ATACK_STATE;	
					//reproducimos sonido
					wgePlayEntitySnd(id,monsterSound[EXPLODE_SND]);					
				end;
			end;
			case ATACK_STATE:							
				//pasamos a reposo cuando toca suelo
				this.vX = 0;
									
				//contamos un tiempo aleatorio hasta siguiente bola
				if (currentStepTime >= cBossClownBallTime + rand(-20,20))
					monsterFire(rand(31,32),x+(cBossClownAtackRange*rand(-1,1)),scroll[cGameScroll].y0,0,0,0);
					currentStepTime = 0;
				else
					//contador paso
					if (clockTick)
						currentStepTime++;
					end;
				end;
				
				//cambio de paso cuando acabe animacion
				if (wgeAnimate(42,43,20,ANIM_ONCE))
					this.state = MOVE_STATE;
				end;
				
				//efecto temblor al tocar suelo
				game.shakeScroll = graph == 42;
				
			end;
			case MOVE_STATE:
				//detenemos el movimiento
				this.vX = 0;
				//espera hasta el siguiente salto
				if (wgeAnimate(40,40,80,ANIM_ONCE))
					//corregimos direccion
					if (exists(idPlayer) )
						if (idPlayer.this.fX > this.fX)
							dir = 1; 
						else
							dir = -1; 
						end;
					end;
					//saltamos
					this.vX = cBossClownVelX*dir;
					this.vY = -cBossClownVelY;
					grounded = false;
					this.state = JUMP_STATE;
				end;
			end;
			case HURT_STATE:  
				//no es colisionable en este estado
				setBit(this.props,NO_COLLISION);
				//reseteamos tiempo de paso
				currentStepTime = 0;
				//detenemos movimiento
				this.vX = 0;
				//si no lo queda energia al boss, lo matamos
				if (bossLife-1 == 0)
					this.state = DEAD_STATE;
				else
					//animacion de daño
					if (currentHurtTime >= cBossClownHurtCycles)
						//le quitamos vida
						bossLife --;
						//cambio de estado
						this.state = MOVE_STATE;
						//vuelve a ser colisionable
						unSetBit(this.props,NO_COLLISION);
						//reiniciamos tiempo daño
						currentHurtTime = 0;
						//quitamos el blend
						unSetBit(flags,B_ABLEND);
					else
						//animacion daño
						if (wgeAnimate(44,45,20,ANIM_LOOP))
							currentHurtTime++;
						end;
						//parpadeo
						blinkEntity(id);
					end;
				end;
			end;
			case DEAD_STATE:
				deadBoss(44,45);
				signal(TYPE monsterFire,s_kill);
				signal(id,s_kill);
			end;
		end;
		
		//ajuste flags segun direccion
		this.vX<=0 ? setBit(flags,B_HMIRROR) : unSetBit(flags,B_HMIRROR);
		
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
	
	//puntuacion por enemigo muerto
	game.score += cKillMonster;
	
	repeat	
			//fisicas
			this.vY += gravity;
			
			this.fX += this.vX;
			this.fY += this.vY;
			positionToInt(id);
			
			wgeAnimate(graph,graph,20,ANIM_LOOP);
			
			frame;
	//morimos al salirnos de la pantalla
	until (out_region(id,cGameRegion));
	
	//creamos gema de fin de nivel
	
end;

//proceso de muerte de monstruo jefe
process deadBoss(int iniGraph,int endGraph)
private
int currentStepTime;		//Tiempo paso actual
	
begin
	region = cGameRegion;
	ctype = c_scroll;
	z = cZMonster;
	file = level.fpgMonsters;
	
	this.fX = father.x;
	this.fY = father.y;
	graph = iniGraph;
	flags = father.flags;
	
	this.vX = 0;
	this.vY = -4;
	
	//puntuacion por jefe muerto??
	game.score += cKillMonster;
	
	repeat	
			//fisicas
			this.vY += gravity;
			
			this.fX += this.vX;
			this.fY += this.vY;
			positionToInt(id);
			
			wgeAnimate(iniGraph,endGraph,5,ANIM_LOOP);
			
			frame;
	//morimos al salirnos de la pantalla
	until (out_region(id,cGameRegion));
	
	//Retardo para activar el flag
	repeat
		if (clockTick)
			currentStepTime++;
		end;
		frame;
	until(currentStepTime >= 50)
	
	//activamos el flag
	game.bossKilled = true;
	
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