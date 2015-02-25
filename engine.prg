// ========================================================================
//  Warcom Game Engine
//  Motor para juegos plataformas 2D
//  21/07/14
//
//  Funcion Motor Principal
// ========================================================================

//Tareas de inicializacion del engine
function WGE_Init()
begin
	         
	
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
	
	//iniciamos variables juego
	game.playerTries 	= 3;
	game.playerLife 	= 3;
	game.playerMaxLife  = 3;
	game.score      	= 0;
	game.numLevel       = 0;
	game.state          = SPLASH;
	
	//Archivos de los niveles
	//level 0
	levelFiles[0].MapFile 	= "test\ToyLand.bin";
	levelFiles[0].DataFile 	= "test\random.dat";
	levelFiles[0].TileFile 	= "test\tiles.fpg";
	//level 1
	levelFiles[1].MapFile 	= "test\ToyLand.bin";
	levelFiles[1].DataFile 	= "test\random.dat";
	levelFiles[1].TileFile 	= "test\tiles.fpg";
	
	//archivo del player
	fpgPlayer = fpg_load("test\player.fpg");
	
	//Iniciamos modo grafico
	WGE_InitScreen();
	
	//Arrancamos el loop del juego
	WGE_Loop();
	
	//Arrancamos rutinas debug si esta definido
	#ifdef USE_DEBUG
		WGE_Debug();
	#endif
end;

//Bucle principal del engine que controla el juego
process WGE_Loop()
private
	int i; 									//Variables auxiliares
	byte clockTickMem;						//Memoria Flanco Reloj
	int pauseText;
	int idDeadPlayer;						//id del proceso muerte del player
begin
	priority = cMainPrior;
	
	loop
		//estado del juego
		switch (game.state)
			case SPLASH:
				//apagamos pantalla
				fade(0,0,0,cFadeTime);
				while(fading) frame; end;
				
				game.state = LOADLEVEL;
			end;
			case MENU:
			end;
			case LOADLEVEL:
				//Creamos datos nivel aleatorios
				//WGE_GenLevelData("test\random.dat");
				//Cargamos archivo nivel
				//WGE_LoadLevel("test\random.dat");
				//Creamos un mapa aleatorio
				//WGE_GenRandomMapFile("test\random.bin",12,8);
				//Creamos un mapa con matriz definida
				//WGE_GenMatrixMapFile("test\random.bin");
				//Cargamos el mapeado del nivel
				WGE_LoadMapLevel(levelFiles[game.numLevel].MapFile,levelFiles[game.numLevel].TileFile);
				//Iniciamos Scroll
				WGE_InitScroll();
				//Dibujamos el mapeado
				WGE_DrawMap();
				//Creamos el nivel cargado
				WGE_CreateLevel();
				
				//Creamos el jugador
				player();
				
				//procesos congelados
				gameSignal(s_freeze_tree);
				
				//encendemos pantalla
				fade(100,100,100,cFadeTime);
				while(fading) frame; end;
				
				//se despiertan los procesos
				gameSignal(s_wakeup_tree);
				
				game.state = PLAYLEVEL;
			end;
			case PLAYLEVEL:
				
				//pausa del juego
				if (WGE_Key(K_PAUSE,KEY_DOWN))
					if (game.paused)
						gameSignal(s_wakeup_tree);
						delete_text(pauseText);
						game.paused = false;
					else
						gameSignal(s_freeze_tree);
						pauseText = write(0,cResx>>1,cResy>>1,ALIGN_CENTER,"-Paused-");
						game.paused = true;
					end;
				end;
				
				//fin del nivel actual
				if (game.endLevel)
					game.state = LEVELENDED;
				end;
				
				//muerte del jugador por perdida energia
				if (game.playerLife == 2 && idPlayer.state != HURT_STATE)
					//creamos el proceso/animacion muerte
					idDeadPlayer = deadPlayer();
					//matamos al player
					signal(idPlayer,s_kill);
					idPlayer = 0;
					//restamos una vida
					game.playerTries --;
					
					//esperamos a que el proceso muerte desaparezca de pantalla
					while(exists(idDeadPlayer))
						frame;
					end;
					//congelamos los procesos
					gameSignal(s_freeze_tree);
					//esperamos un tiempo
					WGE_Wait(100);
					
					//GameOver por perdida de vidas
					if (game.playerTries == 2 )
						game.state = GAME_OVER;
					else
						//reiniciamos el nivel
						game.state = RESTARTLEVEL;
					end;
				end;
			end;
			case RESTARTLEVEL:
				log("Reiniciando nivel",DEBUG_ENGINE);
				
				//apagamos pantalla
				fade(0,0,0,cFadeTime);
				while(fading) frame; end;
				
				//detenemos los procesos
				gameSignal(s_kill_tree);
				idPlayer = 0;
					
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
				fade(100,100,100,cFadeTime);
				while(fading) frame; end;
				
				//variables de inicio de nivel
				game.playerLife = 3;
				
				game.state = PLAYLEVEL;
				
			end;
			case LEVELENDED:
				log("finalizando nivel",DEBUG_ENGINE);
				
				//bajamos el flag
				game.endLevel = false;
				//congelamos durante la melodia de fin a los procesos
				gameSignal(s_freeze_tree);
				WGE_Wait(100);
				
				//apagamos pantalla
				fade(0,0,0,cFadeTime);
				while(fading) frame; end;
				
				clearLevel();
				
				game.numLevel++;
				
				game.state = LOADLEVEL;
			end;
			case GAME_OVER:
				//apagamos pantalla
				fade(0,0,0,cFadeTime);
				while(fading) frame; end;
				//matamos los procesos
				gameSignal(s_kill_tree);
				//encendemos pantalla
				fade(100,100,100,cFadeTime);
				while(fading) frame; end;
				//mensaje hasta pulsar tecla
				write(0,cResx>>1,cResy>>1,ALIGN_CENTER,"GAME OVER");
				repeat
					frame;
				until(key(_ENTER));
				//salimos del juego (TEMPORAL)
				WGE_Quit();
			end;
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
		
		//Control estado de teclas
		keyUse ^= 1;
        for ( i = 0; i < 127; i++ )
            keyState[ i ][ keyUse ] = key( i );
        end;
		
		frame;
	end;

