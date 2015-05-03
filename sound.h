//========================================================================
//  Warcom Game Engine
//  Motor para juegos plataformas 2D
//  3/05/15
//
//  Definiciones del sonido
// ========================================================================

//Constantes
const
	cMusicTimer		= 1;					//Timer usado para el tiempo de musica
	cGameSndChn		= 1;
	cPlayerSndChn   = 1;
End;

Global
	int gameMusic[5];				//Array de identificadores de musicas del juego
	int gameSound[10];				//Array de indentificadores de efectos de sonido generales
	int playerSound[10];			//Array de identificadores de efectos de sonido del player