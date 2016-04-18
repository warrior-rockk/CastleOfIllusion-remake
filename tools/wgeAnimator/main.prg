// ========================================================================
//  wgeAnimator
//  Utilidad para visualizar/componer/exportar los ciclos de animacion
//  12/04/16
//
//  Warcom soft.
// ========================================================================

import "mod_key";
import "mod_map";
import "mod_video";
import "mod_text";
import "mod_scroll";
import "Mod_proc";
import "mod_sound";
import "Mod_screen";
import "Mod_draw";
import "Mod_grproc";
import "Mod_rand";
import "mod_file"; 
import "mod_math";
import "mod_say";
import "mod_debug";
import "mod_string";
import "mod_timers";
import "mod_time";
import "mod_mem";
import "mod_joy";
import "mod_wm";
import "mod_regex"

//incluimos libreria gui
include "fuit.inc";

//archivo definiciones
include "main.h"

//incluimos funciones del WGE
include "../../animation.h";
include "../../animation.prg";

//Proceso principal
Process main()
private
	byte backColor = 0;
	byte scaleMode = 0;
	int i;
Begin
	//iniciamos video	
	set_mode(cResX,cResY);
	set_fps(cFps,0);
	set_title("wgeAnimation Tool");
	
	//iniciamos libreria gui
	fuit_init("src/default.fpg", "src/cursors.fpg");
		
	//cargamos el archivo que se usará
	fpgFile = load_fpg("../../gfx/player.fpg");
	
	//Arrancamos el reloj general
	wgeClock();
	
	//cargamos el archivo de tabla de animaciones
	loadAnimFile();
	
	//lanzamos proceso animacion
	animationDraw();
	
	//creamos el gui
	createGUI();
	
	//Bucle principal
	repeat
		//recojemos los datos del gui
		animationData[actualAnim].startFrame 	= editValue[0].caption;
		animationData[actualAnim].endFrame 		= editValue[1].caption;
		animationData[actualAnim].animSpeed 	= editValue[2].caption;
		animationData[actualAnim].animMode 		= editValue[3].caption;
		animationData[actualAnim].name	 		= editValue[4].caption;
		
		//cambio color fondo
		if (key(_f) && active_control==0)
			backColor = backColor == 0 ? 255 : 0;
			map_clear(0,0,backColor);
			repeat	
				frame;
			until(not key(_f));
		end;
		
		//cambio escala
		if (key(_s) && !key(_CONTROL) && active_control==0)
			scaleMode = scaleMode == 2 ? 0 : scaleMode+1;
			switch (scaleMode)
				case 0:
					scale_resolution = -1;
					scale_mode = SCALE_NONE;
					set_mode(cResX,cResY);
				end;
				case 1:
					scale_resolution = -1;
					scale_mode = SCALE_NORMAL2X;
					set_mode(cResX,cResY);
				end;
				case 2:
					scale_mode = SCALE_NONE;
					scale_resolution = 13650768;
					set_mode(cResX,cResY);
				end;
			end;
			
			repeat	
				frame;
			until(not key(_s));
		end;
		
		//avance animaciones
		if (key(_PGDN) && active_control==0)
			if (actualAnim < numAnims-1)
				actualAnim++;
				//actualizamos gui
				refreshGui();
			end;
			repeat	
				frame;
			until(not key(_PGDN));
		end;
		
		//retroceso animaciones
		if (key(_PGUP) && active_control==0)
			if (actualAnim > 0)
				actualAnim--;
				//actualizamos gui
				refreshGui();
			end;
			repeat	
				frame;
			until(not key(_PGUP));
		end;
		
		//salvar las animaciones
		if (key(_CONTROL) && key(_s) && active_control==0)
			repeat	
				frame;
			until(not key(_s));
			if (MessageBox(100,80,"Salvar Animaciones","¿Desea salvar la tabla de animaciones?",MB_YESNO).ret_yes)
				saveAnimFile();
			end;
			signal(TYPE MessageBox,s_kill);
			active_control = 0;
		end;
		
		//nueva animacion
		if (button[_BT_NEW].event == ui_click)
			//incrementamos animacion
			numAnims++;
			//realocamos el array dinamico
			animationData = realloc(animationData,(numAnims*sizeof(_animationData)));
			//inicializamos la nueva animacion
			animationData[numAnims-1].startFrame 	= 1;
			animationData[numAnims-1].endFrame 		= 2;
			animationData[numAnims-1].animSpeed 	= 10;
			animationData[numAnims-1].animMode 		= 0;
			animationData[numAnims-1].name	 		= "_NEW_ANIMATION";
			//saltamos a esa animacion
			actualAnim = numAnims-1;
			//actualizamos gui
			refreshGui();
		end;
		
		//borrar animacion
		if (button[_BT_DEL].event == ui_click)
			//si hay mas de una animacion
			if (numAnims-1 > 0)
				//reordenamos la tabla
				for (i=actualAnim;i<numAnims-1;i++)
					animationData[i].startFrame 	= animationData[i+1].startFrame;
					animationData[i].endFrame 		= animationData[i+1].endFrame;
					animationData[i].animSpeed 		= animationData[i+1].animSpeed;
					animationData[i].animMode 		= animationData[i+1].animMode;
					animationData[i].name	 		= animationData[i+1].name;
				end;
				//decrementamos animaciones
				numAnims--;
				//realocamos la tabla quitando la ultima posicion
				animationData = realloc(animationData,(numAnims*sizeof(_animationData)));
				//si hemos eliminado la ultima animacion, la actual es la nueva ultima
				actualAnim = actualAnim > numAnims-1 ? numAnims-1 : actualAnim;
			else
				animationData[0].startFrame 	= 0;
				animationData[0].endFrame 		= 0;
				animationData[0].animSpeed 		= 0;
				animationData[0].animMode 		= 0;
				animationData[0].name	 		= "";
			end;
			//actualizamos gui
			refreshGui();
		end;
		
		//lista graficos
		if (key(_l) && active_control==0)
			//eliminamos animacion
			signal(TYPE animationDraw,s_kill);
			//dibujamos lista de graficos
			drawGraphicList();
			repeat	
				frame;
			until(not key(_l));
		end;
		
		Frame;
	until(cant_win()==0 || key(_esc));
	
	free(animationData);
	exit("",0);
	
