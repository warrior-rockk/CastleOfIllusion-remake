// ========================================================================
//  Warcom Game Engine
//  Motor para juegos plataformas 2D
//  21/07/14
//
//  Funcion Motor Principal
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

//Tareas de inicializacion del engine
process WGE_Init()
private
	byte actDebugMode = 0;					//Modo debug activado
	int idDebugText[MAXDEBUGINFO-1];	//Textos debug
	int idCursor;						//Id proceso cursor
		
	int i; 								//Variables auxiliares
begin
	//Dibujamos mapas para testeo (esto ira eliminado)
	mapBox = map_new(cTileSize,cTileSize,8);
	drawing_map(0,mapBox);
	drawing_color(300);
	draw_box(0,0,cTileSize,cTileSize);
	
	mapTriangle135 = map_new(cTileSize,cTileSize,8);
	draw_triangle(mapTriangle135,135);
	
	mapTriangle45 = map_new(cTileSize,cTileSize,8);
	draw_triangle(mapTriangle45,45);
	
	//Bucle principal de control del engine
	Loop 
		//Medicion fps
		if (fps > maxFPS)
			maxFPS = fps;
			if (minFPS == 0) minFPS = maxFPS; end;
		end;
		if (fps < minFPS && fps<>0)
			minFPS = fps;
		end;
		
		//activacion/desactivacion del modo debug
		if (key(_control) && key(_d))
			debugMode = not debugMode;
			WGE_Wait(20);
		end;
		
		//Seteo de fps a 0
		if (key(_control) && key(_f))
			if (FPS==cNumFPS)
				set_fps(cNumFPSDebug,0);
				log("Pasamos a "+cNumFPSDebug+" FPS");
			else
				set_fps(cNumFPS,0);
				log("Pasamos a "+cNumFps+" FPS");
			end;
			WGE_Wait(20);
			//Reseteamos mediciones
			maxFPS = 0;
			minFPS = 0;
		end;
		
		//Tareas de entrada al modo debug
		if (debugMode && not actDebugMode)
			//creamos el cursor
			idCursor = WGE_DebugCursor();
			//creamos frame de la region
			WGE_RegionFrame();
			//mostramos informacion de debug
			idDebugText[0] = write_int(0,DEBUGINFOX,DEBUGINFOY,0,&fps);
			idDebugText[1] = write_int(0,DEBUGINFOX,DEBUGINFOY+10,0,&idCursor.x);
			idDebugText[2] = write_int(0,DEBUGINFOX,DEBUGINFOY+20,0,&idCursor.y);
			//Hacemos al player un blend aditivo para ver las colisiones
			if (idPlayer<>0) idPlayer.flags |= B_ABLEND; end;
			//activamos el modo debug
			actDebugMode = 1;
		end;
		
		//Tareas ciclicas del modo debug
		if (actDebugMode)

			//Pintamos los puntos de deteccion del jugador
			if (idPlayer<>0)
				for (i=0;i<idPlayer.numColPoints;i++)
					if (idPlayer.colPoint[i].enabled)
						debugColPoint(idPlayer.fx+idPlayer.colPoint[i].x,idPlayer.fy+idPlayer.colPoint[i].y);
					end;
				end;
			end;
					
		end;
		
		//Tareas salida del modo debug
		if (not debugMode && actDebugMode)
			//limpiamos los textos
			for (i=0;i<MAXDEBUGINFO;i++)
				delete_text(idDebugText[i]);
			end;
			//Quitamos al player el blend aditivo para ver las colisiones
			if (idPlayer<>0) idPlayer.flags &= B_ABLEND; end;
			//desactivamos el modo debug
			actDebugMode = 0;
		end;
		
		frame;
	end;
	
end;

//Inicialización del modo grafico
function WGE_InitScreen()
begin
	//Complete restore para evitar "flickering" (no funciona)
	restore_type = COMPLETE_RESTORE;
	scale_mode=SCALE_NORMAL2X; 
	set_mode(cResX,cResY,8);
	//set_mode(992,600,8);
	set_fps(cNumFPS,0);
	
	log("Modo Grafico inicializado");
end;

//Definicion Region y Scroll
function WGE_InitScroll()
begin
	define_region(cGameRegion,cRegionX,cRegionY,cRegionW,cRegionH);
	//define_region(cGameRegion,cRegionX,cRegionY,992,600);
	//Caida de frames radical si el mapa del scroll es pequeño (por tener que repetirlo?)
	start_scroll(cGameScroll,0,map_new(cRegionW,cRegionH,8),0,cGameRegion,3);
	
	scroll[cGameScroll].ratio = 100;
	log("Scroll creado");
	
	WGE_ControlScroll();

end;

