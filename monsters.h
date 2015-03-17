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


//declaracion de proceso monstruo generico
Declare Process monster(int monsterType,int _x0,int _y0)
public
	_entityPublicData this;			//datos publicos de entidad
end
end

//declaracion de proceso monstruo cycleClown
Declare Process cycleClown(int graph,int x,int y,int _ancho,int _alto,int _props)
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
Declare process toyPlane(int graph,int x,int y,int _ancho,int _alto,int _props)
public
	_entityPublicData this;			//datos publicos de entidad
end
end

//Declaracion de enemigo ToyPlaneControl
Declare process toyPlaneControl(int graph,int x,int y,int _ancho,int _alto,int _props)
public
	_entityPublicData this;			//datos publicos de entidad
end
end

Declare Process deadMonster()
public
	_entityPublicData this;			//datos publicos de entidad
end
end