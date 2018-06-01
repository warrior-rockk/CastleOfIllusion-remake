// ========================================================================
//  Warcom Game Engine
//  Motor para juegos plataformas 2D
//  21/07/14
//
//  Funcion Motor Principal
// ========================================================================

//Tareas de inicializacion del engine
function wgeInit()
begin
	
	//Dibujamos mapas que componen las distintas figuras de tile
	//que se usarán para comprobar las durezas de colision
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
	
	
	//Cargamos la configuracion del juego
	loadGameConfig();
	
	//Cargamos los textos del juego
	loadGameLang();
	
	//Arrancamos el reloj del juego
	wgeClock();
	
	//Llamomos a updateControls
	wgeUpdateControls();
	
	//Arrancamos rutinas debug si esta definido
	#ifdef USE_DEBUG
		wgeDebug();
	#endif
end;

//funcion que gestiona el flanco de reloj
process wgeClock()
private
	byte clockTickMem;						//Memoria Flanco Reloj
begin
	loop
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
		
		frame;
	end;
end;

//Inicialización del modo grafico
function wgeInitScreen()
begin
	//Complete restore para evitar "flickering" (no funciona)
	//hay un bug con una combinacion de scalemode y restore_type. Si no pongo complete restore y
	//uso scale mode, se cuelga al pasar al modo debug por ejemplo
	restore_type  = COMPLETE_RESTORE; //no provoca diferencia de fps
	//dump_type    = COMPLETE_DUMP;
	
	//hay relevancia de caída de frames segun mas grande es la resolucion de scale
	//Scale_resolution = 19201080;
	//no hay caida de frames de un modo de aspectratio al otro
	//scale_resolution_aspectratio = SRA_STRETCH; //SRA_PRESERVE
	
	//Establecemos titulo ventana
	set_title("Castle of Illusion Remake");
	
	//set_icon (mapa fpg 32x32)
	//mode_is_ok ( <INT width> , <INT height> , <INT depth>, <INT flags> )
	//POINTER get_modes ( <INT depth>, <INT flags> )
	
	//INT get_desktop_size ( <INT POINTER width>, <INT POINTER height> )
	switch (config.videoMode)
		case CONFIG_MODE_WINDOW:
			full_screen = false;
			scale_mode=SCALE_NONE;
		end;
		case CONFIG_MODE_2XSCALE:
			scale_mode=SCALE_NORMAL2X;
		end;
		case CONFIG_MODE_FULLSCREEN:
			//scale_mode=SCALE_NORMAL2X;
			full_screen = true;
		end;
	end;
	
	//resolucion depende del modo de compilacion
	#ifdef RELEASE
		set_mode(cResX,cResY,8);
	#else
		//set_mode(cResX,300,8,MODE_WAITVSYNC);//MODE_WAITVSYNC FIJA LOS FRAMES A 60
		//set_mode(cResX,300,8);
		//setOptimalVideoMode(cResX,cResY,8,MODE_FULLSCREEN);
		set_mode(cResX,cResY,8);
	#endif
	
	//seteamos fps (rendimiento 02/09/15: 300fps)
	set_fps(60,0);
	//definimos la region del scroll
	define_region(cGameRegion,cGameRegionX,cGameRegionY,cGameRegionW,cGameRegionH);
	//definimos la region del HUD
	define_region(cHUDRegion,cHUDRegionX,cHUDRegionY,cHUDRegionW,cHUDRegionH);
	
	log("Modo Grafico inicializado",DEBUG_ENGINE);
end;

//Definicion Region y Scroll
function wgeInitScroll()
begin
	
	//Caida de frames radical si el mapa del scroll es pequeño (por tener que repetirlo?)
	start_scroll(cGameScroll,0,map_new(cGameRegionW,cGameRegionH,8),0,cGameRegion,3);
	
	scroll[cGameScroll].ratio = 100;
	log("Scroll creado",DEBUG_ENGINE);
	
	wgeControlScroll();

end;

//Desactivación del engine y liberacion de memoria
function wgeQuit()
private
	int i; //variable auxiliar
begin
	//descargamos el nivel
	clearLevel();
	
	//descargamos archivos globales
	unload_fpg(fpgGame);
	unload_fpg(fpgPlayer);
	
	//descargamos el archivo de fuente
	unload_fnt(fntGame);
	
	//borramos todos los textos
	delete_text(all_text);
	
	log("Se finaliza la ejecución",DEBUG_ENGINE);
	log("FPS Max: "+maxFPS,DEBUG_ENGINE);
	log("FPS Min: "+minFPS,DEBUG_ENGINE);
	#ifdef _VERSION
		log("Version: "+_VERSION,DEBUG_ENGINE);
	#endif
	exit();
		
end;

//Funcion que setea el modo alpha.Solo se usa cuando se necesita porque
//demora unos segundos generar las tablas de transparencia
process wgeInitAlpha()
begin
	log("Activando modo alpha",DEBUG_ENGINE);
		
	drawing_alpha(cTransLevel);
	drawing_alpha(255);
	
	log("Modo alpha activado",DEBUG_ENGINE); 
end;

//Genera in archivo de nivel aleatorio
function wgeGenLevelData(string file_)
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
Function wgeLoadMapLevel(string file_,string fpgFile)
private 
	int levelMapFile;		//Archivo del nivel
	int i,j;				//Indices auxiliares
	byte mapTileCode;       //Codigo leido del mapa
	