//Desactivación del engine y liberacion de memoria
function WGE_Quit()
begin
	//Limpiamos la memoria dinamica
	free(objetos);
	free(paths);
	//free(tileMap);
	
	log("Se finaliza la ejecución");
	log("FPS Max: "+maxFPS);
	log("FPS Min: "+minFPS);
	exit();
end;

//Funcion que setea el modo alpha.Solo se usa cuando se necesita porque
//demora unos segundos generar las tablas de transparencia
process WGE_InitAlpha()
begin
	log("Activando modo alpha");
		
	drawing_alpha(TRANSLEVEL);
	drawing_alpha(255);
	
	log("Modo alpha activado"); 
end;

//Carga de archivo de nivel
function WGE_LoadLevel(string file_)
private 
	int levelFile;		//Archivo del nivel
	int i,j;			//Indices auxiliares
end

begin 
	//Comprobamos si existe el archivo de datos del nivel
	if (not fexists(file_))
		log("No existe el fichero: " + file_);
		WGE_Quit();
	end;
	
	//Abrimos el archivo
	levelFile = fopen(file_,o_read);
	//Nos situamos al principio del archivo
	fseek(levelFile,0,SEEK_SET);  
	
	//Leemos icion inicial jugador
	log("Leyendo datos nivel");
	fread(levelFile,level.playerX0); 
	fread(levelFile,level.playerY0);
	
	//Leemos numero de objetos
	log("Leyendo objetos nivel");
	fread(levelFile,level.numObjects);
	
	//Asignamos tamaño dinamico al array de objetos
	objetos = calloc(level.numObjects ,sizeof(objeto));
	//Leemos los datos de los objetos
	for (i=0;i<level.numObjects;i++)
			fread(levelFile,objetos[i].tipo);
			fread(levelFile,objetos[i].grafico);
			fread(levelFile,objetos[i].x0);
			fread(levelFile,objetos[i].y0); 
			fread(levelFile,objetos[i].angulo);
			for (j=0;j<MaxObjParams;j++)
				fread(levelFile,objetos[i].param[j]);
			end;
	end; 
	
	//Leemos numero de paths
	log("Leyendo Paths Nivel");
	fread(levelFile,level.numPaths);
	//Asignamos tamaño dinamico al array de paths
	objetos = calloc(level.numPaths , sizeof(path));
	//Leemos los datos de los trackings	
	for (i=0;i<level.numPaths;i++)
			//Leemos numero de puntos
			fread(levelFile,paths[i].numPuntos);
			//Asignamos tamaño dinamico al array de puntos
			paths[i].punto = alloc(paths[i].numPuntos * sizeof(point));
			for (j=0;j<paths[i].numPuntos;j++)
				//Leemos los puntos
				fread(levelFile,paths[i].punto[j].x); 
				fread(levelFile,paths[i].punto[j].y);
			end;
	end;
	
	//cerramos el archivo
	fclose(levelFile);
	log("Fichero nivel leído con " + level.numObjects + " Objetos y " + level.numPaths + " Paths");	
	
end;  

//Genera in archivo de nivel aleatorio
function WGE_GenLevelData(string file_)
private 
	int levelFile;		//Archivo del nivel
	int i,j;			//Indices auxiliares
	byte randByte;		//Byte aleatorio
	int randInt;		//Int aleatorio
end

begin 
	
	//Borramos el anterior si existe
	if (fexists(file_))
		fremove(file_);
		log("Borramos el archivo DataLevel anterior");
	end;	
	
	//Abrimos el archivo
	levelFile = fopen(file_,O_WRITE);
	//Nos situamos al principio del archivo
	fseek(levelFile,0,SEEK_SET);  
	
	//Escribimos icion inicial jugador
	randInt = 0;
	fwrite(levelFile,randInt); 
	fwrite(levelFile,randInt);
	
	//Escribimos numero de objetos
	fwrite(levelFile,randInt);
	
	//Escribimos numero de paths
	fwrite(levelFile,randInt);
		
	//cerramos el archivo
	fclose(levelFile);
	log("Fichero nivel creado");	
	
end;

//Cargamos archivo del tileMap
Function WGE_LoadMapLevel(string file_)
private 
	int levelMapFile;		//Archivo del nivel
	int i,j;				//Indices auxiliares
	byte mapTileCode;       //Codigo leido del mapa
	
