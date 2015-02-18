// ========================================================================
//  Warcom Game Engine
//  Motor para juegos plataformas 2D
//  11/02/15
//
//  Definiciones de las funciones de colision
// ========================================================================

//Modos funcion colCheckVectorY
#define FROMCOLLISION    0					//Comprobar pixeles para salir de la colision
#define TOCOLLISION      1					//Comprobar pixeles hasta llegar a la colision

//Modos funcion colCheckProcess
#define BOTHAXIS			0					//Ambos ejes
#define HORIZONTALAXIS		1					//Eje Horizontal
#define VERTICALAXIS		2					//Eje Vertical
#define INFOONLY			3                   //Solo informacion de colision

//Direccion colision
#define NOCOL		0
#define COLUP		1
#define COLDOWN		2
#define COLIZQ		3
#define COLDER   	4
#define COLCENTER   5

//Puntos de colision
//los puntos laterales deben estar primero de los inferiores/superiores
//para el buen funcionamiento de la deteccion de obstaculos
#define RIGHT_UP_POINT		0
#define RIGHT_DOWN_POINT	1
#define LEFT_UP_POINT		2
#define LEFT_DOWN_POINT		3
#define DOWN_L_POINT		4
#define DOWN_R_POINT		5
#define UP_L_POINT			6
#define UP_R_POINT			7
#define CENTER_POINT		8
#define CENTER_DOWN_POINT	9