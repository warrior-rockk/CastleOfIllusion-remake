// ========================================================================
//  Warcom Game Engine
//  Motor para juegos plataformas 2D
//  22/08/14
//
//  Procesos monsters (enemigos)
// ========================================================================

//Proceso monstruo generico
//Sera el padre del monstruo concreto para tratarlo como unico para colisiones,etc..
Process monster(int monsterType,int x,int y)
private
	monster idMonster;	//id del mosntruo que se crea
begin
	//creamos el tipo de monstruo
	switch (monsterType)
		case T_CYCLECLOWN:
			idMonster = cycleClown(1,x,y,32,48,HURTPLAYER);
		end;
		case T_TOYPLANE:
			idMonster = toyPlane(9,x,y,16,16,HURTPLAYER);
		end;
		case T_TOYPLANECONTROL:
			idMonster = toyPlaneControl(13,x,y,16,16,HURTPLAYER);
		end;
	end;
	
	loop
		//si existe el monstruo (sigue vivo)
		if (exists(idMonster))
			if (state == DEAD_STATE || state == HURT_STATE) 
				//si el monstruo no esta muerto o dañado
				if (idMonster.state <> DEAD_STATE && idMonster.state <> HURT_STATE)
					//actualizo el estado del monstruo
					idMonster.state = state;
				end;
				state = 0;
			end;
		else
			break;
		end;
		frame;
	end;
end;

//Proceso enemigo cycleClown
//Se mueve izquierda a derecha en un rango y dispara cuando el player está cerca
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
	
	state = MOVE_RIGHT_STATE;
	
	loop
		
		//FISICAS	
		vY += gravity;
		
		//maquina de estados
		switch (state)
			case IDLE_STATE:
				;
			end;
			case MOVE_RIGHT_STATE: //movimiento a derecha
				//movimiento lineal
				vX = xVel;
				
				//cambio de estado al superar rango
				if (fx - _x0 > xRange)
					state = MOVE_LEFT_STATE;
				end;
				
				//animacion movimiento
				WGE_Animate(1,6,5,ANIM_LOOP);
			end;
			case MOVE_LEFT_STATE: //movimiento a izquierda
				//movimiento lineal
				vX = -xVel;
				
				//cambio de estado al superar rango
				if (_x0 - fx > xRange)
					state = MOVE_RIGHT_STATE;
				end;
				
				//animacion movimiento
				WGE_Animate(1,6,5,ANIM_LOOP);
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
		
		//Para todos los estados
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
		
		//fisica terreno
		grounded = false;
				
		//Recorremos la lista de puntos a comprobar
		for (i=0;i<cNumColPoints;i++)					
			//aplicamos la direccion de la colision
			applyDirCollision(ID,colCheckTileTerrain(ID,i),&grounded);			
		end;
				
		//Actualizar velocidades
		if (grounded)
			vY = 0;
		end;
		
		fx += vX;
		fy += vY;
		
		//actualizamos la posicion
		positionToInt(id);
		
		//actualizamos el monstruo padre
		updateMonster(id);
		
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

byte grounded;

int colID;			//Id de colision
int colDir;			//direccion de la colision
byte collided;		//flag de colision
byte wallTouch;		//flag de pared alcanzada
float xVel;			//Velocidad movimiento

int hurtedCounter; 	//contador tiempo dañado
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
		
		//maquina de estados
		switch (state)
			case IDLE_STATE: //mirando al frente para cambiar de direcccion
				//detenemos movimiento
				vX = 0;
				//pausa con animacion mirando al frente
				if (WGE_Animate(11,11,30,ANIM_ONCE))
					wallTouch = false;
					state = MOVE_STATE;
					vX = xVel;
				end;
			end;
			case MOVE_STATE: //movimiento de pared a pared
				//dañamos al player
				setBit(props,HURTPLAYER);
				//si toca pared, invierte movimiento
				if (wallTouch)
					xVel = xVel * -1;
					wallTouch = false;
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
				//no dañamos en este estado
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
		
		//fisica terreno
					
		//Recorremos la lista de puntos a comprobar
		for (i=0;i<cNumColPoints;i++)					
			//aplicamos la direccion de la colision
			applyDirCollision(ID,colCheckTileTerrain(ID,i),&grounded);			
		end;
				
		//Actualizar velocidades
		if (grounded)
			vY = 0;
		end;
		
		//si no hay velocidad, a tocado muro
		if (vX == 0 && state == MOVE_STATE)
			wallTouch = true;
		end;
		
		fx += vX;
		fy += vY;
		
		//actualizamos la posicion
		positionToInt(id);
		
		//actualizamos el monstruo padre
		updateMonster(id);
		
		frame;
	end;
	
end;

//Proceso enemigo toyPlaneControl
//Cuando muere, mata a los toyPlane
process toyPlaneControl(int graph,int x,int y,int _ancho,int _alto,int _props)
private
int colID;			//Id de colision
int colDir;			//direccion de la colision
byte collided;		//flag de colision
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
		
		//maquina de estados
		switch (state)
			case IDLE_STATE: 
				WGE_Animate(15,16,30,ANIM_LOOP);
			end;
			case HURT_STATE: //toque
				state = DEAD_STATE;
				//matamos todo toyPlane que esté activo
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
		
		fx += vX;
		fy += vY;
		
		//actualizamos la posicion
		positionToInt(id);
		
		//actualizamos el monstruo padre
		updateMonster(id);
		
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

//funcion que actualiza las propiedades del monstruo padre
function updateMonster(entity monsterSon)
private
	monster idFather;	//id del monstruo padre
begin
	//asociamos al padre
	idFather = 	monsterSon.father;
	
	//copiamos las propiedades
	idFather.ancho = monsterSon.ancho;
	idFather.alto = monsterSon.alto;
	idFather.fX = monsterSon.fX;
	idFather.fY = monsterSon.fY;
	idFather.props = monsterSon.props;
	
end;