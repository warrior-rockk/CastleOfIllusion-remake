// ========================================================================
//  Warcom Game Engine
//  Motor para juegos plataformas 2D
//  16/04/15
//
//  Definiciones de las funciones de plataformas
// ========================================================================

//tipos de plataformas
#define PLATF_LINEAR 		0        

//propiedades plataformas
#define WAIT_PLAYER          4
#define FALL_PLAYER          8
#define FALL_COLLISION       16

//constantes de plataformas
const
	cPlatformFallVel		= 1.5;	//Velocidad caida plataformas
	cPlatformWaitTime       = 20;   //Tiempo espera plataformas
end;

//Objeto
Type _platform         			//Tipo de Dato de plataforma
	int platformType;      		//Tipo del objeto
	int platformGraph;    		//Grafico
	int platformX0;      		//Posicion X
	int platformY0;     		//Posicion Y
	int platformAncho;			//Ancho
	int platformAlto;			//Alto
	int platformAxisAlign;		//Eje
	int platformFlags;			//flags
	int platformProps;			//Propiedades
End;

Global
	_platform* platforms;			//Array Dinamico de objetos
end;

//declaracion de plataforma generica
Declare Process platform(int _platformType,int _graph,int _x0,int _y0,int _ancho,int _alto,int _axisAlign,int _flags,int _props)
public
	_entityPublicData this;			//datos publicos de entidad
end
end

//declaracion de objeto plataforma
Declare Process linearPlatform(int graph,int startX,int startY,int _ancho,int _alto,int _axisAlign,int _flags,int _props,float _vX)
public
	_entityPublicData this;			//datos publicos de entidad
end
end