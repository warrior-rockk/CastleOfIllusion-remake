// ========================================================================
//  Warcom Game Engine
//  Motor para juegos plataformas 2D
//  22/08/14
//
//  Procesos monsters (enemigos)
// ========================================================================


//Proceso enemigo cycleClown
//Se mueve izquierda a derecha en un rango y dispara cuando el player está cerca
process cycleClown(int graph,int x,int y,int _ancho,int _alto,int _props)
begin
end;
/*
private
byte grounded;
int i;
int colID;
float friction;
int colDir;
byte collided;

begin
	region = cGameRegion;
	ctype = c_scroll;
	z = cZObject;
	file = level.fpgObjects;
	
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
				collided = false;
				
				//Recorremos la lista de puntos a comprobar
				for (i=0;i<cNumColPoints;i++)					
					//aplicamos la direccion de la colision
					applyDirCollision(ID,colCheckTileTerrain(ID,i),&grounded);			
				end;
				
				//lanzamos comprobacion con procesos caja
				repeat
					//obtenemos siguiente colision
					colID = get_id(TYPE objeto);
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
			case THROWING_STATE:	
				//mientras se mueve, no es solido
				props |= NO_COLLISION;
				
				grounded = false;
				collided = false;
				
				//Recorremos la lista de puntos a comprobar
				for (i=0;i<cNumColPoints;i++)					
					//obtenemos la direccion de la colision
					colDir = colCheckTileTerrain(ID,i);
					//aplicamos la direccion de la colision
					applyDirCollision(ID,colDir,&grounded);
					//seteamos flag de colisionado
					if (colDir <> NOCOL)
						collided = true;
					end;
				end;
				
				//lanzamos comprobacion con procesos caja
				repeat
					//obtenemos siguiente colision
					colID = get_id(TYPE objeto);
					//si no soy yo mismo
					if (colID <> ID) 
						//obtenemos la direccion de la colision
						colDir = colCheckProcess(id,colID,BOTHAXIS);
						//aplicamos la direccion de la colision
						applyDirCollision(ID,colDir,&grounded);
						//seteamos flag de colisionado
						if (colDir <> NOCOL)
							collided = true;
						end;
					end;
				until (colID == 0);
				
				//cambio de estado
				
				//si es rompible y ha colisionado, lo destruimos
				if (collided && isBitSet(props,BREAKABLE))
					//actualizamos la posicion para ver la explosion en el sitio
					vY = 0;
					fx += vX;
					fy += vY;
					positionToInt(id);
					
					//cambiamos de estado
					state = DEAD_STATE;
				end;
				
				if (grounded && abs(vX) < 0.1) 
					state = IDLE_STATE;
				end;
				
			end;
			case DEAD_STATE:
				WGE_Animation(file,2,3,x,y,10,ANIM_ONCE);
				signal(id,s_kill);
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