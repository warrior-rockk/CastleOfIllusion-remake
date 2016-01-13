// ========================================================================
//  Castle of Illusion Remake
//  Remake del COI de Master System en Bennu
//  07/09/15
// ========================================================================

function gameInit()
begin
	//Iniciamos el engine
	wgeInit();
	
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
	
	//iniciamos variables juego
	game.playerTries 	= 3;
	game.playerLife 	= 3;
	game.playerMaxLife  = 3;
	game.score      	= 0;
	game.numLevel       = TUTORIAL_LEVEL;
	
	//estado inicial
	game.state = LOADING;
	
	//iniciaciones en compilacion release
	#ifdef RELEASE
		//desactivamos niveles inacabados
		game.levelStatus[WOODS_LEVEL] 		= LEVEL_DOOR_CLOSED;
		game.levelStatus[CANDYLAND_LEVEL] 	= LEVEL_DOOR_CLOSED;
	#endif
	
	//Iniciamos modo grafico
	wgeInitScreen();
	
	//arrancamos el loop principal
	gameLoop();
end;

//Bucle principal del juego
process gameLoop()
private
	int i,j; 								//Variables auxiliares
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
			case LOADING:
				//retardo para que la resolucion se setee correctamente
				write(fntGame,cResX>>1,cResY>>1,ALIGN_CENTER,gameTexts[config.lang][LOADING_TEXT]);
				
				//tiempo de seteo resolucion o pulsacion tecla
				repeat
					counterTime++;
					frame;
				until(wgeCheckControl(CTRL_ANY,E_DOWN) || (counterTime >= cNumFPS*cLoadingDelay));
				
				//apagamos pantalla
				wgeFadeOut(FADE_SCREEN);
				//borramos texto
				delete_text(all_text);
				//cambiamos de estado
				firstRun ? game.state = LANG_SEL : game.state = INTRO;
			end;
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
				//hacemos fade musica si seguía sonando
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
				//loop musica nivel
				if (!is_playing_song())
					wgeRepeatMusicLevel();
				end;
					
				//comprobacion entrada puertas
				if (!game.paused)
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
				
				//Pausa
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
					optionString = gameTexts[config.lang][MENU_PAUSE_DOORS_TEXT];
					//componemos un cuadro de dialogo
					idDialog = wgeDialog(cResX>>1,cResY>>1,150,(text_height(fntGame,optionString)*1)+(dialogTextMarginY*2)+(dialogMenuPadding*1));
					
					//escribimos las opciones
					wgeWriteDialogOptions(idDialog,optionString,optionNum);
					
					//texto pausa
					pauseText = write(fntGame,cResX>>1,cResY-15,ALIGN_CENTER,gameTexts[config.lang][PAUSE_TEXT]);
				end;
				
				//Menu Pausa
				if (game.paused)
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
							case 2: //Exit
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
							//si ya está tapiado
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
					//sonido cuenta atrás
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
				if (game.teleport && exists(idPlayer))
					if (!checkInRegion(idPlayer.x,idPlayer.y,idPlayer.this.ancho,idPlayer.this.alto<<1,CHECKREGION_DOWN))
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
		
			//copiamos el HUD vacío
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