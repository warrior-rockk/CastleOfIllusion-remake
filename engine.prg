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
	//que se usar�n para comprobar las durezas de colision
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
	
	//Archivos de los niveles
	//tutorial
	levelFiles[TUTORIAL_LEVEL].MapFile 			= "levels\testRoom\testRoom.bin";
	levelFiles[TUTORIAL_LEVEL].DataFile 		= "levels\testRoom\testRoom.dat";
	levelFiles[TUTORIAL_LEVEL].TileFile 		= "levels\testRoom\tiles.fpg";
	//preludio	
	levelFiles[PRELUDE_LEVEL].MapFile 			= "levels\CastleDoor\CastleDoor.bin";
	levelFiles[PRELUDE_LEVEL].DataFile 			= "levels\CastleDoor\CastleDoor.dat";
	levelFiles[PRELUDE_LEVEL].TileFile 			= "levels\CastleDoor\tiles.fpg";
	levelFiles[PRELUDE_LEVEL].MusicFile 		= "mus\castleDoor.ogg";
	//doorSelect	
	levelFiles[LEVEL_SELECT_LEVEL].MapFile 		= "levels\levelDoors\levelDoors.bin";
	levelFiles[LEVEL_SELECT_LEVEL].DataFile 	= "levels\levelDoors\levelDoors.dat";
	levelFiles[LEVEL_SELECT_LEVEL].TileFile 	= "levels\levelDoors\tiles.fpg";
	levelFiles[LEVEL_SELECT_LEVEL].MusicFile	= "mus\castleDoor.ogg";
	//Toyland	
	levelFiles[TOYLAND_LEVEL].MapFile 			= "levels\ToyLand\ToyLand.bin";
	levelFiles[TOYLAND_LEVEL].DataFile 			= "levels\ToyLand\ToyLand.dat";
	levelFiles[TOYLAND_LEVEL].TileFile 			= "levels\ToyLand\tiles.fpg";
	levelFiles[TOYLAND_LEVEL].MusicFile 		= "mus\ToyLand.ogg";
	levelFiles[TOYLAND_LEVEL].MusicIntroEnd 	= 1.87;
	//Toyland Act 2
	levelFiles[TOYLAND_2_LEVEL].MapFile 		= "levels\ToyLand2\ToyLand2.bin";
	levelFiles[TOYLAND_2_LEVEL].DataFile 		= "levels\ToyLand2\ToyLand2.dat";
	levelFiles[TOYLAND_2_LEVEL].TileFile 		= "levels\ToyLand2\tiles.fpg";
	levelFiles[TOYLAND_2_LEVEL].MusicFile 		= "mus\ToyLand.ogg";
	levelFiles[TOYLAND_2_LEVEL].MusicIntroEnd 	= 1.87;
	//Woods
	levelFiles[WOODS_LEVEL].MapFile 			= "levels\Woods\Woods.bin";
	levelFiles[WOODS_LEVEL].DataFile 			= "levels\Woods\Woods.dat";
	levelFiles[WOODS_LEVEL].TileFile 			= "levels\Woods\tiles.fpg";
	levelFiles[WOODS_LEVEL].MusicFile 			= "mus\Woods.ogg";
	levelFiles[WOODS_LEVEL].MusicIntroEnd 		= 0.0;
	//Candyland
	levelFiles[CANDYLAND_LEVEL].MapFile 		= "levels\CandyLand\CandyLand.bin";
	levelFiles[CANDYLAND_LEVEL].DataFile 		= "levels\CandyLand\CandyLand.dat";
	levelFiles[CANDYLAND_LEVEL].TileFile 		= "levels\CandyLand\tiles.fpg";
	levelFiles[CANDYLAND_LEVEL].MusicFile 		= "mus\candyland.ogg";
	levelFiles[CANDYLAND_LEVEL].MusicIntroEnd 	= 0.0;
	
	//cargamos la paleta general del juego
	load_pal("pal\game.pal");
	
	//archivo graficos generales
	fpgGame 	= fpg_load("gfx\game.fpg");
	
	//archivo del player
	fpgPlayer 	= fpg_load("gfx\player.fpg");
		 
	//fuente del juego
	fntGame     = fnt_load("fnt\gameFont.fnt");
	
	//archivos de sonido
	if (!loadSoundFiles())
		wgeQuit();
	end;
	
	//Cargamos la configuracion del juego
	loadGameConfig();
	
	//Cargamos los textos del juego
	loadGameLang();
	
	//Iniciamos modo grafico
	wgeInitScreen();
	
	//iniciamos variables juego
	game.playerTries 	= 3;
	game.playerLife 	= 3;
	game.playerMaxLife  = 3;
	game.score      	= 0;
	game.numLevel       = CANDYLAND_LEVEL; //TUTORIAL_LEVEL;
	
	//estado inicial
	firstRun ? game.state = LANG_SEL : game.state = LOADLEVEL; //INTRO;
	
	//Arrancamos el reloj del juego
	wgeClock();
	
	//Arrancamos el loop del juego
	wgeLoop();
	
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

//Bucle principal del engine que controla el juego
process wgeLoop()
private
	int i,j; 									//Variables auxiliares
	int counterTime;						//tiempo de paso
	
	int levelDoorX;							//Posicion X de la puerta de seleccion nivel
	int levelDoorY;							//Posicion Y de la puerta de seleccion nivel
	int startDoorTile;						//Numero inicial de tile que representa la puerta
	
	int pauseText;							//Id texto de pausa
	string textMsg;							//Texto mensajes
	
	int idDeadPlayer;						//id del proceso muerte del player
	byte memBoss;							//flag de boss activo
	byte attractActive;						//modo Attractt activo
	
	byte introFinished;						//Flag de intro finalizada
	
	wgeDrawDialog idDialog;
	int optionNum;
	string optionString;
	byte redrawMenu;