end;

//Inicializaci�n del modo grafico
function WGE_InitScreen()
begin
	//Complete restore para evitar "flickering" (no funciona)
	restore_type = COMPLETE_RESTORE;
	scale_mode=SCALE_NORMAL2X; 
	set_mode(cResX,cResY,8);
	//set_mode(992,600,8);
	set_fps(cNumFPS,0);
	
	log("Modo Grafico inicializado",DEBUG_ENGINE);
end;

//Definicion Region y Scroll
function WGE_InitScroll()
begin
	define_region(cGameRegion,cRegionX,cRegionY,cRegionW,cRegionH);
	//define_region(cGameRegion,cRegionX,cRegionY,992,600);
	//Caida de frames radical si el mapa del scroll es peque�o (por tener que repetirlo?)
	start_scroll(cGameScroll,0,map_new(cRegionW,cRegionH,8),0,cGameRegion,3);
	
	scroll[cGameScroll].ratio = 100;
	log("Scroll creado",DEBUG_ENGINE);
	
	WGE_ControlScroll();

end;

//Desactivaci�n del engine y liberacion de memoria
function WGE_Quit()
private
	int i; //variable auxiliar
begin
	//descargamos el nivel
	clearLevel();
	
	//descargamos archivos globales
	unload_fpg(fpgPlayer);
	
	//borramos todos los textos
	delete_text(all_text);
	
	log("Se finaliza la ejecuci�n",DEBUG_ENGINE);
	log("FPS Max: "+maxFPS,DEBUG_ENGINE);
	log("FPS Min: "+minFPS,DEBUG_ENGINE);
	
	exit();
		
end;

