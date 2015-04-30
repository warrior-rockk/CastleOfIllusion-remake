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
#define OBJ_PICKABLE				  	8		//Puede ser recogido
#define OBJ_BREAKABLE             		16		//Se rompe al lanzarlo y colisionar
#define OBJ_ITEM_COIN           	    32		//Contiene item moneda pequeña
#define OBJ_ITEM_BIG_COIN           	64		//Contiene item moneda grande
#define OBJ_ITEM_FOOD              	    128		//Contiene item energia 1 estrella
#define OBJ_ITEM_BIG_FOOD               512		//Contiene item energia todas las estrellas
#define OBJ_ITEM_TRIE              	    1024 	//Contiene item 1 vida extra
#define OBJ_ITEM_STAR	          		2048	//Estrella energia extra
#define OBJ_ITEM_GEM			 		4096	//Gema fin de nivel
//propiedades internas
#define OBJ_IS_KEY               		8192    //Objeto es llave

//constantes de objetos
const
	cObjectMargin		=			2;			//Margen ancho y alto para salir de region
	
	cMinVelXToIdle		= 			0.1;        //Velocidad X minima para pasar a reposo
	cItemVelY 			=			-4;			//Velocidad Y al salir un item
	cBouncyObjectVel	=           0.6;        //Velocidad Y rebote suelo para objetos
	cBouncyItemVel		=           0.8;        //Velocidad Y rebote suelo para items
	cItemTimeOut        =           8;          //Timeout Item
	cItemTimeToBlink    =           4;			//Tiempo parpadeo antes de timeout
	cItemBlinkTime      =           3;			//Velocidad parpadeo
	cDoorTime			=           10;         //Velocidad Puerta
	
	//puntuaciones
	cBigCoinScore       =			1000;
	cSmallCoinScore     =			500;
	
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