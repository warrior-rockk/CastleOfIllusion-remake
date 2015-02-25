// ========================================================================
//  Warcom Game Engine
//  Motor para juegos plataformas 2D
//  21/07/14
//
//  Funciones de colision
// ========================================================================

//Funcion que crea puntos de colision del jugador
function int WGE_CreatePlayerColPoints(entity idObject)
begin
	
	idObject.colPoint[RIGHT_UP_POINT].x 			= (idObject.ancho>>1)-1;
	idObject.colPoint[RIGHT_UP_POINT].y 			= -(idObject.alto/4);
	idObject.colPoint[RIGHT_UP_POINT].colCode 	= COLDER;
	idObject.colPoint[RIGHT_UP_POINT].enabled 	= 1;
	
	idObject.colPoint[RIGHT_DOWN_POINT].x 		= (idObject.ancho>>1)-1;
	idObject.colPoint[RIGHT_DOWN_POINT].y 		= (idObject.alto/4);
	idObject.colPoint[RIGHT_DOWN_POINT].colCode = COLDER;
	idObject.colPoint[RIGHT_DOWN_POINT].enabled = 1;
	
	idObject.colPoint[LEFT_UP_POINT].x 		= -(idObject.ancho>>1);
	idObject.colPoint[LEFT_UP_POINT].y 		= -(idObject.alto/4);
	idObject.colPoint[LEFT_UP_POINT].colCode = COLIZQ;
	idObject.colPoint[LEFT_UP_POINT].enabled = 1;
	
	idObject.colPoint[LEFT_DOWN_POINT].x 		= -(idObject.ancho>>1);
	idObject.colPoint[LEFT_DOWN_POINT].y 		= (idObject.alto/4);
	idObject.colPoint[LEFT_DOWN_POINT].colCode = COLIZQ;
	idObject.colPoint[LEFT_DOWN_POINT].enabled = 1;
	
	idObject.colPoint[DOWN_R_POINT].x 		= (idObject.ancho/4);
	idObject.colPoint[DOWN_R_POINT].y 		= (idObject.alto>>1)-1;
	idObject.colPoint[DOWN_R_POINT].colCode = COLDOWN;
	idObject.colPoint[DOWN_R_POINT].enabled = 1;
	
	idObject.colPoint[DOWN_L_POINT].x 		= -(idObject.ancho/4);
	idObject.colPoint[DOWN_L_POINT].y 		= (idObject.alto>>1)-1;
	idObject.colPoint[DOWN_L_POINT].colCode = COLDOWN;
	idObject.colPoint[DOWN_L_POINT].enabled = 1;
	
	idObject.colPoint[UP_R_POINT].x 		= (idObject.ancho/4);
	idObject.colPoint[UP_R_POINT].y 		= -(idObject.alto>>1);
	idObject.colPoint[UP_R_POINT].colCode = COLUP;
	idObject.colPoint[UP_R_POINT].enabled = 1;
	
	idObject.colPoint[UP_L_POINT].x 		= -(idObject.ancho/4);
	idObject.colPoint[UP_L_POINT].y 		= -(idObject.alto>>1);
	idObject.colPoint[UP_L_POINT].colCode = COLUP;
	idObject.colPoint[UP_L_POINT].enabled = 1;
	
	idObject.colPoint[CENTER_POINT].x 		= 0;
	idObject.colPoint[CENTER_POINT].y 		= 0;
	idObject.colPoint[CENTER_POINT].colCode = COLCENTER;
	idObject.colPoint[CENTER_POINT].enabled = 0;
	
	idObject.colPoint[CENTER_DOWN_POINT].x 		= 0;
	idObject.colPoint[CENTER_DOWN_POINT].y 		= (idObject.alto>>1);
	idObject.colPoint[CENTER_DOWN_POINT].colCode = COLCENTER;
	idObject.colPoint[CENTER_DOWN_POINT].enabled = 0;
	
	return 1;
	
