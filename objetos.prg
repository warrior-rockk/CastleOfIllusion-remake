// ========================================================================
//  Warcom Game Engine
//  Motor para juegos plataformas 2D
//  22/08/14
//
//  Procesos Objetos
// ========================================================================


//Proceso caja con gravedad
process caja(int x,int y,float vX,float vY);
private
byte grounded;
int i;
int colID;
float friction;

begin
	ancho = 32;
	alto = 32;
	
	graph = map_new(ancho,alto,8,0);
	map_clear(0,graph,rand(200,300));
	
	region = cGameRegion;
	ctype = c_scroll;
	z = cZObject;
	
	fx = x;
	fy = y;
	
	WGE_CreateObjectColPoints(id);
	
	friction = floorFriction;
	
	state = MOVE_STATE;
	
	loop
		
		//FISICAS	
		if (grounded)
			vX *= friction;
		end;
		
		vY += gravity;
		
		//comportamiento caja
		switch (state)
			case IDLE_STATE:
				;
			end;
			case MOVE_STATE:
								
				grounded = false;
				
				//Recorremos la lista de puntos a comprobar
				for (i=0;i<cNumColPoints;i++)					
					//aplicamos la direccion de la colision
					applyDirCollision(ID,colCheckTileTerrain(ID,i),&grounded);			
				end;
				
				//lanzamos comprobacion con procesos caja
				repeat
					//obtenemos siguiente colision
					colID = get_id(TYPE caja);
					//si no soy yo mismo
					if (colID <> ID) 
						//aplicamos la direccion de la colision
						applyDirCollision(ID,colCheckProcess(id,colID,BOTHAXIS),&grounded);
					end;
				until (colID == 0);
				
				//cambio de estado
				if (grounded && abs(vX) < 0.1) 
					state = IDLE_STATE; 
				end;
				
			end;
		end;
		
		//Actualizar velocidades
		if (grounded)
			vY = 0;
		end;
		
		fx += vX;
		fy += vY;
		
		positionToInt(id);
			
		frame;
	end;
	
end;

//Proceso plataforma movil
//x inicial
//y inicial
//rango de movimiento
process plataforma(int x,int y,int ancho,int alto,int graph,int rango)
private
	int startX;
	int startY;
	
begin
	region = cGameRegion;
	ctype = c_scroll;
	z = cZObject;
	file = level.fpgObjects;
	
	//modo debug sin graficos
	if (file<0)
		graph = map_new(ancho,alto,8,0);
		map_clear(0,graph,310);
	end;
	
	//puntos de colision del objeto
	id.colPoint[LEFT_UP_POINT].x 		= -(ancho>>1);
	id.colPoint[LEFT_UP_POINT].y 		= 0;
	id.colPoint[LEFT_UP_POINT].colCode = COLIZQ;
	id.colPoint[LEFT_UP_POINT].enabled = 1;
	
	id.colPoint[RIGHT_UP_POINT].x 		= (ancho>>1);
	id.colPoint[RIGHT_UP_POINT].y 		= 0;
	id.colPoint[RIGHT_UP_POINT].colCode = COLDER;
	id.colPoint[RIGHT_UP_POINT].enabled = 1;
	
	fx = x;
	fy = y;
	
	state = IDLE_STATE;
	
	startX = x;
	startY = y;
	
	vX = 0.5;
	vY = 1;
	
	//bucle principal
	loop
		switch (state)
			case IDLE_STATE:
				//estado por defecto
				state = MOVE_RIGHT_STATE; 
			end;
			case MOVE_RIGHT_STATE: //movimiento a derecha
				//movimiento lineal
				fx+=vX; 
				//si el player esta en plataforma
				if (idPlatform == ID)
					//movemos el player
					idPlayer.fx +=vX;
				end;
				//cambio de estado al colisionar
				if (getTileCode(id,RIGHT_UP_POINT) <> NO_SOLID)
					state = MOVE_LEFT_STATE;
				end;
			end;
			case MOVE_LEFT_STATE: //movimiento a izquierda
				//movimiento lineal
				fx-=vX; 
				//movimiento lineal
				if (idPlatform == ID)
					//movemos el player
					idPlayer.fx -=vX;
				end;
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
					idPlayer.fX +=vX;
					idPlayer.fY -=vY;
				end;
			end;
		end;
		
		positionToInt(id);
		
		frame;
	end;
	
end;

//Proceso objeto
process objeto(int graph,int x,int y,int ancho,int alto);
private
byte grounded;
int i;
int colID;
float friction;

begin
	region = cGameRegion;
	ctype = c_scroll;
	z = cZObject;
	file = level.fpgObjects;
	
	props |= PICKABLE;
	
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
		if (grounded)
			vX *= friction;
		end;
		
		vY += gravity;
		
		//comportamiento caja
		switch (state)
			case IDLE_STATE:
				//normalizamos la posicion Y para evitar problemas de colision 
				fY = y;
				props &= ~ NO_COLLISION;
			end;
			case MOVE_STATE:
								
				//mientras se mueve, no es solido
				props |= NO_COLLISION;
				
				grounded = false;
				
				//Recorremos la lista de puntos a comprobar
				for (i=0;i<cNumColPoints;i++)					
					//aplicamos la direccion de la colision
					applyDirCollision(ID,colCheckTileTerrain(ID,i),&grounded);			
				end;
				
				//lanzamos comprobacion con procesos caja
				repeat
					//obtenemos siguiente colision
					colID = get_id(TYPE caja);
					//si no soy yo mismo
					if (colID <> ID) 
						//aplicamos la direccion de la colision
						applyDirCollision(ID,colCheckProcess(id,colID,BOTHAXIS),&grounded);
					end;
				until (colID == 0);
				
				//cambio de estado
				if (grounded && abs(vX) < 0.1) 
					state = IDLE_STATE;
				end;
				
			end;
		end;
		
		//Actualizar velocidades
		if (grounded)
			vY = 0;
		end;
		
		fx += vX;
		fy += vY;
		
		positionToInt(id);
			
		frame;
	end;
	
end;

//Objeto que ha cogido el personaje y lleva encima (objeto pasivo)
process pickedObject(int file,int graph,int ancho,int alto);
private

begin
	region = cGameRegion;
	ctype = c_scroll;
	z = cZObject;
	
	//modo debug sin graficos
	if (file<0)
		graph = map_new(ancho,alto,8,0);
		map_clear(0,graph,rand(200,300));
	end;
	
	//estado inicial
	state = MOVE_STATE;
	x = father.x+(father.ancho>>1);
	y = father.y;
				
	loop
		//estados
		switch (state)
			//animacion de recogiendolo
			case MOVE_STATE:
				if (WGE_Animate(graph,graph,20,ANIM_ONCE))
					state = IDLE_STATE;
				end;
			end;
			//actualizamos posicion segun la del player
			case IDLE_STATE:
				if (isBitSet(father.flags,B_HMIRROR))
					x = father.x-cObjectPickedPosX;
				else
					x = father.x+cObjectPickedPosX;
				end;
				y = father.y+cObjectPickedPosY;
			end;
		end;
		
		frame;
	end;
end;