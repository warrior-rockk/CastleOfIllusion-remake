// ========================================================================
//  Warcom Game Engine
//  Motor para juegos plataformas 2D
//  21/07/14
//
//  Funciones de colision
// ========================================================================

//Funcion que crea puntos de colision del jugador
function int WGE_CreatePlayerColPoints(entity idEntity)
begin
	
	idEntity.this.colPoint[RIGHT_UP_POINT].x 			= (idEntity.this.ancho>>1)-1;
	idEntity.this.colPoint[RIGHT_UP_POINT].y 			= -(idEntity.this.alto/4);
	idEntity.this.colPoint[RIGHT_UP_POINT].colCode 	= COLDER;
	idEntity.this.colPoint[RIGHT_UP_POINT].enabled 	= 1;
	
	idEntity.this.colPoint[RIGHT_DOWN_POINT].x 		= (idEntity.this.ancho>>1)-1;
	idEntity.this.colPoint[RIGHT_DOWN_POINT].y 		= (idEntity.this.alto/4);
	idEntity.this.colPoint[RIGHT_DOWN_POINT].colCode = COLDER;
	idEntity.this.colPoint[RIGHT_DOWN_POINT].enabled = 1;
	
	idEntity.this.colPoint[LEFT_UP_POINT].x 		= -(idEntity.this.ancho>>1);
	idEntity.this.colPoint[LEFT_UP_POINT].y 		= -(idEntity.this.alto/4);
	idEntity.this.colPoint[LEFT_UP_POINT].colCode = COLIZQ;
	idEntity.this.colPoint[LEFT_UP_POINT].enabled = 1;
	
	idEntity.this.colPoint[LEFT_DOWN_POINT].x 		= -(idEntity.this.ancho>>1);
	idEntity.this.colPoint[LEFT_DOWN_POINT].y 		= (idEntity.this.alto/4);
	idEntity.this.colPoint[LEFT_DOWN_POINT].colCode = COLIZQ;
	idEntity.this.colPoint[LEFT_DOWN_POINT].enabled = 1;
	
	idEntity.this.colPoint[DOWN_R_POINT].x 		= (idEntity.this.ancho/4);
	idEntity.this.colPoint[DOWN_R_POINT].y 		= (idEntity.this.alto>>1);
	idEntity.this.colPoint[DOWN_R_POINT].colCode = COLDOWN;
	idEntity.this.colPoint[DOWN_R_POINT].enabled = 1;
	
	idEntity.this.colPoint[DOWN_L_POINT].x 		= -(idEntity.this.ancho/4);
	idEntity.this.colPoint[DOWN_L_POINT].y 		= (idEntity.this.alto>>1);
	idEntity.this.colPoint[DOWN_L_POINT].colCode = COLDOWN;
	idEntity.this.colPoint[DOWN_L_POINT].enabled = 1;
	
	idEntity.this.colPoint[UP_R_POINT].x 		= (idEntity.this.ancho/4);
	idEntity.this.colPoint[UP_R_POINT].y 		= -(idEntity.this.alto>>1);
	idEntity.this.colPoint[UP_R_POINT].colCode = COLUP;
	idEntity.this.colPoint[UP_R_POINT].enabled = 1;
	
	idEntity.this.colPoint[UP_L_POINT].x 		= -(idEntity.this.ancho/4);
	idEntity.this.colPoint[UP_L_POINT].y 		= -(idEntity.this.alto>>1);
	idEntity.this.colPoint[UP_L_POINT].colCode = COLUP;
	idEntity.this.colPoint[UP_L_POINT].enabled = 1;
	
	idEntity.this.colPoint[CENTER_POINT].x 		= 0;
	idEntity.this.colPoint[CENTER_POINT].y 		= 0;
	idEntity.this.colPoint[CENTER_POINT].colCode = COLCENTER;
	idEntity.this.colPoint[CENTER_POINT].enabled = 0;
	
	idEntity.this.colPoint[CENTER_DOWN_POINT].x 		= 0;
	idEntity.this.colPoint[CENTER_DOWN_POINT].y 		= (idEntity.this.alto>>1);
	idEntity.this.colPoint[CENTER_DOWN_POINT].colCode = COLCENTER;
	idEntity.this.colPoint[CENTER_DOWN_POINT].enabled = 0;
	
	return 1;
	
end;

//Funcion que crea puntos de colision de un objeto
function int WGE_CreateObjectColPoints(entity idEntity)