end;

//Funcion que crea puntos de colision de un objeto
function int WGE_CreateObjectColPoints(entity idObject)

begin
		
	idObject.colPoint[RIGHT_UP_POINT].x 			= (idObject.ancho>>1)-1;
	idObject.colPoint[RIGHT_UP_POINT].y 			= -(idObject.alto/4);
	idObject.colPoint[RIGHT_UP_POINT].colCode 	= COLDER;
	idObject.colPoint[RIGHT_UP_POINT].enabled 	= 1;
	
	idObject.colPoint[RIGHT_DOWN_POINT].x 		= (idObject.ancho>>1)-1;
	idObject.colPoint[RIGHT_DOWN_POINT].y 		= (idObject.alto/4);
	idObject.colPoint[RIGHT_DOWN_POINT].colCode = COLDER;
	idObject.colPoint[RIGHT_DOWN_POINT].enabled = 1;
	
	idObject.colPoint[LEFT_UP_POINT].x 		= -(idObject.ancho>>1);
	idObject.colPoint[LEFT_UP_POINT].y 		= -(idObject.alto/4);
	idObject.colPoint[LEFT_UP_POINT].colCode = COLIZQ;
	idObject.colPoint[LEFT_UP_POINT].enabled = 1;
	
	idObject.colPoint[LEFT_DOWN_POINT].x 		= -(idObject.ancho>>1);
	idObject.colPoint[LEFT_DOWN_POINT].y 		= (idObject.alto/4);
	idObject.colPoint[LEFT_DOWN_POINT].colCode = COLIZQ;
	idObject.colPoint[LEFT_DOWN_POINT].enabled = 1;
	
	idObject.colPoint[DOWN_R_POINT].x 		= (idObject.ancho/4);
	idObject.colPoint[DOWN_R_POINT].y 		= (idObject.alto>>1)-1;
	idObject.colPoint[DOWN_R_POINT].colCode = COLDOWN;
	idObject.colPoint[DOWN_R_POINT].enabled = 1;
	
	idObject.colPoint[DOWN_L_POINT].x 		= -(idObject.ancho/4);
	idObject.colPoint[DOWN_L_POINT].y 		= (idObject.alto>>1)-1;
	idObject.colPoint[DOWN_L_POINT].colCode = COLDOWN;
	idObject.colPoint[DOWN_L_POINT].enabled = 1;
	
	idObject.colPoint[UP_R_POINT].x 		= (idObject.ancho/4);
	idObject.colPoint[UP_R_POINT].y 		= -(idObject.alto>>1);
	idObject.colPoint[UP_R_POINT].colCode = COLUP;
	idObject.colPoint[UP_R_POINT].enabled = 1;
	
	idObject.colPoint[UP_L_POINT].x 		= -(idObject.ancho/4);
	idObject.colPoint[UP_L_POINT].y 		= -(idObject.alto>>1);
	idObject.colPoint[UP_L_POINT].colCode = COLUP;
	idObject.colPoint[UP_L_POINT].enabled = 1;
	
	idObject.colPoint[CENTER_POINT].x 		= 0;
	idObject.colPoint[CENTER_POINT].y 		= 0;
	idObject.colPoint[CENTER_POINT].colCode = COLCENTER;
	idObject.colPoint[CENTER_POINT].enabled = 0;
	
	idObject.colPoint[CENTER_DOWN_POINT].x 		= 0;
	idObject.colPoint[CENTER_DOWN_POINT].y 		= (idObject.alto>>1)-1; //diferencia con player?
	idObject.colPoint[CENTER_DOWN_POINT].colCode = COLCENTER;
	idObject.colPoint[CENTER_DOWN_POINT].enabled = 0;
	
	return 1;
	
end;