Begin
	
	//Comprobamos si existe el archivo de mapa del nivel
	if (not fexists(file_))
		log("No existe el fichero de mapa: " + file_);
		WGE_Quit();
	end;
	
	//leemos el archivo de mapa
	levelMapFile = fopen(file_,O_READ);
			
	//Nos situamos al principio del archivo
	fseek(levelMapFile,0,SEEK_SET);  
		
	//Leemos datos del mapa
	log("Leyendo datos archivo del mapa");
	
	fread(levelMapFile,level.numTiles); 	//cargamos el numero de tiles que usa el mapa
	fread(levelMapFile,level.numTilesX);   //cargamos el numero de columnas de tiles
	fread(levelMapFile,level.numTilesY);   //cargamos el numero de filas de tiles
	
	
	//Creamos la matriz dinamica del tileMap
	tileMap = calloc(level.numTilesY,sizeof(tile*));
	from i = 0 to level.numTilesX-1;
		tileMap[i] = calloc(level.numTilesX ,sizeof(tile));
	end;

	//Cargamos la informacion del grafico de los tiles del fichero de mapa
	for (i=0;i<level.numTilesY;i++)
		for (j=0;j<level.numTilesX;j++)
			if (fread(levelMapFile,tileMap[i][j].tileGraph)  == 0)
				log("Fallo leyendo grafico de tiles ("+j+","+i+") en: " + file_);
				WGE_Quit();
			end;
		end;
	end;
	
	//Cargamos el codigo de los tiles del fichero de mapa
	mapUsesAlpha = 0;	//seteamos que no usuara propiedad alpha el mapa
	
	for (i=0;i<level.numTilesY;i++)
		for (j=0;j<level.numTilesX;j++)
			if (fread(levelMapFile,mapTileCode) == 0)
				log("Fallo leyendo codigo de tiles ("+j+","+i+") en: " + file_);
				WGE_Quit();
			else
				//decodificamos los datos del codigo de tile a propiedades
				tileMap[i][j].tileShape = bit_cmp(mapTileCode,BIT_TILE_SHAPE);
				tileMap[i][j].tileProf 	= bit_cmp(mapTileCode,BIT_TILE_DELANTE);
				tileMap[i][j].tileAlpha = bit_cmp(mapTileCode,BIT_TILE_ALPHA);
				tileMap[i][j].tileCode 	= mapTileCode & 31;	

				//Comprobamos si algun tile usa alpha
				if (tileMap[i][j].tileAlpha) mapUsesAlpha = 1; end;
							
			end;
		end;
	end;  
	
	//Si algun tile usa alpha, lo inicializamos
	if (mapUsesAlpha) WGE_InitAlpha(); end;
	
	//cerramos el archivo
	fclose(levelMapFile);
	log("Fichero mapa leído con " + level.numTiles + " Tiles. " + level.numTilesX + " Tiles en X y " + level.numTilesY + " Tiles en Y");   

End;

//funcion para generar un archivo de mapa especificando numero de tiles o aleatorio (numero tiles=0)
function WGE_GenRandomMapFile(string file_,int numTilesX,int numTilesY)
private 
	int levelMapFile;		//Archivo del nivel
	int i,j;				//Indices auxiliares
	byte randByte;			//Byte aleatorio
	int randInt;			//Int aleatorio
	
Begin
	
	//Borramos el anterior si existe
	if (fexists(file_))
		fremove(file_);
		log("Borramos el archivo MapData anterior");
	end;
	
	//creamos el archivo de mapa
	levelMapFile = fopen(file_,O_WRITE);
	//Nos situamos al principio del archivo
	fseek(levelMapFile,0,SEEK_SET);  
		
	//Si no pasamos numero de tiles, lo generamos aleatorio	(10 pantallas maximo)
	if (numTilesX == 0) numTilesX = rand((cResX/cTileSize),(cTileSize*10)); end;
	if (numTilesY == 0) numTilesY = rand((cResY/cTileSize),(cTileSize*10)); end;
		
	//Escribimos los datos del mapa
	randInt = numTilesX*numTilesY;
	fwrite(levelMapFile,randInt); 					//escribimos el numero de tiles que usa el mapa
	fwrite(levelMapFile,numTilesX);   				//escribimos el numero de columnas de tiles
	fwrite(levelMapFile,numTilesY);   				//escribimos el numero de filas de tiles	
	
	//Escribimos la informacion del grafico de los tiles del fichero de mapa
	for (i=0;i<numTilesY;i++)
		for (j=0;j<numTilesX;j++)
			randByte = rand(0,254);
			fwrite(levelMapFile,randByte); 
		end;
	end;
	
	//Escribimos el codigo de los tiles del fichero de mapa
	for (i=0;i<numTilesY;i++)
		for (j=0;j<numTilesX;j++)
			randByte = rand(0,10);
			fwrite(levelMapFile,randByte); 
		end;
	end; 
	
	//cerramos el archivo
	fclose(levelMapFile);
	log("Fichero mapa aleatorio creado");   
	
end;

