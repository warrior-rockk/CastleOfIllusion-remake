// ========================================================================
//  Warcom Game Engine
//  Motor para juegos plataformas 2D
//  19/03/15
//
//  Funciones controles
// ========================================================================

//Funcion que registra las pulsaciones de tecla para grabar partida
process keyLoggerRecorder()
private
	int keyFrameCounter;		//contador frames grabación
	int index;					//indice de registro
	
	int i;						//variable aux
begin 
	log("Grabacion iniciada",DEBUG_ENGINE);
	
	//limpiamos el buffer de grabacion
	for (i=0;i<ckeyLoggerMaxFrames;i++)
		keyLoggerRecord.frameTime[i] = 0;
		keyLoggerRecord.keyCode[i]   = 0;
	end;
	
	repeat
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
				log("Grabada tecla "+keysCheck[i]+" en frame: "+keyFrameCounter,DEBUG_ENGINE);
			end;
		end;
		
		keyFrameCounter ++;
		
		frame;
	
	until(WGE_Key(_control,KEY_PRESSED) && WGE_Key(_s,KEY_DOWN) || index == ckeyLoggerMaxFrames);
	
	log("Grabacion Finalizada",DEBUG_ENGINE);
end;

process keyLoggerPlayer()
private
	int keyFrameCounter;		//contador frames reproducción
	int index;					//indice del registro
	
	int i;						//variable aux
begin 
	log("Reproduccion iniciada",DEBUG_ENGINE);
	
	repeat
		//recorremos el array de teclas a comprobar
		for (i=0;i<ckeyCheckNumber;i++)
			//limpiamos la tecla
			keyLogger[keysCheck[i]] = false;
			//si el timestamp actual coincide con el registro y el codigo de la tecla
			if ( keyLoggerRecord.frameTime[index] == keyFrameCounter &&
      			 keyLoggerRecord.keyCode[index]   == keysCheck[i] )
				//seteamos la tecla en el keylogger
				keyLogger[keyLoggerRecord.keyCode[index]] = true;
				//incrementamos indice
				index++;
				if (index == ckeyLoggerMaxFrames)
					break;
				end;
				log("Reproducida tecla "+keysCheck[i]+" en frame: "+keyFrameCounter,DEBUG_ENGINE);
			end;
		end;
		
		keyFrameCounter ++;
		
		frame;
	
	until (index == ckeyLoggerMaxFrames);
	
	//limpiamos el buffer de reproduccion
	for (i=0;i<ckeyCheckNumber;i++)
		keyLogger[keysCheck[i]] = false;
	end;
	
	log("Reproduccion detenida",DEBUG_ENGINE);
end;
