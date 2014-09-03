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
	map_clear(0,graph,300);
	
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
						applyDirCollision(ID,colCheckProcess(id,colID),&grounded);
					end;
				until (colID == 0);
				
				//cambio de estado
				if (grounded && vX == 0) 
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
		
		//Escalamos la posicion de floats en enteros
		//si la diferencia entre el float y el entero es una unidad
		if (abs(fx-x) >= 1 ) 
			x = fx;
		end;
		y = fy;
		
		frame;
	end;
	
end;

//Proceso plataforma movil
process plataforma(int x,int y,int rango)
#define MOVE_RIGHT_STATE 1
#define MOVE_LEFT_STATE  2
private
	int startX;
	int startY;
begin
	ancho = 64;
	alto = 16;
	
	region = cGameRegion;
	ctype = c_scroll;
	z = cZObject;
	
	graph = map_new(ancho,alto,8,0);
	map_clear(0,graph,310);
	
	fx = x;
	fy = y;
	
	state = IDLE_STATE;
	
	startX = x;
	startY = y;
	
	//bucle principal
	loop
		switch (state)
			case IDLE_STATE:
				state = rand(1,2); //inicio aleatorio
			end;
			case MOVE_RIGHT_STATE: //movimiento a derecha
				fx+=2; //movimiento lineal
				if (fx > startX + rango)
					state = MOVE_LEFT_STATE;
				end;
			end;
			case MOVE_LEFT_STATE: //movimiento a izquierda
				fx-=2; //movimiento lineal
				if (fx < startX - rango)
					state = MOVE_RIGHT_STATE;
				end;
			end;
		end;
		
		//Escalamos la posicion de floats en enteros
		//si la diferencia entre el float y el entero es una unidad
		if (abs(fx-x) >= 1 ) 
			x = fx;
		end;
		y = fy;
		
		frame;
	end;
	
end;