//funcion para generar un archivo de mapa especificando el matriz de obstaculos
function WGE_GenMatrixMapFile(string file_)
private 
	int levelMapFile;		//Archivo del nivel
	int i,j;				//Indices auxiliares
	byte randByte;			//Byte aleatorio
	int randInt;			//Int aleatorio
	int numTilesX = 21;
	int numTilesY = 9;
	int matrixMap[8][20] = 	1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,
							1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,
							1,0,0,0,0,0,0,0,1,0,0,0,0,1,1,0,0,0,0,0,1,
							1,0,0,0,0,1,0,0,0,0,0,0,0,0,0,0,1,1,0,0,1,
							1,0,0,1,1,1,0,0,15,1,14,0,0,0,0,0,0,0,0,0,1,
							1,0,0,1,0,0,0,15,1,1,1,14,0,0,0,0,0,0,1,1,1,
							1,0,0,1,0,0,15,1,1,1,1,1,14,0,0,9,9,0,0,0,1,
							1,0,0,0,0,15,1,1,1,1,1,1,1,14,0,0,0,0,0,1,1,
							1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1;
Begin
	
	//Borramos el anterior si existe
	if (fexists(file_))
		fremove(file_);
		log("Borramos el archivo MapData anterior");
	end;
	
	//creamos el archivo de mapa
	levelMapFile = fopen(file_,O_WRITE);
	//Nos situamos al principio del archivo
	fseek(levelMapFile,0,SEEK_SET);  
		
	//Escribimos los datos del mapa
	randInt = numTilesX*numTilesY;
	fwrite(levelMapFile,randInt); 					//escribimos el numero de tiles que usa el mapa
	fwrite(levelMapFile,numTilesX);   				//escribimos el numero de columnas de tiles
	fwrite(levelMapFile,numTilesY);   				//escribimos el numero de filas de tiles	
	
	//Escribimos la informacion del grafico de los tiles del fichero de mapa
	for (i=0;i<numTilesY;i++)
		for (j=0;j<numTilesX;j++)
			if (matrixMap[i][j] == 0)
				randByte = 0;				//Posicion libre
			else
				randByte = 200;				//Obstaculo
			end;
			fwrite(levelMapFile,randByte); 
		end;
	end;
	
	//Escribimos el codigo de los tiles del fichero de mapa
	for (i=0;i<numTilesY;i++)
		for (j=0;j<numTilesX;j++)
			if (matrixMap[i][j] == 0)
				randByte = 0;				//Posicion libre
			else
				randByte = matrixMap[i][j];	//Obstaculo
			end;
			fwrite(levelMapFile,randByte); 
		end;
	end; 
	
	//cerramos el archivo
	fclose(levelMapFile);
	log("Fichero mapa aleatorio creado");   
	
end;

function WGE_DrawMap()
private
	int i,j,					//Indices auxiliares
	int x_inicial,y_inicial;	//Posiciones iniciales del mapeado			
	int numTilesDraw = 0;		//Numero de tiles dibujados

Begin                    
	
	//Leemos la posicion inicial de la pantalla para dibujar
	x_inicial = scroll[cGameScroll].x0;
	y_inicial = scroll[cGameScroll].y0;
	
	//creamos los procesos tiles segun la posicion x e y iniciales y la longitud de resolucion de pantalla
	//En los extremos de la pantalla se crean el numero definido de tiles (TILESOFFSCREEN) extras para asegurar la fluidez
	for (i=((y_inicial/cTileSize)-TILESYOFFSCREEN);i<(((cRegionH+y_inicial)/cTileSize)+TILESYOFFSCREEN);i++)
		for (j=((x_inicial/cTileSize)-TILESXOFFSCREEN);j<(((cRegionW+x_inicial)/cTileSize)+TILESXOFFSCREEN);j++)
			/*repeat
				frame; 
			until(not key(_space));
			repeat
				frame; 
			until(key(_space));*/
					
			pTile(i,j);
			log("Creado tile: "+i+" "+j);
			numTilesDraw++;
		end;
	end;

	log("Mapa dibujado correctamente. Creados "+numTilesDraw+" tiles");
	
End;

//proceso tile
//TODO: Quitar transparencia del tile (falgs= B_NOCOLORKEY) si no es necesario para ahorrar dibujado
process pTile(int i,int j)
private	
	byte tileColor;		//Color del tile (modo debug)
	byte redraw = 1;	//Flag redibujar y posicionar el tile
	