begin
	priority = cMainPrior;
	
	loop
					
		//estado del juego
		switch (game.state)
			case LANG_SEL:
				//si es la primera ejecucion, elegimos idioma
				firstRun = false;
				
				//iniciamos la opcion del menu
				optionNum = 1;
				
				//componemos opciones menu
				optionString = gameTexts[config.lang][LAN_SEL_TEXT];
				//componemos un cuadro de dialogo
				idDialog = wgeDialog(cResX>>1,cResY>>1,200,(text_height(fntGame,optionString)*2)+(dialogTextMarginY*2)+(dialogMenuPadding*2));
				
				//lo redibujamos inicialmente
				redrawMenu	= true;
				
				//gestion del menu
				while (optionNum <> 0)
					//bajar opcion
					if (wgeCheckControl(CTRL_DOWN,E_DOWN) && optionNum<2)
						optionNum++;
						redrawMenu = true;
					end;
					//subir opcion
					if (wgeCheckControl(CTRL_UP,E_DOWN) && optionNum>1)
						optionNum--;
						redrawMenu = true;
					end;
					//incrementar valor
					if (wgeCheckControl(CTRL_RIGHT,E_DOWN))
						switch (optionNum)
							case 1:
								config.lang == ENG_LANG ? config.lang = ESP_LANG : config.lang = ENG_LANG;
								optionString = gameTexts[config.lang][LAN_SEL_TEXT];
							end;
						end;
						
						saveGameConfig();
						redrawMenu = true;						
					end;
					//decrementar valor
					if (wgeCheckControl(CTRL_LEFT,E_DOWN))
						switch (optionNum)
							case 1:
								config.lang == ENG_LANG ? config.lang = ESP_LANG : config.lang = ENG_LANG;
								optionString = gameTexts[config.lang][LAN_SEL_TEXT];
							end;
						end;
						
						saveGameConfig();
						redrawMenu = true;						
					end;
					//seleccionar opcion
					if (wgeCheckControl(CTRL_START,E_DOWN))
						switch (optionNum)
							case 2: //Aceptar
								game.state = INTRO;
								//salir del menu
								optionNum = 0;
							end;
						end;
					end;
					
					//redibujamos menu
					if (redrawMenu)
						//escribimos las opciones
						wgeWriteDialogOptions(idDialog,optionString,optionNum);
						//escribimos los valores
						wgeWriteDialogValues(idDialog,gameTexts[config.lang][CONFIG_VAL2_TEXT],1,config.lang);
						//cada vez que se redibuja el menu, reproducimos sonido
						wgePlayEntitySnd(id,gameSound[MENU_SND]);
						//reiniciamos flag
						redrawMenu = false;
					end;
					
					frame;
				end;
				
				//eliminamos menu y limpiamos pantalla
				signal(idDialog,s_kill);
				clear_screen();
				delete_text(all_text);
				optionNum = 0;
			end;
			case INTRO:
				//si no existe intro, la lanzamos
				if (!exists(TYPE gameIntro) && !introFinished)
					gameIntro(&introFinished);
				end;
				
				//si acaba la intro o pulsamos tecla, saltamos a splash
				if (introFinished )
					game.state = SPLASH;
				elseif (wgeCheckControl(CTRL_ANY,E_DOWN))
					//hacemos fade
					wgeFadeOut(FADE_SCREEN | FADE_MUSIC);
					//matamos el intro
					signal(TYPE gameIntro,s_kill_tree);
					//limpiamos pantalla
					screen_clear();
					delete_text(all_text);
					//saltamos a splash
					game.state = SPLASH;
				end;
			end;
			case SPLASH:
				//lanzamos el splash
				gameSplash();
				
				//encendemos pantalla
				wgeFadeIn(FADE_SCREEN);
					
				repeat
					counterTime++;
					
					//si pasan 10 segundos sin pulsar tecla
					if (counterTime >= cNumFPS*10)
						//activamos attractMode del nivel ToyLand
						attractActive = true;
						game.numLevel = TOYLAND_LEVEL;
						counterTime=0;					
					end;
					frame;
				until(wgeCheckControl(CTRL_ANY,E_DOWN) || attractActive);
				
				//apagamos pantalla
				wgeFadeOut(FADE_SCREEN);
				//matamos el splash
				signal(TYPE gameSplash,s_kill_tree);
				//cambiamos de estado
				if (attractActive)
					game.state = LOADLEVEL;
				else
					game.state = MENU;
				end;
			end;
			case MENU:
				//hacemos fade musica si segu�a sonando
				wgeFadeOut(FADE_MUSIC);
				
				//iniciamos la opcion del menu
				optionNum = 1;
				
				//componemos lista menu
				optionString = gameTexts[config.lang][MENU_TEXT];
				//componemos un cuadro de dialogo
				idDialog = wgeDialog(cResX>>1,cResY>>1,125,(text_height(fntGame,optionString)*2)+(dialogTextMarginY*2)+(dialogMenuPadding*2));
				
				//escribim,os las opciones
				wgeWriteDialogOptions(idDialog,optionString,optionNum);				
				
				//encendemos pantalla
				wgeFadeIn(FADE_SCREEN);
				
				//gestion del menu
				while (optionNum <> 0)
					//bajar opcion
					if (wgeCheckControl(CTRL_DOWN,E_DOWN) && optionNum<3)
						optionNum++;
						redrawMenu = true;
					end;
					//subir opcion
					if (wgeCheckControl(CTRL_UP,E_DOWN) && optionNum>1)
						optionNum--;
						redrawMenu = true;
					end;
					//seleccionar opcion
					if (wgeCheckControl(CTRL_START,E_DOWN))
						switch (optionNum)
							case 1: //Play
								//apagamos pantalla
								wgeFadeOut(FADE_SCREEN);
								//cambiamos de paso
								game.state = LOADLEVEL;
							end;
							case 2: //Config
								game.state = MENU_CONFIG;
							end;
							case 3: //Exit
								wgeQuit();
							end;
						end;
						//eliminamos menu y limpiamos pantalla
						signal(idDialog,s_kill);
						clear_screen();
						delete_text(all_text);
						optionNum = 0;
					end;
					
					if (redrawMenu)
						//escribimos las opciones
						wgeWriteDialogOptions(idDialog,optionString,optionNum);
						//cada vez que se redibuja el menu, reproducimos sonido
						wgePlayEntitySnd(id,gameSound[MENU_SND]);
						redrawMenu = false;
					end;
					
					frame;
				end;
								
			end;
			case MENU_CONFIG:
				//iniciamos la opcion del menu
				optionNum = 1;
				
				//componemos opciones menu
				optionString = gameTexts[config.lang][CONFIG_TEXT];
				//componemos un cuadro de dialogo
				idDialog = wgeDialog(cResX>>1,cResY>>1,250,(text_height(fntGame,optionString)*5)+(dialogTextMarginY*2)+(dialogMenuPadding*5));
				
				//escribimos las opciones
				wgeWriteDialogOptions(idDialog,optionString,optionNum);
				//escribimos los valores
				wgeWriteDialogValues(idDialog,gameTexts[config.lang][CONFIG_VAL1_TEXT],1,config.videoMode);
				wgeWriteDialogValues(idDialog,gameTexts[config.lang][CONFIG_VAL2_TEXT],2,config.lang);
				wgeWriteDialogVariable(idDialog,0,100,config.soundVolume,4);
				wgeWriteDialogVariable(idDialog,0,100,config.musicVolume,5);
						
				//gestion del menu
				while (optionNum <> 0)
					//bajar opcion
					if (wgeCheckControl(CTRL_DOWN,E_DOWN) && optionNum<6)
						optionNum++;
						redrawMenu = true;
					end;
					//subir opcion
					if (wgeCheckControl(CTRL_UP,E_DOWN) && optionNum>1)
						optionNum--;
						redrawMenu = true;
					end;
					//incrementar valor
					if (wgeCheckControl(CTRL_RIGHT,E_DOWN))
						switch (optionNum)
							case 1:
								config.videoMode < 2 ? config.videoMode ++ : config.videoMode = 0;
								wgeInitScreen();
							end;
							case 2:
								config.lang == ENG_LANG ? config.lang = ESP_LANG : config.lang = ENG_LANG;
								optionString = gameTexts[config.lang][CONFIG_TEXT];
							end;
							case 4:
								if (config.soundVolume < 100)
									config.soundVolume += 5;
									wgeSetChannelsVolume(config.soundVolume);
								end;
							end;
							case 5:
								if (config.musicVolume < 100)
									config.musicVolume += 5;
									set_song_volume(config.musicVolume*1.28);
								end;
							end;
						end;
						
						saveGameConfig();
						redrawMenu = true;
						
					end;
					//decrementar valor
					if (wgeCheckControl(CTRL_LEFT,E_DOWN))
						switch (optionNum)
							case 1:
								config.videoMode > 0 ? config.videoMode -- : config.videoMode = 2;
								wgeInitScreen();
							end;
							case 2:
								config.lang == ENG_LANG ? config.lang = ESP_LANG : config.lang = ENG_LANG;
								optionString = gameTexts[config.lang][CONFIG_TEXT];
							end;
							case 4:
								if (config.soundVolume > 0)
									config.soundVolume -= 5;
									wgeSetChannelsVolume(config.soundVolume);
								end;
							end;
							case 5:
								if (config.musicVolume > 0)
									config.musicVolume -= 5;
									set_song_volume(config.musicVolume*1.28);
								end;
							end;
						end;
						
						saveGameConfig();
						redrawMenu = true;
						
					end;
					//seleccionar opcion
					if (wgeCheckControl(CTRL_START,E_DOWN))
						switch (optionNum)
							case 3: //Controls
								game.state = MENU_CONTROLS;
								//salir del menu
								optionNum = 0;
							end;
							case 6: //Back
								game.state = MENU;
								//salir del menu
								optionNum = 0;
							end;
						end;
					end;
					
					//redibujamos menu
					if (redrawMenu)
						//escribimos las opciones
						wgeWriteDialogOptions(idDialog,optionString,optionNum);
						//escribimos los valores
						wgeWriteDialogValues(idDialog,gameTexts[config.lang][CONFIG_VAL1_TEXT],1,config.videoMode);
						wgeWriteDialogValues(idDialog,gameTexts[config.lang][CONFIG_VAL2_TEXT],2,config.lang);
						wgeWriteDialogVariable(idDialog,0,100,config.soundVolume,4);
						wgeWriteDialogVariable(idDialog,0,100,config.musicVolume,5);
						//cada vez que se redibuja el menu, reproducimos sonido
						wgePlayEntitySnd(id,gameSound[MENU_SND]);
						//reiniciamos flag
						redrawMenu = false;
					end;
					
					frame;
				end;
				
				//eliminamos menu y limpiamos pantalla
				signal(idDialog,s_kill);
				clear_screen();
				delete_text(all_text);
				optionNum = 0;
			end;
			case MENU_CONTROLS:
				//iniciamos la opcion del menu
				optionNum = 1;
				
				//componemos opciones menu
				optionString = gameTexts[config.lang][CONFIG_CONTROLS_TEXT];
				
				//componemos un cuadro de dialogo
				idDialog = wgeDialog(cResX>>1,cResY>>1,150,(text_height(fntGame,optionString)*2)+(dialogTextMarginY*2)+(dialogMenuPadding*2));
				
				//escribimos las opciones
				wgeWriteDialogOptions(idDialog,optionString,optionNum);
				
				//gestion del menu
				while (optionNum <> 0)
					//bajar opcion
					if (wgeCheckControl(CTRL_DOWN,E_DOWN) && optionNum<3)
						optionNum++;
						redrawMenu = true;
					end;
					//subir opcion
					if (wgeCheckControl(CTRL_UP,E_DOWN) && optionNum>1)
						optionNum--;
						redrawMenu = true;
					end;
					//seleccionar opcion
					if (wgeCheckControl(CTRL_START,E_DOWN))
						switch (optionNum)
							case 1: //Keyboard
								//cambiamos de paso
								game.state = MENU_KEYS;
								optionNum = 0;
							end;
							case 2: //GamePad
								game.state = MENU_BUTTONS;
								optionNum = 0;
							end;
							case 3: //Back
								game.state = MENU_CONFIG;
								optionNum = 0;
							end;
						end;
					end;
					
					if (redrawMenu)
						//escribimos las opciones
						wgeWriteDialogOptions(idDialog,optionString,optionNum);
						//cada vez que se redibuja el menu, reproducimos sonido
						wgePlayEntitySnd(id,gameSound[MENU_SND]);
						redrawMenu = false;
					end;
					
					frame;
				end;
				
				//eliminamos menu y limpiamos pantalla
				signal(idDialog,s_kill);
				clear_screen();
				delete_text(all_text);
			end;
			case MENU_KEYS:
				//iniciamos la opcion del menu
				optionNum = 1;
				
				//componemos opciones menu
				optionString = gameTexts[config.lang][CONFIG_CONTROLS_LIST_TEXT];
				
				//componemos un cuadro de dialogo
				idDialog = wgeDialog(cResX>>1,cResY>>1,200,(text_height(fntGame,optionString)*7)+(dialogTextMarginY*2)+(dialogMenuPadding*7));
				
				//escribimos las opciones
				wgeWriteDialogOptions(idDialog,optionString,optionNum);
				//escribimos los valores
				wgeWriteDialogValues(idDialog,";"+keyStrings[configuredKeys[CTRL_UP]]+";",1,0);
				wgeWriteDialogValues(idDialog,";"+keyStrings[configuredKeys[CTRL_DOWN]]+";",2,0);
				wgeWriteDialogValues(idDialog,";"+keyStrings[configuredKeys[CTRL_LEFT]]+";",3,0);
				wgeWriteDialogValues(idDialog,";"+keyStrings[configuredKeys[CTRL_RIGHT]]+";",4,0);
				wgeWriteDialogValues(idDialog,";"+keyStrings[configuredKeys[CTRL_JUMP]]+";",5,0);
				wgeWriteDialogValues(idDialog,";"+keyStrings[configuredKeys[CTRL_ACTION_ATACK]]+";",6,0);
				wgeWriteDialogValues(idDialog,";"+keyStrings[configuredKeys[CTRL_START]]+";",7,0);
				
				//gestion del menu
				while (optionNum <> 0)
					//bajar opcion
					if (wgeCheckControl(CTRL_DOWN,E_DOWN) && optionNum<8)
						optionNum++;
						redrawMenu = true;
					end;
					//bajar opcion
					if (wgeCheckControl(CTRL_UP,E_DOWN) && optionNum>1)
						optionNum--;
						redrawMenu = true;
					end;
					//seleccionar opcion
					if (wgeCheckControl(CTRL_START,E_DOWN))
						switch (optionNum)
							case 1..7: //redefinir controles
								wgeWriteDialogOptions(idDialog,optionString,optionNum);
								//escribimos press key en el control a cambiar
								wgeWriteDialogValues(idDialog,gameTexts[config.lang][PRESS_KEY_TEXT],optionNum,0);
								//esperamos a que se pulse la nueva tecla
								repeat
									frame;
								until (wgeCheckControl(CTRL_KEY_ANY,E_DOWN));
								//si no hemos cancelado el cambio
								if (lastKeyEvent <> _ESC)
									//asignamos esa tecla a las teclas configuradas
									configuredKeys[optionNum-1] = lastKeyEvent;
									saveGameConfig();
								end;
								//redibujamos el menu
								redrawMenu = true;
							end;
							case 8: //Back
								game.state = MENU_CONFIG;
								//salir del menu
								optionNum = 0;
							end;
						end;	
					end;
					
					//redibujamos menu
					if (redrawMenu)
						//escribimos las opciones
						wgeWriteDialogOptions(idDialog,optionString,optionNum);
						//escribimos los valores
						wgeWriteDialogValues(idDialog,";"+keyStrings[configuredKeys[CTRL_UP]]+";",1,0);
						wgeWriteDialogValues(idDialog,";"+keyStrings[configuredKeys[CTRL_DOWN]]+";",2,0);
						wgeWriteDialogValues(idDialog,";"+keyStrings[configuredKeys[CTRL_LEFT]]+";",3,0);
						wgeWriteDialogValues(idDialog,";"+keyStrings[configuredKeys[CTRL_RIGHT]]+";",4,0);
						wgeWriteDialogValues(idDialog,";"+keyStrings[configuredKeys[CTRL_JUMP]]+";",5,0);
						wgeWriteDialogValues(idDialog,";"+keyStrings[configuredKeys[CTRL_ACTION_ATACK]]+";",6,0);
						wgeWriteDialogValues(idDialog,";"+keyStrings[configuredKeys[CTRL_START]]+";",7,0);
						//cada vez que se redibuja el menu, reproducimos sonido
						wgePlayEntitySnd(id,gameSound[MENU_SND]);
						//reseteamos flag
						redrawMenu = false;
					end;
					
					frame;
				end;
				
				//eliminamos menu y limpiamos pantalla
				signal(idDialog,s_kill);
				clear_screen();
				delete_text(all_text);
			end;
			case MENU_BUTTONS:
				//iniciamos la opcion del menu
				optionNum = 1;
				
				//componemos opciones menu
				optionString = optionString = gameTexts[config.lang][CONFIG_CONTROLS_LIST_TEXT];;
				
				//componemos un cuadro de dialogo
				idDialog = wgeDialog(cResX>>1,cResY>>1,200,(text_height(fntGame,optionString)*7)+(dialogTextMarginY*2)+(dialogMenuPadding*7));
				
				//escribimos las opciones
				wgeWriteDialogOptions(idDialog,optionString,optionNum);
				//escribimos los valores
				wgeWriteDialogValues(idDialog,";"+joyStrings[configuredButtons[CTRL_UP]]+";",1,0);
				wgeWriteDialogValues(idDialog,";"+joyStrings[configuredButtons[CTRL_DOWN]]+";",2,0);
				wgeWriteDialogValues(idDialog,";"+joyStrings[configuredButtons[CTRL_LEFT]]+";",3,0);
				wgeWriteDialogValues(idDialog,";"+joyStrings[configuredButtons[CTRL_RIGHT]]+";",4,0);
				wgeWriteDialogValues(idDialog,";"+joyStrings[configuredButtons[CTRL_JUMP]]+";",5,0);
				wgeWriteDialogValues(idDialog,";"+joyStrings[configuredButtons[CTRL_ACTION_ATACK]]+";",6,0);
				wgeWriteDialogValues(idDialog,";"+joyStrings[configuredButtons[CTRL_START]]+";",7,0);
				
				//gestion del menu
				while (optionNum <> 0)
					//bajar opcion
					if (wgeCheckControl(CTRL_DOWN,E_DOWN) && optionNum<8)
						optionNum++;
						redrawMenu = true;
					end;
					//bajar opcion
					if (wgeCheckControl(CTRL_UP,E_DOWN) && optionNum>1)
						optionNum--;
						redrawMenu = true;
					end;
					//seleccionar opcion
					if (wgeCheckControl(CTRL_START,E_DOWN))
						switch (optionNum)
							case 1..7: //redefinir controles
								wgeWriteDialogOptions(idDialog,optionString,optionNum);
								//escribimos press key en el control a cambiar
								wgeWriteDialogValues(idDialog,gameTexts[config.lang][PRESS_BUTTON_TEXT],optionNum,0);
								//esperamos a que se pulse la nueva tecla
								repeat
									frame;
								until (wgeCheckControl(CTRL_BUTTON_ANY,E_DOWN) || wgeKey(_ESC,E_DOWN));
								//si no hemos cancelado el cambio
								if (lastKeyEvent <> _ESC)
									//asignamos esa tecla a las teclas configuradas
									configuredButtons[optionNum-1] = lastButtonEvent;
									saveGameConfig();
								end;
								//redibujamos el menu
								redrawMenu = true;
							end;
							case 8: //Back
								game.state = MENU_CONFIG;
								//salir del menu
								optionNum = 0;
							end;
						end;	
					end;
					
					//redibujamos menu
					if (redrawMenu)
						//escribimos las opciones
						wgeWriteDialogOptions(idDialog,optionString,optionNum);
						//escribimos los valores
						wgeWriteDialogValues(idDialog,";"+joyStrings[configuredButtons[CTRL_UP]]+";",1,0);
						wgeWriteDialogValues(idDialog,";"+joyStrings[configuredButtons[CTRL_DOWN]]+";",2,0);
						wgeWriteDialogValues(idDialog,";"+joyStrings[configuredButtons[CTRL_LEFT]]+";",3,0);
						wgeWriteDialogValues(idDialog,";"+joyStrings[configuredButtons[CTRL_RIGHT]]+";",4,0);
						wgeWriteDialogValues(idDialog,";"+joyStrings[configuredButtons[CTRL_JUMP]]+";",5,0);
						wgeWriteDialogValues(idDialog,";"+joyStrings[configuredButtons[CTRL_ACTION_ATACK]]+";",6,0);
						wgeWriteDialogValues(idDialog,";"+joyStrings[configuredButtons[CTRL_START]]+";",7,0);
						//cada vez que se redibuja el menu, reproducimos sonido
						wgePlayEntitySnd(id,gameSound[MENU_SND]);
						//reseteamos flag
						redrawMenu = false;
					end;
					
					frame;
				end;
				
				//eliminamos menu y limpiamos pantalla
				signal(idDialog,s_kill);
				clear_screen();
				delete_text(all_text);
			end;
			case PRELUDE:
				
				//creamos animacion "OldMan"
				wgeAnimation(fpgGame,13,13,130,112,0,ANIM_LOOP);
				
				//reproducimos la musica del nivel
				wgePlayMusicLevel();
				
				//encendemos pantalla
				wgeFadeIn(FADE_SCREEN);
				
				//se despiertan los procesos
				gameSignal(s_wakeup_tree);
				
				//reproducimos animacion player
				controlLoggerPlayer("prelude.rec");
				repeat
					frame;
				until(controlLoggerFinished);
				//congelamos al personaje
				signal(idPlayer,s_freeze);
				
				//mostramos los textos del preludio
				idDialog = wgeDialog(cResX>>1,cHUDRegionY+(cHUDRegionH>>1),cHUDRegionW-10,25);
				from i=PRELUDE1_TEXT to PRELUDE4_TEXT;
					delete_text(all_text);
					wgeWrite(fntGame,10,cHUDRegionY+(25>>1),ALIGN_CENTER_LEFT,gameTexts[config.lang][i]);
					repeat
						frame;
					until(wgeCheckControl(CTRL_ANY,E_DOWN));
				end;
				//eliminamos cuadro de texto
				delete_text(all_text);
				signal(idDialog,s_kill);
				
				//parpadea y desaparece el "old man"
				clockCounter = 0;
				repeat
					blinkEntity(get_id(TYPE wgeAnimation));
					frame;
				until (tickClock(cNumFPS*4));
				signal(TYPE wgeAnimation,s_kill);
				
				//retardo
				wgeWait(60);
				
				//subimos la puerta cambiando los tiles correspondientes
				from i=7 to 5 step -1;
					wgeReplaceTile(i,10,999);
					wgeReplaceTile(i,11,999);
					wgeReplaceTile(i,12,999);
					//reproducimos sonido
					wgePlayEntitySnd(id,objectSound[DOOR_SND]);
					//retardo				
					wgeWait(50);
				end;
				
				//reproducimos animacion player
				signal(idPlayer,s_wakeup);
				controlLoggerPlayer("prelude2.rec");
				repeat
					frame;
				until(controlLoggerFinished);
				
				//congelamos al personaje
				signal(idPlayer,s_freeze);
				
				//apagamos pantalla
				wgeFadeOut(FADE_SCREEN);
				
				//limpiamos el nivel
				clearLevel();
								
				//cambio de estado	
				game.numLevel 	= LEVEL_SELECT_LEVEL;
				game.state 		= LOADLEVEL;
				
			end;
			case LEVEL_SELECT:			
								
				//comprobacion entrada puertas
				if (wgeCheckControl(CTRL_UP,E_DOWN))  
					//Puerta 1: Woods
					if (colCheckAABB(idPlayer,79,108,30,40,INFOONLY) && game.levelStatus[WOODS_LEVEL] == LEVEL_UNCOMPLETED)
						//iniciamos nivel
						game.numLevel = WOODS_LEVEL;
						//cambio de estado				
						game.state = LOADLEVEL;
					end;
					//Puerta 2: Toyland
					if (colCheckAABB(idPlayer,143,108,30,40,INFOONLY) && game.levelStatus[TOYLAND_LEVEL] == LEVEL_UNCOMPLETED)
						//iniciamos nivel
						game.numLevel = TOYLAND_LEVEL;
						//cambio de estado				
						game.state = LOADLEVEL;
					end;
					//Puerta 3
					if (colCheckAABB(idPlayer,208,108,30,40,INFOONLY) && game.levelStatus[CANDYLAND_LEVEL] == LEVEL_UNCOMPLETED)
						//iniciamos nivel
						game.numLevel = CANDYLAND_LEVEL;
						//cambio de estado				
						game.state = LOADLEVEL;
					end;
				end;
				
				if (game.state <> LEVEL_SELECT)
					//congelamos al personaje
					signal(idPlayer,s_freeze);
					//apagamos pantalla y sonido
					wgeFadeOut(FADE_SCREEN | FADE_MUSIC);
					//limpiamos el nivel
					clearLevel();
					
				end;
			end;
			case LOADLEVEL:		
				//Cargamos el mapeado del nivel
				wgeLoadMapLevel(levelFiles[game.numLevel].MapFile,levelFiles[game.numLevel].TileFile);
				//Cargamos el archivo de datos del nivel
				wgeLoadLevelData(levelFiles[game.numLevel].DataFile);
				//Cargamos la musica del nivel
				level.idMusicLevel = load_song(levelFiles[game.numLevel].MusicFile);
								
				//Iniciamos Scroll
				wgeInitScroll();
				//Dibujamos el mapeado
				wgeDrawMap();
				//Creamos el nivel cargado
				wgeCreateLevel();
				
				//Creamos el jugador
				player();
				
				//procesos congelados
				gameSignal(s_freeze_tree);
				
				//Saltamos al estado correspondiente			
				switch (game.numLevel)
					case TUTORIAL_LEVEL:
						//encendemos pantalla
						wgeFadeIn(FADE_SCREEN);
						
						//se despiertan los procesos
						gameSignal(s_wakeup_tree);
						
						//reproducimos tutorial
						controlLoggerPlayer("tutorial.rec");
						write_var(fntGame,(cHUDRegionW >> 1),cHUDRegionY+cHUDTimeY,ALIGN_CENTER,textMsg);
						game.state = TUTORIAL;				
					end;
					case PRELUDE_LEVEL:
						game.state = PRELUDE;				
					end;
					case LEVEL_SELECT_LEVEL:
						
						//si no suena la musica, la reproducimos
						if (!is_playing_song())
							//reproducimos la musica del nivel
							wgePlayMusicLevel();
						end;
						
						//desperamos los tiles para hacer replace
						signal(TYPE pTile,s_wakeup);
						
						//comprobamos si hay algun nivel completado para "tapiar" puerta
						from i=0 TO cNumLevels;
							switch (i)
								case WOODS_LEVEL:
									levelDoorX = 81;
									levelDoorY = 96;
									startDoorTile = 4;
								end;
								case TOYLAND_LEVEL:
									levelDoorX = 145;
									levelDoorY = 96;
									startDoorTile = 8;
								end;
								case CANDYLAND_LEVEL:
									levelDoorX = 209;
									levelDoorY = 96;
									startDoorTile = 12;
								end;
							end;
							//si esta completado
							if (game.levelStatus[i] == LEVEL_COMPLETED)
								//lanzamos animacion de tapiar
								wgeAnimation(fpgGame,18,22,levelDoorX,levelDoorY,10,ANIM_ONCE);
								game.levelStatus[i] = LEVEL_DOOR_CLOSED;
								idPlayer.this.fX	= levelDoorX;
								idPlayer.x 			= levelDoorX;
							end;
							//si ya est� tapiado
							if (game.levelStatus[i] == LEVEL_DOOR_CLOSED)
								//cambiamos los tiles por tapiado
								wgeReplaceTile(5,startDoorTile,16);
								wgeReplaceTile(5,startDoorTile+1,17);
								wgeReplaceTile(6,startDoorTile,1);
								wgeReplaceTile(6,startDoorTile+1,1);
								wgeReplaceTile(7,startDoorTile,1);
								wgeReplaceTile(7,startDoorTile+1,1);
							end;
						end;
						
						//encendemos pantalla
						wgeFadeIn(FADE_SCREEN);
						
						//se despiertan los procesos
						gameSignal(s_wakeup_tree);
						
						//cambiamos de estado
						game.state = LEVEL_SELECT;
					end;
					default:
						if (attractActive)
							//encendemos pantalla
							wgeFadeIn(FADE_SCREEN);
						
							//se despiertan los procesos
							gameSignal(s_wakeup_tree);
							
							//reproducimos partida AttractMode
							controlLoggerPlayer("partida.rec");
							write_var(fntGame,(cHUDRegionW >> 1),cHUDRegionY+cHUDTimeY,ALIGN_CENTER,textMsg);
							game.state = ATTRACTMODE;
						else
							game.state = INITLEVEL;
						end;
					end;
				end;
			end;
			case INITLEVEL:
				//creamos el HUD (si no es attractMode)
				if (!attractActive)
					HUD();
				end;
				//variables de reinicio de nivel
				game.playerLife		 = game.playerMaxLife;
				game.actualLevelTime = level.levelTime;
				
				//reproducimos la musica del nivel
				wgePlayMusicLevel();
								
				//encendemos pantalla
				wgeFadeIn(FADE_SCREEN);
				
				//esperamos fin intro
				while (!wgeMusicIntroEnded())
					frame;
				end;

				//se despiertan los procesos
				gameSignal(s_wakeup_tree);
				
				//cambiamos de estado
				game.state = PLAYLEVEL;
			end;
			case PLAYLEVEL:
				
				//loop musica nivel
				if (!game.boss || memBoss)
					if (!is_playing_song())
						wgeRepeatMusicLevel();
					end;
				else
					wgeFadeOut(FADE_MUSIC);
					if (!is_playing_song())
						memBoss = true;
						//reproducimo musica boss
						play_song(gameMusic[BOSS_MUS],-1);
						//encerramos la boss zone
						closeBossRoom();
					end;
				end;
				
				//cronometro nivel	
				if ((clockCounter % cNumFps) == 0 && clockTick && !game.paused && level.levelTime <> 0)
					game.actualLevelTime--;
					//sonido cuenta atr�s
					if (game.actualLevelTime <= 30)
						wgePlayEntitySnd(id,gameSound[COUNTDOWN_SND]);
					end;
				end;
				
				//fin del nivel actual
				if (game.endLevel)
					game.state = LEVELENDED;
					memBoss = false;
				end;
				
				//muerte del jugador 
				if ( 
				   //por perdida energia
				   (game.playerLife == 0 && idPlayer.this.state != HURT_STATE) ||
				   (idPlayer.this.state == DEAD_STATE)                         ||
				    //por tiempo a 0
				   (game.actualLevelTime == 0 && level.levelTime <> 0)         ||
				   //por salir de la region
				   (!checkInRegion(idPlayer.x,idPlayer.y,idPlayer.this.ancho,idPlayer.this.alto<<1,CHECKREGION_DOWN) && !game.teleport)
				   )									
					//reproducimos sonido si no es muerte por region
					if (!out_region(idPlayer,cGameRegion) )
						wgePlayEntitySnd(id,playerSound[DEAD_SND]);
					end;
					//creamos el proceso/animacion muerte
					idDeadPlayer = deadPlayer();
					//matamos al player
					signal(idPlayer,s_kill);
					idPlayer = 0;
					//restamos una vida
					game.playerTries --;
					//bajamos flag boss
					memBoss = false;
					//esperamos a que el proceso muerte desaparezca de pantalla
					while(exists(idDeadPlayer))
						frame;
					end;
					//congelamos los procesos
					gameSignal(s_freeze_tree);
					
					//paramos la musica del nivel
					stop_song();
					//reproducimo musica muerte
					play_song(gameMusic[DEAD_MUS],0);
					//esperamos a que finalice
					while (is_playing_song())
						frame;
					end;
					
					//GameOver por perdida de vidas
					if (game.playerTries == 0 )
						game.state = GAMEOVER;
					else
						//reiniciamos el nivel
						game.state = RESTARTLEVEL;
					end;
				end;
				
				//pausa del juego
				if ((wgeCheckControl(CTRL_START,E_DOWN) || !window_status ) && !game.paused )
					game.paused = true;
					//congelamos procesos
					gameSignal(s_freeze_tree);
					//quitamos el HUD
					signal(TYPE HUD,s_kill);
					frame;
					//pausamos musica
					pause_song();
					//reproducimos sonido
					wgePlayEntitySnd(id,gameSound[PAUSE_SND]);
					
					//iniciamos la opcion del menu
					optionNum = 1;
			
					//componemos lista menu
					optionString = gameTexts[config.lang][MENU_PAUSE_TEXT];
					//componemos un cuadro de dialogo
					idDialog = wgeDialog(cResX>>1,cResY>>1,150,(text_height(fntGame,optionString)*2)+(dialogTextMarginY*2)+(dialogMenuPadding*2));
					
					//escribimos las opciones
					wgeWriteDialogOptions(idDialog,optionString,optionNum);
					
					//texto pausa
					pauseText = write(fntGame,cResX>>1,cResY-15,ALIGN_CENTER,gameTexts[config.lang][PAUSE_TEXT]);
				end;
				
				//Menu Pausa
				if (game.paused)
					//bajar opcion
					if (wgeCheckControl(CTRL_DOWN,E_DOWN) && optionNum<3)
						optionNum++;
						redrawMenu = true;
					end;
					//subir opcion
					if (wgeCheckControl(CTRL_UP,E_DOWN) && optionNum>1)
						optionNum--;
						redrawMenu = true;
					end;
					//seleccionar opcion
					if (wgeCheckControl(CTRL_START,E_DOWN))
						switch (optionNum)
							case 1: //Resume
								optionNum = 0;
								signal(idDialog,s_kill);
								delete_text(all_text);
								HUD();
								gameSignal(s_wakeup_tree);
								
								game.paused = false;
								resume_song();
								//reproducimos sonido
								wgePlayEntitySnd(id,gameSound[PAUSE_SND]);
							end;
							case 2: //Restart
								optionNum = 0;
								signal(idDialog,s_kill);
								delete_text(all_text);
								game.paused = false;
								memBoss = false;
								stop_song();
								//apagamos pantalla
								wgeFadeOut(FADE_SCREEN);
								//limpiamos el nivel
								clearLevel();
								//volvemos a la seleccion de puertas				
								game.numLevel = LEVEL_SELECT_LEVEL;		
								game.state = LOADLEVEL;
							end;
							case 3: //Exit
								optionNum = 0;
								game.paused = false;
								memBoss = false;
								signal(idDialog,s_kill);
								delete_text(all_text);
								stop_song();
								//apagamos pantalla
								wgeFadeOut(FADE_SCREEN);
								//limpiamos el nivel
								clearLevel();
								//continuamos juego
								game.state = RESTARTGAME;
							end;
						end;
					end;
					
					if (redrawMenu)
						//escribimos las opciones
						wgeWriteDialogOptions(idDialog,optionString,optionNum);
						//texto pausa
						pauseText = write(fntGame,cResX>>1,cResY-15,ALIGN_CENTER,gameTexts[config.lang][PAUSE_TEXT]);
						//cada vez que se redibuja el menu, reproducimos sonido
						wgePlayEntitySnd(id,gameSound[MENU_SND]);
						redrawMenu = false;
					end;					
				end;
				
				//teletransporte
				if (game.teleport && !checkInRegion(idPlayer.x,idPlayer.y,idPlayer.this.ancho,idPlayer.this.alto<<1,CHECKREGION_DOWN))
					//Congelamos los procesos
					gameSignal(s_freeze_tree);
					
					//apagamos la pantalla
					wgeFadeOut(FADE_SCREEN);
										
					//buscamos la salida del portal en el mapeado
					for (i=0;i < level.numTilesY;i++)
						for (j=0;j < level.numTilesX;j++)
							if (tilemap[i][j].tileCode == PORTAL_OUT)
								//cambiamos posicion de inicio a salida portal
								level.playerx0   = j*cTileSize;
								level.playery0   = i*cTileSize;
								break;
							end;
						end;
					end;
					//Reiniciamos el nivel
					wgeRestartLevel();
					
					//se despiertan los procesos para
					//actualizar el restart
					gameSignal(s_wakeup_tree);
				
					//frame para actualizar los procesos
					frame;
				
					//creamos al player
					idPlayer = player();
				
					//congelamos los procesos de nuevo
					gameSignal(s_freeze_tree);
	
					//encendemos la pantalla
					wgeFadeIn(FADE_SCREEN);
					//despertamos los procesos
					gameSignal(s_wakeup_tree);
					//bajamos flag teleport
					game.teleport = false;
				end;
				
			end;
			case RESTARTLEVEL:
				log("Reiniciando nivel",DEBUG_ENGINE);
				
				wgeFadeOut(FADE_SCREEN);
								
				//reiniciamos el nivel
				wgeRestartLevel();
								
				//se despiertan los procesos para
				//actualizar el restart
				gameSignal(s_wakeup_tree);
				
				//frame para actualizar los procesos
				frame;
				
				//creamos al player
				idPlayer = player();
				
				//congelamos los procesos de nuevo
				gameSignal(s_freeze_tree);
				
				//variables de reinicio de nivel
				game.playerLife = game.playerMaxLife;
				game.actualLevelTime = level.levelTime;
				
				//reproducimos la musica del nivel
				wgePlayMusicLevel();
				
				//encendemos pantalla
				wgeFadeIn(FADE_SCREEN);
				
				//esperamos fin intro
				while (!wgeMusicIntroEnded())
					frame;
				end;
								
				//se despiertan los procesos
				gameSignal(s_wakeup_tree);
								
				game.state = PLAYLEVEL;
				
			end;
			case LEVELENDED:
				log("finalizando nivel",DEBUG_ENGINE);
				//bajamos el flag
				game.endLevel = false;
				
				//congelamos durante la melodia de fin a los procesos
				gameSignal(s_freeze_tree);
				
				//paramos la musica del nivel
				stop_song();
				//reproducimo musica fin nivel
				play_song(gameMusic[END_LEVEL_MUS],0);
				//esperamos a que finalice
				while (is_playing_song())
					frame;
				end;
				
				//obtenemos puntuacion por tiempo restante
				repeat
					game.actualLevelTime--;
					game.score++;
					//reproducimos sonido
					wgePlayEntitySnd(id,gameSound[TIMESCORE_SND]);
					frame;
				until (game.actualLevelTime <= 0);
				
				//reproducimos sonido
				wgePlayEntitySnd(id,gameSound[STOPSCORE_SND]);
				
				wgeWait(100);
				
				//apagamos pantalla
				wgeFadeOut(FADE_SCREEN);
				
				//limpiamos el nivel
				clearLevel();
				//espera
				wgeWait(100);
				
				//marcamos el nivel como completado
				game.levelStatus[game.numLevel] = LEVEL_COMPLETED;
				
				//volvemos a la seleccion de puertas				
				game.numLevel = LEVEL_SELECT_LEVEL;		
				game.state = LOADLEVEL;
				
			end;
			case GAMEOVER:
				//apagamos pantalla
				wgeFadeOut(FADE_SCREEN);
				//limpiamos el nivel
				clearLevel();
				//encendemos pantalla
				wgeFadeIn(FADE_SCREEN);
				//mensaje hasta pulsar tecla
				write(fntGame,cResx>>1,cGameRegionH>>1,ALIGN_CENTER,gameTexts[config.lang][GAMEOVER_TEXT]);
				repeat
					frame;
				until(wgeCheckControl(CTRL_START,E_DOWN));
				//apagamos pantalla
				wgeFadeOut(FADE_SCREEN);
				//continuamos juego
				game.state = CONTINUEGAME;
			end;
			case CONTINUEGAME:
				delete_text(all_text);
				//cargamos nivel inicial
				game.numLevel=LEVEL_SELECT_LEVEL;
				game.score = 0;
				game.playerLife = game.playerMaxLife;
				game.playerTries = 3;
				game.state = SPLASH;
			end;
			case RESTARTGAME:
				game.numLevel=PRELUDE_LEVEL;
				game.score = 0;
				game.playerLife = game.playerMaxLife;
				game.playerTries = 3;
				game.state = SPLASH;
			end;
			case ATTRACTMODE:
				if (controlLoggerFinished || wgeCheckControl(CTRL_START,E_PRESSED))
					//apagamos pantalla y sonido
					wgeFadeOut(FADE_SCREEN | FADE_MUSIC);
					//desactivamos flag
					attractActive = false;
					//paramos reproduccion si no hubiera parado
					StopControlPlaying = true;
					//limpiamos el nivel
					clearLevel();
					//iniciamos nivel
					game.numLevel = 0;
					//pantalla inicial
					game.state = SPLASH;
				else
					//Mensaje attractMode
					if (tickClock(cNumFPS))
						textMsg =="" ? textMsg = gameTexts[config.lang][PRESS_START_TEXT] : textMsg = "";
					end;	
				end;
			end;
			case TUTORIAL:
				if (controlLoggerFinished || wgeCheckControl(CTRL_ANY,E_DOWN))
					//paramos reproduccion
					StopControlPlaying = true;
					//apagamos pantalla y sonido
					wgeFadeOut(FADE_SCREEN | FADE_MUSIC);						
					//limpiamos el nivel
					clearLevel();
						
					//cambiamos de estado
					game.numLevel = PRELUDE_LEVEL;
					//game.state = PRELUDE;
					game.state = LOADLEVEL;
				else
					//mensajes tutorial
					switch(controlPlayingFrame)
						case 1:
							textMsg = gameTexts[config.lang][TUTORIAL1_TEXT] + keyStrings[configuredKeys[CTRL_LEFT]]+","+keyStrings[configuredKeys[CTRL_RIGHT]]+"-";
						end;
						case 280:
							textMsg = gameTexts[config.lang][TUTORIAL2_TEXT]+keyStrings[configuredKeys[CTRL_JUMP]]+"-";
						end;
						case 601:
							textMsg = "-"+keyStrings[configuredKeys[CTRL_ACTION_ATACK]]+gameTexts[config.lang][TUTORIAL3_TEXT];
						end;
						case 1000:
							textMsg = gameTexts[config.lang][TUTORIAL4_TEXT]+keyStrings[configuredKeys[CTRL_ACTION_ATACK]]+"-";
						end;
						case 1200:
							textMsg = "-"+keyStrings[configuredKeys[CTRL_ACTION_ATACK]]+gameTexts[config.lang][TUTORIAL5_TEXT];
						end;
						case 1500:
							textMsg = "";
						end;
					end;
				end;
			end;
		end;
		
		frame;
	end;