End; //Fin del main

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

//proceso principal animacion
process animationDraw()
begin
	file = fpgFile;
	x = cAnimationX;
	y = cAnimationY;
	loop
		wgeAnimate(animationData[actualAnim].startFrame,animationData[actualAnim].endFrame,animationData[actualAnim].animSpeed,animationData[actualAnim].animMode);
		//wgeAnimate2(startFrame,endFrame,animSpeed,animMode);
		frame;
	end;
end;

//funcion que crea el gui
function createGUI()
begin
	//ventana principal
	frVentana = window(cWindowX,cWindowY,"Parámetros Animación",BDR_FIXED);
	frVentana.ancho = cWindowWidth;
	frVentana.alto 	= cWindowHeight;
	frVentana.ancho = cWindowWidth;
	frVentana.ancho = cWindowWidth;
	//campos
	label(frVentana,cWindowMarginX,cWindowMarginY,"Inicio:");
	editValue[0] = input_box(frVentana,cWindowMarginX,cMarginY*2,animationData[actualAnim].startFrame);
	editValue[0].ancho = 30;
	label(frVentana,cMarginX*2,cWindowMarginY,"Fin:");
	editValue[1] = input_box(frVentana,cMarginX*2,cMarginY*2,animationData[actualAnim].endFrame);
	editValue[1].ancho = 30;
	label(frVentana,cMarginX*4,cWindowMarginY,"Velocidad:");
	editValue[2] = input_box(frVentana,cMarginX*4,cMarginY*2,animationData[actualAnim].animSpeed);
	editValue[2].ancho = 30;
	label(frVentana,cMarginX*7,cWindowMarginY,"Modo:");
	editValue[3] = input_box(frVentana,cMarginX*7,cMarginY*2,animationData[actualAnim].animMode);
	editValue[3].ancho = 30;
	
	button[_BT_NEW] = button(frVentana,cMarginX*9,cMarginY*2,"Nuevo");
	button[_BT_NEW].ancho = 50;
	button[_BT_DEL] = button(frVentana,cMarginX*11,cMarginY*2,"Delete");
	button[_BT_DEL].ancho = 50;
	
	label[0] = label(frVentana,cWindowWidth-cMarginX,cWindowMarginY,actualAnim+"/"+(numAnims-1));
	
	label(frVentana,cWindowMarginX,cWindowMarginY*3,"Nombre:");
	editValue[4] = input_box(frVentana,cMarginX*2,cWindowMarginY*3,animationData[actualAnim].name);
	editValue[4].ancho = 320;
end;

//funcion que actualiza el gui
function refreshGui()
begin
	//actualizamos campos
	editValue[0].caption  = animationData[actualAnim].startFrame; 	
	editValue[1].caption  = animationData[actualAnim].endFrame;
	editValue[2].caption  = animationData[actualAnim].animSpeed;
	editValue[3].caption  = animationData[actualAnim].animMode;
	editValue[4].caption  = animationData[actualAnim].name;
	//actualizamos animacion actual / totales
	label[0].caption = actualAnim+"/"+(numAnims-1);
end;

//funcion para cargar una tabla de animacion
function loadAnimFile()
private
	int animFile;
	string fileLine;
	string auxString[9];
	string auxString2[9];
	int stringPieces;
	int numLine = 0;