begin
		
	idEntity.this.colPoint[RIGHT_UP_POINT].x 			= (idEntity.this.ancho>>1)-1;
	idEntity.this.colPoint[RIGHT_UP_POINT].y 			= -(idEntity.this.alto/4);
	idEntity.this.colPoint[RIGHT_UP_POINT].colCode 	= COLDER;
	idEntity.this.colPoint[RIGHT_UP_POINT].enabled 	= 1;
	
	idEntity.this.colPoint[RIGHT_DOWN_POINT].x 		= (idEntity.this.ancho>>1)-1;
	idEntity.this.colPoint[RIGHT_DOWN_POINT].y 		= (idEntity.this.alto/4);
	idEntity.this.colPoint[RIGHT_DOWN_POINT].colCode = COLDER;
	idEntity.this.colPoint[RIGHT_DOWN_POINT].enabled = 1;
	
	idEntity.this.colPoint[LEFT_UP_POINT].x 		= -(idEntity.this.ancho>>1);
	idEntity.this.colPoint[LEFT_UP_POINT].y 		= -(idEntity.this.alto/4);
	idEntity.this.colPoint[LEFT_UP_POINT].colCode = COLIZQ;
	idEntity.this.colPoint[LEFT_UP_POINT].enabled = 1;
	
	idEntity.this.colPoint[LEFT_DOWN_POINT].x 		= -(idEntity.this.ancho>>1);
	idEntity.this.colPoint[LEFT_DOWN_POINT].y 		= (idEntity.this.alto/4);
	idEntity.this.colPoint[LEFT_DOWN_POINT].colCode = COLIZQ;
	idEntity.this.colPoint[LEFT_DOWN_POINT].enabled = 1;
	
	idEntity.this.colPoint[DOWN_R_POINT].x 		= (idEntity.this.ancho/4);
	idEntity.this.colPoint[DOWN_R_POINT].y 		= (idEntity.this.alto>>1)-1;
	idEntity.this.colPoint[DOWN_R_POINT].colCode = COLDOWN;
	idEntity.this.colPoint[DOWN_R_POINT].enabled = 1;
	
	idEntity.this.colPoint[DOWN_L_POINT].x 		= -(idEntity.this.ancho/4);
	idEntity.this.colPoint[DOWN_L_POINT].y 		= (idEntity.this.alto>>1)-1;
	idEntity.this.colPoint[DOWN_L_POINT].colCode = COLDOWN;
	idEntity.this.colPoint[DOWN_L_POINT].enabled = 1;
	
	idEntity.this.colPoint[UP_R_POINT].x 		= (idEntity.this.ancho/4);
	idEntity.this.colPoint[UP_R_POINT].y 		= -(idEntity.this.alto>>1);
	idEntity.this.colPoint[UP_R_POINT].colCode = COLUP;
	idEntity.this.colPoint[UP_R_POINT].enabled = 1;
	
	idEntity.this.colPoint[UP_L_POINT].x 		= -(idEntity.this.ancho/4);
	idEntity.this.colPoint[UP_L_POINT].y 		= -(idEntity.this.alto>>1);
	idEntity.this.colPoint[UP_L_POINT].colCode = COLUP;
	idEntity.this.colPoint[UP_L_POINT].enabled = 1;
	
	idEntity.this.colPoint[CENTER_POINT].x 		= 0;
	idEntity.this.colPoint[CENTER_POINT].y 		= 0;
	idEntity.this.colPoint[CENTER_POINT].colCode = COLCENTER;
	idEntity.this.colPoint[CENTER_POINT].enabled = 0;
	
	idEntity.this.colPoint[CENTER_DOWN_POINT].x 		= 0;
	idEntity.this.colPoint[CENTER_DOWN_POINT].y 		= (idEntity.this.alto>>1)-1; //diferencia con player?
	idEntity.this.colPoint[CENTER_DOWN_POINT].colCode = COLCENTER;
	idEntity.this.colPoint[CENTER_DOWN_POINT].enabled = 0;
	
	return 1;
	
end;

//Funcion de colision con tile segun mapa de durezas segun su punto de colision
//Posiciona el objeto en el borde del tile y devuelve un int con el sentido de la colision o 0 si no lo hay
function int colCheckTileTerrain(entity idEntity,int i)
private 

