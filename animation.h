// ========================================================================
//  Warcom Game Engine
//  Motor para juegos plataformas 2D
//  11/02/15
//
//  Definiciones de las funciones de animacion
// ========================================================================

//Modos de la funcion animacion
#define ANIM_LOOP	0
#define ANIM_ONCE   1

//declaracion de proceso animation
Declare Process wgeAnimation(int file,int startFrame, int endFrame,int x,int y,int animationSpeed,int mode)
public
	_entityPublicData this;			//datos publicos de entidad
end
end

//declaracion de proceso gameAnimation
Declare Process wgeGameAnimation(int file,int startFrame, int endFrame,int x,int y,int animationSpeed,int mode)
public
	_entityPublicData this;			//datos publicos de entidad
end
end
