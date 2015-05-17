// ========================================================================
//  Warcom Game Engine
//  Motor para juegos plataformas 2D
//  19/03/15
//
//  Funciones controles
//
//  Funcion estado de tecla basado en código de SplinterGU
// ========================================================================

//Funcion que devuelve el estado del control solicitado
function WGE_CheckControl(int control,int event)
begin
	switch (event)
		case KEY_DOWN:
			return (keyState[ configuredKeys[control] ][ keyUse ] && !keyState[ configuredKeys[control] ][ keyUse ^ 1 ]) ||
			       (joyState[ configuredButtons[control] ][ keyUse ] && !joyState[ configuredButtons[control] ][ keyUse ^ 1 ]);
		end;
		case KEY_UP:
			return (!keyState[ configuredKeys[control] ][ keyUse ] &&  keyState[ configuredKeys[control] ][ keyUse ^ 1 ]) ||
			       (!joyState[ configuredButtons[control] ][ keyUse ] &&  joyState[ configuredButtons[control] ][ keyUse ^ 1 ]);
		end;
		case KEY_PRESSED:
			return ( keyState[ configuredKeys[control] ][ keyUse ]) ||
			       ( joyState[ configuredButtons[control] ][ keyUse ]);
		end;
	end;
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
		keyState[ i ][ keyUse ] = ( key( i ) && !keyLoggerPlaying ) || 
								  ( keyLogger[ i ] && keyLoggerPlaying );
	end;
end;	

//Funcion que devuelve el estado de la tecla solicitado
function WGE_Key(int k,int event)
begin
return ((event==KEY_DOWN)?(  keyState[ k ][ keyUse ] && !keyState[ k ][ keyUse ^ 1 ] ): \
		(event==KEY_UP  )?( !keyState[ k ][ keyUse ] &&  keyState[ k ][ keyUse ^ 1 ] ): \
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
	for ( i = 0; i < 8; i++ )
		joyState[ i ][ joyUse ] =  joy_getbutton(0,i);
	end;
	//arriba
	joyState[9][ joyUse ] 	= joy_getaxis(0,1) == -32768;
	//abajo
	joyState[10][ joyUse ] 	= joy_getaxis(0,1) ==  32767;
	//izquierda
	joyState[11][ joyUse ] 	= joy_getaxis(0,0) ==  -32768;
	//derecha
	joyState[12][ joyUse ] 	= joy_getaxis(0,0) == 32767;
end;

//Funcion que devuelve el estado del boton solicitado
function WGE_Button(int b,int event)
begin
return ((event==KEY_DOWN)?(  joyState[ b ][ keyUse ] && !joyState[ b ][ keyUse ^ 1 ] ): \
		(event==KEY_UP  )?( !joyState[ b ][ keyUse ] &&  joyState[ b ][ keyUse ^ 1 ] ): \
		( joyState[ b ][ keyUse ]));
end;

//Funcion que registra las pulsaciones de tecla para grabar partida
process keyLoggerRecorder(string _file)
private
	int keyFrameCounter;		//contador frames grabación
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
	
	until(index == ckeyLoggerMaxFrames || WGE_Key(_control,KEY_PRESSED) && WGE_Key(_s,KEY_DOWN));
	
	//marcamos fin de grabacion si no llegó al maximo
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
		log("Archivo "+_file+" guardado con éxito",DEBUG_ENGINE);
	else
		log("Grabacion se guarda en memoria",DEBUG_ENGINE);
	end;
end;

process keyLoggerPlayer(string _file)
private
	int keyFrameCounter;		//contador frames reproducción
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
		log("Archivo "+_file+" leído con éxito",DEBUG_ENGINE);
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
end;