//Funcion que setea el modo alpha.Solo se usa cuando se necesita porque
//demora unos segundos generar las tablas de transparencia
process WGE_InitAlpha()
begin
	log("Activando modo alpha",DEBUG_ENGINE);
		
	drawing_alpha(cTransLevel);
	drawing_alpha(255);
	
	log("Modo alpha activado",DEBUG_ENGINE); 
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
		log("No existe el fichero: " + file_,DEBUG_ENGINE);
		WGE_Quit();
	end;
	
	//Abrimos el archivo
	levelFile = fopen(file_,o_read);
	//Nos situamos al principio del archivo
	fseek(levelFile,0,SEEK_SET);  
	
	//Leemos icion inicial jugador
	log("Leyendo datos nivel",DEBUG_ENGINE);
	fread(levelFile,level.playerX0); 
	fread(levelFile,level.playerY0);
	
	//Leemos numero de objetos
	log("Leyendo objetos nivel",DEBUG_ENGINE);
	fread(levelFile,level.numObjects);
	
	//Asignamos tama�o dinamico al array de objetos
	objetos = calloc(level.numObjects ,sizeof(_objeto));
	//comprobamos el direccionamiento dinamico
	if ( objetos == NULL )
		log("Fallo alocando memoria din�mica (objetos)",DEBUG_ENGINE);
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
	log("Leyendo Paths Nivel",DEBUG_ENGINE);
	fread(levelFile,level.numPaths);
	//Asignamos tama�o dinamico al array de paths
	paths = calloc(level.numPaths , sizeof(_path));
	//comprobamos el direccionamiento dinamico
	if ( paths == NULL )
		log("Fallo alocando memoria din�mica (paths)",DEBUG_ENGINE);
		WGE_Quit();
	end;
	//Leemos los datos de los trackings	
	for (i=0;i<level.numPaths;i++)
			//Leemos numero de puntos
			fread(levelFile,paths[i].numPuntos);
			//Asignamos tama�o dinamico al array de puntos
			paths[i].punto = calloc(paths[i].numPuntos,sizeof(_point));
			//comprobamos el direccionamiento dinamico
			if ( paths[i].punto == NULL )
				log("Fallo alocando memoria din�mica (paths["+i+"])",DEBUG_ENGINE);
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
	log("Fichero nivel le�do con " + level.numObjects + " Objetos y " + level.numPaths + " Paths",DEBUG_ENGINE);	
	
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
		log("Borramos el archivo DataLevel anterior",DEBUG_ENGINE);
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
	log("Fichero nivel creado",DEBUG_ENGINE);	
	
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
		log("No existe el fichero de mapa: " + file_,DEBUG_ENGINE);
		WGE_Quit();
	end;
	
	//leemos el archivo de mapa
	levelMapFile = fopen(file_,O_READ);
			
	//Nos situamos al principio del archivo
	fseek(levelMapFile,0,SEEK_SET);  
		
	//Leemos datos del mapa
	log("Leyendo datos archivo del mapa",DEBUG_ENGINE);
	
	fread(levelMapFile,level.numTiles); 	//cargamos el numero de tiles que usa el mapa
	fread(levelMapFile,level.numTilesX);   //cargamos el numero de columnas de tiles
	fread(levelMapFile,level.numTilesY);   //cargamos el numero de filas de tiles
	
	
	//Creamos la matriz dinamica del tileMap
	//Primera dimension
	tileMap = calloc(level.numTilesY,sizeof(_tile*));
	//comprobamos el direccionamiento
	if ( tileMap == NULL )
		log("Fallo alocando memoria din�mica (tileMap)",DEBUG_ENGINE);
		WGE_Quit();
	end;
	//segunda dimension
	from i = 0 to level.numTilesY-1;
		tileMap[i] = calloc(level.numTilesX ,sizeof(_tile));
		//comprobamos el direccionamiento
		if ( tileMap[i] == NULL )
			log("Fallo alocando memoria din�mica (tileMap["+i+"])",DEBUG_ENGINE);
			WGE_Quit();
		end;	
	end;
	
	//Cargamos la informacion del grafico de los tiles del fichero de mapa
	for (i=0;i<level.numTilesY;i++)
		for (j=0;j<level.numTilesX;j++)
			if (fread(levelMapFile,tileMap[i][j].tileGraph)  == 0)
				log("Fallo leyendo grafico de tiles ("+j+","+i+") en: " + file_,DEBUG_ENGINE);
				WGE_Quit();
			end;
		end;
	end;
	
	//Cargamos el codigo de los tiles del fichero de mapa
	mapUsesAlpha = 0;	//seteamos que no usuara propiedad alpha el mapa
	
	for (i=0;i<level.numTilesY;i++)
		for (j=0;j<level.numTilesX;j++)
			if (fread(levelMapFile,mapTileCode) == 0)
				log("Fallo leyendo codigo de tiles ("+j+","+i+") en: " + file_,DEBUG_ENGINE);
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
	log("Fichero mapa le�do con " + level.numTiles + " Tiles. " + level.numTilesX + " Tiles en X y " + level.numTilesY + " Tiles en Y",DEBUG_ENGINE);   

	//Comprobamos si existe el archivo grafico de tiles
	if (fexists(fpgFile))
		level.fpgTiles = fpg_load(fpgFile);
		log("Archivo fpg de tiles le�do correctamente",DEBUG_ENGINE);
	else
		log("No existe el fichero fpg de tiles: " + fpgFile,DEBUG_ENGINE);
		log("Activamos graficos Debug",DEBUG_ENGINE);
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
		log("Borramos el archivo MapData anterior",DEBUG_ENGINE);
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
	log("Fichero mapa aleatorio creado",DEBUG_ENGINE);   
	
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
		log("Borramos el archivo MapData anterior",DEBUG_ENGINE);
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
	log("Fichero mapa aleatorio creado",DEBUG_ENGINE);   
	
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
			log("Creado tile: "+i+" "+j,DEBUG_TILES);
			numTilesDraw++;
		end;
	end;

	log("Mapa dibujado correctamente. Creados "+numTilesDraw+" tiles",DEBUG_ENGINE);
	
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
			  
			log("Paso de izq a der "+i+","+j,DEBUG_TILES);
			redraw = 1;
		end;
		
		
		//Si sale el tile por la derecha
		if ((scroll[0].x0+cRegionW)< (x-(cTileSize*cTilesXOffScreen)))
			//nueva posicion:a la derecha del tile de offscreen (que pasa a ser onscreen)
			//Se multiplica por 2 porque tenemos tiles offscreen a ambos lados
			i=i;
			j=j-(cRegionW/cTileSize)-(cTilesXOffScreen*2);
			
			log("Paso de der a izq "+i+","+j,DEBUG_TILES);
			redraw = 1;
		end;
		
		
		//Si sale por arriba
		if (scroll[0].y0 > (y+(cTileSize*cTilesYOffScreen)) )
			//nueva posicion
			i=i+(cRegionH/cTileSize)+(cTilesYOffScreen*2);
			j=j;       
			
			log("Paso de arrib a abaj "+i+","+j,DEBUG_TILES);
			redraw = 1;
		end;
		
		//Si sale por abajo
		if ((scroll[0].y0+cRegionH) < (y-(cTileSize*cTilesYOffScreen))) 
			//nueva posicion
			i=i-(cRegionH/cTileSize)-(cTilesYOffScreen*2);
			j=j;       
					
			log("Paso de abajo a arriba "+i+","+j,DEBUG_TILES);
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
	
	object(5,218,712,16,16,PICKABLE | BREAKABLE);
	object(5,1210,136,16,16,PICKABLE);
	
	//cycleClown(1,1250,100,32,48,0);
	monster(T_CYCLECLOWN,1250,100);
	monster(T_TOYPLANE,526,300);
	monster(T_TOYPLANECONTROL,526,320);
	
	object(4,550,300,16,16,ITEM_BIG_COIN | PICKABLE | BREAKABLE);
	object(4,570,300,16,16,ITEM_STAR | PICKABLE | BREAKABLE);
	
	item(1996,257,16,16,GEM);
	
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
		
		//Si el jugador ya est� en ejecuci�n, lo enfocamos
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


//funcion que actualiza las velocidades y la posicion de un proceso
function updateVelPos(entity idObject,byte grounded)
begin
	//Actualizar velocidades
	if (grounded)
		idObject.vY = 0;
	end;
	
	//actualizar posiciones
	idObject.fx += idObject.vX;
	idObject.fy += idObject.vY;
	
	positionToInt(idObject);
end;

//funcion que envia signals a los tipos del juego
function gameSignal(int _signal)
begin
	signal(TYPE WGE_ControlScroll,_signal);
	signal(TYPE pTile,_signal);
	if (idPlayer <> 0 ) 
		signal(idPlayer,_signal);
	end;
	signal(type object,_signal);
	signal(type plataforma,_signal);
	signal(type monster,_signal);
	signal(type item,_signal);
end;

//funcion para limpiar y descargar archivos del nivel actual
function clearLevel()
begin
	gameSignal(s_kill_tree);
	idPlayer = 0;
	
	//Limpiamos la memoria dinamica
	free(objetos);
	free(paths);
	free(tileMap);
	
	//liberamos archivos cargados
	unload_fpg(level.fpgTiles);
	unload_fpg(level.fpgObjects);
	unload_fpg(level.fpgMonsters);
	
end;