Begin
	
	//Comprobamos si existe el archivo de mapa del nivel
	if (not fexists(file_))
		log("No existe el fichero de mapa: " + file_,DEBUG_ENGINE);
		wgeQuit();
	end;
	
	//Limpiamos la memoria dinamica
	/*#ifdef DYNAMIC_MEM
		free(tileMap);
	#endif*/
	
	//liberamos archivos cargados
	if (level.fpgTiles <> 0 ) unload_fpg(level.fpgTiles); end;
	
	//leemos el archivo de mapa
	levelMapFile = fopen(file_,O_READ);
			
	//Nos situamos al principio del archivo
	fseek(levelMapFile,0,SEEK_SET);  
		
	//Leemos datos del mapa
	log("Leyendo datos archivo del mapa",DEBUG_ENGINE);
	
	fread(levelMapFile,level.numTiles); 	//cargamos el numero de tiles que usa el mapa
	fread(levelMapFile,level.numTilesX);   //cargamos el numero de columnas de tiles
	fread(levelMapFile,level.numTilesY);   //cargamos el numero de filas de tiles
	
	log("Fichero mapa leído con " + level.numTiles + " Tiles. " + level.numTilesX + " Tiles en X y " + level.numTilesY + " Tiles en Y",DEBUG_ENGINE);
	
	//Creamos la matriz dinamica del tileMap
	#ifdef DYNAMIC_MEM
		//Primera dimension
		tileMap = calloc(level.numTilesY,sizeof(_tile));
		
		//comprobamos el direccionamiento
		if ( tileMap == NULL )
			log("Fallo alocando memoria dinámica (tileMap)",DEBUG_ENGINE);
			wgeQuit();
		end;
		//segunda dimension
		from i = 0 to level.numTilesY-1;
			tileMap[i] = calloc(level.numTilesX ,sizeof(_tile));
			//comprobamos el direccionamiento
			if ( tileMap[i] == NULL )
				log("Fallo alocando memoria dinámica (tileMap["+i+"])",DEBUG_ENGINE);
				wgeQuit();
			end;	
		end;
		log("Memoria dinamica para mapa asignada correctamente",DEBUG_ENGINE);
	#endif
	
	//Cargamos la informacion del grafico de los tiles del fichero de mapa
	for (i=0;i<level.numTilesY;i++)
		for (j=0;j<level.numTilesX;j++)
			if (fread(levelMapFile,tileMap[i][j].tileGraph)  == 0)
				log("Fallo leyendo grafico de tiles ("+j+","+i+") en: " + file_,DEBUG_ENGINE);
				wgeQuit();
			end;
			//comprobamos si tiene animacion
			if (tileMap[i][j].tileGraph > 128)
				tileMap[i][j].numAnimation = (255 - tileMap[i][j].tileGraph)+1;
			end;
		end;
		
	end;
	log("Cargados numeros graficos del mapa",DEBUG_ENGINE);
	
	//Cargamos el codigo de los tiles del fichero de mapa
	mapUsesAlpha = 0;	//seteamos que no usuara propiedad alpha el mapa
	
	for (i=0;i<level.numTilesY;i++)
		for (j=0;j<level.numTilesX;j++)
			if (fread(levelMapFile,mapTileCode) == 0)
				log("Fallo leyendo codigo de tiles ("+j+","+i+") en: " + file_,DEBUG_ENGINE);
				wgeQuit();
			else
				//decodificamos los datos del codigo de tile a propiedades
				tileMap[i][j].tileShape = isBitSet(mapTileCode,BIT_TILE_SHAPE);
				tileMap[i][j].tileProf 	= isBitSet(mapTileCode,BIT_TILE_DELANTE);
				tileMap[i][j].tileAlpha = isBitSet(mapTileCode,BIT_TILE_ALPHA);
				tileMap[i][j].tileCode 	= mapTileCode & 31;	
				tileMap[i][j].refresh 	= false;
				
				//Comprobamos si algun tile usa alpha
				if (tileMap[i][j].tileAlpha) mapUsesAlpha = 1; end;
							
			end;
		end;
	end;  
	log("Cargados codigos del mapa",DEBUG_ENGINE);
	
	//Si algun tile usa alpha, lo inicializamos
	if (mapUsesAlpha) wgeInitAlpha(); end;
	
	//leemos numero de animaciones
	fread(levelMapFile,tileAnimations.numAnimations);
	log("Leidas "+tileAnimations.numAnimations+" animaciones del mapa",DEBUG_ENGINE);
	
	//si existe alguna animacion
	if ( tileAnimations.numAnimations > 0 )
		//Creamos la matriz dinamica de las secuencias de animacion
		#ifdef DYNAMIC_MEM
			tileAnimations.tileAnimTable = calloc(tileAnimations.numAnimations,sizeof(_tileAnimation));
			
			//comprobamos el direccionamiento
			if ( tileAnimations.tileAnimTable == NULL )
				log("Fallo alocando memoria dinámica (tileAnimations)",DEBUG_ENGINE);
				wgeQuit();
			end;
			log("Memoria dinamica para animaciones del mapa asignada correctamente",DEBUG_ENGINE);
		#endif
		
		//Cargamos las secuencias de animacion
		for (i=0;i<tileAnimations.numAnimations;i++)
			if (fread(levelMapFile,tileAnimations.tileAnimTable[i].numFrames)  == 0)
				log("Fallo leyendo numero de frames secuencia ("+i+") en: " + file_,DEBUG_ENGINE);
				wgeQuit();
			end;
			//Creamos la matriz dinamica de los graficos de los frames de animacion
			#ifdef DYNAMIC_MEM
				tileAnimations.tileAnimTable[i].frameGraph = calloc(tileAnimations.tileAnimTable[i].numFrames,sizeof(byte));
				
				//comprobamos el direccionamiento
				if ( tileAnimations.tileAnimTable.frameGraph == NULL )
					log("Fallo alocando memoria dinámica (tileAnimTable.frameGraph) en secuencia"+i,DEBUG_ENGINE);
					wgeQuit();
				end;
				log("Memoria dinamica para (tileAnimTable.frameGraph) asignada correctamente",DEBUG_ENGINE);
			#endif
			//Creamos la matriz dinamica de la duracion de cada frame de animacion
			#ifdef DYNAMIC_MEM
				tileAnimations.tileAnimTable[i].frameTime = calloc(tileAnimations.tileAnimTable[i].numFrames,sizeof(byte));
				
				//comprobamos el direccionamiento
				if ( tileAnimations.tileAnimTable.frameTime == NULL )
					log("Fallo alocando memoria dinámica (tileAnimTable.frameTime) en secuencia"+i,DEBUG_ENGINE);
					wgeQuit();
				end;
				log("Memoria dinamica para (tileAnimTable.frameTime) asignada correctamente",DEBUG_ENGINE);
			#endif
			//Cargamos los frames de la secuencia actual
			for (j=0;j<tileAnimations.tileAnimTable[i].numFrames;j++)
				if (fread(levelMapFile,tileAnimations.tileAnimTable[i].frameGraph[j])  == 0)
					log("Fallo leyendo grafico de frames secuencia ("+i+") en numero de frame ("+j+"): " + file_,DEBUG_ENGINE);
					wgeQuit();
				end;
				if (fread(levelMapFile,tileAnimations.tileAnimTable[i].frameTime[j])  == 0)
					log("Fallo leyendo duracion de frames secuencia ("+i+") en numero de frame ("+j+"): " + file_,DEBUG_ENGINE);
					wgeQuit();
				end;
			end;
		end;
		//Cargamos los codigos de tile de las animaciones
		for (i=0;i<tileAnimations.numAnimations;i++)
			if (fread(levelMapFile,tileAnimations.tileAnimTable[i].tileCode)  == 0)
				log("Fallo leyendo codigo de tile de secuencia ("+i+") + " + file_,DEBUG_ENGINE);
				wgeQuit();
			end;
		end;
	end;
	
	
	//cerramos el archivo
	fclose(levelMapFile);
	log("Fichero de mapa cerrado",DEBUG_ENGINE);   

	//Comprobamos si existe el archivo grafico de tiles
	if (fexists(fpgFile))
		level.fpgTiles = fpg_load(fpgFile);
		log("Archivo fpg de tiles leído correctamente",DEBUG_ENGINE);
	else
		log("No existe el fichero fpg de tiles: " + fpgFile,DEBUG_ENGINE);
		log("Activamos graficos Debug",DEBUG_ENGINE);
		level.fpgTiles = -1;
	end;
End;

//funcion para generar un archivo de mapa especificando numero de tiles o aleatorio (numero tiles=0)
function wgeGenRandomMapFile(string file_,int numTilesX,int numTilesY)
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
function wgeGenMatrixMapFile(string file_)
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

function wgeDrawMap()
private
	int i,j,					//Indices auxiliares
	int x_inicial,y_inicial;	//Posiciones iniciales del mapeado			
	int numTilesDraw = 0;		//Numero de tiles dibujados

Begin                    
	
	//Leemos la posicion inicial de la pantalla para dibujar
	x_inicial = scroll[cGameScroll].x0;
	y_inicial = scroll[cGameScroll].y0;
	
	numPTiles = 0;
	
	//creamos los procesos tiles segun la posicion x e y iniciales y la longitud de resolucion de pantalla
	//En los extremos de la pantalla se crean el numero definido de tiles (TILESOFFSCREEN) extras para asegurar la fluidez
	for (i=((y_inicial/cTileSize)-cTilesYOffScreen);i<(((cGameRegionH+y_inicial)/cTileSize)+cTilesYOffScreen);i++)
		for (j=((x_inicial/cTileSize)-cTilesXOffScreen);j<(((cGameRegionW+x_inicial)/cTileSize)+cTilesXOffScreen);j++)
							
			pTile(i,j);
			log("Creado tile: "+i+" "+j,DEBUG_TILES);
			numTilesDraw++;
		end;
	end;

	log("Mapa dibujado correctamente. Creados "+numTilesDraw+" tiles, "+numPTiles+" procesos",DEBUG_ENGINE);
	
	//lanzamos proceso actualizador animaciones de tiles
	wgeUpdateTileAnimations();
End;

//Proceso tile
//Se crea en la posicion inicial definida e ira comprobando si se sale por la pantalla
//para redibujarse en el otro extremo de la pantalla con el grafico correspondiente.
//y con las propiedades de tile correspondientes.
process pTile(int i,int j)
private	
	byte tileColor;		//Color del tile (modo debug)
	byte redraw = 1;	//Flag redibujar y posicionar el tile
	byte actualFrame;	//Frame actual de animacion
