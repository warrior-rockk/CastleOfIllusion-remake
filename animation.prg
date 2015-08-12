// ========================================================================
//  Warcom Game Engine
//  Motor para juegos plataformas 2D
//  16/09/14
//
//  Funciones animacion
// ========================================================================

//Funciona que anima el proceso que lo llama cambiando
//su grafico en cada llamada a la velocidad especificada
//Devuelve true cuando vuelve a empezar la animacion
function int WGE_Animate(int startFrame, int endFrame, int animationSpeed,int mode)
private
byte animFinished;	//flag de animacion terminada
entity idFather;	//entidad del proceso padre
begin
	animFinished = false;
	idFather = father.id;
	
	//no puede tener velocidad 0
	if (animationSpeed == 0) animationSpeed = 1; end;
	
	//si el proceso cambia de estado, se reseta cuenta
	if ( idFather.this.prevState <> idFather.this.state )
		idFather.this.frameCount = 0;
	end;
	
	//si el proceso no tiene grafico aun, se le asigna el startFrame
	if (idFather.graph == 0)
		idFather.graph = startFrame;
	end;
	
	//evitamos el primer frame
	if (idfather.this.frameCount <> 0)
	    //si toca animar en el frame correspondiente
		if ( (idfather.this.frameCount % animationSpeed ) == 0  && clockTick)	
			//incrementamos frame si estamos en el rango
			if (idfather.graph < endFrame && idfather.graph >= startFrame)
				idfather.graph++;
			else 
				//si hemos llegado al final, pasamos al inicio
				if (mode == ANIM_LOOP)
					idfather.graph = startFrame; 
				end;
				animFinished =  true;
			end;
		else
		//si no nos toca animar, reseteamos a inicio en caso de que estemos fuera de rango
			if (idfather.graph > endFrame || idfather.graph < startFrame)
				idfather.graph = startFrame; 
			end;
		end;
	end;
	
	//incrementamos contador local 
	idfather.this.frameCount+=clockTick;
	
	//devolvemos finalizado
	return animFinished;

end;

//Funcion que crea un proceso en pantalla mostrando una animación
process WGE_Animation(int file,int startFrame, int endFrame,int x,int y,int animationSpeed,int mode)
private
int endAnimation; //flag de animacion terminada

begin
	
	region = cGameRegion;
	ctype = c_scroll;
	
	z = cZObject;
	
	//no puede tener velocidad 0
	if (animationSpeed == 0) animationSpeed = 1; end;
	
	//lanzamos la animacion hasta que se acabe si el modo el ANIM_ONCE
	repeat
	
		endAnimation = WGE_Animate(startFrame,endFrame,animationSpeed,mode);
		
		frame;
	
	until(endAnimation && mode == ANIM_ONCE)
	
end;

//Funcion que crea un proceso en pantalla mostrando una animación pero no en la region de juego
process WGE_GameAnimation(int file,int startFrame, int endFrame,int x,int y,int animationSpeed,int mode)
private
int endAnimation; //flag de animacion terminada

begin
	
	z = cZObject;

	//lanzamos la animacion hasta que se acabe si el modo el ANIM_ONCE
	repeat
	
		endAnimation = WGE_Animate(startFrame,endFrame,animationSpeed,mode);
		
		frame;
	
	until(endAnimation && mode == ANIM_ONCE)
	
end;

//proceso que actualiza los frames de las animaciones de tiles para que vayan sincronizadas
process WGE_UpdateTileAnimations()
private
	int actualAnimation;	//animacion actual
begin
//finalizamos el proceso si no hay animaciones en el mapa
while(tileAnimations.numAnimations > 0 )
	//recorremos todas las animaciones
	for (actualAnimation = 0;actualAnimation < tileAnimations.numAnimations;actualAnimation++)
		if (tickClock(30))
			//incrementamos el frame actual o volvemos al inicio
			if (tileAnimations.tileAnimTable[actualAnimation].actualFrame < tileAnimations.tileAnimTable[actualAnimation].numFrames-1)
				tileAnimations.tileAnimTable[actualAnimation].actualFrame++;
			else
				tileAnimations.tileAnimTable[actualAnimation].actualFrame = 0;
			end;
		end;
	end;
	
	frame;
end;
end;