//Funcion de colision con tile segun mapa de durezas segun su punto de colision
//Posiciona el objeto en el borde del tile y devuelve un int con el sentido de la colision o 0 si no lo hay
function int colCheckTileTerrain(entity idObject,int i)
private 

_vector colVector;	//Vector de comprobacion colision
int distColX;		//Distancia con la colision en X
int distColY;		//Distancia con la colision en Y
int colDir;			//Sentido de la colision

begin
		colDir = 0;
				
		//comprobamos si el punto de control esta activo
		if (!idObject.colPoint[i].enabled) return colDir; end;
		
		//===============
		//COLISIONES EN X
		//===============
		
		//desactivamos puntos de control inferiores si estamos en rampa
		if (cSlopesEnabled)
			idObject.colPoint[LEFT_DOWN_POINT].enabled  = getTileCode(idObject,CENTER_DOWN_POINT) <> SLOPE_135;
			idObject.colPoint[RIGHT_DOWN_POINT].enabled = getTileCode(idObject,CENTER_DOWN_POINT) <> SLOPE_45;
		end;
		
		//si el punto de deteccion es lateral (X)
		if (idObject.colPoint[i].colCode == COLDER || idObject.colPoint[i].colCode == COLIZQ )
			
			//Establecemos el vector a chequear
			colVector.vStart.x = idObject.fx+idObject.colPoint[i].x;
			colVector.vEnd.x   = colVector.vStart.x+idObject.vX;
			colVector.vStart.y = idObject.fy+idObject.colPoint[i].y;
			colVector.vEnd.y   = colVector.vStart.y;
				
			//lanzamos la comprobacion de colision en X
			distColX = colCheckVectorX(0,mapBox,&colVector,idObject.colPoint[i].colCode);
			
			//Si hay colision
			If (distColX>=0)
				//Colision Derecha
				if (idObject.colPoint[i].colCode == COLDER) 
					//situamos el objeto al borde de la colision	
					idObject.fx+= distColX-1;
					colDir = COLDER;
					
				end;
				//Colision Izquierda
				if (idObject.colPoint[i].colCode == COLIZQ) 			
					//situamos el objeto al borde de la colision
					idObject.fx-= distColX-1;
					colDir = COLIZQ;
				end;
			end;  
		end;
		
		//===============
		//COLISIONES EN Y
		//===============
		
		//Si el punto de deteccion es uno de los superiores/inferiores
		if (idObject.colPoint[i].colCode == COLUP || idObject.colPoint[i].colCode == COLDOWN)
			
			//Establecemos el vector a comparar
			colVector.vStart.x = idObject.fx+idObject.colPoint[i].x;
			colVector.vEnd.x   = colVector.vStart.x;
			colVector.vStart.y = idObject.fy+idObject.colPoint[i].y;
			colVector.vEnd.y   = colVector.vStart.y+idObject.vY;
			
			//Lanzamos la comprobacion de colision en Y
			distColY = colCheckVectorY(0,mapBox,&colVector,idObject.colPoint[i].colCode,TOCOLLISION);
			
			//Si hay colision
			If (distColY>=0) 
				//Colision inferior
				if (idObject.colPoint[i].colCode == COLDOWN && idObject.vY>=0)
					//Situamos al objeto en el borde de la colision
					idObject.fy += distColY;
					colDir = COLDOWN;
					
					//Deteccion de pendiente,comprobamos si estamos enterrados
					if (cSlopesEnabled)
												
						//Establecemos el vector a comparar (centro/inferior del objeto)
						colVector.vStart.x = idObject.fx+idObject.colPoint[CENTER_DOWN_POINT].x;
						colVector.vEnd.x   = colVector.vStart.x;
						colVector.vStart.y = idObject.fy+idObject.colPoint[CENTER_DOWN_POINT].y;
						colVector.vEnd.y   = colVector.vStart.y-cHillHeight; //altura maxima para considerar pendiente
						
						//Lanzamos la comprobacion de colision en Y
						distColY = colCheckVectorY(0,mapBox,&colVector,COLCENTER,FROMCOLLISION);
						
						//Subimos al objeto a la pendiente
						if (distColY >0)
							idObject.fy -= distColY-1;
						end;
					end;
				End;                                 
				
				//Colision superior
				if (idObject.colPoint[i].colCode == COLUP && idObject.vY<0)
					//Situamos al objeto en el borde de la colision
					idObject.fy -= distColY;
					colDir = COLUP;
				End;
			
			else 
				//si no hay colision, comprobamos si pendiente hacia abajo
				if (cSlopesEnabled)
					//lo comprobamos si no estamos en escalera para despegarnos del suelo
					if (idObject.vY > 0)
						//Establecemos el vector a comparar (centro/inferior del objeto)
						colVector.vStart.x = idObject.fx+idObject.colPoint[CENTER_DOWN_POINT].x;
						colVector.vEnd.x   = colVector.vStart.x;
						colVector.vStart.y = idObject.fy+idObject.colPoint[CENTER_DOWN_POINT].y-1;
						colVector.vEnd.y   = colVector.vStart.y+idObject.vY+cHillHeight; //altura maxima para considerar pendiente
						
						//Lanzamos la comprobacion de colision en Y
						distColY = colCheckVectorY(0,mapBox,&colVector,COLCENTER,TOCOLLISION);
						
						//Bajamos al objeto a la pendiente
						if (distColY >0)
							idObject.fy += distColY;
						end;	
					end;
				end;
			end; 
			
		end;
		
		//Devolvemos el sentido de la colision
		return colDir;