BEGIN
	//definimos propiedades iniciales
	this.alto = cTileSize;
	this.ancho = cTileSize;
	ctype = c_scroll;
	region = cGameRegion;
	priority = cTilePrior;
	file = level.fpgTiles;
	actualFrame = 0;
	
	//modo sin graficos
	if (file<0)
		graph = map_new(this.alto,this.ancho,8);
	end;
	
	//establecemos su posicion inicial
	x = (j*cTileSize)+cHalfTSize;
	y = (i*cTileSize)+cHalfTSize;
	
	numPTiles++;
	log("Tile:Creado tile: "+i+" "+j+" En posicion:"+x+" "+y+" con id:"+id,DEBUG_TILES);
	
	loop
				
		//Si el tile desaparece por la izquierda
		if (scroll[0].x0 > (x+(cTileSize*cTilesXOffScreen)) )	
			//nueva posicion:a la derecha del tile de offscreen (que pasa a ser onscreen)
			//Se multiplica por 2 porque tenemos tiles offscreen a ambos lados
			i=i;
			j=j+(cGameRegionW/cTileSize)+(cTilesXOffScreen*2);
			  
			log("Paso de izq a der "+i+","+j,DEBUG_TILES);
			redraw = 1;
		end;
		
		
		//Si sale el tile por la derecha
		if ((scroll[0].x0+cGameRegionW)< (x-(cTileSize*cTilesXOffScreen)))
			//nueva posicion:a la derecha del tile de offscreen (que pasa a ser onscreen)
			//Se multiplica por 2 porque tenemos tiles offscreen a ambos lados
			i=i;
			j=j-(cGameRegionW/cTileSize)-(cTilesXOffScreen*2);
			
			log("Paso de der a izq "+i+","+j,DEBUG_TILES);
			redraw = 1;
		end;
		
		
		//Si sale por arriba
		if (scroll[0].y0 > (y+(cTileSize*cTilesYOffScreen)) )
			//nueva posicion
			i=i+(cGameRegionH/cTileSize)+(cTilesYOffScreen*2);
			j=j;       
			
			log("Paso de arrib a abaj "+i+","+j,DEBUG_TILES);
			redraw = 1;
		end;
		
		//Si sale por abajo
		if ((scroll[0].y0+cGameRegionH) < (y-(cTileSize*cTilesYOffScreen))) 
			//nueva posicion
			i=i-(cGameRegionH/cTileSize)-(cTilesYOffScreen*2);
			j=j;       
					
			log("Paso de abajo a arriba "+i+","+j,DEBUG_TILES);
			redraw = 1;
		end;
		
		//Comprobaciones tile existente
		if (tileExists(i,j))
			//si se activa flag de actualizar tile
			if (tileMap[i][j].refresh)
				redraw = true;
			end;
			//gestion de animacion Tile
			if (tileMap[i][j].NumAnimation <> 0)
				//actualizamos grafico
				graph = tileAnimations.tileAnimTable[tileMap[i][j].NumAnimation-1].frameGraph[tileAnimations.tileAnimTable[tileMap[i][j].NumAnimation-1].actualFrame];
				//actualizamos codigo
				tileMap[i][j].tileCode = tileAnimations.tileAnimTable[tileMap[i][j].NumAnimation-1].tileCode;
			end;
		end;
				
		//Redibujamos el tile
		if (redraw)
			//posicion
			x = (j*cTileSize)+cHalfTSize;
			y = (i*cTileSize)+cHalfTSize;
			
			//grafico
			if (tileExists(i,j))
				//Dibujamos su grafico (o una caja si no hay archivo)
				if (file>=0)
					//comprobamos si tiene animacion
					if (tileMap[i][j].NumAnimation <> 0)
						//actualizamos grafico
						graph = tileAnimations.tileAnimTable[tileMap[i][j].NumAnimation-1].frameGraph[tileAnimations.tileAnimTable[tileMap[i][j].NumAnimation-1].actualFrame];
						//actualizamos codigo
						tileMap[i][j].tileCode = tileAnimations.tileAnimTable[tileMap[i][j].NumAnimation-1].tileCode;
					else
						graph = tileMap[i][j].tileGraph;
					end;
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
				
				//bajamos flag actualizacion
				if (tileMap[i][j].refresh) tileMap[i][j].refresh = false; end;
			else
				//tile no existente
				graph = 79; //intentando debuggear el fallo de tile en negro
				tileColor = 255; 
			end;
			
			//si no tiene archivo de tiles,dibujamos un grafico
			if (file<0)
				debugDrawTile(id,tileColor,i,j);
			end;
			
			//en modo debug, escribimos su posicion si no tiene grafico
			if (debugMode && file<0)
				set_text_color((255-TileColor)+1);
				map_put(file,graph,write_in_map(0,i,3),this.ancho>>1,0);
				map_put(file,graph,write_in_map(0,j,3),this.ancho>>1,8);
			end;
			
			//bajamos flags
			redraw = 0;		
						
		end;
		
		//Comprobacion codigos de tile
		if (tileExists(i,j))
			//si existe el player
			if (exists(idPlayer))
				//compromos la posicion y codigo de detencion X
				if (checkNoScroll(idPlayer.x,x,tileMap[i][j].tileCode))
					tileMap[i][j].tileCode == NO_SCROLL_R ? stopScrollXR = true : stopScrollXL = true;
				end;
				//comprobamos codigo detencion Y
				if (tileMap[i][j].tileCode == NO_SCROLL_Y || tileMap[i][j].tileCode == WATER ||
				    tileMap[i][j].tileCode == PORTAL_IN   || tileMap[i][j].tileCode == PORTAL_OUT )
					stopScrollY = true;
				end;
				//comprobamos Boss Zone
				if (tileMap[i][j].tileCode == BOSS_ZONE)
					game.boss = true;
				end;
				//comprobaciones portal entrada
				if (tileMap[i][j].tileCode == PORTAL_IN)
					game.teleport = true;
				end;		
				//comprobamos autoScroll
				if (tileMap[i][j].tileCode == AUTOSCROLL_R)
					level.levelFlags.autoScrollX = 1;
				end;
				//comprobamos autoScroll
				if (tileMap[i][j].tileCode == AUTOSCROLL_L)
					level.levelFlags.autoScrollX = 2;
				end;
				//comprobamos autoScroll
				if (tileMap[i][j].tileCode == AUTOSCROLL_STOP)
					//si el autoscroll es a derechas
					if (
					   (level.levelFlags.autoScrollX == 1 && scroll[cGameScroll].x0+cGameRegionW >= ((j*cTileSize)+cHalfTSize))
					   ||
					   (level.levelFlags.autoScrollX == 2 && scroll[cGameScroll].x0 <= ((j*cTileSize)-cHalfTSize))
						)
							level.levelFlags.autoScrollX = 0;
					end;
				end;
			end;
		end;
			
		//intentando debuggear fallo tile en negro
		if (tileExists(i,j) && graph == 0)
			debug;
		end;
		
		frame;
	
	end;

OnExit	
	log("Tile eliminado: "+i+","+j,DEBUG_TILES);
	numPTiles--;
end;

//funcion que cambia el grafico de un tile
function wgeReplaceTile(i,j,tileGraph)
begin
	tileMap[i][j].tileGraph = tileGraph;
	tileMap[i][j].refresh = true;
end;

//Cargamos datos del nivel
Function wgeLoadLevelData(string file_)
private 
	int levelDataFile;		//Archivo del nivel
	int i,j;				//Indices auxiliares
