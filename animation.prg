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
	
	//si el proceso cambia de estado, se reseta cuenta
	if ( idFather.prevState <> idFather.state )
		idFather.frameCount = 0;
	end;
	
	//si el proceso no tiene grafico aun, se le asigna el startFrame
	if (idFather.graph == 0)
		idFather.graph = startFrame;
	end;
	
	//evitamos el primer frame
	if (idfather.frameCount <> 0)
	    //si toca animar en el frame correspondiente
		if ( (idfather.frameCount % animationSpeed ) == 0  && clockTick)	
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
	idfather.frameCount+=clockTick;
	
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

	//lanzamos la animacion hasta que se acabe si el modo el ANIM_ONCE
	repeat
	
		endAnimation = WGE_Animate(startFrame,endFrame,animationSpeed,mode);
		
		frame;
	
	until(endAnimation && mode == ANIM_ONCE)
	
end;