_vector colVector;	//Vector de comprobacion colision
int distColX;		//Distancia con la colision en X
int distColY;		//Distancia con la colision en Y
int colDir;			//Sentido de la colision

begin
		colDir = 0;
				
		//comprobamos si el punto de control esta activo
		if (!idEntity.this.colPoint[i].enabled) return colDir; end;
		
		//===============
		//COLISIONES EN X
		//===============
		
		//desactivamos puntos de control inferiores si estamos en rampa
		if (cSlopesEnabled)
			idEntity.this.colPoint[LEFT_DOWN_POINT].enabled  = getTileCode(idEntity,CENTER_DOWN_POINT) <> SLOPE_135;
			idEntity.this.colPoint[RIGHT_DOWN_POINT].enabled = getTileCode(idEntity,CENTER_DOWN_POINT) <> SLOPE_45;
		end;
		
		//si el punto de deteccion es lateral (X)
		if (idEntity.this.colPoint[i].colCode == COLDER || idEntity.this.colPoint[i].colCode == COLIZQ )
			
			//Establecemos el vector a chequear
			colVector.vStart.x = idEntity.this.fX+idEntity.this.colPoint[i].x;
			colVector.vEnd.x   = colVector.vStart.x+idEntity.this.vX;
			colVector.vStart.y = idEntity.this.fY+idEntity.this.colPoint[i].y;
			colVector.vEnd.y   = colVector.vStart.y;
				
			//lanzamos la comprobacion de colision en X
			distColX = colCheckVectorX(idEntity,&colVector,idEntity.this.colPoint[i].colCode);
			
			//Si hay colision
			If (distColX>=0)
				//Colision Derecha
				if (idEntity.this.colPoint[i].colCode == COLDER) 
					//situamos el objeto al borde de la colision	
					idEntity.this.fX+= distColX-1;
					colDir = COLDER;
					
				end;
				//Colision Izquierda
				if (idEntity.this.colPoint[i].colCode == COLIZQ) 			
					//situamos el objeto al borde de la colision
					idEntity.this.fX-= distColX-1;
					colDir = COLIZQ;
				end;
			end;  
		end;
		
		//===============
		//COLISIONES EN Y
		//===============
		
		//Si el punto de deteccion es uno de los superiores/inferiores
		if (idEntity.this.colPoint[i].colCode == COLUP || idEntity.this.colPoint[i].colCode == COLDOWN)
			
			//Establecemos el vector a comparar
			colVector.vStart.x = idEntity.this.fX+idEntity.this.colPoint[i].x;
			colVector.vEnd.x   = colVector.vStart.x;
			colVector.vStart.y = idEntity.this.fY+idEntity.this.colPoint[i].y;
			colVector.vEnd.y   = colVector.vStart.y+idEntity.this.vY;
			
			//Lanzamos la comprobacion de colision en Y
			distColY = colCheckVectorY(idEntity,&colVector,idEntity.this.colPoint[i].colCode,TOCOLLISION);
			
			//Si hay colision
			If (distColY>=0) 
				//Colision inferior
				if (idEntity.this.colPoint[i].colCode == COLDOWN && idEntity.this.vY>=0)
					//Situamos al objeto en el borde de la colision
					idEntity.this.fY += distColY;
					colDir = COLDOWN;
					
					//Deteccion de pendiente,comprobamos si estamos enterrados
					if (cSlopesEnabled)
												
						//Establecemos el vector a comparar (centro/inferior del objeto)
						colVector.vStart.x = idEntity.this.fX+idEntity.this.colPoint[CENTER_DOWN_POINT].x;
						colVector.vEnd.x   = colVector.vStart.x;
						colVector.vStart.y = idEntity.this.fY+idEntity.this.colPoint[CENTER_DOWN_POINT].y;
						colVector.vEnd.y   = colVector.vStart.y-cHillHeight; //altura maxima para considerar pendiente
						
						//Lanzamos la comprobacion de colision en Y
						distColY = colCheckVectorY(idEntity,&colVector,COLCENTER,FROMCOLLISION);
						
						//Subimos al objeto a la pendiente
						if (distColY >0)
							idEntity.this.fY -= distColY-1;
						end;
					end;
				End;                                 
				
				//Colision superior
				if (idEntity.this.colPoint[i].colCode == COLUP && idEntity.this.vY<0)
					//Situamos al objeto en el borde de la colision
					idEntity.this.fY -= distColY;
					colDir = COLUP;
				End;
			
			else 
				//si no hay colision, comprobamos si pendiente hacia abajo
				if (cSlopesEnabled)
					//lo comprobamos si no estamos en escalera para despegarnos del suelo
					if (idEntity.this.vY > 0)
						//Establecemos el vector a comparar (centro/inferior del objeto)
						colVector.vStart.x = idEntity.this.fX+idEntity.this.colPoint[CENTER_DOWN_POINT].x;
						colVector.vEnd.x   = colVector.vStart.x;
						colVector.vStart.y = idEntity.this.fY+idEntity.this.colPoint[CENTER_DOWN_POINT].y-1;
						colVector.vEnd.y   = colVector.vStart.y+idEntity.this.vY+cHillHeight; //altura maxima para considerar pendiente
						
						//Lanzamos la comprobacion de colision en Y
						distColY = colCheckVectorY(idEntity,&colVector,COLCENTER,TOCOLLISION);
						
						//Bajamos al objeto a la pendiente
						if (distColY >0)
							idEntity.this.fY += distColY;
						end;	
					end;
				end;
			end; 
			
		end;
		
		//Devolvemos el sentido de la colision
		return colDir;
