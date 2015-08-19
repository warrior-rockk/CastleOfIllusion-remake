// ========================================================================
//  Warcom Game Engine
//  Motor para juegos plataformas 2D
//  3/05/15
//
//  Funciones Sonido
// ========================================================================

//funcion que reproduce la musica del nivel
function wgePlayMusicLevel()
begin
	if (level.idMusicLevel > 0)
		play_song(level.idMusicLevel,0);
		timer[cMusicTimer] = 0;
	end;
end;

//funcion que comprueba si el intro de la musica del nivel a finalizado
function int wgeMusicIntroEnded()
begin
	return timer[cMusicTimer] >= (levelFiles[game.numLevel].MusicIntroEnd*100);
end;

//funcion que repite la musica del nivel saltando el intro
function wgeRepeatMusicLevel()
begin
	if (level.idMusicLevel > 0)
		wgePlayMusicLevel();
		set_music_position(levelFiles[game.numLevel].MusicIntroEnd);
	end;
end;

//funcion que reproduce el sonido de estado de una entidad
function wgePlayEntityStateSnd(entity idEntity,int idSound)
private
	int sndChannel;		//canal de sonido para reproducir
begin
	//comprobamos si existe el idSound
	if (idSound <> 0)
		//seteamos el canal de sonido segun entidad
		switch (getType(idEntity))
			case (TYPE player):
				sndChannel = cPlayerSndChn;
			end;
			default:
				if (exists(idEntity.father))
					switch (getType(idEntity.father))
						case (TYPE object):
							sndChannel = cObjectSndChn;
						end;
						case (TYPE monster):
							sndChannel = cMonsterSndChn;
						end;
						default:
							sndChannel = cDefaultSndChn;
						end;
					end;
				else
					sndChannel = cDefaultSndChn;
				end;
			end;
		end;
			
		//reproducimos el sonido al entrar en el estado
		if (idEntity.this.prevState <> idEntity.this.state)
			play_wav(idSound,0,sndChannel);
			log("Reproducido sonido en canal "+sndChannel,DEBUG_SOUND);
		end;
	else
		log("Id sonido inexistente",DEBUG_SOUND);
	end;
end;

//funcion que reproduce un sonido de una entidad
function wgePlayEntitySnd(entity idEntity,int idSound)
private
	int sndChannel;		//canal de sonido para reproducir
begin
	//comprobamos si existe el idSound
	if (idSound <> 0 )
		//seteamos el canal de sonido segun entidad
		switch (getType(idEntity))
			case (TYPE player):
				sndChannel = cPlayerSndChn;
			end;
			default:
				if (exists(idEntity.father))
					switch (getType(idEntity.father))
						case (TYPE object):
							sndChannel = cObjectSndChn;
						end;
						case (TYPE monster):
							sndChannel = cMonsterSndChn;
						end;
						default:
							sndChannel = cDefaultSndChn;
						end;
					end;
				else
					sndChannel = cDefaultSndChn;
				end;
			end;
		end;
		
		//reproducimos el sonido
		play_wav(idSound,0,sndChannel);
		log("Reproducido sonido en canal "+sndChannel,DEBUG_SOUND);
	else
		log("Id sonido inexistente",DEBUG_SOUND);
	end;
end;

//funcion para cargar archivo de sonido
function int wgeLoadSound(string soundFile)
private
	int soundID;	//identificador del sonido
begin
	if ((soundID =  load_wav(soundFile)) <=0 ) 
		log("Fallo al cargar el archivo de sonido: "+soundFile,DEBUG_SOUND);
	end;
	
	return soundID;
end;

//funcion para cargar archivo de musica
function int wgeLoadMusic(string musicFile)
private
	int musicID;	//identificador del sonido
begin
	if ((musicID =  load_song(musicFile)) <=0 ) 
		log("Fallo al cargar el archivo de musica: "+musicFile,DEBUG_SOUND);
	end;
	
	return musicID;
end;

//funcion que setea el volumen de todos los canales
function wgeSetChannelsVolume(int volume)
begin
	set_channel_volume(cDefaultSndChn,volume*1.28);
	set_channel_volume(cGameSndChn,volume*1.28);
	set_channel_volume(cPlayerSndChn,volume*1.28);
	set_channel_volume(cObjectSndChn,volume*1.28);
	set_channel_volume(cMonsterSndChn,volume*1.28);
end;