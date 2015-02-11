// ========================================================================
//  Warcom Game Engine
//  Motor para juegos plataformas 2D
//  11/02/15
//
//  Definiciones de las funciones de animacion
// ========================================================================

//propiedades de los objetos
#define PICKABLE				1
#define NO_COLLISION            2
#define BREAKABLE               4

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