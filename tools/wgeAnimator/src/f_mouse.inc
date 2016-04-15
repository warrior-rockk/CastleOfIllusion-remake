
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

#IFNDEF FUIT_MOUSE_INC
#DEFINE FUIT_MOUSE_INC

/*
********************************************************************
* FUNCION INTERNA         /controla cursor del mouse                                         *
********************************************************************
*/
PROCESS FUIT_Control()
Private
temp;
BEGIN
 	mouse.file=skin.cursors_fpg;
    mouse.graph=1;    
    
    Loop
        //controla cursor del mouse
    	my_mouse=1;    	
    		temp=get_id(TYPE window);
 			While (temp!=0) 		
 				If (temp.reserved.status==2)
 					If (temp.my_mouse!=1)
 				        my_mouse=temp.my_mouse;
 				        Break;
 					END 
 				END	   
 			temp=get_id(TYPE window);
 			END
 			temp=get_id(TYPE Input_box);
 			While (temp!=0) 		
 				If (temp.reserved.status==2)
 					If (temp.my_mouse!=1)
 				        my_mouse=temp.my_mouse;
 				        Break;
 					END 
 				END	   
 			temp=get_id(TYPE Input_box);
 			END
 			mouse.graph=my_mouse;   
 				
 		Frame;	
    END    
END

/*  
********************************************************************
* Este proceso devuelve uno si el mouse se encuentra sobre el area *
* visible de el proceso que se pasa como parametro                 *
********************************************************************
*/
PROCESS on_visible_area(proceso)
Private
temp;
BEGIN        
 
     
 //si esta dentro del rectangulo
 If (mouse.x>=proceso.x AND mouse.y>=proceso.y AND mouse.x<=proceso.x+proceso.ancho AND mouse.y<=proceso.y+proceso.alto) 	
 	//si es una ventana
 	If (proceso.reserved.process_type == TYPE window) 		
 		//recorre la lista de ventanas  
 		temp=get_id(TYPE window);
 		While (temp!=0)
 		    
 		    //si se esta moviENDo o cambiando de tamaño
 		    If (temp.win_prop.moviENDo>0 OR temp.win_prop.sizing>0)
 				Return 0;
 			END 		    
 		    
 		    //si esta mas arriba que el proceso
 			If (temp.z < proceso.z)      
 			 	//si el mouse esta dentro de esta
 				If (on_visible_area(temp)==1)
 					Return 0;
 				END 				
 			END 
 			
 		//avanza en la lista		   
 		temp=get_id(TYPE window);
 		END         		 
 		//si llego hasta aca 		
 		Return 1;
 	Else   		
 		//si no es ventana
 		If (on_visible_area(proceso.container))
 		Return 1;
 		Else                                   
 		Return 0;
 		END
 	END
 Else
 	Return 0;
 END 
END

#ENDIF