BEGIN
	//definimos propiedades iniciales
	alto = cTileSize;
	ancho = cTileSize;
	ctype = c_scroll;
	region = cGameRegion;
	priority = TILEPRIOR;
	graph = map_new(alto,ancho,8);
	
	//establecemos su posicion inicial
	x = (j*cTileSize)+cHalfTSize;
	y = (i*cTileSize)+cHalfTSize;
	
	loop
				
		//Si el tile desaparece por la izquierda
		if (scroll[0].x0 > (x+(cTileSize*TILESXOFFSCREEN)) )	
			//nueva posicion:a la derecha del tile de offscreen (que pasa a ser onscreen)
			//Se multiplica por 2 porque tenemos tiles offscreen a ambos lados
			i=i;
			j=j+(cRegionW/cTileSize)+(TILESXOFFSCREEN*2);
			  
			log("Paso de izq a der "+i+","+j);
			redraw = 1;
		end;
		
		
		//Si sale el tile por la derecha
		if ((scroll[0].x0+cRegionW)< (x-(cTileSize*TILESXOFFSCREEN)))
			//nueva posicion:a la derecha del tile de offscreen (que pasa a ser onscreen)
			//Se multiplica por 2 porque tenemos tiles offscreen a ambos lados
			i=i;
			j=j-(cRegionW/cTileSize)-(TILESXOFFSCREEN*2);
			
			log("Paso de der a izq "+i+","+j);
			redraw = 1;
		end;
		
		
		//Si sale por arriba
		if (scroll[0].y0 > (y+(cTileSize*TILESYOFFSCREEN)) )
			//nueva posicion
			i=i+(cRegionH/cTileSize)+(TILESYOFFSCREEN*2);
			j=j;       
			
			log("Paso de arrib a abaj "+i+","+j);
			redraw = 1;
		end;
		
		//Si sale por abajo
		if ((scroll[0].y0+cRegionH) < (y-(cTileSize*TILESYOFFSCREEN))) 
			//nueva posicion
			i=i-(cRegionH/cTileSize)-(TILESYOFFSCREEN*2);
			j=j;       
					
			log("Paso de abajo a arriba "+i+","+j);
			redraw = 1;
		end;
		
		//Redibujamos el tile
		if (redraw)
			//posicion
			x=(j*cTileSize)+cHalfTSize;
			y = (i*cTileSize)+cHalfTSize;
			
			//grafico
			if (tileExists(i,j))
				//Dibujamos su grafico
				tileColor = tileMap[i][j].tileGraph;
				//Establecemos sus propiedades segun TileCode
				if (tileMap[i][j].tileShape)
					flags &= B_NOCOLORKEY;	
				else
					flags |= B_NOCOLORKEY;
				end;
				if (tileMap[i][j].tileAlpha)
					alpha = TRANSLEVEL;		
				else
					alpha = 255;
				end;
				if (tileMap[i][j].tileProf)
					z = ZMAP2;
				else
					z = ZMAP1;
				end;
			else
				tileColor = 255;
			end;
			
			//dibujamos el tile
			map_clear(0,graph,0);
			drawing_map(0,graph);
			drawing_color(tileColor);
			
			//provisional
			if (tileExists(i,j))
				if (tileMap[i][j].tileCode == SLOPE_135) 
					map_put(0,graph,mapTriangle135,cTileSize>>1,cTileSize>>1);
				elseif (tileMap[i][j].tileCode == SLOPE_45)
					map_put(0,graph,mapTriangle45,cTileSize>>1,cTileSize>>1);
				else
					draw_box(0,0,alto,ancho);
				end;
			end;
			
			//graph=tileMap[i-(cResY/cTileSize)-2][j];
			
			//en modo debug, escribimos su posicion
			if (debugMode)
				set_text_color((255-TileColor)+1);
				map_put(0,graph,write_in_map(0,i,3),16,10);
				map_put(0,graph,write_in_map(0,j,3),16,18);
			end;
			
			redraw = 0;
		end;
		
		frame;
	
	end;
end;

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

//Creacion de los elementos del nivel
function WGE_CreateLevel()
private 
	int i;			//Indices auxiliares
end
Begin
	
	//Cargamos el archivo del tileMap
	//carga_tiles(Niveles[num_nivel]+"toyland.bin",Niveles[num_nivel]+"tiles.fpg",Niveles[num_nivel]+"durezas.fpg"); //funcion importada de "tileador.inc"
	
	//Dibujamos el tileMap
	//dibuja_tiles(player_x0,player_y0,C_cResX,C_cResY,0); //funcion importada de "tileador.inc"
	
	//creamos los objetos del nivel
	for (i=0;i<level.numObjects;i++) 
		//crea_objeto(i,1);
	end;
			
	//creamos los enemigos del nivel
	//crea_enemigo(x);
	
	//if (C_AHORRO_OBJETOS)control_sectores();end;
	          
End;

//Grafico que encuadra la region actual
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

process WGE_ControlScroll()
	