end; 


//Funcion que devuelve,dado un vector, el numero de pixeles en x hasta la colision, o -1 si no hay
function int colCheckVectorX(Int fich,Int graf,_vector *colVector, int colCode)
Private 
int dist=0;		//distancia de colision
int inc;		//Incremento

Begin
		
	//seteamos el sentido del incremento
	(colVector.vEnd.x>=colVector.vStart.x) ? inc = 1 : inc = -1;
	
    //Recorremos el vector buscando colision con pixel 
	Repeat
			
		//si el tile en esta posicion existe
		if (tileExists(colVector.vStart.y/cTileSize,colVector.vStart.x/cTileSize))
			//si el tile es solido
			if (tileMap[colVector.vStart.y/cTileSize][colVector.vStart.x/cTileSize].tileCode <> NO_SOLID)
				//comprobar el codigo del tile para contarlo como colision o no
				if (checkTileCode(idPlayer,colCode,colVector.vStart.y/cTileSize,colVector.vStart.x/cTileSize))
					if(map_get_pixel(fich,mapBox,(colVector.vStart.x%cTileSize),(colVector.vStart.y%cTileSize)) <> 0)
						return dist;
					end;
				end;
			end;
		end;
				
		//Incrementamos distancia
		dist++;
		//Incrementamos vector
		colVector.vStart.x+=inc;
	
	//hasta recorrer todo el vector	
	Until(colVector.vStart.x==(colVector.vEnd.x+inc))
	
	//No ha habido colision
	Return -1; 
	
End

////Funcion que devuelve,dado un vector, el numero de pixeles en y hasta la colision, o -1 si no hay
//El byte "mode", determina si la comprobacion es el numero de pixeles hasta llegar a la colision (TOCOLLISION 1)
//o numero de pixeles para salir de la colision (FROMCOLLISION 0)
Function int colCheckVectorY(int fich,int graf,_vector *colVector,int colCode,byte mode)
Private 
int dist=0;				//distancia de colision
int inc;				//Incremento
byte colPixel=0;		//pixel de la colision

