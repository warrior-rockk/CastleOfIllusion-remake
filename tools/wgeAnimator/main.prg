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
	
Begin
	//iniciamos video	
	set_mode(cResX,cResY);
	set_fps(cFps,0);
	
	//iniciamos libreria gui
	fuit_init("src/default.fpg", "src/cursors.fpg");
	
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
		if (key(_f))
			backColor = backColor == 0 ? 255 : 0;
			map_clear(0,0,backColor);
			repeat	
				frame;
			until(not key(_f));
		end;
		
		//cambio escala
		if (key(_s))
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
					scale_resolution = 10240768;
					set_mode(cResX,cResY);
				end;
			end;
			
			repeat	
				frame;
			until(not key(_s));
		end;
		
		//avance animaciones
		if (key(_PGDN))
			if (actualAnim < 5)
				actualAnim++;
				editValue[0].caption  = animationData[actualAnim].startFrame; 	
				editValue[1].caption  = animationData[actualAnim].endFrame;
				editValue[2].caption  = animationData[actualAnim].animSpeed;
				editValue[3].caption  = animationData[actualAnim].animMode;
				editValue[4].caption  = animationData[actualAnim].name;
			end;
			repeat	
				frame;
			until(not key(_PGDN));
		end;
		
		//retroceso animaciones
		if (key(_PGUP))
			if (actualAnim > 0)
				actualAnim--;
				editValue[0].caption  = animationData[actualAnim].startFrame; 	
				editValue[1].caption  = animationData[actualAnim].endFrame;
				editValue[2].caption  = animationData[actualAnim].animSpeed;
				editValue[3].caption  = animationData[actualAnim].animMode;
				editValue[4].caption  = animationData[actualAnim].name;
			end;
			repeat	
				frame;
			until(not key(_PGUP));
		end;
		
		//salvar las animaciones
		if (key(_CONTROL) && key(_s))
			saveAnimations();
			repeat	
				frame;
			until(not key(_s));
		end;
		
		Frame;
	until(cant_win()==0);
	
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
	file = load_fpg("../../gfx/player.fpg");
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
	
	label(frVentana,cWindowMarginX,cWindowMarginY*3,"Nombre:");
	editValue[4] = input_box(frVentana,cMarginX*2,cWindowMarginY*3,animationData[actualAnim].name);
	editValue[4].ancho = 200;
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
	
	//recorremos las lineas del archivo y las tratamos
	while (!feof(animFile))
		fileLine = fgets(animFile);		
		
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
	
	//cerramos el archivo
	fclose(animFile);	
end;

//funcion para salvar una tabla de animacion
function saveAnimFile()
private
	int animFile;
	string fileLine;
	string auxString[9];
	string auxString2[9];
	int stringPieces;
	int numLine = 0;
begin
	//abrimos el archivo de animaciones
	animFile = fopen("../../playerAnims.h",O_WRITE);
	
	//recorremos las lineas del archivo y las tratamos
	while (!feof(animFile))
		fileLine = fgets(animFile);		
		
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
	
	//cerramos el archivo
	fclose(animFile);
		
	
end;