// ========================================================================
//  Warcom Game Engine
//  Motor para juegos plataformas 2D
//  22/08/14
//
//  Procesos monsters (enemigos)
// ========================================================================

//Proceso monstruo generico
//Sera el padre del monstruo concreto para tratarlo como unico para colisiones,etc..
Process monster(int monsterType,int _x0,int _y0)
private
	monster idMonster;		//id del mosntruo que se crea
	
	byte    inRegion;		//flag de monstruo en region
	byte    outRegion;		//flag de monstruo fuera de region
begin
	//el objeto padre tiene que tener prioridad superior a los hijos
	priority = cMonsterPrior;
	
	state = INITIAL_STATE;
	
	loop
		//si se reinicia, se actualiza flags region
		if (state == INITIAL_STATE)
			inRegion  = region_in(_x0,_y0);
			outRegion = true;
		end;
		
		//si existe el monstruo
		if (exists(idMonster))
			
			//actualizamos el hijo
			updateMonster(id,idMonster);
			
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
			setBit(props,NO_COLLISION);
			
			//la region se comprueba con las coordenadas iniciales
			x = _x0;
			y = _y0;
			
			//creamos el monstruo si entra en la region
			if (inRegion && outRegion) 
				//creamos el tipo de monstruo
				switch (monsterType)
					case T_CYCLECLOWN:
						idMonster = cycleClown(1,_x0,_y0,26,40,HURTPLAYER);
					end;
					case T_TOYPLANE:
						idMonster = toyPlane(9,_x0,_y0,16,16,HURTPLAYER);
					end;
					case T_TOYPLANECONTROL:
						idMonster = toyPlaneControl(15,_x0,_y0,16,16,HURTPLAYER);
					end;
				end;	
				log("Se crea el monstruo "+idMonster,DEBUG_MONSTERS);
				
				outRegion = false;
			end;
		end;
		
		//Comprobamos si entra en la region
		if (region_in(x,y))
			inRegion = true;
		end;
		
		//Comprobamos si sale de la region
		if (!region_in(x,y))
			outRegion = true;
		end;
			
		frame;
	end;
end;

//Proceso enemigo cycleClown
//Se mueve izquierda a derecha en un rango y dispara cuando el player est� cerca
process cycleClown(int graph,int x,int y,int _ancho,int _alto,int _props)
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
	
	//igualamos la propiedades publicas a las de parametros
	ancho = _ancho;
	alto = _alto;
	axisAlign = DOWN_AXIS;
	props = _props;
	
	//modo debug sin graficos
	if (file<0)
		graph = map_new(ancho,alto,8,0);
		map_clear(0,graph,rand(200,300));
	end;
	
	fx = x;
	fy = y;
	
	_x0 = x;
	xRange = 10;
	xVel   = 0.2;
	atackRangeX = 50;
	
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
				;
			end;
			case MOVE_STATE: //movimiento en rango
				//cambio de direccion al superar rango
				if (abs(fx - _x0) > xRange)
					xVel *= -1;
				end;
				
				//movimiento lineal
				vX = xVel;
				
				//animacion movimiento
				WGE_Animate(1,6,5,ANIM_LOOP);	
				
				//si existe el player
				if (idPlayer <> 0 )
					//miramos a su direccion
					if (idPlayer.fX > fX)
						flags &=~ B_HMIRROR; 
					else
						flags |= B_HMIRROR; 
					end;
					//player en rango ataque
					if (abs(idPlayer.fX - fX) < atackRangeX && !atack)
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
				state = DEAD_STATE;
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
	vX = _vX;
	vY = _vY;
	
	fX = x;
	fY = y;
	
	repeat	
			//fisicas
			vY += gravity;
			
			fx += vX;
			fy += vY;
			positionToInt(id);
			
			frame;
	//morimos al salirnos de la pantalla
	until (out_region(id,cGameRegion));
	
end;

//Proceso enemigo toyPlane
//Se mueve izquierda a derecha hasta tocar pared y no muerte hasta matar el mando a distancia
process toyPlane(int graph,int x,int y,int _ancho,int _alto,int _props)
private
float friction;		//friccion local
byte grounded;		//flag de en suelo