Begin
	
	//seteamos el sentido del incremento
	(colVector.vEnd.y>=colVector.vStart.y ) ? inc=1 : inc=-1;
	
	//linea que delimita cuantos px estara el personaje sobre el suelo (con 1, estara justo 1 pix por encima de la linea de suelo)
	colVector.vStart.y += 1;

	//Recorremos el vector buscando colision con pixel
	Repeat
			
			//si el tile de esa posicion existe		
			if (tileExists(colVector.vStart.y/cTileSize,colVector.vStart.x/cTileSize))
				//si el tile no es solido
				if (tileMap[colVector.vStart.y/cTileSize][colVector.vStart.x/cTileSize].tileCode == NO_SOLID)
					colPixel = 0;
				else
					//comprobar el codigo del tile para contarlo como colision o no
					if (checkTileCode(idPlayer,colCode,colVector.vStart.y/cTileSize,colVector.vStart.x/cTileSize))
						//Obtenemos el pixel de colision segun el tipo de tile
						switch (tileMap[colVector.vStart.y/cTileSize][colVector.vStart.x/cTileSize].tileCode)
							case SLOPE_135:
								colPixel = map_get_pixel(0,mapTriangle135,(colVector.vStart.x%cTileSize),(colVector.vStart.y%cTileSize));
							end;
							case SLOPE_45:
								colPixel = map_get_pixel(0,mapTriangle45,(colVector.vStart.x%cTileSize),(colVector.vStart.y%cTileSize));
							end;
							case TOP_STAIRS,SOLID_ON_FALL:
								colPixel = map_get_pixel(0,mapSolidOnFall,(colVector.vStart.x%cTileSize),(colVector.vStart.y%cTileSize));
							end;
							default:
								colPixel = map_get_pixel(0,mapBox,(colVector.vStart.x%cTileSize),(colVector.vStart.y%cTileSize));
							end;
						end;
					end;
				end;	
			end;
			
			//comprobamos modo
			If (mode == TOCOLLISION)	
				//si ha detectado terreno, devolvemos distancia
				if (colPixel <> 0 )
					return dist;
				end;
			Else
				//si ha salido del terreno, devolvemos distancia
				if (colPixel == 0 )
					return dist;
				end;
			End;
			
			//incrementamos distancia
			dist++;
			//incrementamos vector
			colVector.vStart.y+=inc;
			
	//hasta recorrer todo el vector
	Until( (colVector.vStart.y>colVector.vEnd.y && inc==1) || (colVector.vStart.y<colVector.vEnd.y && inc==-1) )
	
	//No ha habido colision
	return -1;
	
End;

//Funcion de chequeo de colision entre procesos elegiendo el eje
//Posiciona el objeto al borde del tile y devuelve un int con el sentido de la colision o 0 si no hay
function int colCheckProcess(entity idObject,idObjectB, int axis)
private
float vcX,vcY,hW,hH,oX,oY;
int ColDir;