end; 


//Funcion que devuelve,dado un vector, el numero de pixeles en x hasta la colision, o -1 si no hay
//dado una entidad, un vector de comprobacion y el punto de colision a chequear
function int colCheckVectorX(entity idEntity,_vector *colVector, int colCode)
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
				if (checkTileCode(idEntity,colCode,colVector.vStart.y/cTileSize,colVector.vStart.x/cTileSize))
					if(map_get_pixel(0,mapBox,(colVector.vStart.x%cTileSize),(colVector.vStart.y%cTileSize)) <> 0)
						return dist;
					end;
				end;
			end;
		else
			//si no existe, se considera solido
			return dist;
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

////Funcion que devuelve,dado una entidad,un vector y un punto de colision a comprobar, 
//el numero de pixeles en y hasta la colision, o -1 si no hay
//El byte "mode", determina si la comprobacion es el numero de pixeles hasta llegar a la colision (TOCOLLISION 1)
//o numero de pixeles para salir de la colision (FROMCOLLISION 0)
Function int colCheckVectorY(entity idEntity,_vector *colVector,int colCode,byte mode)
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
					if (checkTileCode(idEntity,colCode,colVector.vStart.y/cTileSize,colVector.vStart.x/cTileSize))
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
function int colCheckProcess(entity idEntity,idEntityB, int axis)
private
float vcX,vcY,hW,hH,oX,oY;
int ColDir;

begin
    //comprobamos los id de los procesos
	if (idEntity == 0 || idEntityB == 0) return 0; end;
	
	//comprobamos si el objeto es solido
	if (isBitSet(idEntityB.this.props,NO_COLLISION)) return 0; end;
	
	//Obtiene los vectores de los centros para comparar
	//teniendo en cuenta la velocidad del objeto principal
	//y el eje seleccionado en parametro axis
	if (axis==BOTHAXIS || axis==HORIZONTALAXIS || axis==INFOONLY )
		vcX = (idEntity.this.fX+idEntity.this.vX) - (idEntityB.this.fX );
	else
		vcX = (idEntity.this.fX) - (idEntityB.this.fX );
	end;
	if (axis==BOTHAXIS || axis==VERTICALAXIS || axis==INFOONLY )
		vcY = (idEntity.this.fY+idEntity.this.vY) - (idEntityB.this.fY );
	else
		vcY = (idEntity.this.fY) - (idEntityB.this.fY );
	end;
	
	// suma las mitades de los this.anchos y los this.altos
	hW =  (idEntity.this.ancho>>1) + (idEntityB.this.ancho>>1);
	hH = (idEntity.this.alto>>1) + (idEntityB.this.alto>>1);
	
	colDir = 0;

    //si los vectores e x y son menores que las mitades de this.anchos y this.altos, ESTAN colisionando
	if (abs(vcX) < hW && abs(vcY) < hH) 
        
		//calculamos el sentido de la colision (top, bottom, left, or right)
        oX = hW - abs(vcX);
        oY = hH - abs(vcY);
        
		if (oX >= oY) 
            if (axis==BOTHAXIS || axis==VERTICALAXIS || axis==INFOONLY )
				if (vcY > 0) 			//Arriba
					colDir = COLUP;
					if (axis != INFOONLY)
						idEntity.this.fY += oY+idEntity.this.vY;
					end;
				else 
					colDir = COLDOWN;	//Abajo
					if (axis != INFOONLY)
					idEntity.this.fY -= oY-idEntity.this.vY;
					end;
				end;
			end;
        else
			if (axis==BOTHAXIS || axis==HORIZONTALAXIS || axis==INFOONLY)
				if (vcX > 0) 
					colDir = COLIZQ;	//Izquierda
					if (axis != INFOONLY)
					idEntity.this.fX += oX+idEntity.this.vX;
					end;
				else 
					colDir = COLDER;	//Derecha
					if (axis != INFOONLY)
						idEntity.this.fX -= oX-idEntity.this.vX;
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
function int colCheckAABB(entity idEntity,int shapeBx,int shapeBy,int shapeBW,int shapeBH,int axis)
private
float vcX,vcY,hW,hH,oX,oY;
int ColDir;