end;

//Inicializaci�n del modo grafico
function wgeInitScreen()
begin
	//Complete restore para evitar "flickering" (no funciona)
	//hay un bug con una combinacion de scalemode y restore_type. Si no pongo complete restore y
	//uso scale mode, se cuelga al pasar al modo debug por ejemplo
	restore_type  = COMPLETE_RESTORE; //no provoca diferencia de fps
	//dump_type    = COMPLETE_DUMP;
	
	//hay relevancia de ca�da de frames segun mas grande es la resolucion de scale
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
		case MODE_WINDOW:
			full_screen = false;
			scale_mode=SCALE_NONE;
		end;
		case MODE_2XSCALE:
			scale_mode=SCALE_NORMAL2X;
		end;
		case MODE_FULLSCREEN:
			scale_mode=SCALE_NORMAL2X;
			full_screen = true;
		end;
	end;
	
	//resolucion depende del modo de compilacion
	#ifdef RELEASE
		set_mode(cResX,cResY,8);
	#else
		//set_mode(cResX,300,8,MODE_WAITVSYNC);//MODE_WAITVSYNC FIJA LOS FRAMES A 60
		set_mode(cResX,300,8);
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
	
	//Caida de frames radical si el mapa del scroll es peque�o (por tener que repetirlo?)
	start_scroll(cGameScroll,0,map_new(cGameRegionW,cGameRegionH,8),0,cGameRegion,3);
	
	scroll[cGameScroll].ratio = 100;
	log("Scroll creado",DEBUG_ENGINE);
	
	wgeControlScroll();