begin
	priority = SCROLLPRIOR;
	
	//Centramos el scroll en la posicion inicial
	scroll[cGameScroll].x0 = level.playerX0 - (cRegionW>>1);
	scroll[cGameScroll].y0 = level.playerY0 - (cRegionH>>1);	
	
	loop
		
		//movimiento del scroll
		
		//Si el jugador ya está en ejecución, lo enfocamos
		if (idPlayer <> 0 )
			scroll[cGameScroll].x0 = idPlayer.x - (cRegionW>>1);
			scroll[cGameScroll].y0 = idPlayer.y - (cRegionH>>1);	
		end;
		
		//Ajustamos limites pantalla
		
		//Limite izquierdo
		if (scroll[cGameScroll].x0 < 0 )
			scroll[cGameScroll].x0 = 0;
		end;
		//Limite derecho
		if ((scroll[cGameScroll].x0+cRegionW) > (level.numTilesX*cTileSize))
			scroll[cGameScroll].x0 = (level.numTilesX*cTileSize)-cRegionW;
		end;
		//Limite inferior
		if (scroll[cGameScroll].y0 < 0 )
			scroll[cGameScroll].y0 = 0;
		end;
		//Limite superior
		if ((scroll[cGameScroll].y0+cRegionH) > (level.numTilesY*cTileSize))
			scroll[cGameScroll].y0 = (level.numTilesY*cTileSize)-cRegionH;
		end;
		
		//Actualizamos el scroll
		move_scroll(cGameScroll);
		
		frame;
	
	end;
end;

function int WGE_Wait(int t)
Begin
    t += timer[0];
    While(timer[0]<t) frame; End
    return t-timer[0];
End

//Funcion de chequeo de colision entre proceso y AABB
//Posiciona el objeto al borde del tile y devuelve un int con el sentido de la colision o 0 si no hay
function int colCheckAABB(int idObject, int shapeBx,int shapeBy,int shapeBW,int shapeBH)
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

//Funcion que comprueba si una posicion del tile existe en el mapa
function int tileExists(int posY,int posX)
begin

	Return (posY<level.numTilesY && posX<level.numTilesX && posY>=0 && posX>=0);
end;

//Funcion de chequeo de colision entre proceso y tile (dando sus coordenadas en mapa)
//Posiciona el objeto al borde del tile y devuelve un int con el sentido de la colision o 0 si no hay
function int colCheckTile(int idObject,int posX,int posY)
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

//Funcion que comprueba, segun el codigo del tile, el comportamiento de la colision segun la direccion
//Devuelve 1 si colisiona en esa direccion o 0 si no colisiona.
function int checkTileCode(int idObject,int colDir,int posY,int posX)
begin
	switch(colDir)
		//Colisiones superiores
		case COLUP:
			return tileMap[posY][posX].tileCode <> SOLID_ON_FALL;
		end;
		//Colisiones inferiores
		case COLDOWN:
			return (tileMap[posY][posX].tileCode<> SOLID_ON_FALL) || 
			       (tileMap[posY][posX].tileCode==SOLID_ON_FALL && idObject.vY>0);
		end;
		//Colisiones lateral izquierdas
		case COLIZQ:
			return tileMap[posY][posX].tileCode <> SOLID_ON_FALL && tileMap[posY][posX].tileCode <> SLOPE_135 && tileMap[posY][posX].tileCode <> SLOPE_45;
		end;
		//Colisiones lateral derechas
		case COLDER:
			return tileMap[posY][posX].tileCode <> SOLID_ON_FALL && tileMap[posY][posX].tileCode <> SLOPE_135 && tileMap[posY][posX].tileCode <> SLOPE_45;
		end;
	end;
end;


//Funcion de colision con tile segun mapa de durezas
//Posiciona el objeto en el borde del tile y devuelve un int con el sentido de la colision o 0 si no lo hay
function int colCheckTileTerrain(int idObject,int i)
private 
int distColX;	//Distancia con la colision en X
int distColY;	//Distancia con la colision en Y
int iniX;		//Inicio X
int finX;		//FIn X
int iniY;		//Inicio Y
int finY;		//Fin Y
int colDir;		//Sentido de la colision

