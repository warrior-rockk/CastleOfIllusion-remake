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
	log("Se finaliza la ejecución");
end;


//Carga de archivo de nivel
function WGE_LoadLevel(string file_)
private 
	int levelFile;		//Archivo del nivel
	int i,j;
end

begin 
	//Comprobamos si existe el archivo de datos del nivel
	if (file_exists(file_))
		//Abrimos el archivo
		levelFile = fopen(file_,o_read);
		//Nos situamos al principio del archivo
		fseek(levelFile,0,SEEK_SET);  
		
		//Leemos posicion inicial jugador
		fread(levelFile,level.playerX0);
		fread(levelFile,level.playerY0);
		
		//Leemos numero de objetos
		fread(levelFile,level.numObjectos);
		//Asignamos tamaño dinamico al array de objetos
		objetos = alloc(level.numObjectos * sizeof(objeto));
		//Leemos los datos de los objetos
		for (i=0;i<level.numObjectos;i++)
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
		fread(levelFile,level.numPaths);
		//Asignamos tamaño dinamico al array de paths
		objetos = alloc(level.numPaths * sizeof(path));
		//Leemos los datos de los trackings	
		for (i=0;i<level.numPaths;i++)
				//Leemos numero de puntos
				fread(levelFile,paths[i].numPuntos);
				for (j=0;j<paths[i].numPuntos;j++)
					//Leemos los puntos
					fread(levelFile,paths[i].punto[j].x); 
					fread(levelFile,paths[i].punto[j].y);
				end;
		end;
		//cerramos el archivo
		fclose(levelFile);
        /*		
		
		//creamos los objetos del nivel
		for (i=1;i<=num_objetos;i++) 
			crea_objeto(i,1);
		end;
		
		//creamos los enemigos del nivel
		crea_enemigo(1);
		//crea_enemigo(2);
		crea_enemigo(3);
		//crea_enemigo(5);
		tiempo = 400;
		
		if (C_AHORRO_OBJETOS)control_sectores();end;
		*/
	else
		exit("No existe el fichero " + file_ +".dat",-1);
	end;
end;  

/*
function genera_nivel(byte num_nivel)
Begin
fich_perso=load_fpg("fpg/mickey.fpg");
fich_objetos=load_fpg("fpg/objetos.fpg");
fich_screen=load_fpg("fpg/screens.fpg");
fich_nivel=load_fpg("fpg/niveles.fpg");



carga_nivel(Niveles[num_nivel]+"toyland.dat");

//creamos el personaje
//player_x0 = 420;//252;//420;//950;//385;//950;//448;//252;
//player_y0 = 220;//704;//128;//20;//320;//20;//496;//704;

p_personaje = personaje(player_x0,player_y0);

carga_tiles(Niveles[num_nivel]+"toyland.bin",Niveles[num_nivel]+"tiles.fpg",Niveles[num_nivel]+"durezas.fpg"); //funcion importada de "tileador.inc"

dibuja_tiles(player_x0,player_y0,C_RES_X,C_RES_Y,0); //funcion importada de "tileador.inc"          

nubes(2);
nubes(5);
nubes(8);
End;
*/

