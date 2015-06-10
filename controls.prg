// ========================================================================
//  Warcom Game Engine
//  Motor para juegos plataformas 2D
//  19/03/15
//
//  Funciones controles
//
//  Rutina contenida en WGE_Key basado en c�digo de SplinterGU
// ========================================================================

//Proceso encargado de actualizar el estado de los controles
process WGE_UpdateControls()
begin
	loop
		//actualizamos el estado de las teclas
		keyStateUpdate();
		//actualizamos el estado de los botones
		joyStateUpdate();
		
		frame;
	end;
end;

//Funcion que devuelve el estado del control solicitado
function WGE_CheckControl(int control,int event)
begin
	return (WGE_Key(configuredKeys[control],event)  	 && (!controlLoggerPlaying || control==CTRL_START)) ||
	       (WGE_Button(configuredButtons[control],event) && (!controlLoggerPlaying || control==CTRL_START)) ||
		   (controlLogger[control][event]				 &&  controlLoggerPlaying);
end;

//Funcion actualizacion estado de teclas
function keyStateUpdate()
private
	int i;		//variable aux
begin
	//intercambiamos el flanco
	keyUse ^= 1;
	//recorremos el array de estados tecla
	for ( i = 0; i < 127; i++ )
		keyState[ i ][ keyUse ] = key( i );
	end;
end;	

//Funcion que devuelve el estado de la tecla solicitado
function WGE_Key(byte k,int event)
begin
return ((event==E_DOWN)?(  keyState[ k ][ keyUse ] && !keyState[ k ][ keyUse ^ 1 ] ): \
		(event==E_UP  )?( !keyState[ k ][ keyUse ] &&  keyState[ k ][ keyUse ^ 1 ] ): \
		( keyState[ k ][ keyUse ]));
end;

//Funcion actualizacion estado de botones joystick
function JoyStateUpdate()
private
	int i;		//variable aux
begin
	//intercambiamos el flanco
	joyUse ^= 1;
	//recorremos el array de estados botones
	for ( i = 0; i < 10; i++ )
		joyState[ i ][ joyUse ] =  joy_getbutton(0,i);
	end;
	
	//arriba
	joyState[10][ joyUse ] 	= joy_getaxis(0,1) == -32768;
	//abajo
	joyState[11][ joyUse ] 	= joy_getaxis(0,1) ==  32767;
	//izquierda
	joyState[12][ joyUse ] 	= joy_getaxis(0,0) ==  -32768;
	//derecha
	joyState[13][ joyUse ] 	= joy_getaxis(0,0) == 32767;
	
end;

//Funcion que devuelve el estado del boton solicitado
function WGE_Button(byte b,int event)
begin
return ((event==E_DOWN)?(  joyState[ b ][ keyUse ] && !joyState[ b ][ keyUse ^ 1 ] ): \
		(event==E_UP  )?( !joyState[ b ][ keyUse ] &&  joyState[ b ][ keyUse ^ 1 ] ): \
		( joyState[ b ][ keyUse ]));
end;

//Funcion que registra los controles para grabar partida
process ControlLoggerRecorder(string _file)
private
	int controlFrameCounter;		//contador frames grabaci�n
	int index;					//indice de registro
	
	int recordFile;				//archivo de grabacion
	int i;						//variable aux
begin 	
	//iniciamos flags
	controlLoggerRecording = true;
	controlLoggerFinished = false;
	
	log("Grabacion iniciada",DEBUG_ENGINE);
	
	//limpiamos el buffer de grabacion
	for (i=0;i<cControlLoggerMaxFrames;i++)
		controlLoggerRecord.frameTime[i] = 0;
		controlLoggerRecord.controlCode[i]   = 0;
	end;
	
	//loop grabacion
	repeat
		//comprobamos si el player esta vivo
		if (get_status(idPlayer) <> STATUS_ALIVE)
			log("Esperando a player para grabacion",DEBUG_ENGINE);
		else
						
			//comprobamos todos los controles disponibles
			for (i=0;i<=cControlCheckNumber;i++)
				//si se ha presionado un control
				if (WGE_CheckControl(i,E_PRESSED))
					//registramos el control con el frametimestamp
					controlLoggerRecord.frameTime[index] = controlFrameCounter;
					controlLoggerRecord.controlCode[index]   = i;
					//registramos el tipo de evento
					if (WGE_CheckControl(i,E_DOWN))
						controlLoggerRecord.controlEvent[index]  	 = E_DOWN;
					elseif (WGE_CheckControl(i,E_UP))
						controlLoggerRecord.controlEvent[index]  = E_UP;
					else
						controlLoggerRecord.controlEvent[index]  = E_PRESSED;
					end;
					
					//incrementamos el indice
					index ++;
					if (index == cControlLoggerMaxFrames)
						break;
					end;
					log("Grabado control "+controlStrings[i]+" con evento "+controlLoggerRecord.controlEvent[index-1]+" en frame: "+controlFrameCounter+" e indice: "+index,DEBUG_ENGINE);
				end;
			end;
			
			controlFrameCounter ++;
		
		end;
		
		frame;
	
	until(index == cControlLoggerMaxFrames || WGE_Key(_control,E_PRESSED) && WGE_Key(_s,E_DOWN));
	
	//marcamos fin de grabacion si no lleg� al maximo
	if (index < cControlLoggerMaxFrames)
		controlLoggerRecord.frameTime[index] = controlFrameCounter;
		controlLoggerRecord.controlCode[index]   = cendRecordCode; 	
	end;
	
	controlLoggerRecording = false;
	
	log("Grabacion Finalizada",DEBUG_ENGINE);
	
	//guardamos la grabacion a archivo
	if (_file <> "" )
		recordFile = fopen(_file,O_WRITE);
		//escribimos los registros grabados
		for (i=0;i<ccontrolLoggerMaxFrames;i++)
			fwrite(recordFile,controlLoggerRecord.frameTime[i]);
			fwrite(recordFile,controlLoggerRecord.controlCode[i]);
			fwrite(recordFile,controlLoggerRecord.controlEvent[i]);
		end;
		//cerramos el archivo
		fclose(recordFile);
		log("Archivo "+_file+" guardado con �xito",DEBUG_ENGINE);
	else
		log("Grabacion se guarda en memoria",DEBUG_ENGINE);
	end;
