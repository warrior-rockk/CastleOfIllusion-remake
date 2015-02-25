// ========================================================================
//  Warcom Game Engine
//  Motor para juegos plataformas 2D
//  22/08/14
//
//  Funciones Debug Engine
// ========================================================================

//Rutina de debug
process WGE_Debug()
private
	byte actDebugMode = 0;					//Modo debug activado
	int idDebugText[cMaxDebugInfo-1];		//Textos debug
	int idCursor;							//Id proceso cursor
	int pID;								//Process ID
	int i;									//Variables auxiliares
begin 
	loop
		//Medicion fps
		if (fps > maxFPS)
			maxFPS = fps;
			if (minFPS == 0) minFPS = maxFPS; end;
		end;
		if (fps < minFPS && fps<>0)
			minFPS = fps;
		end;
		
		//activacion/desactivacion del debugMode
		if (key(_control) && WGE_Key(_d,KEY_DOWN))
			debugMode = not debugMode;
		end;
		
		//Seteo de fps a 0
		if (key(_control) && WGE_Key(_f,KEY_DOWN))
			if (FPS==cNumFPS)
				set_fps(cNumFPSDebug,0);
				log("Pasamos a "+cNumFPSDebug+" FPS");
			else
				set_fps(cNumFPS,0);
				log("Pasamos a "+cNumFps+" FPS");
			end;
			//Reseteamos mediciones
			maxFPS = 0;
			minFPS = 0;
		end;

		//Subida/Bajada de fps
		If (WGE_Key(_C_MINUS,KEY_DOWN))
			set_fps(fps-10,0);
			log("Pasamos a "+fps+" FPS");
		end;
		If (WGE_Key(_C_PLUS,KEY_DOWN))
			set_fps(fps+10,0);
			log("Pasamos a "+fps+" FPS");
		end;

		//reiniciar nivel
		if (WGE_Key(_r,KEY_DOWN))
			WGE_RestartLevel();
		end;
		
		//Tareas de entrada al modo debug
		if (debugMode && not actDebugMode)
			//creamos el cursor
			idCursor = WGE_DebugCursor();
			//creamos frame de la region
			WGE_RegionFrame();
			//mostramos informacion de debug
			idDebugText[0] = write_int(0,cDebugInfoX,cDebugInfoY,0,&fps);
			idDebugText[1] = write_int(0,cDebugInfoX,cDebugInfoY+10,0,&idCursor.x);
			idDebugText[2] = write_int(0,cDebugInfoX,cDebugInfoY+20,0,&idCursor.y);
			idDebugText[3] = write_float(0,cDebugInfoX,cDebugInfoY+30,0,&idPlayer.vX);
			//idDebugText[4] = write_float(0,cDebugInfoX,cDebugInfoY+40,0,&friction);
			//Hacemos al player un blend aditivo para ver las colisiones
			if (idPlayer<>0) idPlayer.flags |= B_ABLEND; end;
			//activamos el modo debug
			actDebugMode = 1;
		end;
		
		//Tareas ciclicas del modo debug
		if (actDebugMode)
			//Pintamos la caja de deteccion del player
			debugColBox(idPlayer);
			//pintamos caja deteccion monsters
			repeat
				pID = get_id(TYPE monster);
				debugColBox(pID);
			until (pID == 0);
			
			//Pintamos los puntos de deteccion del jugador
			/*for (i=0;i<cNumColPoints;i++)			
				//debugColPoint(idPlayer.fx+idPlayer.colPoint[i].x,idPlayer.fy+idPlayer.colPoint[i].y);
				debugColPoint(idPlayer,i);
			end;*/
			
		end;
		
		//Tareas salida del modo debug
		if (not debugMode && actDebugMode)
			//limpiamos los textos
			for (i=0;i<cMaxDebugInfo;i++)
				delete_text(idDebugText[i]);
			end;
			//Quitamos al player el blend aditivo para ver las colisiones
			if (idPlayer<>0) idPlayer.flags &= ~ B_ABLEND; end;
			//desactivamos el modo debug
			actDebugMode = 0;
		end;
		
		frame;
	end;
end;

//Salida por consola
function log(string texto)
begin
	say ("WGE: " + texto);
