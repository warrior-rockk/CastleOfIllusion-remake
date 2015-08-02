// ========================================================================
//  RIPEADOR DE TILES
//  v2.0  11/2/13
//  
//
//  Ripea los tiles de un archivo .png generando un fpg sin duplicados y
//  dado un png de escenario con esos tiles, genera un archivo .map para Tile Studio
//  que los representará
//
//  Warcom soft.
// ========================================================================

import "mod_key";
import "mod_map";
import "mod_video";
import "mod_text";
import "mod_scroll";
import "Mod_proc";
import "mod_sound";
import "Mod_screen";
import "Mod_draw";
import "Mod_grproc";
import "Mod_rand";
import "mod_file";
import "mod_math";
import "mod_say";
import "mod_debug";

CONST
C_TILE_SIZE = 16;
end;

private
ix,iy,i,j,imagen_tiles,nuevo,nuevo2,i_destino,i_destino_dur,image_x=0,image_y=0,count=1,imagen_mapa,archivo_map;
int num_graphs,tiles_count;
byte k,iguales,b_0 = 0;

begin

set_mode(320,240,8);

//cargamos el mapa grafico de tiles 
//load_pal("../fpg/mickey.fpg");
imagen_tiles=load_png("gfx\tiles.png");
nuevo=new_fpg();  
nuevo2=new_fpg();
ix = graphic_info(0,imagen_tiles,G_WIDE);
iy = graphic_info(0,imagen_tiles,G_HEIGHT);

//troceamos el mapa grafico y guardamos los tiles al fpg en memoria
repeat
	repeat
		i_destino=new_map(C_TILE_SIZE,C_TILE_SIZE,8);
		i_destino_dur=new_map(C_TILE_SIZE,C_TILE_SIZE,8);
		
		map_block_copy(0,i_destino,0,0,imagen_tiles,image_x,image_y,C_TILE_SIZE,C_TILE_SIZE,0);
		
		
		fpg_add(nuevo2,count,0,i_destino);
		image_x+=C_TILE_SIZE;
		count++;
		tiles_count++;
	until(image_x==graphic_info(0,imagen_tiles,G_WIDE));
	image_x=0;
	image_y+=C_TILE_SIZE;
until (image_y==graphic_info(0,imagen_tiles,G_HEIGHT));

graph=i_destino_dur;
//Salvamos el fpg de tiles
save_fpg(nuevo2,"tiles.fpg");
say("ok");
end;