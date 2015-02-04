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

begin
	animFinished = false;
	
	//evitamos el primer frame
	if (father.frameCount <> 0)
	    //si toca animar en el frame correspondiente
		if ( (father.frameCount % animationSpeed ) == 0  && clockTick)	
			//incrementamos frame si estamos en el rango
			if (father.graph < endFrame && father.graph >= startFrame)
				father.graph++;
			else 
				//si hemos llegado al final, pasamos al inicio
				if (mode == ANIM_LOOP)
					father.graph = startFrame; 
				end;
				animFinished =  true;
			end;
		else
		//si no nos toca animar, reseteamos a inicio en caso de que estemos fuera de rango
			if (father.graph > endFrame || father.graph < startFrame)
				father.graph = startFrame; 
			end;
		end;
	end;
	
	//incrementamos contador local 
	father.frameCount+=clockTick;
	
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
