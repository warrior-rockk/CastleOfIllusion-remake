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

//Tareas de inicializacion del engine
process WGE_Init()
private
	int cursorMap;						//Id grafico  cursor
	int idDebugText[MAXDEBUGINFO-1];	//Textos debug
	int i; 								//Variables auxiliares
	
begin
		
	//creamos el cursor de debug
	cursorMap = map_new(cTileSize,cTileSize,8);
	drawing_map(0,cursorMap);
	drawing_color(CURSORCOLOR);
	draw_line(1,cTileSize>>1,cTileSize,cTileSize>>1);
	draw_line(cTileSize>>1,1,cTileSize>>1,cTileSize);
	
	//Bucle principal de control del engine
	Loop 
		//limpiamos los textos
		for (i=0;i<MAXDEBUGINFO;i++)
			delete_text(idDebugText[i]);
		end;

		//Tareas del modo debug
		if (debugMode)
			//visualizamos cursor
			mouse.graph = cursorMap; 
			mouse.region = cGameRegion;
			
			//mostramos informacion de debug
			idDebugText[0] = write(0,DEBUGINFOX,DEBUGINFOY,0,"FPS:" + fps);
			idDebugText[1] = write(0,DEBUGINFOX,DEBUGINFOY+10,0,"X:" + mouse.x);
			idDebugText[2] = write(0,DEBUGINFOX,DEBUGINFOY+20,0,"Y:" + mouse.y);
			
			//movimiento del scroll
			scroll[cGameScroll].x0+=key(_right);
			scroll[cGameScroll].x0-=key(_left);
			scroll[cGameScroll].y0-=key(_up);
			scroll[cGameScroll].y0+=key(_down);
			
			move_scroll(cGameScroll);
			
			
			
		else
			//ocultamos todas las informaciones de debug
			mouse.graph = 0;			
		end;
		
		frame;
	end;
	
end;

//Inicializaci�n del modo grafico
function WGE_InitScreen()
begin
	//scale_mode=SCALE_NORMAL2X; 
	//set_mode(cResX,cResY,8);
	set_mode(992,600,8);
	set_fps(cNumFPS,0);
	log("Modo Grafico inicializado");
end;

//Definicion Region y Scroll
function WGE_InitScroll()
begin
	//define_region(cGameRegion,cRegionX,cRegionY,cRegionW,cRegionH);
	define_region(cGameRegion,cRegionX,cRegionY,992,600);
	start_scroll(cGameScroll,0,map_new(1,1,8),0,cGameRegion,3);
	scroll[cGameScroll].ratio = 100;
	log("Scroll creado");
end;

//Desactivaci�n del engine y liberacion de memoria
function WGE_Quit()
begin
	//Limpiamos la memoria dinamica
	free(objetos);
	free(paths);
	//free(tileMap);
	
	log("Se finaliza la ejecuci�n");
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
	if (not file_exists(file_))
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
	
	//Asignamos tama�o dinamico al array de objetos
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
	//Asignamos tama�o dinamico al array de paths
	objetos = calloc(level.numPaths , sizeof(path));
	//Leemos los datos de los trackings	
	for (i=0;i<level.numPaths;i++)
			//Leemos numero de puntos
			fread(levelFile,paths[i].numPuntos);
			//Asignamos tama�o dinamico al array de puntos
			paths[i].punto = alloc(paths[i].numPuntos * sizeof(point));
			for (j=0;j<paths[i].numPuntos;j++)
				//Leemos los puntos
				fread(levelFile,paths[i].punto[j].x); 
				fread(levelFile,paths[i].punto[j].y);
			end;
	end;
	
	//cerramos el archivo
	fclose(levelFile);
	log("Fichero nivel le�do con " + level.numObjects + " Objetos y " + level.numPaths + " Paths");	
	
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
	if (not file_exists(file_))
		log("No existe el fichero de mapa: " + file_);
		WGE_Quit();
	end;
	
	//leemos el archivo de mapa
	levelMapFile = fopen(file_,o_read);
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
	log("Fichero mapa le�do con " + level.numTiles + " Tiles. " + level.numTilesX + " Tiles en X y " + level.numTilesY + " Tiles en Y");   