end;

//Desactivaci�n del engine y liberacion de memoria
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
	
	log("Se finaliza la ejecuci�n",DEBUG_ENGINE);
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
	#ifdef DYNAMIC_MEM
		free(tileMap);
	#endif
	
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
	
	
	//Creamos la matriz dinamica del tileMap
	#ifdef DYNAMIC_MEM
		//Primera dimension
		tileMap = calloc(level.numTilesY,sizeof(_tile));
		
		//comprobamos el direccionamiento
		if ( tileMap == NULL )
			log("Fallo alocando memoria din�mica (tileMap)",DEBUG_ENGINE);
			wgeQuit();
		end;
		//segunda dimension
		from i = 0 to level.numTilesY-1;
			tileMap[i] = calloc(level.numTilesX ,sizeof(_tile));
			//comprobamos el direccionamiento
			if ( tileMap[i] == NULL )
				log("Fallo alocando memoria din�mica (tileMap["+i+"])",DEBUG_ENGINE);
				wgeQuit();
			end;	
		end;
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
	
	//Si algun tile usa alpha, lo inicializamos
	if (mapUsesAlpha) wgeInitAlpha(); end;
	
	//leemos numero de animaciones
	fread(levelMapFile,tileAnimations.numAnimations);
	
	//si existe alguna animacion
	if ( tileAnimations.numAnimations > 0 )
		//Creamos la matriz dinamica de las secuencias de animacion
		#ifdef DYNAMIC_MEM
			tileAnimations.tileAnimTable = calloc(tileAnimations.numAnimations,sizeof(_tileAnimation));
			
			//comprobamos el direccionamiento
			if ( tileAnimations.tileAnimTable == NULL )
				log("Fallo alocando memoria din�mica (tileAnimations)",DEBUG_ENGINE);
				wgeQuit();
			end;
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
					log("Fallo alocando memoria din�mica (tileAnimTable.frameGraph) en secuencia"+i,DEBUG_ENGINE);
					wgeQuit();
				end;
			#endif
			//Creamos la matriz dinamica de la duracion de cada frame de animacion
			#ifdef DYNAMIC_MEM
				tileAnimations.tileAnimTable[i].frameTime = calloc(tileAnimations.tileAnimTable[i].numFrames,sizeof(byte));
				
				//comprobamos el direccionamiento
				if ( tileAnimations.tileAnimTable.frameTime == NULL )
					log("Fallo alocando memoria din�mica (tileAnimTable.frameTime) en secuencia"+i,DEBUG_ENGINE);
					wgeQuit();
				end;
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
	
	//creamos los procesos tiles segun la posicion x e y iniciales y la longitud de resolucion de pantalla
	//En los extremos de la pantalla se crean el numero definido de tiles (TILESOFFSCREEN) extras para asegurar la fluidez
	for (i=((y_inicial/cTileSize)-cTilesYOffScreen);i<(((cGameRegionH+y_inicial)/cTileSize)+cTilesYOffScreen);i++)
		for (j=((x_inicial/cTileSize)-cTilesXOffScreen);j<(((cGameRegionW+x_inicial)/cTileSize)+cTilesXOffScreen);j++)
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
			log("Fallo alocando memoria din�mica (objects)",DEBUG_ENGINE);
			wgeQuit();
		end;
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
	
	//numero de enemigos
	fread(levelDataFile,level.numMonsters);
	
	//Creamos el array dinamico de enemigos
	#ifdef DYNAMIC_MEM
		monsters = calloc(level.numMonsters,sizeof(_monster));
		
		//comprobamos el direccionamiento
		if ( monsters == NULL )
			log("Fallo alocando memoria din�mica (monsters)",DEBUG_ENGINE);
			wgeQuit();
		end;
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
	
	//numero de plataformas
	fread(levelDataFile,level.numPlatforms);
	
	//Creamos el array dinamico de plataformas
	#ifdef DYNAMIC_MEM
		platforms = calloc(level.numPlatforms,sizeof(_platform));
		
		//comprobamos el direccionamiento
		if ( platforms == NULL )
			log("Fallo alocando memoria din�mica (platforms)",DEBUG_ENGINE);
			wgeQuit();
		end;
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
	
	//numero de checkpoints
	fread(levelDataFile,level.numCheckPoints);
	
	//Creamos el array dinamico de checkpoints
	#ifdef DYNAMIC_MEM
		level.checkPoints = calloc(level.numCheckPoints,sizeof(_checkPoint));
		
		//comprobamos el direccionamiento
		if ( level.checkPoints == NULL )
			log("Fallo alocando memoria din�mica (checkPoints)",DEBUG_ENGINE);
			wgeQuit();
		end;
	#endif
	
	//leemos los checkpoints
	from i=0 to level.numCheckPoints-1;
		fread(levelDataFile,level.checkpoints[i].position.x);
		fread(levelDataFile,level.checkpoints[i].position.y);
		fread(levelDataFile,level.checkpoints[i]._flags);
	end;
	
	//cerramos el archivo
	fclose(levelDataFile);
	
	log("Fichero datos nivel le�do correctamente:",DEBUG_ENGINE);   
	log("Le�dos "+level.numObjects+" objetos",DEBUG_ENGINE);
	log("Le�dos "+level.numMonsters+" enemigos",DEBUG_ENGINE);
	log("Le�dos "+level.numPlatforms+" plataformas",DEBUG_ENGINE);
	log("Le�dos "+level.numCheckPoints+" checkPoints",DEBUG_ENGINE);
	
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
		
	//creamos los enemigos del nivel
	from i=0 to level.numMonsters-1;
		monster(monsters[i].monsterType,monsters[i].monsterX0,monsters[i].monsterY0,monsters[i].monsterAncho,monsters[i].monsterAlto,monsters[i].monsterAxisAlign,monsters[i].monsterFlags,monsters[i].monsterProps);	
	end;
	
	//creamos las plataformas del nivel
	from i=0 to level.numPlatforms-1;
		platform(platforms[i].platformType,platforms[i].platformGraph,platforms[i].platformX0,platforms[i].platformY0,platforms[i].platformAncho,platforms[i].platformAlto,platforms[i].platformAxisAlign,platforms[i].platformFlags,platforms[i].platformProps);		
	end;
	
