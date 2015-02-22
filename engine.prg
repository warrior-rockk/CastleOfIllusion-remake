// ========================================================================
//  Warcom Game Engine
//  Motor para juegos plataformas 2D
//  21/07/14
//
//  Funcion Motor Principal
// ========================================================================

//Tareas de inicializacion del engine
//TODO: el mapa que esta en la posicion de mapStairs, se borra¿¿¿
//¿es por culpa de tener id 0 el sistema y el primer fpg?
process WGE_Init()
private
	byte actDebugMode = 0;					//Modo debug activado
	int idDebugText[cMaxDebugInfo-1];		//Textos debug
	int idCursor;							//Id proceso cursor
		
	int i; 									//Variables auxiliares
	byte clockTickMem;						//Memoria Flanco Reloj
	int pauseText;
begin
	priority = 1000;         
	
	//Dibujamos mapas para testeo (esto ira eliminado)
	mapBox = map_new(cTileSize,cTileSize,8);
	drawing_map(0,mapBox);
	drawing_color(300);
	draw_box(0,0,cTileSize,cTileSize);
	
	mapStairs = map_new(cTileSize,cTileSize,8);
	draw_stairs(mapStairs);
	
	mapTriangle135 = map_new(cTileSize,cTileSize,8);
	draw_triangle(mapTriangle135,135);
	
	mapTriangle45 = map_new(cTileSize,cTileSize,8);
	draw_triangle(mapTriangle45,45);
	
	mapSolidOnFall = map_new(cTileSize,cTileSize,8);
	draw_SolidOnFall(mapSolidOnFall);
	
	//iniciamos juego
	game.playerTries 	= 3;
	game.playerLife 	= 3;
	game.playerMaxLife  = 3;
	game.score      	= 0;
	
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
		
		//contador de reloj por frames.A 60 fps = 16ms 
		clockCounter++;
		
		//Flanco de reloj segun intervalo escogido
		if (clockCounter % cTimeInterval == 0) 
			if (!clockTickMem)
				clockTick = true;
				clockTickMem = true;
			end;
		else
			clockTick = false;
			clockTickMem = false;
		end;
		
		//activacion/desactivacion del modo debug
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
		
		//pausa del juego
		if (WGE_Key(K_PAUSE,KEY_DOWN))
			if (game.paused)
				signal(idPlayer,s_wakeup);
				signal(type objeto,s_wakeup);
				signal(type plataforma,s_wakeup);
				signal(type monster,s_wakeup_tree);
				delete_text(pauseText);
				game.paused = false;
			else
				signal(idPlayer,s_freeze);
				signal(type objeto,s_freeze);
				signal(type plataforma,s_freeze);
				signal(type monster,s_freeze_tree);
				pauseText = write(0,cResx>>1,cResy>>1,ALIGN_CENTER,"-Paused-");
				game.paused = true;
			end;
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
			//Pintamos los puntos de deteccion del jugador
			if (idPlayer<>0)
				for (i=0;i<cNumColPoints;i++)			
					//debugColPoint(idPlayer.fx+idPlayer.colPoint[i].x,idPlayer.fy+idPlayer.colPoint[i].y);
					debugColPoint(idPlayer,i);
				end;
			end;
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
		
		//Control estado de teclas
		keyUse ^= 1;
        for ( i = 0; i < 127; i++ )
            keyState[ i ][ keyUse ] = key( i );
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
private
	int i; //variable auxiliar