Begin
	
	//Comprobamos si existe el archivo de datos del nivel
	if (not fexists(file_))
		log("No existe el fichero de datos nivel: " + file_,DEBUG_ENGINE);
		wgeQuit();
	end;
	
	//leemos el archivo de mapa
	levelDataFile = fopen(file_,O_READ);
			
	//Nos situamos al principio del archivo
	fseek(levelDataFile,0,SEEK_SET);  
		
	//Leemos datos del nivel
	log("Leyendo datos archivo de datos del nivel",DEBUG_ENGINE);
	
	//posicion inicial del jugador
	fread(levelDataFile,level.playerX0); 
	fread(levelDataFile,level.playerY0);  
	
	//orientacion inicial del jugador
	fread(levelDataFile,level.playerFlags); 
	
	//tiempo del nivel
	fread(levelDataFile,level.levelTime);
	
	//numero de objetos
	fread(levelDataFile,level.numObjects);
	
	//Creamos el array dinamico de objetos
	#ifdef DYNAMIC_MEM
		objects = calloc(level.numObjects,sizeof(_object));
		
		//comprobamos el direccionamiento
		if ( objects == NULL )
			log("Fallo alocando memoria dinámica (objects)",DEBUG_ENGINE);
			wgeQuit();
		end;
		log("Memoria dinamica para objetos asignada",DEBUG_ENGINE);
	#endif
	
	//leemos los objetos
	from i=0 to level.numObjects-1;
		fread(levelDataFile,objects[i].objectType);
		fread(levelDataFile,objects[i].objectGraph);
		fread(levelDataFile,objects[i].objectX0);
		fread(levelDataFile,objects[i].objectY0);
		fread(levelDataFile,objects[i].objectAncho);
		fread(levelDataFile,objects[i].objectAlto);
		fread(levelDataFile,objects[i].objectAxisAlign);
		fread(levelDataFile,objects[i].objectFlags);
		fread(levelDataFile,objects[i].objectProps);
	end;
	log("Objetos leidos correctamente",DEBUG_ENGINE);
	
	//numero de enemigos
	fread(levelDataFile,level.numMonsters);
	
	//Creamos el array dinamico de enemigos
	#ifdef DYNAMIC_MEM
		monsters = calloc(level.numMonsters,sizeof(_monster));
		
		//comprobamos el direccionamiento
		if ( monsters == NULL )
			log("Fallo alocando memoria dinámica (monsters)",DEBUG_ENGINE);
			wgeQuit();
		end;
		log("Memoria dinamica para enemigos asignada",DEBUG_ENGINE);
	#endif
	
	//leemos los enemigos
	from i=0 to level.numMonsters-1;
		fread(levelDataFile,monsters[i].monsterType);
		fread(levelDataFile,monsters[i].monsterGraph);
		fread(levelDataFile,monsters[i].monsterX0);
		fread(levelDataFile,monsters[i].monsterY0);
		fread(levelDataFile,monsters[i].monsterAncho);
		fread(levelDataFile,monsters[i].monsterAlto);
		fread(levelDataFile,monsters[i].monsterAxisAlign);
		fread(levelDataFile,monsters[i].monsterFlags);
		fread(levelDataFile,monsters[i].monsterProps);
	end;
	log("Enemigos leidos correctamente",DEBUG_ENGINE);
	
	//numero de plataformas
	fread(levelDataFile,level.numPlatforms);
	
	//Creamos el array dinamico de plataformas
	#ifdef DYNAMIC_MEM
		platforms = calloc(level.numPlatforms,sizeof(_platform));
		
		//comprobamos el direccionamiento
		if ( platforms == NULL )
			log("Fallo alocando memoria dinámica (platforms)",DEBUG_ENGINE);
			wgeQuit();
		end;
		log("Memoria dinamica para plataformas asignada",DEBUG_ENGINE);
	#endif
	
	//leemos las plataformas
	from i=0 to level.numPlatforms-1;
		fread(levelDataFile,Platforms[i].PlatformType);
		fread(levelDataFile,Platforms[i].PlatformGraph);
		fread(levelDataFile,Platforms[i].PlatformX0);
		fread(levelDataFile,Platforms[i].PlatformY0);
		fread(levelDataFile,Platforms[i].PlatformAncho);
		fread(levelDataFile,Platforms[i].PlatformAlto);
		fread(levelDataFile,Platforms[i].PlatformAxisAlign);
		fread(levelDataFile,Platforms[i].PlatformFlags);
		fread(levelDataFile,Platforms[i].PlatformProps);
	end;
	log("Plataformas leidas correctamente",DEBUG_ENGINE);
	
	//numero de checkpoints
	fread(levelDataFile,level.numCheckPoints);
	
	//Creamos el array dinamico de checkpoints
	#ifdef DYNAMIC_MEM
		level.checkPoints = calloc(level.numCheckPoints,sizeof(_checkPoint));
		
		//comprobamos el direccionamiento
		if ( level.checkPoints == NULL )
			log("Fallo alocando memoria dinámica (checkPoints)",DEBUG_ENGINE);
			wgeQuit();
		end;
		log("Memoria dinamica para checkpoints asignada",DEBUG_ENGINE);
	#endif
	
	//leemos los checkpoints
	from i=0 to level.numCheckPoints-1;
		fread(levelDataFile,level.checkpoints[i].position.x);
		fread(levelDataFile,level.checkpoints[i].position.y);
		fread(levelDataFile,level.checkpoints[i]._flags);
	end;
	log("Checkpoints leidos correctamente",DEBUG_ENGINE);
	
	//cerramos el archivo
	fclose(levelDataFile);
	
	log("Fichero datos nivel leído correctamente:",DEBUG_ENGINE);   
	log("Leídos "+level.numObjects+" objetos",DEBUG_ENGINE);
	log("Leídos "+level.numMonsters+" enemigos",DEBUG_ENGINE);
	log("Leídos "+level.numPlatforms+" plataformas",DEBUG_ENGINE);
	log("Leídos "+level.numCheckPoints+" checkPoints",DEBUG_ENGINE);
	
End;

//Creacion de los elementos del nivel
function wgeCreateLevel()
private 
	int i;			//Indices auxiliares
end
Begin
	level.fpgObjects = fpg_load("gfx\objects.fpg");
	level.fpgMonsters = fpg_load("gfx\monsters.fpg");

	//creamos los objetos del nivel
	from i=0 to level.numObjects-1;
		object(objects[i].objectType,objects[i].objectGraph,objects[i].objectX0,objects[i].objectY0,objects[i].objectAncho,objects[i].objectAlto,objects[i].objectAxisAlign,objects[i].objectFlags,objects[i].objectProps);	
	end;
	log("Creados "+ level.numObjects +" objetos",DEBUG_ENGINE);
	
	//creamos los enemigos del nivel
	from i=0 to level.numMonsters-1;
		monster(monsters[i].monsterType,monsters[i].monsterX0,monsters[i].monsterY0,monsters[i].monsterAncho,monsters[i].monsterAlto,monsters[i].monsterAxisAlign,monsters[i].monsterFlags,monsters[i].monsterProps);	
	end;
	log("Creados "+ level.numMonsters +" enemigos",DEBUG_ENGINE);
	
	//creamos las plataformas del nivel
	from i=0 to level.numPlatforms-1;
		platform(platforms[i].platformType,platforms[i].platformGraph,platforms[i].platformX0,platforms[i].platformY0,platforms[i].platformAncho,platforms[i].platformAlto,platforms[i].platformAxisAlign,platforms[i].platformFlags,platforms[i].platformProps);		
	end;
	log("Creadas "+ level.numPlatforms +" plataformas",DEBUG_ENGINE);
	
End;

//Funcion que reinicia un nivel ya creado
function wgeRestartLevel()
private 
	int i;			//Indices auxiliares
end
Begin
	log("Se resetea el nivel",DEBUG_ENGINE);

    //detenemos los procesos
	signal(TYPE wgeControlScroll,s_kill_tree);
	signal(TYPE wgeUpdateTileAnimations,s_kill_tree);
	signal(TYPE pTile,s_kill_tree);
	if (exists(idPlayer)) 
		signal(idPlayer,s_kill);
	end;	

	//frame de sincronizacion para que desaparezcan los procesos matados
	//creo qur provocaba que se eliminaran tiles despues de crearloss
	frame(0);
	
	//limpiamos la memoria dinamica de LoadMap
	#ifdef DYNAMIC_MEM
		if (tileMap != NULL)
			free(tileMap);
			tileMap = NULL;			
		end;
		if (tileAnimations.tileAnimTable != NULL)
			free(tileAnimations.tileAnimTable);	
			tileAnimations.tileAnimTable = NULL;			
		end;
		log("Memoria dinamica de mapa liberada",DEBUG_ENGINE);
	#endif
	
	//Cargamos el mapeado del nivel por si se ha modificado en runtime
	wgeLoadMapLevel(levelFiles[game.numLevel].MapFile,levelFiles[game.numLevel].TileFile);
	//arrancamos el control de scroll
	wgeControlScroll();
	//dibujamos el mapa
	wgeDrawMap();
	
	//Reiniciamos los procesos del nivel
	restartEntityType(TYPE object);
	restartEntityType(TYPE monster);
	restartEntityType(TYPE platform);	
	
	//reiniciamos flags
	game.boss = false;
	game.bossKilled = false;
	game.teleport = false;
End;

//Proceso que controla el movimiento del scroll
process wgeControlScroll()
private
	byte doTransition;		//flag de hacer transicion
	
	int i;					//variables auxiliarles
	int j;					