End;

//Funcion que reinicia un nivel ya creado
function wgeRestartLevel()
private 
	int i;			//Indices auxiliares
end
Begin
    //detenemos los procesos
	signal(TYPE wgeControlScroll,s_kill_tree);
	signal(TYPE wgeUpdateTileAnimations,s_kill_tree);
	signal(TYPE pTile,s_kill_tree);
	if (exists(idPlayer)) 
		signal(idPlayer,s_kill);
	end;	
	
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
		
		//movimiento automatico si est� activo
		if (level.levelflags.autoScrollX)
			//incrementamos/decrementamos la posicion float
			level.levelflags.autoScrollX == 1 ? scrollfX += cVelAutoScroll : scrollfX -= cVelAutoScroll;
		else
			//Si el jugador ya est� en ejecuci�n, lo enfocamos
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
					//si no hay roomTransition, centramos scroll mientras no haya stopScroll o no est�s en los limites para aplicarlo
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
						//si no hay transicion vertical, ajustamos la posicion multiplo de tama�o tile
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
	//comprobamos si el tile es visible en la pantalla, asi, los tiles fuera de region no ser�n solidos
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
	//matamos los procesos
	gameSignal(s_kill_tree);
	idPlayer = 0;
	
	//quitamos el HUD
	signal(TYPE HUD,s_kill);
	
	//eliminamos textos
	delete_text(all_text);
	
	//Limpiamos la memoria dinamica
	#ifdef DYNAMIC_MEM
		free(objects);
		free(monsters);
		free(platforms);
		//free(paths);
		free(tileMap);
		free(tileAnimations);
	#endif
	
	//liberamos archivos cargados
	unload_fpg(level.fpgTiles);
	unload_fpg(level.fpgObjects);
	unload_fpg(level.fpgMonsters);
	
