
//-----------------------------------------------
//Program: sistema de ventanas en Fenix
//Author: JaViS
//Team:
//-----------------------------------------------


/* Fenix User Interface ToolKit
 * Copyright (C) 2002 Javier Arias
 *
 * This Program is free software; you can redistribute it AND/OR modify
 * it under the terms of the GNU General Public License as published by
 * the free Software Foundation; either version 2 of the License, OR
 * (at your option) any later version.
 * 
 * This Program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY OR FITNESS For A PARTICULAR PURPOSE.  See the
 * GNU General Public License For more details.
 * 
 * You should have received a copy of the GNU General Public License
 * along with this Program; If NOT, write To the free Software
 * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 */

#IFNDEF FUIT_DRAW_INC
#DEFINE FUIT_DRAW_INC

/*
********************************************************************
*                      Funcion interna                             *
********************************************************************
*/ 
PROCESS Draw_border(Int src_map,Int dest_map)
Private
	i;
BEGIN 
 file=skin.fpg;
 ancho=graphic_info (0,dest_map,g_wide);
 alto=graphic_info (0,dest_map,g_height);
 //superior
   	From i=0 To ancho Step 10;
   	map_block_copy(skin.fpg,dest_map,i,0,src_map,10,0,10,10,0);
   	END
 //izquierdo
 	From i=0 To alto Step 10;
   	map_block_copy (skin.fpg,dest_map,0,i,src_map,0,10,10,10,0);
   	END
 //derecho
 	From i=0 To alto Step 10;
   	map_block_copy (skin.fpg,dest_map,ancho-10,i,src_map,20,10,10,10,0);
   	END
 //inferior
   	From i=0 To ancho Step 10;
   	map_block_copy(skin.fpg,dest_map,i,alto-10,src_map,10,20,10,10,0);
   	END   	   	
 //esquinas                                          
 //superior izqierda
 map_block_copy(skin.fpg,dest_map,0,0,src_map,0,0,10,10,0);
 //superior derecha
 map_block_copy (skin.fpg,dest_map,ancho-10,0,src_map,20,0,10,10,0);
 //inferior derecha
 map_block_copy (skin.fpg,dest_map,ancho-10,alto-10,src_map,20,20,10,10,0);
 //inferior izqierda
 map_block_copy(skin.fpg,dest_map,0,alto-10,src_map,0,20,10,10,0);
END 
/*
********************************************************************
*                      Funcion interna                             *
********************************************************************
*/
PROCESS New_image_map(Int map,proc_id)
Private
 i;
BEGIN
//creacion del mapa 
 		image_map=new_map(proc_id.ancho,proc_id.alto,16) ;//imagen donde se dibujara 
		set_center(0,image_map,0,0);//se pone el punto de control en la esquina superior izq.
 		drawing_map(0,image_map);//asignamos para dibujar sobre el
 		
 		//dibuja 
 		drawing_color(map_get_pixel(skin.fpg,map,15,15));//color de la skin
 		draw_box (0,0,proc_id.ancho,proc_id.alto); //pintamos el fondo
 		
 		//si tiene picture asignado se lo pinta
 		If (proc_id.picture!=0)       
 			set_center(0,proc_id.picture,0,0);
 			map_put(0,image_map,proc_id.picture,0,0);
 		END 
 		
 		//bordes    
 		If (proc_id.border>0)
 			draw_border(map,image_map);
 		END
 		/*
 		//superior
 	    	From i=0 To proc_id.ancho Step 10;
 	    	map_block_copy(skin.fpg,image_map,i,0,map,10,0,10,10,1);
 	       	END
 		//izquierdo
 			From i=0 To proc_id.alto Step 10;
 	    	map_block_copy (skin.fpg,image_map,0,i,map,0,10,10,10,1);
 	       	END
 	    //derecho
 			From i=0 To proc_id.alto Step 10;
 	    	map_block_copy (skin.fpg,image_map,proc_id.ancho-10,i,map,20,10,10,10,1);
 	       	END
 	    //inferior
 	    	From i=0 To proc_id.ancho Step 10;
 	    	map_block_copy(skin.fpg,image_map,i,proc_id.alto-10,map,10,20,10,10,1);
 	       	END   	   	
 		//esquinas                                          
 			//superior izqierda
 			map_block_copy(skin.fpg,image_map,0,0,map,0,0,10,10,1);
 			//superior derecha
 			map_block_copy (skin.fpg,image_map,proc_id.ancho-10,0,map,20,0,10,10,1);
 			//inferior derecha
 			map_block_copy (skin.fpg,image_map,proc_id.ancho-10,proc_id.alto-10,map,20,20,10,10,1);
 			//inferior izqierda
 			map_block_copy(skin.fpg,image_map,0,proc_id.alto-10,map,0,20,10,10,1);
 			*/
	Return image_map; 			
END
#ENDIF
