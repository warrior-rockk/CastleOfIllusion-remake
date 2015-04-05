// ========================================================================
//  Warcom Game Engine
//  Motor para juegos plataformas 2D
//  13/02/15
//
//  Definiciones de las procesos monsters
// ========================================================================

//propiedades de los monstruos
#define HURTPLAYER		1


//Tipos de monstruo
#define T_CYCLECLOWN			0 		//Monstruo CycleClown
#define T_TOYPLANE   			1 		//Monstruo ToyPlane
#define T_TOYPLANECONTROL   	2 		//Monstruo ToyPlaneControl

//enemigo
Type _monster         			//Tipo de Dato de enemigo
	int monsterType;      		//Tipo del enemigo
	int monsterGraph;    		//Grafico
	int monsterX0;    			//Posicion X
	int monsterY0;     			//Posicion Y
	int monsterAncho;		    //Ancho
	int monsterAlto;            //Alto
	int monsterFlags;           //flags
	int monsterProps;           //Propiedades
End;

Global
	_monster* monsters;			//Array Dinamico de enemigos
end;

//declaracion de proceso monstruo generico
Declare Process monster(int monsterType,int _x0,int _y0,int _flags,int _props)
public
	_entityPublicData this;			//datos publicos de entidad
end
end

//declaracion de proceso monstruo cycleClown
Declare Process cycleClown(int graph,int x,int y,int _ancho,int _alto,int _flags,int _props)
public
	_entityPublicData this;			//datos publicos de entidad
end
end

//declaracion de fuego enemigo (proyectil)
Declare Process monsterFire(int graph,int x,int y,float _vX,float _vY)
public
	_entityPublicData this;			//datos publicos de entidad
end
end

//Declaracion de enemigo ToyPlane
Declare process toyPlane(int graph,int x,int y,int _ancho,int _alto,int _flags,int _props)
public
	_entityPublicData this;			//datos publicos de entidad
end
end

//Declaracion de enemigo ToyPlaneControl
Declare process toyPlaneControl(int graph,int x,int y,int _ancho,int _alto,int _flags,int _props)
public
	_entityPublicData this;			//datos publicos de entidad
end
end

Declare Process deadMonster()
public
	_entityPublicData this;			//datos publicos de entidad
end
end