end;

//Cuadro de informacion en pantalla "Head's Up Display"
process HUD()
private
	string strScore;	//puntuacion en formato string 5 digitos
	string strTries;	//vidas en formato string 2 digitos
	string strTime;		//tiempo en formato string 3 digitos
	string strMessage;	//Mensaje pantalla
	
	int prevPlayerLife;	//Energia anterior del player para redibujar
	int i;				//variables auxiliares
begin
	region = cHUDRegion;
	ctype = C_SCREEN;
	
	//posicion del HUD
	x = (cHUDRegionW >> 1);
	y = cHUDRegionY;
		
	//grafico del HUD
	graph = map_clone(fpgGame,1);
	//cambiamos su centro
	map_info_set(file,graph,G_Y_CENTER,0);
	
	//mostramos string de puntuacion
	write_var(fntGame,x+cHUDScoreX,y+cHUDScoreY,ALIGN_CENTER,strScore);
	//mostramos string de vidas
	write_var(fntGame,x+cHUDTriesX,y+cHUDTriesY,ALIGN_CENTER,strTries);
	//mostramos tiempo nivel
	write_var(fntGame,x+cHUDTimeX,y+cHUDTimeY,ALIGN_CENTER,strTime);
		
	loop
		
		//Convertimos la puntuacion a string formato de 5 digitos
		int2String(game.score,&strScore,5);
		
		//Convertimos las vidas a string formato de 2 digitos
		int2String(game.playerTries,&strTries,2);
		
		//Convertimos el tiempo a string formato de 3 digitos
		int2String(game.actualLevelTime,&strTime,3);
		
		//comprobamos si ha cambiado la vida del player para redibujar
		if (prevPlayerLife <> game.playerLife)
		
			//copiamos el HUD vac�o
			map_del(0,graph);
			graph = map_clone(0,1);
			//reestablecemos el centro
			map_info_set(file,graph,G_Y_CENTER,0);
			
			//dibujamos las estrellas de energia
			for (i=0;i<game.playerMaxLife;i++)
				if (game.playerLife <= i)
					//estrella apagada
					map_put(0,graph,2,cHudLifeX+(cHUDLifeSize*i),cHudLifeY);
				else
					//estrella encendida
					map_put(0,graph,3,cHudLifeX+(cHUDLifeSize*i),cHudLifeY);
				end;
			end;
		end;
		
		//actualizamos la energia del player
		prevPlayerLife = game.playerLife;
				
		frame;
	end;

	onexit:
		delete_text(all_text);
