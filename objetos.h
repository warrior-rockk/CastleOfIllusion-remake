// ========================================================================
//  Warcom Game Engine
//  Motor para juegos plataformas 2D
//  11/02/15
//
//  Definiciones de las funciones de animacion
// ========================================================================

//tipos de objetos
#define OBJ_SOLIDITEM			  0       //Objeto solido (cofre,piedra...)
#define OBJ_ITEM                  1       //Objeto Item
#define OBJ_BUTTON                2       //Objeto boton
#define OBJ_DOORBUTTON            3       //Objeto puerta con boton
#define OBJ_KEY					  4       //Objeto llave
#define OBJ_DOORKEY               5       //Objeto puerta con llave

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
#define BOUNCY_HIGH           512       //Objeto tiene rebote alto
#define IS_KEY               1024       //Objeto es llave

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
	cDoorTime			=           10;         //Velocidad Puerta
end;

//Objeto
Type _object         			//Tipo de Dato de objeto
	int objectType;      		//Tipo del objeto
	int objectGraph;    		//Grafico
	int objectX0;      			//Posicion X
	int objectY0;     			//Posicion Y
	int objectAncho;			//Ancho
	int objectAlto;				//Alto
	int objectAxisAlign;		//Eje
	int objectFlags;			//flags
	int objectProps;			//Propiedades
End;

Global
	_object* objects;			//Array Dinamico de objetos
end;

//declaracion de proceso objeto
Declare Process object(int objectType,int _graph,int _x0,int _y0,int _ancho,int _alto,int _axisAlign,int _flags,int _props)
public
	_entityPublicData this;			//datos publicos de entidad
end
end

//declaracion de proceso bloque
Declare Process solidItem(int graph,int x,int y,int _ancho,int _alto,int _axisAlign,int _flags,int _props)
public
	_entityPublicData this;			//datos publicos de entidad
end
end

//declaracion de objeto item
Declare Process item(int x,int y,int _ancho,int _alto,int _axisAlign,int _flags,int _props)
public
	_entityPublicData this;			//datos publicos de entidad
end
end

//declaracion de objeto boton
Declare Process button(int _graph,int x,int y,int _ancho,int _alto,int _axisAlign,int _flags,int _props)
public
	_entityPublicData this;			//datos publicos de entidad
end
end

//declaracion de objeto puerta con boton
Declare Process doorButton(int _graph,int x,int y,int _ancho,int _alto,int _axisAlign,int _flags,int _props)
public
	_entityPublicData this;			//datos publicos de entidad
end
end

//declaracion de objeto puerta de llave
Declare Process keyDoor(int _graph,int x,int y,int _ancho,int _alto,int _axisAlign,int _flags,int _props)
public
	_entityPublicData this;			//datos publicos de entidad
end
end