begin
	priority = cScrollPrior;
	
	//Calculamos la posicion del scroll segun la posicion inicial del player
	
	//inicialmente enfocamos scroll para personaje en centro pantalla
	scroll[cGameScroll].x0 = level.playerX0 - (cGameRegionW>>1);
	
	//recorremos el zona del mapeado de la posicion inicial centrada
	//para ver si hay algun tile de ajuste de scroll
	for (i=(level.playerY0 - (cGameRegionH>>1))/cTileSize; i<(level.playerY0 + (cGameRegionH>>1))/cTileSize; i++)
		for (j=(level.playerX0 - (cGameRegionW>>1))/cTileSize; j<(level.playerX0 + (cGameRegionW>>1))/cTileSize; j++)
			//si existe el tile en el mapa
			if (tileExists(i,j))
				//Codigo NoScrollR
				if (tileMap[i][j].tileCode == NO_SCROLL_R)
					if (checkNoScroll(level.playerx0,(j*cTileSize),NO_SCROLL_R))
						//ajusto posicion X scroll al tile
						scroll[cGameScroll].x0 = ((j+1)*cTileSize)-cGameRegionW;
					end;					
				end;
				//Codigo NoScrollR
				if (tileMap[i][j].tileCode == NO_SCROLL_L)
					if (checkNoScroll(level.playerx0,(j*cTileSize),NO_SCROLL_L))
						//ajusto posicion X scroll al tile
						scroll[cGameScroll].x0 = j*cTileSize;
					end;
				end;
			end;			
		end;
	end;

	//Posicion Y depende de tener activado el RoomScroll
	if (!cRoomScroll)
		//Posicion Y para personaje en centro pantalla
		scroll[cGameScroll].y0 = level.playerY0 - (cGameRegionH>>1);	
	else
		//Posicion Y para enfoque de pantalla segun limite de region de pantalla
		scroll[cGameScroll].y0 = (cGameRegionH + (cTilesBetweenRooms*cTileSize)) * (level.playerY0 / (cGameRegionH + (cTilesBetweenRooms*cTileSize)));
	end;
	
	//inicializamos la parte float
	scrollfX = 	scroll[cGameScroll].x0;
	
	loop
		
		//movimiento del scroll
		
		//movimiento automatico si está activo
		if (level.levelflags.autoScrollX)
			//incrementamos/decrementamos la posicion float
			level.levelflags.autoScrollX == 1 ? scrollfX += cVelAutoScroll : scrollfX -= cVelAutoScroll;
		else
			//Si el jugador ya está en ejecución, lo enfocamos
			if (exists(idPlayer) )
			
				//Posicion X depende de tener activado el RoomScroll
				if (!cRoomScroll)
					//Posicion X para personaje en centro pantalla
					scroll[cGameScroll].x0 = idPlayer.x - (cGameRegionW>>1);
				else
					//Posicion X: al llegar a la mitad del primer tile izquierdo de la pantalla y que no estes al borde:transicion room
					if (idPlayer.x <= (scroll[0].x0 + (cTileSize)) && scroll[cGameScroll].x0 > 0)
						doTransition = ROOM_TRANSITION_LEFT;
					end;
					//Posicion X: al llegar a la mitad del ultimo tile izquierdo de la pantalla y que no sea el ultimo del mapa, transicion room
					if (idPlayer.x >= (scroll[0].x0 +  cGameRegionW - (cTileSize)) && (scroll[cGameScroll].x0+cGameRegionW) < (level.numTilesX*cTileSize)) 
						doTransition = ROOM_TRANSITION_RIGHT;
					end;
					//si no hay roomTransition, centramos scroll mientras no haya stopScroll o no estés en los limites para aplicarlo
					if (doTransition == 0)		
						if  (
						    (!stopScrollXR || scroll[cGameScroll].x0 >= idPlayer.x - (cGameRegionW>>1)) &&
							(!stopScrollXL || scroll[cGameScroll].x0 <= idPlayer.x - (cGameRegionW>>1))
							)
							//Posicion X para personaje en centro pantalla
							scroll[cGameScroll].x0 = idPlayer.x - (cGameRegionW>>1);
						end;
					end;
				end;
					
				//si no esta detenido el scroll Y
				if (!stopScrollY)
					//Posicion Y depende de tener activado el RoomScroll
					if (!cRoomScroll)
						//Posicion Y para personaje en centro pantalla
						scroll[cGameScroll].y0 = idPlayer.y - (cGameRegionH>>1);				
					else
						//Posicion Y: al llegar a la mitad del ultimo tile inferior de la pantalla, transicion room
						if (idPlayer.y >= (scroll[0].y0 + cGameRegionH - (cTileSize>>1)))
							doTransition = ROOM_TRANSITION_DOWN;
						end;
						//Posicion Y: al llegar a la mitad del primer tile inferior de la pantalla, transicion room
									//solo se hace transicion superior mediante escaleras
						if (idPlayer.y <= (scroll[0].y0 + (cTileSize>>1)) && idPlayer.this.state == MOVE_ON_STAIRS_STATE)
							doTransition = ROOM_TRANSITION_UP;
						end;
						//si no hay transicion vertical, ajustamos la posicion multiplo de tamaño tile
						if (doTransition <> ROOM_TRANSITION_DOWN && doTransition <> ROOM_TRANSITION_UP &&						
						    scroll[cGameScroll].y0 % cTileSize <> 0)
							if (scroll[cGameScroll].y0 % cTileSize > cHalfTSize)
								scroll[cGameScroll].y0 += cTileSize - (scroll[cGameScroll].y0 % cTileSize);
							else
								scroll[cGameScroll].y0 -= scroll[cGameScroll].y0 % cTileSize;
							end;
						end;
					end;
				end;
			end;
		end;
		
		//Ajustamos limites pantalla
		
		//Limite izquierdo
		if (scroll[cGameScroll].x0 < 0 )
			scroll[cGameScroll].x0 = 0;
			scrollfX = 	scroll[cGameScroll].x0;
		end;
		//Limite derecho
		if ((scroll[cGameScroll].x0+cGameRegionW) >= (level.numTilesX*cTileSize))
			scroll[cGameScroll].x0 = (level.numTilesX*cTileSize)-cGameRegionW;
			scrollfX = 	scroll[cGameScroll].x0;
		end;
		//Limite superior
		if (scroll[cGameScroll].y0 <= 0 )
			scroll[cGameScroll].y0 = 0;
			if (doTransition == ROOM_TRANSITION_UP)
				doTransition = 0;
			end;
		end;
		//Limite inferior
		if ((scroll[cGameScroll].y0+cGameRegionH) >= (level.numTilesY*cTileSize))
			scroll[cGameScroll].y0 = (level.numTilesY*cTileSize)-cGameRegionH;
			if (doTransition == ROOM_TRANSITION_DOWN)
				doTransition = 0;
			end;
		end;
		
		//Efecto temblor Scroll
		if (game.shakeScroll)			
			scroll[cGameScroll].y0 += cVelShakeScroll*rand(-1,1);
			game.shakeScroll = false;
		end;
			
		//lanzamos transicion de scroll
		if (doTransition <> 0)
			roomScrollTransition(doTransition);
			doTransition = 0;
		end;
		
		//lanzamos comprobacion de checkPoints
		checkLevelCheckPoints();
		
		//Actualizamos el scroll
		move_scroll(cGameScroll);
		
		//resteamos flags de detencion scroll
		stopScrollXR = false;
		stopScrollXL = false;
		stopScrollY  = false;
		
		frame;
	
	end;
end;

//funcion que comprueba si se aplica el noScroll de una posicion
function byte checkNoScroll(int playerX,int tileX,byte dir)
begin
	switch (dir)
		case NO_SCROLL_R:
			//si el player esta antes que el tile y el scroll sobrepasa el tile
			if (playerX < tileX && (scroll[cGameScroll].x0+cGameRegionW) >= (tileX+cHalfTSize))
				return true;
			end;
		end;
		case NO_SCROLL_L:
			//si el player esta despues del tile y el scroll sobrepasa el tile
			if (playerX > tileX && scroll[cGameScroll].x0 <= (tileX-cHalfTSize))
				return true;
			end;
		end;
	end;
	
	return false;
end;

//funcion que realiza transicion de scroll entre rooms
function roomScrollTransition(byte transitionDir)
private
	int scrollY0;			//Posicion inicial del scroll
	int scrollX0;			//Posicion inicial del scroll
	int dir;				//direccion de la transicion
	entity	animPlayer;		//Proceso animacion del jugador durante transicion
	entity  animObject;		//Proceso animacion del posible objeto cogido durante transicion
	entity idObj;			//Objeto en estado recogido