begin
	//abrimos el archivo de animaciones
	animFile = fopen("../../playerAnims.h",O_READ);
	//contamos las lineas
	while (!feof(animFile))
		if (fgets(animFile) <> "")
			numAnims++;
		end;
	end;
	//volvemos al principio del archivo
	frewind(animFile);
	//iniciamos el array dinamico
	animationData = calloc(numAnims,sizeof(_animationData));
	
	//recorremos las lineas del archivo y las tratamos
	while (!feof(animFile))
		fileLine = fgets(animFile);		
		
		if (fileLine <> "")
			// separamos por comas
			stringPieces = split(",",fileLine,&auxString,10);
			//quitamos el define
			auxString[0] = regex_replace("#define ","",auxString[0]);
			//quitamos tabulados del nombre
			stringPieces = split(chr(9),auxString[0],&auxString2,10);
			
			//seteamos los datos
			animationData[numLine].name		 	= auxString2[0];
			animationData[numLine].startFrame 	= auxString2[stringPieces-1];
			animationData[numLine].endFrame 	= auxString[1];
			animationData[numLine].animSpeed 	= auxString[2];
			animationData[numLine].animMode 	= auxString[3];
			
			numLine++;
		end;
	end;
	
	//cerramos el archivo
	fclose(animFile);	
	
end;

//funcion para salvar una tabla de animacion
function saveAnimFile()
private
	int animFile;
	string fileLine;
	int i,j;
	int numTabs;
begin
	//abrimos el archivo de animaciones
	animFile = fopen("../../playerAnims.h",O_WRITE);
	
	//recorremos las animaciones
	for (i=0;i<numAnims;i++)
		//componemos la linea de animacion
		fileLine = "#define "+animationData[i].name;
		//añadimos tabuladores para alinear
		numTabs = 11 - (len(animationData[i].name) / 4);
		for (j=0;j<numTabs;j++)
			fileLine = fileLine + chr(9);
		end;
		fileLine = fileLine + animationData[i].startFrame + ",";
		fileLine = fileLine + animationData[i].endFrame + ",";
		fileLine = fileLine + animationData[i].animSpeed + ",";
		if (animationData[i].animMode == ANIM_LOOP)
			fileLine = fileLine + "ANIM_LOOP";
		end;
		if (animationData[i].animMode == ANIM_ONCE)
			fileLine = fileLine + "ANIM_ONCE";
		end;
		//la escribimos
		fputs(animFile,fileLine);
	end;
	
	//cerramos el archivo
	fclose(animFile);		
	
end;

//proceso que muestra los graficos del archivo fpg
process drawGraphicList()
private
	int i;
	int idMap;
	int gridX 		= 40;
	int gridY 		= 40;
	int gridRow		= 6;
	int gridCol 	= 12;
	int lastGraph	= 1;
begin
	signal(father,s_sleep);
	signal(TYPE window,s_sleep_tree);
	
	set_text_color(100);
	idMap = map_new(cResX,cResY,8,0);
	map_clear(0,idMap,0);
	
	for (i=lastGraph;i<gridRow*gridCol;i++)
		map_block_copy(fpgFile,idMap,(((i-1)%gridCol)*gridX),((i/gridCol)*gridY),i,0,0,gridX,gridY,0);	
		write(0,(((i-1)%gridCol)*gridX),((i/gridCol)*gridY),0,0,i);
	end;
	
	lastGraph = gridRow*gridCol;
	screen_put(0,idMap);
	
	repeat
		//avance graficos
		if (key(_PGDN))
			if (lastGraph < 1000)
				map_clear(0,idMap,0);
				delete_text(all_text);
				for (i=lastGraph;i<(lastGraph+(gridRow*gridCol));i++)
					map_block_copy(fpgFile,idMap,(((i-lastGraph)%gridCol)*gridX),(((i-lastGraph)/gridCol)*gridY),i,0,0,gridX,gridY,0);	
					write(0,(((i-lastGraph)%gridCol)*gridX),(((i-lastGraph)/gridCol)*gridY),0,0,i);
				end;
				lastGraph = lastGraph + (gridRow*gridCol);
				screen_put(0,idMap);
			end;
			repeat	
				frame;
			until(not key(_PGDN));
		end;
		
		//retroceso graficos
		if (key(_PGUP))
			lastGraph -= 2*(gridRow*gridCol);
			if (lastGraph < 1)
				lastGraph = 1;
			end;		
			map_clear(0,idMap,0);
			delete_text(all_text);
			for (i=lastGraph;i<(lastGraph+(gridRow*gridCol));i++)
				map_block_copy(fpgFile,idMap,(((i-lastGraph)%gridCol)*gridX),(((i-lastGraph)/gridCol)*gridY),i,0,0,gridX,gridY,0);	
				write(0,(((i-lastGraph)%gridCol)*gridX),(((i-lastGraph)/gridCol)*gridY),0,0,i);
			end;
			
			screen_put(0,idMap);
			lastGraph = lastGraph + (gridRow*gridCol);
			repeat	
				frame;
			until(not key(_PGUP));
		end;
		
		frame;
	until(key(_esc));
	
	repeat
		frame;
	until(!key(_esc));
	
	clear_screen();
	delete_text(all_text);
	
	signal(father,s_wakeup);
	signal(TYPE window,s_wakeup_tree);
	animationDraw();
end;