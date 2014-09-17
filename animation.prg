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
//animationSpeed en decimas de segundo
function int WGE_Animate(int startFrame, int endFrame, int animationSpeed)
begin
//si toca animar en el frame correspondiente
if (clockCounter <> 0)
	if (clockCounter % animationSpeed == 0  && clockTick)	
		//incrementamos frame si estamos en el rango
		if (father.graph < endFrame && father.graph >= startFrame)
			father.graph++;
		else 
			//si hemos llegado al final, pasamos al inicio
			father.graph = startFrame; 
			return true;
		end;
	else
	//si no nos toca animar, reseteamos a inicio en caso de que estemos fuera de rango
		if (father.graph > endFrame || father.graph < startFrame)
			father.graph = startFrame; 
		end;
	end;
end;

return false;

end;