end;

//funcion que convierte un entero a string a�adiendo ceros a la izquierda
function int2String(int entero,string *texto,int numDigitos)
begin
	//convertimos el entero a string
	*texto = itoa(entero);
	//a�adimos 0 a la izquierda
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

//cargamos archivos de sonido
function int loadSoundFiles()
private
	int numSoundFiles;		//numero de archivos
	int fileError;			//error en algun archivo
begin
	//iniciamos
	numSoundFiles = 0;
	fileError 	  = false;
	
	//musicas generales
	(gameMusic[DEAD_MUS]        = wgeLoadMusic("mus\dead.ogg")) 		<= 0 ? fileError = true : numSoundFiles++;
	(gameMusic[END_LEVEL_MUS]   = wgeLoadMusic("mus\levelEnd.ogg")) 	<= 0 ? fileError = true : numSoundFiles++;
	(gameMusic[BOSS_MUS]    	= wgeLoadMusic("mus\boss.ogg"))		<= 0 ? fileError = true : numSoundFiles++;
	(gameMusic[INTRO_MUS]    	= wgeLoadMusic("mus\intro.ogg"))		<= 0 ? fileError = true : numSoundFiles++;
	
	//sonidos generales
	(gameSound[PAUSE_SND] 		= wgeLoadSound("snd\pause.ogg")) 		<= 0 ? fileError = true : numSoundFiles++;
	(gameSound[TIMESCORE_SND] 	= wgeLoadSound("snd\timeScor.ogg")) 	<= 0 ? fileError = true : numSoundFiles++;
	(gameSound[STOPSCORE_SND] 	= wgeLoadSound("snd\endScore.ogg")) 	<= 0 ? fileError = true : numSoundFiles++;
	(gameSound[COUNTDOWN_SND] 	= wgeLoadSound("snd\count.ogg")) 	    <= 0 ? fileError = true : numSoundFiles++;
	(gameSound[MENU_SND]	 	= wgeLoadSound("snd\menu.ogg")) 	    <= 0 ? fileError = true : numSoundFiles++;
	
    //sonidos del jugador
	(playerSound[BOUNCE_SND] 	= wgeLoadSound("snd\bounce.ogg")) 		<= 0 ? fileError = true : numSoundFiles++;
	(playerSound[DEAD_SND] 		= wgeLoadSound("snd\dead.ogg")) 		<= 0 ? fileError = true : numSoundFiles++;	
	(playerSound[HURT_SND]		= wgeLoadSound("snd\hurt.ogg")) 		<= 0 ? fileError = true : numSoundFiles++;	
	(playerSound[JUMP_SND] 		= wgeLoadSound("snd\jump.ogg")) 		<= 0 ? fileError = true : numSoundFiles++;	
	(playerSound[PICK_SND]		= wgeLoadSound("snd\pick.ogg")) 		<= 0 ? fileError = true : numSoundFiles++;	
	(playerSound[STAIRS_SND]	= wgeLoadSound("snd\stairs.ogg")) 		<= 0 ? fileError = true : numSoundFiles++;	
	(playerSound[THROW_SND] 	= wgeLoadSound("snd\throw.ogg")) 		<= 0 ? fileError = true : numSoundFiles++;
	(playerSound[NOPICK_SND] 	= wgeLoadSound("snd\noPick.ogg")) 		<= 0 ? fileError = true : numSoundFiles++;
	
	//sonidos de objetos
	(objectSound[BREAK_SND] 	= wgeLoadSound("snd\break.ogg")) 		<= 0 ? fileError = true : numSoundFiles++;
	(objectSound[KILL_SND]		= wgeLoadSound("snd\kill.ogg")) 		<= 0 ? fileError = true : numSoundFiles++;
	(objectSound[KILLSOLID_SND] = wgeLoadSound("snd\killSolid.ogg")) 	<= 0 ? fileError = true : numSoundFiles++;
	(objectSound[PICKITEM_SND] 	= wgeLoadSound("snd\pickItem.ogg")) 	<= 0 ? fileError = true : numSoundFiles++;
	(objectSound[PICKCOIN_SND] 	= wgeLoadSound("snd\pickCoin.ogg")) 	<= 0 ? fileError = true : numSoundFiles++;
	(objectSound[PICKSTAR_SND] 	= wgeLoadSound("snd\star.ogg")) 		<= 0 ? fileError = true : numSoundFiles++;
	(objectSound[PICKTRIE_SND] 	= wgeLoadSound("snd\trie.ogg")) 		<= 0 ? fileError = true : numSoundFiles++;
	(objectSound[DOOR_SND] 	    = wgeLoadSound("snd\door.ogg")) 		<= 0 ? fileError = true : numSoundFiles++;
	
	//sonidos de enemigos
	(monsterSound[BUBBLE_SND]	= wgeLoadSound("snd\bubble.ogg")) 		<= 0 ? fileError = true : numSoundFiles++;
	(monsterSound[EXPLODE_SND]	= wgeLoadSound("snd\explode.ogg"))		<= 0 ? fileError = true : numSoundFiles++;
	
	fileError ? log("Ha habido un fallo en algun archivo de sonido",DEBUG_SOUND) : log("Cargados "+numSoundFiles+" archivos de sonido",DEBUG_SOUND);
	
	return !fileError;
	