begin
	//obtenemos posicion inicial del scroll
	scrollX0 = scroll[cGameScroll].x0;
	scrollY0 = scroll[cGameScroll].y0;
	
	//seteamos direccion de la transicion
	if (transitionDir == ROOM_TRANSITION_DOWN || transitionDir == ROOM_TRANSITION_RIGHT)
		dir = 1;
	else
		dir = -1;
	end;
	
	//dormimos el proceso jugador
	signal(idPlayer,s_sleep);
	//dormimos el control del scroll
	signal(TYPE wgeControlScroll,s_sleep);
	//dormimos el resto de entidades
	signal(type object,s_sleep_tree);
	signal(type monster,s_sleep_tree);
	signal(type platform,s_sleep_tree);
	
	//creamos una animacion del personaje segun su estado
	switch (idPlayer.this.state)
		case MOVE_ON_STAIRS_STATE:
			animPlayer = wgeAnimation(fpgPlayer,19, 20,idPlayer.x,idPlayer.y,8,ANIM_LOOP);
		end;
		case MOVE_STATE:
			animPlayer = wgeAnimation(fpgPlayer,3, 8,idPlayer.x,idPlayer.y,4,ANIM_LOOP);
		end;
		default:
			//buscamos si hay algun objeto recogido para crear su animacion
			repeat
				idObj = get_id(TYPE object);
				if (idObj <> 0 )
					if (idObj.this.state == PICKED_STATE)
						animObject = wgeAnimation(level.fpgObjects,idObj.son.graph,idObj.son.graph,idObj.x,idObj.y,8,ANIM_LOOP);
						animObject.flags = idObj.flags;
						signal(idObj,s_sleep_tree);
					end;
				end;
			until (idObj == 0 || animObject <> 0);
			
			animPlayer = wgeAnimation(fpgPlayer,idPlayer.graph,idPlayer.graph,idPlayer.x,idPlayer.y,8,ANIM_LOOP);
		end;
	end;
	
	//seteamos los mismos flags
	animPlayer.flags = idPlayer.flags;
	
	//seteamos posicion entidad animacion
	animPlayer.this.fX = animPlayer.x;
	animPlayer.this.fY = animPlayer.y;
	
	//seteamos posicion entidad animacion objeto
	if (animObject <> 0 )
		animObject.this.fX = animObject.x;
		animObject.this.fY = animObject.y;
	end;
	
	//movemos el scroll y la animacion hasta la nueva room
	//Transicion vertical
	if (transitionDir == ROOM_TRANSITION_DOWN || transitionDir == ROOM_TRANSITION_UP)
		repeat
			//movemos scroll
			scroll[0].y0 += cVelRoomTransition * dir;
			
			//movemos animacion player
			animPlayer.this.vY = (cVelRoomTransition*cVelRoomTransFactorY)*dir;
			animPlayer.this.fY += animPlayer.this.vY;
			positionToInt(animPlayer);
			//actualizamos la posicion del player para no dar muerte por region
			idPlayer.y  = animPlayer.y;
			
			//movemos animacion objeto si lo llevaras
			if (animObject <> 0 )
				animObject.this.vY = (cVelRoomTransition*cVelRoomTransFactorY)*dir;
				animObject.this.fY += animObject.this.vY;
				positionToInt(animObject);
			end;
						
			//si la transicion es por escaleras, efecto sonido
			if (idPlayer.this.state == MOVE_ON_STAIRS_STATE)
				//reproducimos sonido en cada loop
				if (tickClock(16))
					wgePlayEntitySnd(id,playerSound[STAIRS_SND]);
				end;
			end;
			
			frame;
		until( abs(scroll[0].y0 - scrollY0) >= cGameRegionH+(cTilesBetweenRooms*cTileSize) )
	end;
	
	//Transicion horizontal
	if (transitionDir == ROOM_TRANSITION_LEFT || transitionDir == ROOM_TRANSITION_RIGHT)
		repeat
			//movemos scroll
			scroll[0].x0 += cVelRoomTransition * dir;
			
			//movemos animacion player
			animPlayer.this.vX = (cVelRoomTransition*cVelRoomTransFactorX)*dir;
			animPlayer.this.fX += animPlayer.this.vX;
			positionToInt(animPlayer);
			//actualizamos la posicion del player para no dar muerte por region
			idPlayer.x  = animPlayer.x;
			
			//movemos animacion objeto
			if (animObject <> 0 )
				animObject.this.vY = (cVelRoomTransition*cVelRoomTransFactorX)*dir;
				animObject.this.fY += animObject.this.vY;
				positionToInt(animObject);
			end;
			
			frame;
		
		until( abs(scroll[0].x0 - scrollX0) >= cGameRegionW)
	end;
	
	//igualamos la posicion del player a la animacion
	switch (transitionDir)
		case ROOM_TRANSITION_DOWN:
			idPlayer.this.fY = scroll[0].y0 + cTileSize;
			if (idObj <> 0)
				idObj.y = scroll[0].y0 + cTileSize;
				idObj.this.fY = idObj.y;
			end;
		end;
		case ROOM_TRANSITION_UP:
			idPlayer.this.fY = scroll[0].y0 +cGameRegionH - cTileSize;
			if (idObj <> 0)
				idObj.y = scroll[0].y0 +cGameRegionH - cTileSize;
				idObj.this.fY = idObj.y;
			end;
		end;
		case ROOM_TRANSITION_LEFT:
			idPlayer.this.fX = scroll[0].x0 +cGameRegionW - (cTileSize*2);
			if (idObj <> 0)
				idObj.x = scroll[0].x0 +cGameRegionW - (cTileSize*2);
				idObj.this.fX = idObj.x;
			end;
		end;
		case ROOM_TRANSITION_RIGHT:
			idPlayer.this.fX = scroll[0].x0 + (cTileSize*2);
			if (idObj <> 0)
				idObj.x = scroll[0].x0 + (cTileSize*2);
				idObj.this.fX = idObj.x;
			end;
		end;
	end;
		
	//despertamos los procesos
	signal(idPlayer,s_wakeup);
	signal(TYPE wgeControlScroll,s_wakeup);
	if (idObj <> 0 )
		signal(idObj,s_wakeup_tree);
	end;
	signal(type object,s_wakeup_tree);
	signal(type monster,s_wakeup_tree);
	signal(type platform,s_wakeup_tree);
	
	//forzamos un frame para mostrar al player en la posicion
	frame;
	
	//destruimos la animacion
	signal(animPlayer,s_kill_tree);
	if (animObject <> 0)
		signal(animObject,s_kill_tree);
	end;
end;

//funcion que se encarga de actualizar la posicion de inicio de nivel
//segun el ultimo checkpoint pasado
function checkLevelCheckPoints()
private
	int i;		//variable auxiliar
begin
	//si existe el player
	if (exists(idPlayer))
		//recorremos todos los checkpoints del nivel
		for (i=0;i<level.numCheckPoints;i++)
			//si el checkpoint no es la posicion actual
			if (level.playerX0 <> level.checkPoints[i].position.x &&
			    level.playerY0 <> level.checkPoints[i].position.y)
				//si la posicion del checkpoint esta en la region de pantalla visible actual
				if ( scroll[cGameScroll].x0 <= level.checkPoints[i].position.x && 
					 scroll[cGameScroll].x0+cGameRegionW >= level.checkPoints[i].position.x &&
					 scroll[cGameScroll].y0 <= level.checkPoints[i].position.y &&
					 scroll[cGameScroll].y0+cGameRegionH >= level.checkPoints[i].position.y
				   )
					//asociamos la posicion de inicio del nivel al checkpoint
					level.playerX0 		= level.checkPoints[i].position.x;
					level.playerY0 		= level.checkPoints[i].position.y;
					level.playerFlags	= level.checkPoints[i]._flags;
					
					log("Se alcanza el checkpoint "+i,DEBUG_ENGINE);
				end;
			end;
		end;
	end;
end


function int wgeWait(int t)
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
function int checkTileCode(entity idEntity,int colDir,int posY,int posX)
begin
	//comprobamos si el tile es visible en la pantalla, asi, los tiles fuera de region no serán solidos
	if (checkTileVisible(idEntity,posX,posY))
		switch(colDir)
			//Colisiones superiores
			case COLUP:
				return tileMap[posY][posX].tileCode == SOLID ||
					   tileMap[posY][posX].tileCode == NO_SCROLL_L ||
					   tileMap[posY][posX].tileCode == NO_SCROLL_R;
			end;
			//Colisiones inferiores
			case COLDOWN,COLCENTER:
				return tileMap[posY][posX].tileCode == SOLID     ||
					   tileMap[posY][posX].tileCode == SLOPE_135 ||
					   tileMap[posY][posX].tileCode == SLOPE_45  ||
					   tileMap[posY][posX].tileCode == NO_SCROLL_L ||
					   tileMap[posY][posX].tileCode == NO_SCROLL_R ||
					  (tileMap[posY][posX].tileCode == SOLID_ON_FALL && ( idEntity.this.vY>0 || isType(idEntity,TYPE player)) )||
					  (tileMap[posY][posX].tileCode == TOP_STAIRS && (idEntity.this.vY>0 || isType(idEntity,TYPE player)) );
			end;
			//Colisiones lateral izquierdas
			case COLIZQ:
				return tileMap[posY][posX].tileCode == SOLID       ||
					   tileMap[posY][posX].tileCode == NO_SCROLL_L ||
					   tileMap[posY][posX].tileCode == NO_SCROLL_R;
					  
			end;
			//Colisiones lateral derechas
			case COLDER:
				return tileMap[posY][posX].tileCode == SOLID       ||
					   tileMap[posY][posX].tileCode == NO_SCROLL_L ||
					   tileMap[posY][posX].tileCode == NO_SCROLL_R;
					   
			end;
		end;
	else
		return NO_SOLID; 
	end;