begin
		colDir = 0;
		
		if (!idObject.colPoint[i].enabled) return colDir; end;
		
		//COLISIONES EN X
		
		//si el punto de deteccion es uno de los laterales
		if (idObject.colPoint[i].colCode == COLDER || idObject.colPoint[i].colCode == COLIZQ )
			
			//Establecemos el vector a chequear
			iniX = idObject.fx+idObject.colPoint[i].x;
			finX = iniX+idObject.vX;
			iniY = idObject.fy+idObject.colPoint[i].y;
			finY = iniY;
			
			//lanzamos la comprobacion de colision en X
			distColX = colCheckVectorX(0,mapBox,idObject.alto,inix,iniy,finx,0);
			
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
		
		//COLISIONES EN Y
		
		//Si el punto de deteccion es uno de los superiores/inferiores
		if (idObject.colPoint[i].colCode == COLUP || idObject.colPoint[i].colCode == COLDOWN)
			
			//Establecemos el vector a comparar
			iniY = idObject.fy+idObject.colPoint[i].y;
			finY = iniY+idObject.vY;
			iniX = idObject.fx+idObject.colPoint[i].x;
			finX = iniX;
			
			//Lanzamos la comprobacion de colision en Y
			distColY = colision_y(0,mapBox,idObject.alto,inix,iniy,finy,0,1);
			
			//Si hay colision
			If (distColY>=0) 
				//Colision inferior
				if (idObject.colPoint[i].colCode == COLDOWN && idObject.vY>=0)
					//Situamos al objeto en el borde de la colision
					idObject.fy += distColY;
					colDir = COLDOWN;
					
					
					//deteccion de pendiente. Comprobamos si estamos enterrados
					//Establecemos el vector a comparar (centro/inferior del objeto)
					iniY = idObject.fy+(idObject.alto>>1)-1;
					finY = iniY-HILLHEIGHT; //altura maxima para considerar pendiente
					iniX = idObject.fx;
					finX = iniX;
					
					//Lanzamos la comprobacion de colision en Y
					distColY = colision_y(0,mapBox,idObject.alto,inix,iniy,finy,0,0);
					
					//Subimos al objeto a la pendiente
					if (distColY >0)
						idObject.fy -= distColY-1;
					end;
					
				End;                                 
				//Colision superior
				if (idObject.colPoint[i].colCode == COLUP && idObject.vY<0)
					//Situamos al objeto en el borde de la colision
					idObject.fy -= distColY;
					colDir = COLUP;
				End;
			
			else //si no hay colision, comprobamos si pendiente por debajo
				
				//Establecemos el vector a comparar (centro/inferior del objeto)
				iniY = idObject.fy+(idObject.alto>>1)-1;
				finY = iniY+idObject.vY+HILLHEIGHT; //altura maxima para considerar pendiente
				iniX = idObject.fx;
				finX = iniX;
				
				//Lanzamos la comprobacion de colision en Y
				distColY = colision_y(0,mapBox,idObject.alto,inix,iniy,finy,0,1);
				
				//Bajamos al objeto a la pendiente
				if (distColY >0)
					idObject.fy += distColY;
				end;	
				
			end; 
			
		end;
		
		//Devolvemos el sentido de la colision
		return colDir;
end; 


//Funcion que devuelve el numero de pixeles en x hasta la dureza, o -1 si no hay
function int colCheckVectorX(Int fich,Int graf,int alto,int x_org,Int y_org,int x_dest,Int color)
Private 
int dist=0;		//distancia de colision
int inc;		//Incremento

Begin
 
	//seteamos el sentido del incremento
	(x_dest>=x_org) ? inc = 1 : inc = -1;
	
    //Recorremos el vector buscando colision con pixel 
	Repeat
		
		if (color == 0 )		   	    
			//si el tile en esta posicion existe
			if (tileExists(y_org/cTileSize,x_org/cTileSize))
				//si el tile es solido
				if (tileMap[y_org/cTileSize][x_org/cTileSize].tileCode <> NO_SOLID)
					//comprobar el codigo del tile
					if (checkTileCode(idPlayer,COLDER,y_org/cTileSize,x_org/cTileSize))
						if(map_get_pixel(fich,mapBox,(x_org%cTileSize),(y_org%cTileSize)) <> 0)
							return dist;
						end;
					end;
				end;
			end;
			
		else
			;
		end;
		
		//Incrementamos distancia
		dist++;
		//Incrementamos vector
		x_org+=inc;
		
	Until(x_org==(x_dest+inc))
	
	//No ha habido colision
	Return -1; 
End