end;

//funcion que reproduce los controles grabados
process controlLoggerPlayer(string _file)
private
	int index;					//indice del registro
	
	int playerFile;				//archivo de reproduccion
	int i;						//variable aux
begin 
	//iniciamos flags
	controlLoggerFinished = false;
	StopControlPlaying	  = false;
	
	//abrimos la reproduccion de archivo
	if (_file <> "" && fexists(_file) )
		playerFile = fopen(_file,O_READ);
		//leemos los registros grabados
		for (i=0;i<cControlLoggerMaxFrames;i++)
			fread(playerFile,controlLoggerRecord.frameTime[i]);
			fread(playerFile,controlLoggerRecord.controlCode[i]);
			fread(playerFile,controlLoggerRecord.controlEvent[i]);
		end;
		//cerramos el archivo
		fclose(playerFile);
		log("Archivo "+_file+" le�do con �xito",DEBUG_ENGINE);
	else
		log("Grabacion se lee de memoria",DEBUG_ENGINE);
	end;
	
	log("Reproduccion iniciada",DEBUG_ENGINE);
	
	repeat
		//comprobamos si el player esta vivo
		if (get_status(idPlayer) <> STATUS_ALIVE)
			log("Esperando a player para reproduccion",DEBUG_ENGINE);
			controlLoggerPlaying = false;
		else
			controlLoggerPlaying = true;
			
			//recorremos el array de teclas a comprobar
			for (i=0;i<cControlCheckNumber;i++)
				//limpiamos los eventos del control actual
				controlLogger[i][E_PRESSED] = false;
				controlLogger[i][E_DOWN]	= false;
				controlLogger[i][E_UP] 		= false;
				//si el timestamp actual coincide con el registro y el control activo es el actual
				if ( controlLoggerRecord.frameTime[index] == controlPlayingFrame && 
					 controlLoggerRecord.controlCode[index]  == i )
					//seteamos el control y su evento en el controlLogger
					controlLogger[controlLoggerRecord.controlCode[index]][controlLoggerRecord.controlEvent[index]] = true;
					//si el evento es E_DOWN, �mplicitamente es E_PRESSED tambi�n
					if (controlLoggerRecord.controlEvent[index] == E_DOWN)
						controlLogger[controlLoggerRecord.controlCode[index]][E_PRESSED] = true;
					end;
					
					//incrementamos indice
					index++;
					if (index == cControlLoggerMaxFrames)
						break;
					end;
					log("Reproducido control "+controlStrings[i]+" con evento:"+controlLoggerRecord.controlEvent[index-1]+" en frame: "+controlPlayingFrame+" e indice: "+index,DEBUG_ENGINE);
				end;
			end;
			
			controlPlayingFrame ++;

		end;
		
		frame;
	
	//se comprueba con key porque WGE_Key esta deshabilitado en reproduccion
	until (index == cControlLoggerMaxFrames || controlLoggerRecord.controlCode[index]  == cendRecordCode || key(_control) && key(_s) || StopControlPlaying ); 
	
	//limpiamos el buffer de reproduccion
	for (i=0;i<cControlCheckNumber;i++)
		controlLogger[i][E_PRESSED] = false;
		controlLogger[i][E_DOWN]	= false;
		controlLogger[i][E_UP] 		= false;
	end;
	
	//reiniciamos flags
	controlLoggerPlaying = false;
	controlLoggerFinished = true;
	StopControlPlaying = false;
	
	log("Reproduccion detenida",DEBUG_ENGINE);
end;

//FUNCIONES ANTIGUAS NO USADAS DE GRABACION DE TECLAS

