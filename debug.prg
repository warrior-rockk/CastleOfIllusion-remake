// ========================================================================
//  Warcom Game Engine
//  Motor para juegos plataformas 2D
//  22/08/14
//
//  Funciones Debug Engine
// ========================================================================

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
begin
	//creamos el cursor de debug
	cursorMap = map_new(cTileSize,cTileSize,8);
	drawing_map(0,cursorMap);
	drawing_color(CURSORCOLOR);
	draw_line(1,chalfTSize,cTileSize,chalfTSize);
	draw_line(chalfTSize,1,chalfTSize,cTileSize);
	
	//visualizamos cursor
	graph = cursorMap; 
	region = cGameRegion;
	mouse.region  = region;
	ctype = c_scroll;
	z = ZCURSOR;
		
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
					" TileCode: " +tileMap[posTileY][posTileX].tileCode);
			else
				log("TilePosX: "+posTileX+" TilePosY: "+posTileY + 
				    " fuera del mapeado");
			end;
			
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

//Funcion para dibujar un triangulo del tamaño de tile.
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

//Funcion para pintar los puntos de colision
//de un proceso
process debugColPoint(float fx,float fy)
begin
	region = cGameRegion;
	ctype = c_scroll;
	z = -100;

	graph = map_new(1,1,8);
	drawing_map(0,graph);
	drawing_color(100);
	draw_box(0,0,1,1);
	x = fx;
	y = fy;
	frame;
end;