End;

//funcion para generar un archivo de mapa especificando numero de tiles o aleatorio (numero tiles=0)
function WGE_GenRandomMapFile(string file_,int numTilesX,int numTilesY)
private 
	int levelMapFile;		//Archivo del nivel
	int i,j;				//Indices auxiliares
	byte randByte;			//Byte aleatorio
	int randInt;			//Int aleatorio
	
Begin
	
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

function WGE_DrawMap()
private
	int i,j,					//Indices auxiliares
	int x_inicial,y_inicial;	//Posiciones iniciales del mapeado			
	
	byte out_scr_x = 0; 	//marca fuera de pantalla en x
	byte out_scr_y = 0;     //marca fuera de pantalla en y

	int tiles_id[100][100]; //array de procesos de tiles
	int temp;
	int x0_ant; 
	int limite_x_izq,limite_x_der,limite_y_sup,limite_y_inf; //limites pantalla
	byte scroll_manual = 0;

Begin                    
	/*
	//Calculamos los limites de la pantalla
	limite_x_izq = cResX>>1;
	limite_x_der = (tiles_x*cTileSize)-(cResX>>1);
	limite_y_sup = C_REGION_Y>>1;
	limite_y_inf = (tiles_y*cTileSize)-(C_REGION_Y>>1);

	//SI usamos autoscroll, inicialmente enfocamos al personaje
	if (auto_scroll == 1) scroll[0].camera = p_personaje; end;

	//Seteamos la icion inicial para pintar los tiles segun la resolucion de pantalla
	if (x_inicial<=limite_x_izq)  			
		x_inicial = 0;								      //borde izquierdo de la pantalla
		scroll[0].camera = 0;
	elseif (x_inicial>=limite_x_der) 
		x_inicial = (tiles_x*cTileSize)-cResX;		  //borde derecho de la pantalla
		scroll[0].camera = 0;
	else
		x_inicial = x_inicial - (cResX>>1);				  //mitad de la pantalla
	end;
	if (auto_scroll == 1) //Si usamos autoscroll (camara en personaje)
		if (y_inicial<=limite_y_sup)					  //borde superior pantalla 
			y_inicial = 0;
			scroll[0].camera = 0;		
		elseif (y_inicial >= limite_y_inf)                //borde inferior pantalla
			y_inicial = (tiles_y*cTileSize)-C_REGION_Y;
			scroll[0].camera = 0;
		else 
			y_inicial = y_inicial - (cResY>>1);			  //mitad de la pantalla
		end;
	else
		//sin autoscroll
		//LA COORDENADA Y INICIAL PARA SCROLL FIJO DE MASTER SYSTEM VA DE 160 EN 160 MAS 2 TILES ENTRE SCROLLS
		//QUE SOLO SE VE AL CRUZARLO. ESTA COORDENADA SIRVE TANTO PARA EMPEZAR A DIBUJAR LOS TILES COMO CENTRAR EL SCROLL
		y_inicial = (y_inicial/(C_REGION_Y+(2*cTileSize)))*(C_REGION_Y+(2*cTileSize)); 
	end;

	//Centramos el scroll en la icion inicial
	scroll[0].x0 = x_inicial;
	scroll[0].y0 = y_inicial;
    */

	x_inicial = 1000;//level.playerx0;
	y_inicial = 1000;//level.playery0;
	
	scroll[0].x0 = x_inicial; 
	scroll[0].y0 = y_inicial;
	
	//creamos los procesos tiles segun la posicion x e y iniciales y la longitud de resolucion de pantalla
	//En los extremos de la pantalla se crean el numero definido de tiles (TILESOFFSCREEN) extras para asegurar la fluidez
	for (i=((y_inicial/cTileSize)-TILESYOFFSCREEN);i<(((cResY+y_inicial)/cTileSize)+TILESYOFFSCREEN);i++)
		for (j=((x_inicial/cTileSize)-TILESXOFFSCREEN);j<(((cResX+x_inicial)/cTileSize)+TILESXOFFSCREEN);j++)
			debugMode = 0;
			if (debugMode) 
				repeat
					frame; 
				until(not key(_space));
				repeat
					frame; 
				until(key(_space));
			end;
			debugMode = 1;
			
			ptile(i,j);
			log("Creado tile: "+i+" "+j);	
		end;
	end;
	log("Mapa dibujado correctamente");
