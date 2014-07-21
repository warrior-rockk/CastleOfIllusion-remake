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

//Inicialización del modo grafico
function WGE_InitScreen()
begin
	scale_mode=SCALE_NORMAL2X; 
	set_mode(cResX,cResY,8);
	set_fps(cNumFPS,0);
	log("Modo Grafico inicializado");
end;

//Definicion Region y Scroll
function WGE_InitScroll()
begin
	define_region(cGameRegion,cRegionX1,cRegionY1,cRegionX2,cRegionY2);
	start_scroll(cGameScroll,0,map_new(cRegionX2-cRegionX1,cRegionY2-cRegionY1,8),0,cGameRegion,0); 
	scroll[cGameScroll].ratio = 100;
	log("Scroll creado");
end;

//Desactivación del engine y liberacion de memoria
function WGE_Quit()
begin
	//Limpiamos la memoria dinamica
	free(objetos);
	free(paths);
	free(tileMap);
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
	if (not file_exists(file_))
		log("No existe el fichero: " + file_);
		WGE_Quit();
	end;
	
	//Abrimos el archivo
	levelFile = fopen(file_,o_read);
	//Nos situamos al principio del archivo
	fseek(levelFile,0,SEEK_SET);  
	
	//Leemos posicion inicial jugador
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


//Cargamos archivo del mapeado
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
	
	//Creamos la matriz dinamica del mapeado
	tileMap = calloc(level.numTilesY ,sizeof(tile*));
	from i = 0 to level.numTilesX-1;
		tileMap[i] = calloc(level.numTilesX ,sizeof(tile));
	end;
	
	//cerramos el archivo
	fclose(levelMapFile);
	log("Fichero mapa leído con " + level.numTiles + " Tiles. " + level.numTilesX + " Tiles en X y " + level.numTilesY + " Tiles en Y");   
	
End;

function WGE_DrawMap()
private
	int i,j,x_inicial,y_inicial;				//Indices auxiliares
	
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
	limite_x_izq = res_x>>1;
	limite_x_der = (tiles_x*C_TAMANO_TILE)-(res_x>>1);
	limite_y_sup = C_REGION_Y>>1;
	limite_y_inf = (tiles_y*C_TAMANO_TILE)-(C_REGION_Y>>1);

	//SI usamos autoscroll, inicialmente enfocamos al personaje
	if (auto_scroll == 1) scroll[0].camera = p_personaje; end;

	//Seteamos la posicion inicial para pintar los tiles segun la resolucion de pantalla
	if (x_inicial<=limite_x_izq)  			
		x_inicial = 0;								      //borde izquierdo de la pantalla
		scroll[0].camera = 0;
	elseif (x_inicial>=limite_x_der) 
		x_inicial = (tiles_x*C_TAMANO_TILE)-res_x;		  //borde derecho de la pantalla
		scroll[0].camera = 0;
	else
		x_inicial = x_inicial - (res_x>>1);				  //mitad de la pantalla
	end;
	if (auto_scroll == 1) //Si usamos autoscroll (camara en personaje)
		if (y_inicial<=limite_y_sup)					  //borde superior pantalla 
			y_inicial = 0;
			scroll[0].camera = 0;		
		elseif (y_inicial >= limite_y_inf)                //borde inferior pantalla
			y_inicial = (tiles_y*C_TAMANO_TILE)-C_REGION_Y;
			scroll[0].camera = 0;
		else 
			y_inicial = y_inicial - (res_y>>1);			  //mitad de la pantalla
		end;
	else
		//sin autoscroll
		//LA COORDENADA Y INICIAL PARA SCROLL FIJO DE MASTER SYSTEM VA DE 160 EN 160 MAS 2 TILES ENTRE SCROLLS
		//QUE SOLO SE VE AL CRUZARLO. ESTA COORDENADA SIRVE TANTO PARA EMPEZAR A DIBUJAR LOS TILES COMO CENTRAR EL SCROLL
		y_inicial = (y_inicial/(C_REGION_Y+(2*C_TAMANO_TILE)))*(C_REGION_Y+(2*C_TAMANO_TILE)); 
	end;

	//Centramos el scroll en la posicion inicial
	scroll[0].x0 = x_inicial;
	scroll[0].y0 = y_inicial;
    */
	x_inicial = 0;//level.playerx0;
	y_inicial = 0;//level.playery0;
	
	//creamos los procesos tiles segun la posicion x e y iniciales y la longitud de resolucion de pantalla
	for (i=(y_inicial/cTileSize);i<=(((cResy+y_inicial)/cTileSize)+1);i++)
		for (j=(x_inicial/cTileSize);j<=(((cResX+x_inicial)/cTileSize)+1);j++)
			say(i + "  " + j);
			ptile(tileMap[i][j].tileGraph,(j*cTileSize)+(cTileSize/2),(i*cTileSize)+(cTileSize/2),i,j);
			frame;		
		end;
	end;
End;

process ptile(byte nada,int x, int y,int nada2,int nada3)
BEGIN
	alto = 32;
	ancho = 32;
	graph = map_new(alto,ancho,8);
	drawing_map(0,graph);
	drawing_color(300);
	draw_box(0,0,alto,ancho);
	fx = x;
	fy = y;
	ctype = c_scroll;
	loop
		
		frame;
	end;
end;

//Creacion de los elementos del nivel
function WGE_CreateLevel()
private 
	int i;			//Indices auxiliares
end
Begin
	
	//Cargamos el archivo del mapeado
	//carga_tiles(Niveles[num_nivel]+"toyland.bin",Niveles[num_nivel]+"tiles.fpg",Niveles[num_nivel]+"durezas.fpg"); //funcion importada de "tileador.inc"
	
	//Dibujamos el mapeado
	//dibuja_tiles(player_x0,player_y0,C_RES_X,C_RES_Y,0); //funcion importada de "tileador.inc"
	
	//creamos los objetos del nivel
	for (i=0;i<level.numObjects;i++) 
		//crea_objeto(i,1);
	end;
			
	//creamos los enemigos del nivel
	//crea_enemigo(x);
	
	//if (C_AHORRO_OBJETOS)control_sectores();end;
	          
End;


