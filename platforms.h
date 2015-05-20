// ========================================================================
//  Warcom Game Engine
//  Motor para juegos plataformas 2D
//  16/04/15
//
//  Definiciones de las funciones de plataformas
// ========================================================================

//tipos de plataformas
#define PLATF_LINEAR 		0        
#define PLATF_CLOUD 		1        
#define PLATF_SPRINGBOX		2

//propiedades plataformas
#define PLATF_WAIT_PLAYER          8		//Esta en espera a que suba el player
#define PLATF_FALL_PLAYER          16		//Se cae cuando sube el player
#define PLATF_FALL_COLLISION       32		//Se cae cuando colisiona con pared
#define PLATF_ONE_WAY_COLL         64       //Se atraviesa y colisiona al caer

//constantes de plataformas
const
	cPlatformMargin         =  2;	//Margen para outregion
	
	cPlatformDefaultVel     = 0.5;  //Velocidad por defecto plataformas
	cPlatformFallVel		= 1.5;	//Velocidad caida plataformas
	cPlatformWaitTime       = 20;   //Tiempo espera plataformas
	
	//springBoxPlatform
	cSpringBoxVel			= 2;	//Velocidad springBox
	cSpringBoxImpulse		= 5;	//Impulso que le da al player
	cSpringBoxJumpImpulse	= 2;	//Impulso que le da al player si pulsa saltar
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
	#ifdef DYNAMIC_MEM
		_platform* platforms;			//Array Dinamico de objetos
	#else
		_platform platforms[100];			//Array Estatico de objetos
	#endif
	
end;

//declaracion de plataforma generica
Declare Process platform(int _platformType,int _graph,int _x0,int _y0,int _ancho,int _alto,int _axisAlign,int _flags,int _props)
public
	_entityPublicData this;			//datos publicos de entidad
end
end

//declaracion de plataforma lineal
Declare Process linearPlatform(int graph,int startX,int startY,int _ancho,int _alto,int _axisAlign,int _flags,int _props,float _vX)
public
	_entityPublicData this;			//datos publicos de entidad
end
end

//declaracion de plataforma nubes
Declare Process cloudPlatform(int _graph,int startX,int startY,int _ancho,int _alto,int _axisAlign,int _flags,int _props)
public
	_entityPublicData this;			//datos publicos de entidad
end
end

//declaracion de plataforma springBox
Declare Process springBoxPlatform(int _graph,int startX,int startY,int _ancho,int _alto,int _axisAlign,int _flags,int _props)
public
	_entityPublicData this;			//datos publicos de entidad
end
end