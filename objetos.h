// ========================================================================
//  Warcom Game Engine
//  Motor para juegos plataformas 2D
//  11/02/15
//
//  Definiciones de las funciones de animacion
// ========================================================================

//tipos de objetos
#define T_SOLIDITEM				0       //Objeto solido (cofre,piedra...)
#define T_ITEM                  1       //Objeto Item

//tipos de plataformas
#define P_LINEARPLATFORM 		0       
#define P_TRIGGERPLATFORM 		1       

//propiedades de los objetos
#define PICKABLE				1		//Puede ser recogido
#define NO_COLLISION            2		//No colisiona con otros procesos
#define NO_PHYSICS              4       //No le afecta las fisicas
#define BREAKABLE               8		//Se rompe al lanzarlo y colisionar
#define NO_PERSISTENT          16       //No se vuelve a crear si desaparece
#define ITEM_BIG_COIN          32		//Contiene item moneda grande
#define ITEM_STAR	           64		//Estrella energia extra
#define ITEM_GEM			  128		//Gema fin de nivel
#define BOUNCY_LOW            256       //Objeto tiene rebote bajo
#define BOUNCY_HIGH           512       //Objeto tiene rebote bajo

//constantes de objetos
const
	cMinVelXToIdle		= 			0.1;        //Velocidad X minima para pasar a reposo
	cItemVelY 			=			-4;			//Velocidad Y al salir un item
	cBouncyObjectVel	=           0.6;        //Velocidad Y rebote suelo para objetos
	cBouncyItemVel		=           0.8;        //Velocidad Y rebote suelo para items
	cBigCoinScore		=			100;		//Puntuacion de moneda grande
	cItemTimeOut        =           8;          //Timeout Item
	cItemTimeToBlink    =           4;			//Tiempo parpadeo antes de timeout
	cItemBlinkTime      =           3;			//Velocidad parpadeo
end;

//Objeto
Type _objeto         			//Tipo de Dato de objeto
	byte tipo;      			//Tipo del objeto
	int grafico;    			//Grafico
	int x0;         			//Posicion X
	int y0;         			//Posicion Y
	int angulo;     			//Angulo
	int param[cMaxObjParams];	//Parametros del objeto
	byte dibujado;				//Flag de si ha sido dibujado (sectorizacion)
End;

Global
	_objeto* objetos;			//Array Dinamico de objetos
end;

//declaracion de proceso objeto
Declare Process object(int objectType,int _graph,int _x0,int _y0,int _ancho,int _alto,int _props)
public
	_entityPublicData this;			//datos publicos de entidad
end
end

//declaracion de proceso bloque
Declare Process solidItem(int graph,int x,int y,int _ancho,int _alto,int _props)
public
	_entityPublicData this;			//datos publicos de entidad
end
end

//declaracion de proceso pickedObject
Declare Process pickedObject(int file,int graph,int _ancho,int _alto, int _props)
public
	_entityPublicData this;			//datos publicos de entidad
end
end

//declaracion de objeto caja
Declare Process caja(int x,int y,float _vX,float _vY)
public
	_entityPublicData this;			//datos publicos de entidad
end
end

//declaracion de plataforma generica
Declare Process platform(int _platformType,int _graph,int _x0,int _y0,int _ancho,int _alto)
public
	_entityPublicData this;			//datos publicos de entidad
end
end

//declaracion de objeto plataforma
Declare Process linearPlatform(int graph,int startX,int startY,int _ancho,int _alto,float _vX)
public
	_entityPublicData this;			//datos publicos de entidad
end
end

//declaracion de objeto plataforma
Declare Process triggerPlatform(int graph,int startX,int startY,int _ancho,int _alto,float _vX,int deadDir)
public
	_entityPublicData this;			//datos publicos de entidad
end
end

//declaracion de objeto item
Declare Process item(int x,int y,int _ancho,int _alto,int _props)
public
	_entityPublicData this;			//datos publicos de entidad
end
end