begin
	//Limpiamos la memoria dinamica
	free(objetos);
	free(paths);
	free(tileMap);
	
	//liberamos archivos cargados
	unload_fpg(level.fpgTiles);
	
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
		
	drawing_alpha(cTransLevel);
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
	objetos = calloc(level.numObjects ,sizeof(_objeto));
	//comprobamos el direccionamiento dinamico
	if ( objetos == NULL )
		log("Fallo alocando memoria dinámica (objetos)");
		WGE_Quit();
	end;
	
	//Leemos los datos de los objetos
	for (i=0;i<level.numObjects;i++)
			fread(levelFile,objetos[i].tipo);
			fread(levelFile,objetos[i].grafico);
			fread(levelFile,objetos[i].x0);
			fread(levelFile,objetos[i].y0); 
			fread(levelFile,objetos[i].angulo);
			for (j=0;j<cMaxObjParams;j++)
				fread(levelFile,objetos[i].param[j]);
			end;
	end; 
	
	//Leemos numero de paths
	log("Leyendo Paths Nivel");
	fread(levelFile,level.numPaths);
	//Asignamos tamaño dinamico al array de paths
	paths = calloc(level.numPaths , sizeof(_path));
	//comprobamos el direccionamiento dinamico
	if ( paths == NULL )
		log("Fallo alocando memoria dinámica (paths)");
		WGE_Quit();
	end;
	//Leemos los datos de los trackings	
	for (i=0;i<level.numPaths;i++)
			//Leemos numero de puntos
			fread(levelFile,paths[i].numPuntos);
			//Asignamos tamaño dinamico al array de puntos
			paths[i].punto = calloc(paths[i].numPuntos,sizeof(_point));
			//comprobamos el direccionamiento dinamico
			if ( paths[i].punto == NULL )
				log("Fallo alocando memoria dinámica (paths["+i+"])");
				WGE_Quit();
			end;
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
Function WGE_LoadMapLevel(string file_,string fpgFile)
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
	//Primera dimension
	tileMap = calloc(level.numTilesY,sizeof(_tile*));
	//comprobamos el direccionamiento
	if ( tileMap == NULL )
		log("Fallo alocando memoria dinámica (tileMap)");
		WGE_Quit();
	end;
	//segunda dimension
	from i = 0 to level.numTilesY-1;
		tileMap[i] = calloc(level.numTilesX ,sizeof(_tile));
		//comprobamos el direccionamiento
		if ( tileMap[i] == NULL )
			log("Fallo alocando memoria dinámica (tileMap["+i+"])");
			WGE_Quit();
		end;	
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
				tileMap[i][j].tileShape = isBitSet(mapTileCode,BIT_TILE_SHAPE);
				tileMap[i][j].tileProf 	= isBitSet(mapTileCode,BIT_TILE_DELANTE);
				tileMap[i][j].tileAlpha = isBitSet(mapTileCode,BIT_TILE_ALPHA);
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

	//Comprobamos si existe el archivo grafico de tiles
	if (fexists(fpgFile))
		level.fpgTiles = fpg_load(fpgFile);
		log("Archivo fpg de tiles leído correctamente");
	else
		log("No existe el fichero fpg de tiles: " + fpgFile);
		log("Activamos graficos Debug");
		level.fpgTiles = -1;
	end;
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
							1,0,0,1,0,0,0,0,1,0,0,0,0,1,1,0,0,0,0,0,1,
							1,0,0,0,0,1,0,0,0,0,0,0,0,0,0,0,1,1,0,0,1,
							1,0,1,6,1,1,0,0,15,1,14,0,0,0,0,0,0,0,0,0,1,
							1,0,1,5,1,0,0,15,1,1,1,14,0,0,0,0,0,0,1,1,1,
							1,0,0,5,0,0,15,1,1,1,1,1,14,0,0,9,9,0,0,0,1,
							1,0,0,5,0,15,1,1,1,1,1,1,1,14,0,0,0,0,0,1,1,
							1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1;
	/*
	int matrixMap[8][20] = 	1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,
							1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,
							1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,
							1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,
							1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,
							1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,
							1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,
							1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,
							1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1;
	*/
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
	for (i=((y_inicial/cTileSize)-cTilesYOffScreen);i<(((cRegionH+y_inicial)/cTileSize)+cTilesYOffScreen);i++)
		for (j=((x_inicial/cTileSize)-cTilesXOffScreen);j<(((cRegionW+x_inicial)/cTileSize)+cTilesXOffScreen);j++)
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