End;

//proceso tile
process ptile(int i,int j)
private	
	byte tileColor;
	byte redraw = 0;
BEGIN
	//definimos propiedades iniciales
	alto = cTileSize;
	ancho = cTileSize;
	ctype = c_scroll;
	region = cGameRegion;
		
	//establecemos su posicion inicial
	x = (j*cTileSize)+cHalfTSize;
	y = (i*cTileSize)+cHalfTSize;
	
	//comprobamos si el tile existe en el mapeado
	//y leemos su grafico
	if (i<level.numTilesY && j<level.numTilesX && i>=0 && j>=0)
		tileColor = tileMap[i][j].tileGraph;
	else
		tileColor = 255;
	end;
	
	//dibujamos el tile
	graph = map_new(alto,ancho,8);
	drawing_map(0,graph);
	drawing_color(tileColor);
	draw_box(0,0,alto,ancho);
	set_text_color((255-TileColor)+1);
	map_put(0,graph,write_in_map(0,i,3),16,10);
	map_put(0,graph,write_in_map(0,j,3),16,18);
	
	loop
				
		//Si el tile desaparece por la izquierda
		if (scroll[0].x0 > (x+(cTileSize*TILESXOFFSCREEN)) )	
			//nueva posicion:a la derecha del tile de offscreen (que pasa a ser onscreen)
			//Se multiplica por 2 porque tenemos tiles offscreen a ambos lados
			i=i;
			j=j+(cResX/cTileSize)+(TILESXOFFSCREEN*2);
			  
			log("Paso de izq a der "+i+","+j);
			redraw = 1;
		end;
		
		
		//Si sale el tile por la derecha
		if ((scroll[0].x0+cResX)< (x-(cTileSize*TILESXOFFSCREEN)))
			//nueva posicion:a la derecha del tile de offscreen (que pasa a ser onscreen)
			//Se multiplica por 2 porque tenemos tiles offscreen a ambos lados
			i=i;
			j=j-(cResX/cTileSize)-(TILESXOFFSCREEN*2);
			
			log("Paso de der a izq "+i+","+j);
			redraw = 1;
		end;
		
		
		//Si sale por arriba
		if (scroll[0].y0 > (y+(cTileSize*TILESYOFFSCREEN)) )
			//nueva posicion
			i=i+(cResY/cTileSize)+(TILESYOFFSCREEN*2);
			j=j;       
			
			log("Paso de arrib a abaj "+i+","+j);
			redraw = 1;
		end;
		
		//Si sale por abajo
		if ((scroll[0].y0+cResY) < (y-(cTileSize*TILESYOFFSCREEN))) 
			//nueva posicion
			i=i-(cResY/cTileSize)-(TILESYOFFSCREEN*2);
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
			if (i<level.numTilesY && j<level.numTilesX && i>=0 && j>=0)
				tileColor = tileMap[i][j].tileGraph;
			else
				tileColor = 255;
			end;
		
			drawing_map(0,graph);
			drawing_color(tileColor);
			draw_box(0,0,alto,ancho);
			//graph=tileMap[i-(cResY/cTileSize)-2][j];
			set_text_color((255-TileColor)+1);
			map_put(0,graph,write_in_map(0,i,3),16,10);
			map_put(0,graph,write_in_map(0,j,3),16,18);
			
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

process WGE_Frame()
begin
	//ctype = c_scroll;
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
	loop
		frame;
	end;
end;

process WGE_DebugMoveScroll()
begin
	graph = mouse.graph;
	x = cResX>>1;
	y = cResY>>1;
	region = cGameRegion;
	//scroll[cGameScroll].camera = id;
	loop
		scroll[cGameScroll].x0+=key(_right);
		scroll[cGameScroll].x0-=key(_right);
		scroll[cGameScroll].y0-=key(_up);
		scroll[cGameScroll].y0+=key(_down);
		
		frame;
	end;
end;