end;

//funcion que comprueba si el tile se ve en la region actual del juego
function int checkTileVisible(entity idEntity,int posX,int posY)
begin
	//comprobacion solo para el player
	if (idEntity <> idPlayer)
		return true;
	else
		return ((posY*cTileSize)+cTileSize) >= scroll[cGameScroll].y0 &&
			   (posY*cTileSize) <= scroll[cGameScroll].y0+cGameRegionH &&
			   ((posX*cTileSize)+cTileSize) >= scroll[cGameScroll].x0 &&
			   (posX*cTileSize) <= scroll[cGameScroll].x0+cGameRegionW;
	end;
end;

//funcion que devuelve el codigo de Tile de un punto de colision
function int getTileCode(entity idEntity,int pointType)
begin
	//sumamos la posicion del objeto al punto de colision
	x = idEntity.x + idEntity.this.colPoint[pointType].x;
	y = idEntity.y + idEntity.this.colPoint[pointType].y;
	
	//comprobamos si existe en el mapeado y si es visible
	if (!tileExists(y/cTileSize,x/cTileSize) || !checkTileVisible(idEntity,x/cTileSize,y/cTileSize))
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
function positionToInt(entity idEntity)
begin
	//movemos si la posicion a cambiado partes enteras
	idEntity.x+= idEntity.this.fX - idEntity.x;
		
	//movemos si la posicion a cambiado partes enteras
	idEntity.y+= idEntity.this.fy - idEntity.y;
end;

//funcion que actualiza las velocidades y la posicion de un proceso
function updateVelPos(entity idEntity,byte grounded)
begin
	//Actualizar velocidades
	if (grounded)
		idEntity.this.vY = 0;
	end;
	
	//actualizar posiciones
	idEntity.this.fX += idEntity.this.vX;
	idEntity.this.fY += idEntity.this.vY;
	
	positionToInt(idEntity);
end;

//funcion que envia signals a los tipos del juego
function gameSignal(int _signal)
begin
	signal(TYPE wgeControlScroll,_signal);
	signal(TYPE wgeUpdateTileAnimations,_signal);
	signal(TYPE pTile,_signal);
	if (exists(idPlayer) ) 
		signal(idPlayer,_signal);
	end;
	
	signal(type object,_signal);
	signal(type monster,_signal);
	signal(type platform,_signal);
	
	
end;

//funcion para limpiar y descargar archivos del nivel actual
function clearLevel()
begin
	log("Se limpia el nivel",DEBUG_ENGINE);
	
	//matamos los procesos
	gameSignal(s_kill_tree);
	idPlayer = 0;
	
	//quitamos el HUD
	signal(TYPE HUD,s_kill);
	
	//eliminamos textos
	delete_text(all_text);
	
	//Limpiamos la memoria dinamica
	#ifdef DYNAMIC_MEM
		if (objects != NULL)
			free(objects);
			objects = NULL;			
		end;
		if (monsters != NULL)
			free(monsters);
			monsters = NULL;			
		end;
		if (platforms != NULL)
			free(platforms);

			platforms = NULL;			
		end;
		if (tileMap != NULL)
			free(tileMap);
			tileMap = NULL;			
		end;
		if (level.checkPoints != NULL)
			free(level.checkPoints);
			level.checkPoints = NULL;			
		end;
		//free(paths);
		if (tileAnimations.tileAnimTable != NULL)
			free(tileAnimations.tileAnimTable);	
			tileAnimations.tileAnimTable = NULL;
		end;
		log("Memoria dinamica total liberada",DEBUG_ENGINE);
	#endif
	
	//liberamos archivos cargados
	unload_fpg(level.fpgTiles);
	unload_fpg(level.fpgObjects);
	unload_fpg(level.fpgMonsters);
	
	//reseteamos flags
	game.boss = false;
	game.bossKilled = false;
	game.teleport = false;
	
end;

//funcion que convierte un entero a string añadiendo ceros a la izquierda
function int2String(int entero,string *texto,int numDigitos)
begin
	//convertimos el entero a string
	*texto = itoa(entero);
	//añadimos 0 a la izquierda
	if (len(*texto) < numDigitos )
		repeat
			*texto = "0" + *texto;
		until(len(*texto)==numDigitos)
	end;
end;

//funcion que devuelve si un rectangulo esta en la region del juego
//pudiendo elegirse en que direccion se comprueba con checkMode
function checkInRegion(int _x0,int _y0,int _ancho,int _alto,int checkMode)
begin
	switch (checkMode)
		case CHECKREGION_ALL:
			return ((_x0 - _ancho) <= scroll[cGameScroll].x0+(cGameRegionW) && (_x0 + _ancho) >= scroll[cGameScroll].x0 &&
		   (_y0 + _alto) >= scroll[cGameScroll].y0 && (_y0 - _alto) <= scroll[cGameScroll].y0+(cGameRegionH) );
		end;
		case CHECKREGION_DOWN:
			return ((_x0 - _ancho) <= scroll[cGameScroll].x0+(cGameRegionW) && (_x0 + _ancho) >= scroll[cGameScroll].x0 &&
		   (_y0 - _alto) <= scroll[cGameScroll].y0+(cGameRegionH) );
		end;
	end;
	
end;

//funcion que devuelve a inicio las entidades de un tipo
function restartEntityType(int entityType)
private
	entity entityID; //id de la entidad
begin
	repeat
		//obtenemos siguiente entidad
		entityID = get_id(entityType);
		//reiniciamos la entidad
		if (entityID <> 0) 
			entityID.this.state = INITIAL_STATE;
		end;
	until (entityID == 0);
end;

//funcion que realiza parpadeo de una entidad
function blinkEntity(int idEntity)
begin
	if (tickClock(cBlinkEntityTime))
		isBitSet(idEntity.flags,B_ABLEND) ? unsetBit(idEntity.flags,B_ABLEND) : setBit(idEntity.flags,B_ABLEND);
	end;
end;


//funcion para salvar la configuracion
function saveGameConfig()
private
	int configFile;
	int i;
begin
	
	configFile = fopen("gameconfig.cfg",O_WRITE);
	
	//escribimos la configuracion general
	fwrite(configFile,config.videoMode);
	fwrite(configFile,config.lang);
	fwrite(configFile,config.soundVolume);
	fwrite(configFile,config.musicVolume);
	
	//escribimos la configuracion de teclas y joyPad
	for (i=0;i<cControlCheckNumber;i++)
		fwrite(configFile,configuredKeys[i]);
		fwrite(configFile,configuredButtons[i]);
	end;
	
	//cerramos el archivo
	fclose(configFile);
	
	log("Archivo de configuración guardado",DEBUG_ENGINE);
	
end;

//funcion para abrir la configuracion
function loadGameConfig()
private
	int configFile;
	int i;
begin
	//si existe el archivo de configuracion
	if (fexists("gameconfig.cfg"))
		//abrimos el archivo
		configFile = fopen("gameconfig.cfg",O_READ);
		
		//leemos la configuracion general
		fread(configFile,config.videoMode);
		fread(configFile,config.lang);
		fread(configFile,config.soundVolume);
		wgeSetChannelsVolume(config.soundVolume);
		
		fread(configFile,config.musicVolume);
		set_song_volume(config.musicVolume*1.28);
		
		//escribimos la configuracion de teclas y joyPad
		for (i=0;i<cControlCheckNumber;i++)
			fread(configFile,configuredKeys[i]);
			fread(configFile,configuredButtons[i]);
		end;
		
		//cerramos el archivo
		fclose(configFile);
		
		
		log("Archivo de configuración leído",DEBUG_ENGINE);
	else
		config.videoMode   = CONFIG_MODE_2XSCALE;
		config.soundVolume = 100;
		config.musicVolume = 100;
		
		log("No hay archivo de configuracion. Se cargan valores por defecto",DEBUG_ENGINE);
		
		//seteamos primer arranque
		firstRun = true;
	end;