end;

//funcion que realiza parpadeo de una entidad
function blinkEntity(int idEntity)
begin
	if (tickClock(cBlinkEntityTime))
		isBitSet(idEntity.flags,B_ABLEND) ? unsetBit(idEntity.flags,B_ABLEND) : setBit(idEntity.flags,B_ABLEND);
	end;
end;

//funcion que realiza animacion de introduccion. Devuelve 1 cuando termine
process gameIntro(*introFinished)
private
	int introTime;					//Tiempo animacion
	entity introAnimations[10];		//Array de animaciones	
	
begin
	//el porque de este primer frame es interesante. Si no lo ponemos, no liberamos al proceso Loop debido a que en este proceso llamaremos a funciones que enclavan bucles frame y, si no ha sido ejecutada por primera vez un frame en este proceso, y por consiguiente, no hemos vuelto al proceso Loop ha hacer su primer frame, ese proceso Loop se queda en estado WAIT colgado.
	frame;
	
	//apagamos y limpiamos la pantalla
	wgeFadeOut(FADE_SCREEN);
	screen_clear();
	delete_text(all_text);
	
	//reproducimos musica intro
	play_song(gameMusic[INTRO_MUS],0);
	timer[cMusicTimer] = 0;
	
	//mostramos pantallas y texto de introduccion
	wgeWrite(fntGame,cResX>>1,cResY>>1,ALIGN_CENTER,gameTexts[config.lang][INTRO1_TEXT]);
	introMusicTransition(4.0);
		
	put(fpgGame,16,cResX>>1,cResY>>1);
	introMusicTransition(8.0);
	
	wgeWrite(fntGame,10,50,ALIGN_CENTER_LEFT,gameTexts[config.lang][INTRO2_TEXT]);
	introMusicTransition(18.0);
	
	put(fpgGame,17,cResX>>1,cResY>>1);
	introMusicTransition(22.0);
	
	wgeWrite(fntGame,10,50,ALIGN_CENTER_LEFT,gameTexts[config.lang][INTRO3_TEXT]);
	introMusicTransition(30.0);	
	
	//definimos regiones para el scroll de la intro
	define_region(3,0,0,cGameRegionW,40);
	define_region(4,0,40,cGameRegionW,16);
	define_region(5,0,56,cGameRegionW,8);
	define_region(6,0,64,cGameRegionW,72);
	define_region(7,0,136,cGameRegionW,56);
	//arrancamos los scrolls
	start_scroll(1,fpgGame,4,0,3,3);
	start_scroll(2,fpgGame,5,0,4,3);
	start_scroll(3,fpgGame,6,0,5,3);
	start_scroll(4,fpgGame,7,0,6,3);
	start_scroll(5,fpgGame,8,0,7,3);
	//definimos la posicion inicial de las capas de scroll
	scroll[1].x0=162;
	scroll[2].x0=161;
	scroll[3].x0=196;
	scroll[4].x0=64;
	scroll[5].x0=154;
	//creamos las animaciones estaticas
	introAnimations[0] = wgeGameAnimation(fpgGame,9,9,172,120,10,ANIM_LOOP);
	introAnimations[1] = wgeGameAnimation(fpgGame,10,10,122,54,10,ANIM_LOOP);
	
	//encedemos pantalla
	wgeWait(150);
	wgeFadeIn(FADE_SCREEN);
	
	//hacemos el barrido de perspectiva hasta tiempo definido
	repeat
		introTime++;
		//movemos las animaciones
		introAnimations[0].x   -=((introTime % 4) == 0) && (scroll[5].x0 < cGameRegionW+16);
		introAnimations[1].x   +=((introTime % 8) == 0) && (scroll[4].x0 > 8);
		//movemos cada plano a distinta velocidad hasta su posicion
		scroll[1].x0-=((introTime % 1) == 0);
		scroll[2].x0-=((introTime % 2) == 0);
		scroll[3].x0-=((introTime % 3) == 0);
		scroll[4].x0-=((introTime % 8) == 0) && (scroll[4].x0 > 8);
		scroll[5].x0+=((introTime % 4) == 0) && (scroll[5].x0 < cGameRegionW+16);
		
		frame;
	until(timer[cMusicTimer]>= 4550);//(introTime >= 800);
	
	//devolvemos animacion terminada
	*introFinished = true;
	
	frame;
	
	//eliminamos los procesos animacion
	signal(introAnimations[0],s_kill);
	signal(introAnimations[1],s_kill);
	
end;

//Proceso que muestra el splash en pantalla
process gameSplash()
private
	entity gameAnimations[10];		//Array de animaciones	
	int splashTime;					//Tiempo de splash
	string textmsg;					//Texto Splash
begin
	//creamos los procesos de animacion
	gameAnimations[0] = wgeGameAnimation(fpgGame,9,9,54,120,10,ANIM_LOOP);
	gameAnimations[1] = wgeGameAnimation(fpgGame,10,10,178,54,10,ANIM_LOOP);
	gameAnimations[2] = wgeGameAnimation(fpgGame,11,11,cResX>>1,192>>1,10,ANIM_LOOP);
	gameAnimations[2].z--;
	
	//definimos regiones para el scroll del splash
	define_region(3,0,0,cGameRegionW,40);
	define_region(4,0,40,cGameRegionW,16);
	define_region(5,0,56,cGameRegionW,8);
	define_region(6,0,64,cGameRegionW,72);
	define_region(7,0,136,cGameRegionW,56);
	
	//arrancamos los scrolls
	start_scroll(1,fpgGame,4,0,3,3);
	start_scroll(2,fpgGame,5,0,4,3);
	start_scroll(3,fpgGame,6,0,5,3);
	start_scroll(4,fpgGame,7,0,6,3);
	start_scroll(5,fpgGame,8,0,7,3);
	//seteamos posicion scrolls
	scroll[4].x0 = 8;
	scroll[5].x0 = cGameRegionW+16;
	
		
	//mensaje hasta pulsar tecla
	write_var(fntGame,cGameRegionW>>1,cGameRegionH>>1,ALIGN_CENTER,textMsg);
	
	//version
	#ifdef _VERSION
		write(0,cResX-text_width(0,"v"+_VERSION),cResY-text_height(0,"v"+_VERSION),ALIGN_CENTER_LEFT,"v"+_VERSION);
	#endif
	
	loop
		//movemos planos nubes
		scroll[1].x0-=((splashTime % 1) == 0);
		scroll[2].x0-=((splashTime % 2) == 0);
		scroll[3].x0-=((splashTime % 3) == 0);
		
		//mensaje
		if (splashTime % 30 == 0)
			textMsg =="" ? textMsg = gameTexts[config.lang][PRESS_START_TEXT] : textMsg = "";
		end;
		
		splashTime++;
		
		frame;
	end;

onexit:
	//detenemos los scrolls
	stop_scroll(1);
	stop_scroll(2);
	stop_scroll(3);
	stop_scroll(4);
	stop_scroll(5);
	screen_clear();				
	//eliminamos texto
	delete_text(all_text);
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
	
	log("Archivo de configuraci�n guardado",DEBUG_ENGINE);
	
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
		
		
		log("Archivo de configuraci�n le�do",DEBUG_ENGINE);
	else
		config.videoMode   = 2;
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
		
		log("Archivo de idioma ENG le�do",DEBUG_ENGINE);
	else
		log("Falta el archivo de ENG",DEBUG_ENGINE);
		wgeQuit();
	end;
	
	//Cargamos el idioma Espa�ol
	
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
		
		log("Archivo de idioma ESP le�do",DEBUG_ENGINE);
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

//Proceso que cambia los tiles de una Boss Room para encerrar al player
process closeBossRoom()
begin
	//esperamos a que el player este vivo
	while( get_status(idPlayer) <> STATUS_ALIVE )
		frame;
	end;
	//reemplazamos los tiles necesarios para encerrar al player segun el nivel
	switch (game.numlevel)
		case WOODS_LEVEL:
			wgeReplaceTile(36,80,104);
			tileMap[36][80].tileCode = SOLID;
			wgeWait(20);
			wgeReplaceTile(37,80,104);
			tileMap[37][80].tileCode = SOLID;
			wgeWait(20);
			wgeReplaceTile(38,80,104);
			tileMap[38][80].tileCode = SOLID;
			wgeWait(20);
			wgeReplaceTile(39,80,104);
			tileMap[39][80].tileCode = SOLID;
			wgeWait(20);
		end;
		case TOYLAND_LEVEL:
			wgeReplaceTile(29,63,3);
			tileMap[29][63].tileCode = SOLID;
			wgeWait(20);
			wgeReplaceTile(30,63,3);
			tileMap[30][63].tileCode = SOLID;
			wgeWait(20);
			wgeReplaceTile(31,63,3);
			tileMap[31][63].tileCode = SOLID;
			wgeWait(20);
			wgeReplaceTile(32,63,3);
			tileMap[32][63].tileCode = SOLID;
			wgeWait(20);
		end;
	end;
end;