end;

process WGE_DebugCursor()
private
	int cursorMap;	//Id grafico  cursor
	int posTileX;	//posicion X Tile Clicado
	int posTileY;	//posicion Y Tile Clicado
	object idObj;	//Objeto de debug;
begin
	//creamos el cursor de debug
	cursorMap = map_new(cTileSize,cTileSize,8);
	drawing_map(0,cursorMap);
	drawing_color(cCursorColor);
	draw_line(1,chalfTSize,cTileSize,chalfTSize);
	draw_line(chalfTSize,1,chalfTSize,cTileSize);
	
	//visualizamos cursor
	graph = cursorMap; 
	region = cGameRegion;
	mouse.region  = region;
	ctype = c_scroll;
	z = cZCursor;
		
	//posicionamos el cursor a mitad de pantalla
	mouse.x = (cRegionW>>1);
	mouse.y = (cRegionH>>1);
	
	repeat
		
		//actualizamos posicion del cursor
		x = mouse.x + scroll[cGameScroll].x0;
		y = mouse.y + scroll[cGameScroll].y0;
		
		//Al hacer clic, mostramos informacion de tile
		if (mouse.left)
			
			posTileX = x/cTileSize;
			posTileY = y/cTileSize;
			
			if (posTileX < level.numTilesX && x >= 0 &&
			    posTileY < level.numTilesY && y >= 0  )
				log("TilePosX: "+posTileX+" TilePosY: "+posTileY + 
				    " TileGraph: "+tileMap[posTileY][posTileX].tileGraph + 
					" TileShape: "+tileMap[posTileY][posTileX].tileShape +
					" TileProf: " +tileMap[posTileY][posTileX].tileProf +
					" TileAlpha: "+tileMap[posTileY][posTileX].tileAlpha +
					" TileCode: " +tileMap[posTileY][posTileX].tileCode + 
					" ProcessID: "+collision(type pTile));
			else
				log("TilePosX: "+posTileX+" TilePosY: "+posTileY + 
				    " fuera del mapeado");
			end;
			
			WGE_Wait(20);
			
		end;
		
		//al hacer click secundario, creamos una caja
		if (mouse.right)
			
			idObj = object(1,x,y,16,16,BREAKABLE);
			idObj.vX = 2;
			idObj.vY = -2;
			
			WGE_Wait(20);
		end;
		
		//posicionar personaje en cursor
		if (key(_p))
			idPlayer.fx = x;
			idPlayer.fy = y;
			WGE_Wait(20);
		end;
		
		frame;
	
	until(not debugMode)
	
	//eliminamos grafico cursor
	graph = 0;
	map_del(0,cursorMap);
end;

//Grafico que encuadra la region actual
//para probar como aparecen los tiles
process WGE_RegionFrame()
begin
	
	region = cGameRegion;
	graph = map_new(cResX+1,cResY+1,8);
	drawing_map(0,graph);
	drawing_color(300);
	draw_line(0,0,cRegionW,0);
	draw_line(0,0,0,cRegionH);
	draw_line(cRegionW,0,cRegionW,cRegionH);
	draw_line(0,cRegionH,cRegionW,cRegionH);
	x = cResX>>1;
	y = cResY>>1;
	
	repeat
		frame;
	until(not debugMode);
	
	map_del(0,graph);
end;

//Funcion para pintar los puntos de colision
//de un proceso
process debugColPoint(entity idObject,int numPoint)
begin
	region = cGameRegion;
	ctype = c_scroll;
	z = -100;

	graph = map_new(1,1,8);
	drawing_map(0,graph);
	if (idObject.colPoint[numPoint].enabled)
		drawing_color(100);
	else
		drawing_color(30);
	end;
	
	draw_box(0,0,1,1);
	
	x = idObject.fx+idObject.colPoint[numPoint].x;
	y = idObject.fy+idObject.colPoint[numPoint].y;
	
	frame;
	
	map_unload(0,graph);
end;

