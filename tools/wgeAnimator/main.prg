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
	//wgeClock();
	
	animationDraw();
	
	//creamos el gui
	createGUI();
	
	//Bucle principal
	repeat
		//recojemos los datos del gui
		startFrame 	= editValue[0].caption;
		endFrame 	= editValue[1].caption;
		animSpeed 	= editValue[2].caption;
		animMode 	= editValue[3].caption;
		
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
			say(scaleMode);
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
		clockTick = true;
		//Flanco de reloj segun intervalo escogido
		/*if (clockCounter % cTimeInterval == 0) 
			if (!clockTickMem)
				clockTick = true;
				clockTickMem = true;
			end;
		else
			clockTick = false;
			clockTickMem = false;
		end;*/
		
		frame;
	end;
end;

process animationDraw()
begin
	file = load_fpg("../../gfx/player.fpg");
	x = cAnimationX;
	y = cAnimationY;
	loop
		wgeAnimate2(startFrame,endFrame,animSpeed,animMode);
		frame;
	end;
end;


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
	editValue[0] = input_box(frVentana,cWindowMarginX,cMarginY*2,startFrame);
	editValue[0].ancho = 30;
	label(frVentana,cMarginX*2,cWindowMarginY,"Fin:");
	editValue[1] = input_box(frVentana,cMarginX*2,cMarginY*2,endFrame);
	editValue[1].ancho = 30;
	label(frVentana,cMarginX*4,cWindowMarginY,"Velocidad:");
	editValue[2] = input_box(frVentana,cMarginX*4,cMarginY*2,animSpeed);
	editValue[2].ancho = 30;
	label(frVentana,cMarginX*7,cWindowMarginY,"Modo:");
	editValue[3] = input_box(frVentana,cMarginX*7,cMarginY*2,animMode);
	editValue[3].ancho = 30;
end;