begin
    //comprobamos los id de los procesos
	if (idObject == 0 || idObjectB == 0) return 0; end;
	
	//comprobamos si el objeto es solido
	if (isBitSet(idObjectB.props,NO_COLLISION)) return 0; end;
	
	//Obtiene los vectores de los centros para comparar
	//teniendo en cuenta la velocidad del objeto principal
	//y el eje seleccionado en parametro axis
	if (axis==BOTHAXIS || axis==HORIZONTALAXIS || axis==INFOONLY )
		vcX = (idObject.fx+idObject.vX) - (idObjectB.fx );
	else
		vcX = (idObject.fx) - (idObjectB.fx );
	end;
	if (axis==BOTHAXIS || axis==VERTICALAXIS || axis==INFOONLY )
		vcY = (idObject.fy+idObject.vY) - (idObjectB.fy );
	else
		vcY = (idObject.fy) - (idObjectB.fy );
	end;
	
	// suma las mitades de los anchos y los altos
	hW =  (idObject.ancho>>1) + (idObjectB.ancho>>1);
	hH = (idObject.alto>>1) + (idObjectB.alto>>1);
	
	colDir = 0;

    //si los vectores e x y son menores que las mitades de anchos y altos, ESTAN colisionando
	if (abs(vcX) < hW && abs(vcY) < hH) 
        
		//calculamos el sentido de la colision (top, bottom, left, or right)
        oX = hW - abs(vcX);
        oY = hH - abs(vcY);
        
		if (oX >= oY) 
            if (axis==BOTHAXIS || axis==VERTICALAXIS || axis==INFOONLY )
				if (vcY > 0) 			//Arriba
					colDir = COLUP;
					if (axis != INFOONLY)
						idObject.fy += oY+idObject.vY;
					end;
				else 
					colDir = COLDOWN;	//Abajo
					if (axis != INFOONLY)
					idObject.fy -= oY-idObject.vY;
					end;
				end;
			end;
        else
			if (axis==BOTHAXIS || axis==HORIZONTALAXIS || axis==INFOONLY)
				if (vcX > 0) 
					colDir = COLIZQ;	//Izquierda
					if (axis != INFOONLY)
					idObject.fx += oX+idObject.vX;
					end;
				else 
					colDir = COLDER;	//Derecha
					if (axis != INFOONLY)
						idObject.fx -= oX-idObject.vX;
					end;
				end;
			end;
	     end;
	end;
        
    //Devolvemos el sentido de la colision o 0 si no hay
    return colDir;

end;

//Funcion de chequeo de colision entre proceso y AABB
//Posiciona el objeto al borde del tile y devuelve un int con el sentido de la colision o 0 si no hay
function int colCheckAABB(entity idObject, int shapeBx,int shapeBy,int shapeBW,int shapeBH)
private
float vcX,vcY,hW,hH,oX,oY;
int ColDir;

begin
    //Obtiene los vectores de los centros para comparar
	vcX = (idObject.fx) - (shapeBx );
	vcY = (idObject.fy) - (shapeBy );
	// suma las mitades de los anchos y los altos
	hW =  (idObject.ancho / 2) + (shapeBW / 2);
	hH = (idObject.alto / 2) + (shapeBH / 2);
	
	colDir = 0;

    //si los vectores e x y son menores que las mitades de anchos y altos, ESTAN colisionando
	if (abs(vcX) < hW && abs(vcY) < hH) 
        
		//calculamos el sentido de la colision (top, bottom, left, or right)
        oX = hW - abs(vcX);
        oY = hH - abs(vcY);
        
		if (oX >= oY) 
            if (vcY > 0) 			//Arriba
				colDir = COLUP;
                idObject.fy += oY;
             else 
                colDir = COLDOWN;	//Abajo
                idObject.fy -= oY;
             end;
        else 
            if (vcX > 0) 
                colDir = COLIZQ;	//Izquierda
                idObject.fx += oX;
             else 
                colDir = COLDER;	//Derecha
                idObject.fx -= oX;
             end;
	     end;
	end;
        
    //Devolvemos el sentido de la colision o 0 si no hay
    return colDir;

end;

//Funcion de chequeo de colision entre proceso y tile (dando sus coordenadas en mapa)
//Posiciona el objeto al borde del tile y devuelve un int con el sentido de la colision o 0 si no hay
function int colCheckTile(entity idObject,int posX,int posY)
private
float vcX,vcY,hW,hH,oX,oY;
int ColDir;