//Proceso tile
//Se crea en la posicion inicial definida e ira comprobando si se sale por la pantalla
//para redibujarse en el otro extremo de la pantalla con el grafico correspondiente.
//y con las propiedades de tile correspondientes.
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
	priority = cTilePrior;
	file = level.fpgTiles;
	
	//modo sin graficos
	if (file<0)
		graph = map_new(alto,ancho,8);
	end;
	
	//establecemos su posicion inicial
	x = (j*cTileSize)+cHalfTSize;
	y = (i*cTileSize)+cHalfTSize;
	
	loop
				
		//Si el tile desaparece por la izquierda
		if (scroll[0].x0 > (x+(cTileSize*cTilesXOffScreen)) )	
			//nueva posicion:a la derecha del tile de offscreen (que pasa a ser onscreen)
			//Se multiplica por 2 porque tenemos tiles offscreen a ambos lados
			i=i;
			j=j+(cRegionW/cTileSize)+(cTilesXOffScreen*2);
			  
			log("Paso de izq a der "+i+","+j);
			redraw = 1;
		end;
		
		
		//Si sale el tile por la derecha
		if ((scroll[0].x0+cRegionW)< (x-(cTileSize*cTilesXOffScreen)))
			//nueva posicion:a la derecha del tile de offscreen (que pasa a ser onscreen)
			//Se multiplica por 2 porque tenemos tiles offscreen a ambos lados
			i=i;
			j=j-(cRegionW/cTileSize)-(cTilesXOffScreen*2);
			
			log("Paso de der a izq "+i+","+j);
			redraw = 1;
		end;
		
		
		//Si sale por arriba
		if (scroll[0].y0 > (y+(cTileSize*cTilesYOffScreen)) )
			//nueva posicion
			i=i+(cRegionH/cTileSize)+(cTilesYOffScreen*2);
			j=j;       
			
			log("Paso de arrib a abaj "+i+","+j);
			redraw = 1;
		end;
		
		//Si sale por abajo
		if ((scroll[0].y0+cRegionH) < (y-(cTileSize*cTilesYOffScreen))) 
			//nueva posicion
			i=i-(cRegionH/cTileSize)-(cTilesYOffScreen*2);
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
				
				//Dibujamos su grafico (o una caja si no hay archivo)
				if (file>=0)
					graph = tileMap[i][j].tileGraph;
				else
					tileColor = tileMap[i][j].tileGraph;
				end;
				
				//Establecemos sus propiedades segun TileCode
				if (tileMap[i][j].tileShape)
					flags &= ~ B_NOCOLORKEY;	
				else
					flags |= B_NOCOLORKEY;
				end;
				if (tileMap[i][j].tileAlpha)
					alpha = cTransLevel;		
				else
					alpha = 255;
				end;
				if (tileMap[i][j].tileProf)
					z = cZMap2;
				else
					z = cZMap1;
				end;
			else
				//tile no existente
				graph = 0;
				tileColor = 255; 
			end;
			
			//si no tiene archivo de tiles,dibujamos un grafico
			if (file<0)
				debugDrawTile(id,tileColor,i,j);
			end;
			
			//en modo debug, escribimos su posicion
			if (debugMode)
				set_text_color((255-TileColor)+1);
				map_put(file,graph,write_in_map(0,i,3),ancho>>1,0);
				map_put(file,graph,write_in_map(0,j,3),ancho>>1,8);
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
	level.fpgObjects = fpg_load("test\objetos.fpg");
	level.fpgMonsters = fpg_load("test\monsters.fpg");
	
	plataforma(800,696,32,16,8,25);
	plataforma(620,729,32,16,8,25);
	plataforma(458,729,32,16,8,25);
	
	objeto(5,218,712,16,16,PICKABLE | BREAKABLE);
	objeto(5,1210,136,16,16,PICKABLE);
	
	//cycleClown(1,1250,100,32,48,0);
	monster(T_CYCLECLOWN,1250,100);
	monster(T_TOYPLANE,526,300);
	monster(T_TOYPLANECONTROL,526,320);
	
	objeto(4,550,300,16,16,ITEM_BIG_COIN | PICKABLE | BREAKABLE);
	objeto(4,570,300,16,16,ITEM_STAR | PICKABLE | BREAKABLE);
	
	//creamos los objetos del nivel
	//for (i=0;i<level.numObjects;i++) 
		//crea_objeto(i,1);
	//end;
			
	//creamos los enemigos del nivel
	//crea_enemigo(x);
	
	//if (C_AHORRO_OBJETOS)control_sectores();end;
	          
End;

process WGE_ControlScroll()
	
begin
	priority = cScrollPrior;
	
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

//Funcion que comprueba si una posicion del tile existe en el mapa
function int tileExists(int posY,int posX)
begin

	Return (posY<level.numTilesY && posX<level.numTilesX && posY>=0 && posX>=0);
end;