//Funcion para dibujar un triangulo del tama�o de tile.
//Solo funciona el angulo 135 y 45
function draw_triangle(int map,int angle)
private xx,yy,iniY;
begin
	if (angle == 135)
		iniY = 0;
		for (xx=0;xx<cTileSize;xx++)
			for (yy=iniY;yy<cTileSize;yy++)
				map_put_pixel(0,map,xx,yy,250);
			end;
			iniY++;
		end;
	else
		iniY = cTileSize;
		for (xx=0;xx<cTileSize;xx++)
			for (yy=iniY;yy<cTileSize;yy++)
				map_put_pixel(0,map,xx,yy,250);
			end;
			iniY--;
		end;
	end;
end;

//Funcion para dibujar unq escalera del tama�o de tile.
function draw_stairs(int map)
private xx,yy;
begin
	map_clear(0,map,200);
	//barras laterales
	for (yy=0;yy<cTileSize;yy++)
		map_put_pixel(0,map,(cTileSize>>1)-(cTileSize/4),yy,250);
		map_put_pixel(0,map,(cTileSize>>1)+(cTileSize/4),yy,250);
	end;
	//travesa�os
	for (xx=(cTileSize>>1)-(cTileSize/4)+1;xx<(cTileSize>>1)+(cTileSize/4);xx++)
		map_put_pixel(0,map,xx,(cTileSize>>1)-(cTileSize/4),250);
		map_put_pixel(0,map,xx,(cTileSize>>1),250);
		map_put_pixel(0,map,xx,(cTileSize>>1)+(cTileSize/4),250);
	end;
	
end;

//Funcion para dibujar una plataforma traspasable SOLID_ON_FALL
function draw_SolidOnFall(int map)
private xx,yy;
begin;	
	map_clear(0,map,0);
	drawing_map(0,map);
	drawing_color(300);
	draw_box(0,0,cTileSize,10);
end;

//Funcion que dibuja un tile como un cuadrado de color variable
//y dibujando su tipo correspondiente a modo de debug 
function debugDrawTile(entity idTile,byte tileColor,int i,int j)
begin
	//dibujamos el tile
	map_clear(idTile.file,idTile.graph,0);
	drawing_map(idTile.file,idTile.graph);
	drawing_color(tileColor);
	
	//tipo de Tile
	if (tileExists(i,j))
		if (tileMap[i][j].tileCode == SLOPE_135) 
			map_put(idTile.file,idTile.graph,mapTriangle135,cTileSize>>1,cTileSize>>1);
		elseif (tileMap[i][j].tileCode == SLOPE_45)
			map_put(idTile.file,idTile.graph,mapTriangle45,cTileSize>>1,cTileSize>>1);
		elseif (tileMap[i][j].tileCode == STAIRS) //|| tileMap[i][j].tileCode == TOP_STAIRS)
			map_put(idTile.file,idTile.graph,mapStairs,cTileSize>>1,cTileSize>>1);
		elseif (tileMap[i][j].tileCode == TOP_STAIRS) 
			map_put(idTile.file,idTile.graph,mapStairs,cTileSize>>1,cTileSize>>1);
		else
			draw_box(idTile.file,0,idTile.alto,idTile.ancho);
		end;
	end;
end;

//funcion que dibuja un player sin graficos
function DebugDrawPlayer()
begin
	map_del(0,idPlayer.graph);
	idPlayer.graph = map_new(idPlayer.ancho,idPlayer.alto,8);
	drawing_map(0,idPlayer.graph);
	drawing_color(300);
	draw_box(0,0,idPlayer.ancho,idPlayer.alto);
	//dibujamos la nariz para diferenciar hacia donde mira
	drawing_color(200);
	draw_fcircle((idPlayer.ancho>>1)+(idPlayer.ancho>>2),(idPlayer.alto>>2),4);
end;

//Funcion para pintar la caja de colision 
//de un proceso segun su alto/ancho
process debugColBox(entity idObject)
begin
	if (idObject <> 0 )
		region = cGameRegion;
		ctype = c_scroll;
		z = -100;
		setBit(flags,B_ABLEND);
		
		graph = map_new(idObject.ancho,idObject.alto,8);
		drawing_map(0,graph);
		
		drawing_color(300);
		draw_box(0,0,idObject.ancho,idObject.alto);
		
		x = idObject.x;
		y = idObject.y;
		
		frame;
		
		map_unload(0,graph);
	end;
end;