int colID;			//Id de colision
int colDir;			//direccion de la colision
byte collided;		//flag de colision

float xVel;			//Velocidad movimiento
int hurtedCounter; 	//contador tiempo da�ado

int i;				//Variable auxiliar
begin
	region = cGameRegion;
	ctype = c_scroll;
	z = cZMonster;
	file = level.fpgMonsters;
	
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
	
	xVel   = -2;
	
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
			case IDLE_STATE: //mirando al frente para cambiar de direcccion
				//detenemos movimiento
				vX = 0;
				//pausa con animacion mirando al frente
				if (WGE_Animate(11,11,5,ANIM_ONCE))
					collided = false;
					state = MOVE_STATE;
					vX = xVel;
				end;
			end;
			case MOVE_STATE: //movimiento de pared a pared
				//da�amos al player
				setBit(props,HURTPLAYER);
				//si toca pared, invierte movimiento
				if (collided)
					xVel = xVel * -1;
					collided = false;
					state = IDLE_STATE;
				end;
				//actualizamos movimiento
				vX = xVel;
				//animacion movimiento
				WGE_Animate(9,10,5,ANIM_LOOP);
				//sentido del grafico
				xVel < 0 ? setBit(flags,B_HMIRROR) : unsetBit(flags,B_HMIRROR);
			end;
			case HURT_STATE: //toque
				//detenemos el movimiento
				vX = 0;
				//no da�amos en este estado
				unsetBit(props,HURTPLAYER);
				//animacion toque durante 8 animaciones
				if (hurtedCounter < 8)
					if (WGE_Animate(12,14,5,ANIM_LOOP))
						hurtedCounter++;
					end;
				else
					//pasado el tiempo, volvemos a movernos
					hurtedCounter = 0;
					state = MOVE_STATE;
					vX = xVel;
				end;
			end;
			case DEAD_STATE:
				deadMonster();
				signal(id,s_kill);
			end;
		end;
		
		//no tiene gravedad
		vY = 0;
		
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
process toyPlaneControl(int graph,int x,int y,int _ancho,int _alto,int _props)
private
byte grounded;		//flag de en suelo
monster idToyPlane;	//id de toyPlane activo

int i;				//Variable auxiliar
begin
	region = cGameRegion;
	ctype = c_scroll;
	z = cZMonster;
	file = level.fpgMonsters;
	
	//igualamos la propiedades publicas a las de parametros
	ancho = _ancho;
	alto = _alto;
	axisAlign = DOWN_AXIS;
	props = _props;
	
	//modo debug sin graficos
	if (file<0)
		graph = map_new(ancho,alto,8,0);
		map_clear(0,graph,rand(200,300));
	end;
	
	fx = x;
	fy = y;
	
	WGE_CreateObjectColPoints(id);
	
	state = IDLE_STATE;
	
	loop
		//FISICAS	
		terrainPhysics(ID,1,&grounded);
		
		//guardamos estado actual
		prevState = state;
		
		//maquina de estados
		switch (state)
			case IDLE_STATE: 
				WGE_Animate(15,16,30,ANIM_LOOP);
			end;
			case HURT_STATE: //toque
				state = DEAD_STATE;
				//matamos todo toyPlane que est� activo
				repeat
					idToyPlane = get_id(TYPE toyPlane);
					if (idToyPlane <> 0 )
						idToyPlane.state = DEAD_STATE;
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
	
	fX = father.x;
	fY = father.y;
	graph = father.graph;
	flags = father.flags;
	
	vX = 0;
	vY = -4;
	
	repeat	
			//fisicas
			vY += gravity;
			
			fx += vX;
			fy += vY;
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
	monsterB.ancho 		= monsterA.ancho;
	monsterB.alto 		= monsterA.alto;
	monsterB.axisAlign	= monsterA.axisAlign;
	monsterB.fX 		= monsterA.fX;
	monsterB.fY 		= monsterA.fY;
	monsterB.x  		= monsterA.x;
	monsterB.y  		= monsterA.y;
	monsterB.vX 		= monsterA.vX;
	monsterB.vY 		= monsterA.vY;
	monsterB.props 		= monsterA.props;
	monsterB.state      = monsterA.state;
	
end;