/*
//Funcion que registra las pulsaciones de tecla para grabar partida
process keyLoggerRecorder(string _file)
private
	int keyFrameCounter;		//contador frames grabaci�n
	int index;					//indice de registro
	
	int recordFile;				//archivo de grabacion
	int i;						//variable aux
begin 
	keyLoggerRecording = true;
	
	log("Grabacion iniciada",DEBUG_ENGINE);
	
	//limpiamos el buffer de grabacion
	for (i=0;i<ckeyLoggerMaxFrames;i++)
		keyLoggerRecord.frameTime[i] = 0;
		keyLoggerRecord.keyCode[i]   = 0;
	end;
	
	repeat
		//si se ha pulsado alguna tecla
		if (scan_code)
			//recorremos el array de teclas a registrar
			for (i=0;i<ckeyCheckNumber;i++)
				//si se ha pulsado la tecla del array
				if (key(keysCheck[i]))
					//registramos la tecla con el frametimestamp
					keyLoggerRecord.frameTime[index] = keyFrameCounter;
					keyLoggerRecord.keyCode[index]   = keysCheck[i];
					//incrementamos el indice
					index ++;
					if (index == ckeyLoggerMaxFrames)
						break;
					end;
					log("Grabada tecla "+keysCheck[i]+" en frame: "+keyFrameCounter+" e indice: "+index,DEBUG_ENGINE);
				end;
			end;
		end;
		
		keyFrameCounter ++;
		
		frame;
	
	until(index == ckeyLoggerMaxFrames || WGE_Key(_control,E_PRESSED) && WGE_Key(_s,E_DOWN));
	
	//marcamos fin de grabacion si no lleg� al maximo
	if (index < ckeyLoggerMaxFrames)
		keyLoggerRecord.frameTime[index] = keyFrameCounter;
		keyLoggerRecord.keyCode[index]   = cendRecordCode; 	
	end;
	
	keyLoggerRecording = false;
	
	log("Grabacion Finalizada",DEBUG_ENGINE);
	
	//guardamos la grabacion a archivo
	if (_file <> "" )
		recordFile = fopen(_file,O_WRITE);
		//escribimos los registros grabados
		for (i=0;i<ckeyLoggerMaxFrames;i++)
			fwrite(recordFile,keyLoggerRecord.frameTime[i]);
			fwrite(recordFile,keyLoggerRecord.keyCode[i]);
		end;
		//cerramos el archivo
		fclose(recordFile);
		log("Archivo "+_file+" guardado con �xito",DEBUG_ENGINE);
	else
		log("Grabacion se guarda en memoria",DEBUG_ENGINE);
	end;
end;

process keyLoggerPlayer(string _file)
private
	int keyFrameCounter;		//contador frames reproducci�n
	int index;					//indice del registro
	
	int playerFile;				//archivo de reproduccion
	int i;						//variable aux
begin 
	//abrimos la reproduccion de archivo
	if (_file <> "" && fexists(_file) )
		playerFile = fopen(_file,O_READ);
		//leemos los registros grabados
		for (i=0;i<ckeyLoggerMaxFrames;i++)
			fread(playerFile,keyLoggerRecord.frameTime[i]);
			fread(playerFile,keyLoggerRecord.keyCode[i]);
		end;
		//cerramos el archivo
		fclose(playerFile);
		log("Archivo "+_file+" le�do con �xito",DEBUG_ENGINE);
	else
		log("Grabacion se lee de memoria",DEBUG_ENGINE);
	end;
	
	keyLoggerPlaying = true;
	
	log("Reproduccion iniciada",DEBUG_ENGINE);
	
	repeat
		//recorremos el array de teclas a comprobar
		for (i=0;i<ckeyCheckNumber;i++)
			//limpiamos la tecla
			keyLogger[keysCheck[i]] = false;
			//si el timestamp actual coincide con el registro y la tecla es una del array a comprobar
			if ( keyLoggerRecord.frameTime[index] == keyFrameCounter && 
				 keyLoggerRecord.keyCode[index]  == keysCheck[i] )
				//seteamos la tecla en el keylogger
				keyLogger[keyLoggerRecord.keyCode[index]] = true;
				//incrementamos indice
				index++;
				if (index == ckeyLoggerMaxFrames)
					break;
				end;
				log("Reproducida tecla "+keysCheck[i]+" en frame: "+keyFrameCounter+" e indice: "+index,DEBUG_ENGINE);
			end;
		end;
		
		keyFrameCounter ++;

		frame;
	
	//se comprueba con key porque WGE_Key esta deshabilitado en reproduccion
	until (index == ckeyLoggerMaxFrames || keyLoggerRecord.keyCode[index]  == cendRecordCode || key(_control) && key(_s)); 
	
	//limpiamos el buffer de reproduccion
	for (i=0;i<ckeyCheckNumber;i++)
		keyLogger[keysCheck[i]] = false;
	end;
	
	keyLoggerPlaying = false;
	
	log("Reproduccion detenida",DEBUG_ENGINE);
end;*/