begin
    //Si el tile no es sólido, o no existe en el mapa, no hay colision
	if (!tileExists(posy,posx))
		return 0;
	elseif((tileMap[posY][posX].tileCode) == NO_SOLID )
		return 0;
	end;
	
	//Obtiene los vectores de los centros para comparar
	vcX = (idObject.fx) - ((posX*cTileSize)+cHalfTSize);
	vcY = (idObject.fy) - ((posY*cTileSize)+cHalfTSize);
	// suma las mitades de los anchos y los altos
	hW =  (idObject.ancho / 2) + chalfTSize;
	hH =  (idObject.alto / 2) + chalfTSize;
	
	colDir = 0;

    //si los vectores e x y son menores que las mitades de anchos y altos, ESTAN colisionando
	if (abs(vcX) < hW && abs(vcY) < hH) 
        
		//calculamos el sentido de la colision (top, bottom, left, or right)
        oX = hW - abs(vcX);
        oY = hH - abs(vcY);
        
		if (oX >= oY) 
            if (vcY > 0) 			//Arriba
				if (checkTileCode(idObject,COLUP,posY,posX))
					colDir = COLUP;
					idObject.fy += oY;
				end;
             else 
                if (checkTileCode(idObject,COLDOWN,posY,posX))
					colDir = COLDOWN;	//Abajo
					idObject.fy -= oY;
				end;
             end;
        else 
            if (vcX > 0) 
                if (checkTileCode(idObject,COLIZQ,posY,posX))
					colDir = COLIZQ;	//Izquierda
					idObject.fx += oX;
				end;
             else 
				if (checkTileCode(idObject,COLDER,posY,posX))
					colDir = COLDER;	//Derecha
					idObject.fx -= oX;
				end;
             end;
	     end;
	end;
    
	//Devolvemos el sentido de la colision o 0 si no hay
    return colDir;

end;

//funcion que aplica la direccion de la colision en el objeto
function applyDirCollision(entity idObject,int colDir,byte *objGrounded)
begin
	//acciones segun colision
	if (colDir == COLIZQ || colDir == COLDER) 
		idObject.vX = 0;
	elseif (colDir == COLDOWN) 
		//si es un objeto o un item, rebota al tocar suelo
		if (isType(idObject,TYPE object) || isType(idObject,TYPE item))
			//comprobacion si no es rompible
			if (!isBitSet(idObject.props,BREAKABLE))
				//rebote en suelo
				if (isType(idObject,TYPE object))
					idObject.vY *= -cBouncyObjectVel;
					//cantidad de rebote
					if ( abs(idObject.vY) < cBouncyObjectVel )
						*objGrounded = true;		
					end;
				else
					idObject.vY *= -cBouncyItemVel;
					//cantidad de rebote
					if ( abs(idObject.vY) < cBouncyItemVel )
						*objGrounded = true;		
					end;
				end;
			else
				*objGrounded = true;
			end;
		else
			*objGrounded = true;
		end;
	elseif (colDir == COLUP) 
		idObject.vY = 0;			//Flota por el techo	
		//idObject.vY *= -1;		//Rebota hacia abajo con la velocida que subia
		//idObject.vY = 2;		//Rebota hacia abajo con valor fijo
	end;
end;

//funcion que engloba la gestion de las fisicas de un proceso
//devuelve si hubo alguna colision con el terreno
function byte terrainPhysics(entity idObject,float friction,byte *objGrounded)
private
	int i;					//Var auxiliar
	int collided = false; 	//flag de colision
	int colDir;				//Direccion colision
	int grounded;			//flag de en suelo
begin
	//leemos el flag de en suelo del objeto
	grounded = *objGrounded;
	
	if (!isBitSet(idObject.props,NO_PHYSICS))
		if (grounded)
			idObject.vX *= friction;
		end;
		
		idObject.vY += gravity;
		
		grounded = false;
		collided = false;
		
		//COLISION TERRENO
		//Recorremos la lista de puntos a comprobar
		for (i=0;i<cNumColPoints;i++)					
			//obtenemos la direccion de la colision
			colDir = colCheckTileTerrain(idObject,i);
			//aplicamos la direccion de la colision
			applyDirCollision(idObject,colDir,&grounded);
			//seteamos flag de colisionado
			if (colDir <> NOCOL)
				collided = true;
			end;
		end;
	end;
	
	//aplicamos el flag de en suelo al objeto
	*objGrounded = grounded;
	
	return collided;	//devolvemos flag colision
	
end;