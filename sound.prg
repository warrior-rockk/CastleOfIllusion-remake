// ========================================================================
//  Warcom Game Engine
//  Motor para juegos plataformas 2D
//  3/05/15
//
//  Funciones Sonido
// ========================================================================

//funcion que reproduce la musica del nivel
function WGE_PlayMusicLevel()
begin
	play_song(level.idMusicLevel,0);
	timer[cMusicTimer] = 0;
end;

//funcion que comprueba si el intro de la musica del nivel a finalizado
function int WGE_MusicIntroEnded()
begin
	return timer[cMusicTimer] >= (levelFiles[game.numLevel].MusicIntroEnd*100);
end;

//funcion que repite la musica del nivel saltando el intro
function WGE_RepeatMusicLevel()
begin
	WGE_PlayMusicLevel();
	set_music_position(levelFiles[game.numLevel].MusicIntroEnd);
end;