begin
    //comprobamos los id de los procesos
	if (idEntity == 0) return 0; end;
	
	//comprobamos si el objeto es solido
	if (isBitSet(idEntity.this.props,NO_COLLISION)) return 0; end;
	
	//Obtiene los vectores de los centros para comparar
	//teniendo en cuenta la velocidad del objeto principal
	//y el eje seleccionado en parametro axis
	if (axis==BOTHAXIS || axis==HORIZONTALAXIS || axis==INFOONLY )
		vcX = (idEntity.this.fX+idEntity.this.vX) - (shapeBx);
	else
		vcX = (idEntity.this.fX) - (shapeBx);
	end;
	if (axis==BOTHAXIS || axis==VERTICALAXIS || axis==INFOONLY )
		vcY = (idEntity.this.fY+idEntity.this.vY) - (shapeBy);
	else
		vcY = (idEntity.this.fY) - (shapeBy);
	end;
	
	// suma las mitades de los this.anchos y los this.altos
	hW =  (idEntity.this.ancho>>1) + (shapeBW>>1);
	hH = (idEntity.this.alto>>1) + (shapeBH>>1);
	
	colDir = 0;

    //si los vectores e x y son menores que las mitades de this.anchos y this.altos, ESTAN colisionando
	if (abs(vcX) < hW && abs(vcY) < hH) 
        
		//calculamos el sentido de la colision (top, bottom, left, or right)
        oX = hW - abs(vcX);
        oY = hH - abs(vcY);
        
		if (oX >= oY) 
            if (axis==BOTHAXIS || axis==VERTICALAXIS || axis==INFOONLY )
				if (vcY > 0) 			//Arriba
					colDir = COLUP;
					if (axis != INFOONLY)
						idEntity.this.fY += oY+idEntity.this.vY;
					end;
				else 
					colDir = COLDOWN;	//Abajo
					if (axis != INFOONLY)
					idEntity.this.fY -= oY-idEntity.this.vY;
					end;
				end;
			end;
        else
			if (axis==BOTHAXIS || axis==HORIZONTALAXIS || axis==INFOONLY)
				if (vcX > 0) 
					colDir = COLIZQ;	//Izquierda
					if (axis != INFOONLY)
					idEntity.this.fX += oX+idEntity.this.vX;
					end;
				else 
					colDir = COLDER;	//Derecha
					if (axis != INFOONLY)
						idEntity.this.fX -= oX-idEntity.this.vX;
					end;
				end;
			end;
	     end;
	end;
        
    //Devolvemos el sentido de la colision o 0 si no hay
    return colDir;

end;