end;

//funcion que realiza una transicion fade off/on a una posicion de cancion dada
function introMusicTransition(float musicPos)
begin
	//encedemos pantalla
	fade(100,100,100,cFadeTime);
	while(fading) frame; end;
	
	//esperamos la marca de tiempo
	while (timer[cMusicTimer] < (musicPos*100))
		frame;
	end;
	//apagamos pantalla
	fade(0,0,0,cFadeTime);
	while(fading) frame; end;
	
	screen_clear();
	delete_text(all_text);
end;

function loadGameLang()
private
	int langFile;		//archivo de idioma
	int textIndex;		//indice del texto
begin
		
	//Cargamos el idioma Ingles
	
	//si existe el archivo de idioma
	if (fexists("lang/game-en.lng"))
		//abrimos el archivo
		langFile = fopen("lang/game-en.lng",O_READ);
		
		textIndex = 0;
		
		//recorremos las lineas del archivo
		while (!feof(langFile))
			gameTexts[ENG_LANG][textIndex] = fgets(langFile);
			textIndex++;
		end;
		
		//cerramos el archivo
		fclose(langFile);
		
		log("Archivo de idioma ENG leído",DEBUG_ENGINE);
	else
		log("Falta el archivo de ENG",DEBUG_ENGINE);
		wgeQuit();
	end;
	
	//Cargamos el idioma Español
	
	//si existe el archivo de idioma
	if (fexists("lang/game-es.lng"))
		//abrimos el archivo
		langFile = fopen("lang/game-es.lng",O_READ);
		
		textIndex = 0;
				
		//recorremos las lineas del archivo
		while (!feof(langFile))
			gameTexts[ESP_LANG][textIndex] = fgets(langFile);
			textIndex++;
		end;
		
		//cerramos el archivo
		fclose(langFile);
		
		log("Archivo de idioma ESP leído",DEBUG_ENGINE);
	else
		log("Falta el archivo de idioma ESP",DEBUG_ENGINE);	
	end;
	
end;

//funcion que hace fade in de la pantalla (no existe fade in de musica)
function wgeFadeIn(int fadeType)
begin
	//fade pantalla si se ha seleccionado
	if (isBitSet(fadeType,FADE_SCREEN))
		fade(100,100,100,cFadeTime);
	end;
	//bucle hasta que termine el fade
	while(fading && isBitSet(fadeType,FADE_SCREEN)) 
	    frame; 
	end;
end;

//funcion que hace fade out de la pantalla y/o musica
function wgeFadeOut(int fadeType)
begin
	
	//fade pantalla si se ha seleccionado
	if (isBitSet(fadeType,FADE_SCREEN))
		fade(0,0,0,cFadeTime);
	end;
	//fade musica si se ha seleccionado y hay musica en marcha
	if (isBitSet(fadeType,FADE_MUSIC) && is_playing_song())
		fade_music_off(cFadeMusicTime);
	end;
	//bucle hasta que termine cada fade
	while( (fading            && isBitSet(fadeType,FADE_SCREEN)) 
	        ||
	       (is_playing_song() && isBitSet(fadeType,FADE_MUSIC))
		 ) 
		  frame; 
	end;

end;

//funcion que setea el modo de video mas optimo al sistema
function setOptimalVideoMode(int resX,int resY,int resDepth,int resMode)
private
	byte ARatio;
	int sW;
	int sH;
	int* modes;
	_videoMode* videoModes;
	byte outAR  = false;
	int numModes = 0;
	int i;
begin
	//si el modo es ventana, no ajustamos nada (de momento)
	if (false)//isBitSet(resMode,MODE_WINDOW))
		sW = resX;
		sH = resY;
	else
		//Obtenemos el aspect ratio de la resolucion pedida
		aRatio = getAspectRatio(resX,resY);
		say("Modo pedido:"+resX+"x"+resY+" - "+aRatio);
		
		//comprobamos si el modo pedido es correcto
		if (mode_is_ok(resX,resY,resDepth,resMode) == resDepth)
			sW = resX;
			sH = resY;
			say("Modo soportado por el sistema");
		else 
			say("Modo no soportado por el sistema");
			//obtenemos los modos soportados por el sistema
			say("Modos disponibles:");
			modes = get_modes(resDepth, resMode);
			while (*modes)
				if (numModes == 0)
					videoModes = calloc(1,sizeof(_videoMode));
				else
					videoModes = realloc(videoModes,(numModes+1)*sizeof(_videoMode));
				end;
				videoModes[numModes].rW = *modes++;
				videoModes[numModes].rH = *modes++;
				//obtenemos aspect ratio
				videoModes[numModes].aRatio = getAspectRatio(videoModes[numModes].rW,videoModes[numModes].rH);
				say(videoModes[numModes].rW + " X "+videoModes[numModes].rH + " - " + videoModes[numModes].aRatio);
				
				numModes++;
				
			end;
			
			//buscamos el modo mas parecido
					
			//si la pedida es mas pequeña que el modo mas bajo
			if (resX < videoModes[numModes-1].rW)
				//Seteamos el modo mas bajo
				sW = videoModes[numModes-1].rW;
				sH = videoModes[numModes-1].rH;
				if (videoModes[numModes-1].aRatio != ARatio)
					outAR = true;
				end;
				say("Usamos el modo mas bajo de los soportados");
			//si la pedida es mas grande que el modo mas alto
			elseif (resX > videoModes[0].rW)
				//seteamos el modo mas alto
				sW = videoModes[0].rW;
				sH = videoModes[0].rH;
				if (videoModes[0].aRatio != ARatio)
					outAR = true;
				end;
				say("Usamos el modo mas alto de los soportados");		
			else
				//recorremos los modos para buscar el modo mas cercano al pedido
				for (i=0;i<numModes;i++)
					if (videoModes[i].rW < resX )
						if (i>0)
							sW = videoModes[i-1].rW;
							sH = videoModes[i-1].rH;
							if (videoModes[i-1].aRatio != ARatio)
								outAR = true;
							end;
							break;
						else
							sW = videoModes[i].rW;
							sH = videoModes[i].rH;
							if (videoModes[i].aRatio != ARatio)
								outAR = true;
							end;
							say("Solo hay un modo posible");
						end;
					else
						sW = videoModes[i].rW;
						sH = videoModes[i].rH;
					end;
				end;
				
				if (sW<>0 && sH<>0)
					if (!outAR)
						say("Encontrado modo en tu aspect Ratio:"+sW+"x"+sH);
					else
						say("Encontrado modo fuera de tu aspect Ratio:"+sW+"x"+sH);
					end;
				end;
			end;
					
			//si la resolucion difiere de la pedida
			if (sW != resX || sH != resY)
				//reescalamos a la encontrada
				say("Reescalamos");
				scale_resolution = (sW*10000) + sH;
				if (outAR)
					scale_resolution_aspectratio = SRA_STRETCH;
					say("Aplicamos Strech al escalado");
				else			
					scale_resolution_aspectratio = SRA_PRESERVE;
					say("Preservamos aspect ratio al escalado");
				end;
				//pero seteamos resolucion original
				sW = resX;
				sH = resY;
			//resolucion identica
			else
				say("No reescalamos");
			end;
			//liberamos puntero resoluciones
			free(videoModes);
		end;
	end;
	
	//seteamos modo
	set_mode(sW,sH,resDepth);
	say("Modo seteado a "+sW+" x " + sH);
	//obtenemos el modo seteado por la tarjeta grafica
	get_desktop_size(&sW,&sH);
	say("Sistema se setea a:" + sW+" x " + sH);
	
end;

//obtenemos el aspect ratio
function byte getAspectRatio(int resX,int resY)
private
	float f1,f2,fResult;
begin
	f1 = resX;
	f2 = resY;
	fResult = f1 / f2;
	
	if (fResult >= 1.33 && fResult <= 1.34)
		return AR_4_3;
	elseif(fResult >= 1.77 && fResult <= 1.78)
		return AR_16_9;
	elseif(fResult == 1.6)
		return AR_16_10;
	elseif(fResult >= 1.25 && fResult <= 1.26)
		return AR_5_4;
	elseif(fResult >= 1.66 && fResult <= 1.67)
		return AR_5_3;	
	else
		return AR_UNK;			
	end;
end;