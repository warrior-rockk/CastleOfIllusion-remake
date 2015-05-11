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

//funcion que reproduce el sonido de estado de una entidad
function WGE_PlayEntityStateSnd(entity idEntity,int idSound)
private
	int sndChannel;		//canal de sonido para reproducir
begin
	//seteamos el canal de sonido segun entidad
	switch (getType(idEntity))
		case (TYPE player):
			sndChannel = cPlayerSndChn;
		end;
	end;
		
	//reproducimos el sonido al entrar en el estado
	if (idEntity.this.prevState <> idEntity.this.state)
		play_wav(idSound,0,sndChannel);
	end;
end;

//funcion que reproduce un sonido de una entidad
function WGE_PlayEntitySnd(entity idEntity,int idSound)
private
	int sndChannel;		//canal de sonido para reproducir
begin
	//seteamos el canal de sonido segun entidad
	switch (getType(idEntity))
		case (TYPE WGE_Loop):
			sndChannel = cGameSndChn;
		end;
		case (TYPE player):
			sndChannel = cPlayerSndChn;
		end;
	end;
	
	//reproducimos el sonido
	play_wav(idSound,0,sndChannel);
end;