//Funcion de chequeo de colision entre proceso y tile (dando sus coordenadas en mapa)
//Posiciona el objeto al borde del tile y devuelve un int con el sentido de la colision o 0 si no hay
function int colCheckTile(entity idEntity,int posX,int posY)
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
	vcX = (idEntity.this.fX) - ((posX*cTileSize)+cHalfTSize);
	vcY = (idEntity.this.fY) - ((posY*cTileSize)+cHalfTSize);
	// suma las mitades de los this.anchos y los this.altos
	hW =  (idEntity.this.ancho / 2) + chalfTSize;
	hH =  (idEntity.this.alto / 2) + chalfTSize;
	
	colDir = 0;

    //si los vectores e x y son menores que las mitades de this.anchos y this.altos, ESTAN colisionando
	if (abs(vcX) < hW && abs(vcY) < hH) 
        
		//calculamos el sentido de la colision (top, bottom, left, or right)
        oX = hW - abs(vcX);
        oY = hH - abs(vcY);
        
		if (oX >= oY) 
            if (vcY > 0) 			//Arriba
				if (checkTileCode(idEntity,COLUP,posY,posX))
					colDir = COLUP;
					idEntity.this.fY += oY;
				end;
             else 
                if (checkTileCode(idEntity,COLDOWN,posY,posX))
					colDir = COLDOWN;	//Abajo
					idEntity.this.fY -= oY;
				end;
             end;
        else 
            if (vcX > 0) 
                if (checkTileCode(idEntity,COLIZQ,posY,posX))
					colDir = COLIZQ;	//Izquierda
					idEntity.this.fX += oX;
				end;
             else 
				if (checkTileCode(idEntity,COLDER,posY,posX))
					colDir = COLDER;	//Derecha
					idEntity.this.fX -= oX;
				end;
             end;
	     end;
	end;
    
	//Devolvemos el sentido de la colision o 0 si no hay
    return colDir;

end;

//funcion que aplica la direccion de la colision en el objeto
function applyDirCollision(entity idEntity,int colDir,byte *objGrounded)
begin
	//acciones segun colision
	if (colDir == COLIZQ || colDir == COLDER) 
		idEntity.this.vX = 0;
	elseif (colDir == COLDOWN) 
		//si es un solidItem
		if (isType(idEntity,TYPE solidItem))
			idEntity.this.vY *= -cBouncyObjectVel;
			//cantidad de rebote
			if ( abs(idEntity.this.vY) < cBouncyObjectVel )
				*objGrounded = true;		
			end;
		//si es un item
		elseif (isType(idEntity,TYPE Item))
			idEntity.this.vY *= -cBouncyItemVel;
			//cantidad de rebote
			if ( abs(idEntity.this.vY) < cBouncyItemVel )
				*objGrounded = true;		
			end;			
		else
			*objGrounded = true;
		end;
	elseif (colDir == COLUP) 
		idEntity.this.vY = 0;			//Flota por el techo	
		//idEntity.this.vY *= -1;		//Rebota hacia abajo con la velocida que subia
		//idEntity.this.vY = 2;		//Rebota hacia abajo con valor fijo
	end;
end;

//funcion que engloba la gestion de las fisicas de un proceso
//devuelve si hubo alguna colision hortizontal con el terreno, ya que las verticales
//las devuelve en el flag grounded
function byte terrainPhysics(entity idEntity,float friction,byte *objGrounded)
private
	int i;					//Var auxiliar
	int collided = false; 	//flag de colision
	int colDir;				//Direccion colision
	int grounded;			//flag de en suelo
begin
	//leemos el flag de en suelo del objeto
	grounded = *objGrounded;
			
	if (!isBitSet(idEntity.this.props,NO_PHYSICS))
		if (grounded)
			idEntity.this.vX *= friction;
		end;
		
		idEntity.this.vY += gravity;
		
		grounded = false;
		collided = false;		
		
		//COLISION TERRENO
		//Recorremos la lista de puntos a comprobar
		for (i=0;i<cNumColPoints;i++)					
			//obtenemos la direccion de la colision
			colDir = colCheckTileTerrain(idEntity,i);
			//aplicamos la direccion de la colision
			applyDirCollision(idEntity,colDir,&grounded);
			//seteamos flag de colisionado
			if (colDir == COLDER || colDir == COLIZQ || colDir == COLUP)
				collided = true;
			end;
		end;
	else
		grounded = true;
	end;
	
	//aplicamos el flag de en suelo al objeto
	*objGrounded = grounded;
	
	return collided;	//devolvemos flag colision
	
end;

//funcion que alinea el eje central del grafico respecto a la caja de deteccion
function alignAxis(entity idEntity)
begin
	switch (idEntity.this.axisAlign)
		case CENTER_AXIS:
		end;
		case UP_AXIS:
			map_info_set(idEntity.file,idEntity.graph,G_Y_CENTER,abs((map_info(idEntity.file,idEntity.graph,G_HEIGHT))+(idEntity.this.alto>>1)));
		end;
		case DOWN_AXIS:
			map_info_set(idEntity.file,idEntity.graph,G_Y_CENTER,abs((map_info(idEntity.file,idEntity.graph,G_HEIGHT))-(idEntity.this.alto>>1)));
		end;
	end;
end;