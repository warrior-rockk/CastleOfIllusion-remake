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
					" TileCode: "+tileMap[posTileY][posTileX].tileCode);
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
	
	//Bucle principal de control del engine
	Loop 
		
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
			//activamos el modo debug
			actDebugMode = 1;
		end;
		
		//Tareas ciclicas del modo debug
		if (actDebugMode)
			
			;			
		end;
		
		//Tareas salida del modo debug
		if (not debugMode && actDebugMode)
			//limpiamos los textos
			for (i=0;i<MAXDEBUGINFO;i++)
				delete_text(idDebugText[i]);
			end;
			//desactivamos el modo debug
			actDebugMode = 0;
		end;
		
		frame;
	end;
	
end;

//Inicialización del modo grafico
function WGE_InitScreen()
begin
	//Complete restore para evitar "flickering"
	restore_type = COMPLETE_RESTORE;
	//scale_mode=SCALE_NORMAL2X; 
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
	exit();
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
	for (i=0;i<level.numTilesY;i++)
		for (j=0;j<level.numTilesX;j++)
			if (fread(levelMapFile,tileMap[i][j].tileCode) == 0)
				log("Fallo leyendo codigo de tiles ("+j+","+i+") en: " + file_);
				WGE_Quit();
			end;
		end;
	end;  
	
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
							1,0,0,1,1,1,0,0,0,1,0,0,0,0,0,0,0,0,0,0,1,
							1,0,0,1,0,0,0,0,1,1,0,0,0,0,0,0,0,0,1,1,1,
							1,0,0,1,0,0,0,1,1,1,0,0,0,0,0,2,2,0,0,0,1,
							1,0,0,0,0,0,1,1,1,1,0,0,0,0,0,0,0,0,0,1,1,
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
process pTile(int i,int j)
private	
	byte tileColor;		//Color del tile (modo debug)
	byte redraw = 0;	//Flag redibujar y posicionar el tile
	
BEGIN
	//definimos propiedades iniciales
	alto = cTileSize;
	ancho = cTileSize;
	ctype = c_scroll;
	region = cGameRegion;
	z = ZMAP;
	priority = TILEPRIOR;
	
	//establecemos su posicion inicial
	x = (j*cTileSize)+cHalfTSize;
	y = (i*cTileSize)+cHalfTSize;
	
	//comprobamos si el tile existe en el mapeado
	//y leemos su grafico
	if (tileExists(i,j))
		tileColor = tileMap[i][j].tileGraph;
	else
		tileColor = 255;
	end;
	
	//dibujamos el tile
	graph = map_new(alto,ancho,8);
	drawing_map(0,graph);
	drawing_color(tileColor);
	draw_box(0,0,alto,ancho);
	
	//en modo debug, escribimos su posicion
	if (debugMode)
		set_text_color((255-TileColor)+1);
		map_put(0,graph,write_in_map(0,i,3),16,10);
		map_put(0,graph,write_in_map(0,j,3),16,18);
	end;
	
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
				tileColor = tileMap[i][j].tileGraph;
			else
				tileColor = 255;
			end;
		
			drawing_map(0,graph);
			drawing_color(tileColor);
			draw_box(0,0,alto,ancho);
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
//Devuelve un int con el sentido de la colision o 0 si no hay
function int colCheckAABB(int idShapeA, int shapeBx,int shapeBy,int shapeBW,int shapeBH)
private
float vcX,vcY,hW,hH,oX,oY;
int ColDir;

begin
    //Obtiene los vectores de los centros para comparar
	vcX = (idShapeA.fx) - (shapeBx );
	vcY = (idShapeA.fy) - (shapeBy );
	// suma las mitades de los anchos y los altos
	hW =  (idShapeA.ancho / 2) + (shapeBW / 2);
	hH = (idShapeA.alto / 2) + (shapeBH / 2);
	
	colDir = 0;

    //si los vectores e x y son menores que las mitades de anchos y altos, ESTAN colisionando
	if (abs(vcX) < hW && abs(vcY) < hH) 
        
		//calculamos el sentido de la colision (top, bottom, left, or right)
        oX = hW - abs(vcX);
        oY = hH - abs(vcY);
        
		if (oX >= oY) 
            if (vcY > 0) 			//Arriba
				colDir = COLUP;
                idShapeA.fy += oY;
             else 
                colDir = COLDOWN;	//Abajo
                idShapeA.fy -= oY;
             end;
        else 
            if (vcX > 0) 
                colDir = COLIZQ;	//Izquierda
                idShapeA.fx += oX;
             else 
                colDir = COLDER;	//Derecha
                idShapeA.fx -= oX;
             end;
	     end;
	end;
        
    //Devolvemos el sentido de la colision o 0 si no hay
    return colDir;

end;

//Funcion que comprueba si una posicion del tile existe en el mapa
function int tileExists(int i,int j)
begin

	Return (i<level.numTilesY && j<level.numTilesX && i>=0 && j>=0);
end;

//Funcion de chequeo de colision entre proceso y tile (dando sus coordenadas en mapa)
//Devuelve un int con el sentido de la colision o 0 si no hay
function int colCheckTile(int idShapeA,int posX,int posY)
private
float vcX,vcY,hW,hH,oX,oY;
int ColDir;

begin
    //Si el tile no es sólido, o no existe en el mapa, no hay colision
	if ( tileMap[posY][posX].tileCode == 0 || !tileExists(posy,posx))
		return 0;
	end;
	
	//Obtiene los vectores de los centros para comparar
	vcX = (idShapeA.fx) - ((posX*cTileSize)+cHalfTSize);
	vcY = (idShapeA.fy) - ((posY*cTileSize)+cHalfTSize);
	// suma las mitades de los anchos y los altos
	hW =  (idShapeA.ancho / 2) + chalfTSize;
	hH =  (idShapeA.alto / 2) + chalfTSize;
	
	colDir = 0;

    //si los vectores e x y son menores que las mitades de anchos y altos, ESTAN colisionando
	if (abs(vcX) < hW && abs(vcY) < hH) 
        
		//calculamos el sentido de la colision (top, bottom, left, or right)
        oX = hW - abs(vcX);
        oY = hH - abs(vcY);
        
		if (oX >= oY) 
            if (vcY > 0) 			//Arriba
				colDir = COLUP;
                idShapeA.fy += oY;
             else 
                colDir = COLDOWN;	//Abajo
                idShapeA.fy -= oY;
             end;
        else 
            if (vcX > 0) 
                colDir = COLIZQ;	//Izquierda
                idShapeA.fx += oX;
             else 
                colDir = COLDER;	//Derecha
                idShapeA.fx -= oX;
             end;
	     end;
	end;
    
	//Devolvemos el sentido de la colision o 0 si no hay
    return colDir;

end;