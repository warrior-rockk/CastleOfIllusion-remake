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
	monster idMonster;		//id del mosntruo que se crea
	int 	_x0;			//X inicial
	int 	_y0;           	//Y inicial
	byte    inRegion;		//flag de monstruo en region
begin
	//guardamos la posicion inicial
	_x0 = x;
	_y0 = y;
	inRegion = false;
	
	loop
		//si se reinicia, se baja el flag de en region
		if (state == INITIAL_STATE)
			inRegion = false;
		end;
		
		//si existe el monstruo (sigue vivo)
		if (exists(idMonster))
			//si nos mandan reiniciar
			if (state == INITIAL_STATE)
				//eliminamos el monstruo existente
				signal(idMonster,s_kill);
				log("Se reinicia el monstruo "+idMonster,DEBUG_MONSTERS);
			else
				//envio de estado muerte o da�o
				if (state == DEAD_STATE || state == HURT_STATE) 
					//si el monstruo no esta muerto o da�ado
					if (idMonster.state <> DEAD_STATE && idMonster.state <> HURT_STATE)
						//actualizo el estado del monstruo
						idMonster.state = state;
					end;
					state = 0;
				end;
				//desaparece al salir de la region del juego
				if (!region_in(x,y)) 
					log("Se elimina el monstruo "+idMonster,DEBUG_MONSTERS);
					signal(idMonster,s_kill);			
				end;
			end;
		else
			//si no hay monstruo creado, es como si estuviera muerto
			state = DEAD_STATE;
			setBit(props,NO_COLLISION);
			
			//lo creamos si entra en la region
			if (region_in(_x0,_y0) && !inRegion) 
				//flag de region
				inRegion = true;
				//reinciamos estado padre
				state = 0;
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
			end;
			
			//bajamos el flag cuando salgas de la region
			if (!region_in(_x0,_y0))
				inRegion = false;
			end;
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
		updateMonster(id);
		
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
		updateMonster(id);
		
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
		updateMonster(id);
		
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

//funcion que actualiza las propiedades del monstruo padre
function updateMonster(entity monsterSon)
private
	monster idFather;	//id del monstruo padre
begin
	//aseguramos que el padre es un monstruo
	if (isType(monsterSon.father,TYPE monster))
		//asociamos al padre
		idFather = 	monsterSon.father;
		
		//copiamos las propiedades
		idFather.ancho = monsterSon.ancho;
		idFather.alto = monsterSon.alto;
		idFather.axisAlign = monsterSon.axisAlign;
		idFather.fX = monsterSon.fX;
		idFather.fY = monsterSon.fY;
		idFather.x  = monsterSon.x;
		idFather.y  = monsterSon.y;
		idFather.props = monsterSon.props;
	end;
end;