//Funcion que comprueba, segun el codigo del tile, el comportamiento de la colision segun la direccion
//Devuelve 1 si colisiona en esa direccion o 0 si no colisiona.
function int checkTileCode(entity idObject,int colDir,int posY,int posX)
begin
	switch(colDir)
		//Colisiones superiores
		case COLUP:
			return tileMap[posY][posX].tileCode == SOLID;
		end;
		//Colisiones inferiores
		case COLDOWN,COLCENTER:
			return tileMap[posY][posX].tileCode == SOLID     ||
				   tileMap[posY][posX].tileCode == SLOPE_135 ||
				   tileMap[posY][posX].tileCode == SLOPE_45  ||
			      (tileMap[posY][posX].tileCode == SOLID_ON_FALL && idObject.vY>0) ||
				  (tileMap[posY][posX].tileCode == TOP_STAIRS && idObject.vY>0);
			/*return ((tileMap[posY][posX].tileCode <> SOLID_ON_FALL) && (tileMap[posY][posX].tileCode <> STAIRS) ) || 
			        (tileMap[posY][posX].tileCode == SOLID_ON_FALL && idObject.vY>0) ||
					(tileMap[posY][posX].tileCode == STAIRS && idObject.onStairs);*/
				   
		end;
		//Colisiones lateral izquierdas
		case COLIZQ:
			return tileMap[posY][posX].tileCode == SOLID;
		end;
		//Colisiones lateral derechas
		case COLDER:
			return tileMap[posY][posX].tileCode == SOLID;;
		end;
	end;
end;

//funcion que devuelve el codigo de Tile de un punto de colision
function int getTileCode(entity idObject,int pointType)
begin
	//sumamos la posicion del objeto al punto de colision
	x = idObject.x + idObject.colPoint[pointType].x;
	y = idObject.y + idObject.colPoint[pointType].y;
	
	//comprobamos si existe en el mapeado
	if (!tileExists(y/cTileSize,x/cTileSize))
		return 0;
	else
		//devolvemos el tileCode
		return tileMap[y/cTileSize][x/cTileSize].tileCode;
	end;
end;

function int round(float number)
private
	int trunc;
begin
	trunc = number;
	if ((number - trunc) > 0.5)
		return trunc+1;
	else
		return trunc;
	end;
end;

//Escalamos la posicion de floats en enteros
//si la diferencia entre el float y el entero es una unidad
function positionToInt(entity idObject)
begin
	if (abs(idObject.fX-idObject.x) >= 1 ) 
		//redondeamos el valor a entero
		idObject.x = round(idObject.fX);
	end;
	//en vertical,la asignacion es directa	
	idObject.y = idObject.fY;
end;

//Funcion que devuelve el estado de la tecla solicitado
function WGE_Key(int k,int event)
begin
return ((event==KEY_DOWN)?(  keyState[ k ][ keyUse ] && !keyState[ k ][ keyUse ^ 1 ] ): \
		(event==KEY_UP  )?( !keyState[ k ][ keyUse ] &&  keyState[ k ][ keyUse ^ 1 ] ): \
		( keyState[ k ][ keyUse ]));
end;

//Funcion para reiniciar el nivel actual
function WGE_RestartLevel()
begin
	log("Reiniciando nivel");
	
	//apagamos pantalla
	fade_off();
	repeat
		frame;
	until (not fading);
	log("detenemos scroll");
	//detenemos el control del scroll
	signal(TYPE WGE_ControlScroll,s_kill);
	log("eliminamos tiles");
	//eliminamos los tiles de la pantalla
	signal(TYPE pTile,s_kill);
	log("eliminamos objetos");
	//eliminamos los objetos de la pantalla
	signal(TYPE objeto,s_kill_tree);
	log("eliminamos items");
	//eliminamos los items
	signal(TYPE item,s_kill_tree);
	log("eliminamos plataformas");
	//eliminamos plataformas
	signal(TYPE plataforma,s_kill_tree);
	log("eliminamos al jugador");
	//eliminamos al jugador
	signal(idPlayer,s_kill_tree);
	idPlayer = 0;
	log("eliminamos enemigos");
	//eliminamos a los enemigos
	signal(TYPE monster,s_kill_tree);
	//actualizamos
	frame;
	
	//arrancamos el control de scroll
	WGE_ControlScroll();
	//dibujamos el mapa
	WGE_DrawMap();
	//creamos el nivel
	WGE_CreateLevel();
	//creamos al player
	player();
	//esperamos un tiempo
	WGE_Wait(50);
	
	//encendemos pantalla
	fade_on();
	repeat
		frame;
	until (not fading);
end;