//funcion que devuelve el numero de pixeles en y hasta la dureza, o -1 si no hay
//El byte "modo", determina si la comprobacion es el numero de pixeles hasta llegar
//al color (modo 1) o a salir del color (modo 0)
Function int colision_y(int fich,int graf,int alto,int x_org,int y_org,int y_dest,int color,byte modo)
Private 
byte i=0;
Int inc_y;
byte num_dur_tile=0;
Begin
	If (y_dest>=y_org || !modo )inc_y=1;Else inc_y=-1;End
	//y_org += (alto/2)*inc_y;
	//y_dest += (alto/2)*inc_y;
	y_org += 1*inc_y;  //linea que delimita cuantos px estara el personaje sobre el suelo (con 1, estara justo 1 pix por encima de la linea de suelo)
	if (!modo) inc_y=-1;end;
	Repeat
					
			if (tileExists(y_org/cTileSize,x_org/cTileSize))
				if (tileMap[y_org/cTileSize][x_org/cTileSize].tileCode == NO_SOLID)
					num_dur_tile = 0;
				else
					//comprobar el codigo del tile
					if (checkTileCode(idPlayer,COLDOWN,y_org/cTileSize,x_org/cTileSize))
						if (tileMap[y_org/cTileSize][x_org/cTileSize].tileCode == SLOPE_135)
							num_dur_tile = map_get_pixel(fich,mapTriangle135,(x_org%cTileSize),(y_org%cTileSize));
						elseif (tileMap[y_org/cTileSize][x_org/cTileSize].tileCode == SLOPE_45)
							num_dur_tile = map_get_pixel(fich,mapTriangle45,(x_org%cTileSize),(y_org%cTileSize));
						else
							num_dur_tile = map_get_pixel(fich,mapBox,(x_org%cTileSize),(y_org%cTileSize));
						end;
					end;
				end;	
			end;
			
			If (modo)	
				
				if (num_dur_tile <> 0 )
					return i;
				/*
				switch (num_dur_tile)
					case (C_DUR_SUELO):
						Return(((C_DUR_SUELO+10)*100)+i);
					end;
					case (C_DUR_UP_STAIR):
						Return(((C_DUR_UP_STAIR+10)*100)+i);
					end;
					case (C_DUR_AVANCE_X_DER):
						Return(((C_DUR_AVANCE_X_DER+10)*100)+i);
					end;
					case (C_DUR_AVANCE_X_IZQ):
						Return(((C_DUR_AVANCE_X_IZQ+10)*100)+i);
					end;
					case (C_DUR_SUELO_NOTECHO):
						Return(((C_DUR_SUELO_NOTECHO+10)*100)+i);
					end;
					case (C_DUR_PENDIENTE):
						Return(((C_DUR_PENDIENTE+10)*100)+i);
					end;
					case (C_DUR_PENDIENTE_45):
						Return(((C_DUR_PENDIENTE_45+10)*100)+i);
					end;
				*/
				end;
				
			Else
				if (num_dur_tile == 0 )
					return i;
				end;
				//buscamos salirnos del suelo y la pendiente, en teoria este modo solo se usa para las pendientes
				//&& num_dur_tile !=C_DUR_PENDIENTE && num_dur_tile !=C_DUR_PENDIENTE_45
				//If (num_dur_tile !=color )Return (((color+10)*100)+i);End;
			End;
					 
			y_org+=inc_y;
			i++;
	Until( (y_org>y_dest && inc_y==1) || (y_org<y_dest && inc_y==-1) )
	return -1;
End;   

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

//Funcion que crea puntos de colision predefinidos (esquinas naturales)
function int WGE_CreateDefaultColPoints(int idObject,int numColPoints)
private
i= 0; 	//Variables auxiliares

begin
	if (numColPoints == 0) return 1; end;
	
	idObject.colPoint[i].x 		= (idObject.ancho>>1)-1;
	idObject.colPoint[i].y 		= -(idObject.alto/4);
	idObject.colPoint[i].colCode = COLDER;
	idObject.colPoint[i].enabled = 1;
	
	if (numColPoints == 1) return 1; end;
	i = 1;
	
	idObject.colPoint[i].x 		= (idObject.ancho>>1)-1;
	idObject.colPoint[i].y 		= (idObject.alto/4);
	idObject.colPoint[i].colCode = COLDER;
	idObject.colPoint[i].enabled = 1;
	
	if (numColPoints == 2) return 1; end;
	i = 2;
	
	idObject.colPoint[i].x 		= -(idObject.ancho>>1);
	idObject.colPoint[i].y 		= -(idObject.alto/4);
	idObject.colPoint[i].colCode = COLIZQ;
	idObject.colPoint[i].enabled = 1;
	
	if (numColPoints == 3) return 1; end;
	i = 3;
	
	idObject.colPoint[i].x 		= -(idObject.ancho>>1);
	idObject.colPoint[i].y 		= (idObject.alto/4);
	idObject.colPoint[i].colCode = COLIZQ;
	idObject.colPoint[i].enabled = 1;
	
	if (numColPoints == 4) return 1; end;
	i = 4;
	
	idObject.colPoint[i].x 		= (idObject.ancho/4);
	idObject.colPoint[i].y 		= (idObject.alto>>1)-1;
	idObject.colPoint[i].colCode = COLDOWN;
	idObject.colPoint[i].enabled = 1;
	
	if (numColPoints == 5) return 1; end;
	i = 5;
	
	idObject.colPoint[i].x 		= -(idObject.ancho/4);
	idObject.colPoint[i].y 		= (idObject.alto>>1)-1;
	idObject.colPoint[i].colCode = COLDOWN;
	idObject.colPoint[i].enabled = 1;
	
	if (numColPoints == 6) return 1; end;
	i = 6;
		
	idObject.colPoint[i].x 		= (idObject.ancho/4);
	idObject.colPoint[i].y 		= -(idObject.alto>>1);
	idObject.colPoint[i].colCode = COLUP;
	idObject.colPoint[i].enabled = 1;
	
	if (numColPoints == 7) return 1; end;
	i = 7;
	
	idObject.colPoint[i].x 		= -(idObject.ancho/4);;
	idObject.colPoint[i].y 		= -(idObject.alto>>1);
	idObject.colPoint[i].colCode = COLUP;
	idObject.colPoint[i].enabled = 1;
	
	return 1;
	
end;