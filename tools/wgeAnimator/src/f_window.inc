
#IFNDEF FUIT_WINDOW_INC
#DEFINE FUIT_WINDOW_INC

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

/*
Devuelve el ID de la ventana que se encuentra debajo de la
ventana que se pasa como parametro

*/    

PROCESS Get_Top_win(actual)
Private
 temp;
 tope;
BEGIN 
 temp=get_id(TYPE window);
 If (tope==0 AND temp!=actual)
 	tope=temp;
 END 
 While (temp!=0)
 	If (tope==0 AND temp!=actual)
 		tope=temp;
 	END 
 	If (tope!=0)
 		If ( temp.z<tope.z AND temp.z>actual.z)
 			tope=temp;
 		END        
 	END
 	temp=get_id(TYPE window);
 END
 If (tope==0)
 	Return actual;
 Else        
 	Return tope;
 END
END

/*
Retorna el contenedor ventana de un control
*/                                         
PROCESS Get_Control_win(control)
Private
 Cont;
 
BEGIN 
 cont=control.container;
 While (cont.reserved.process_type!=TYPE window)
 	cont=cont.container;
 END
 Return cont;
END

/*
Retorna la cantidad de controles existentes en una ventana
*/

PROCESS Cant_controls(contenedor)                           
Private
temp,contador;
BEGIN 
 While (contenedor.reserved.process_type!= TYPE window)
 	contenedor=contenedor.container;
 END
 temp=get_id(0);
 While(temp!=0) 
 	If (exists(temp) AND temp.control_type==ui_control)
 		If ( get_control_win(temp)==contenedor)
 		contador++;                              
 		END
 	END
 	temp=get_id(0);
 END
 Return contador;
END  

/*
Retorna el id del primer control en el oden focus
*/           
           
PROCESS first_tab(ventana)
Private
 temp;
 first;
BEGIN  
 temp=get_id(0);
 While(temp!=0) 
 	If (temp.control_type==ui_control)
 		If (get_control_win(temp)==ventana )
 			If ( first==0)
 				first=temp;
 			Else        
 				If (temp.tab_index<first.tab_index)
 					first=temp;
 				END	
 			END 
 		END
 	END
 	temp=get_id(0);
 END    
 Return first;
END

/*
Retorna el id del proximo control en el oden focus
*/

PROCESS Next_Tab(actual)
Private
  temp; 
  win;
  next1;
BEGIN 
 win=get_control_win(actual);
 temp=get_id(0);
 While(temp!=0)  
 	If (temp.control_type==ui_control)  
 		If (win==get_control_win(temp))
 			//da valor a next en primera vuelta
 			If (temp.tab_index>actual.tab_index AND next1==0)
 				next1=temp;
 			END
 			//en las vueltas siguientes busca uno mas chico a next
 			If (next1!=0)				
	 			If (temp.tab_index>actual.tab_index AND 
 					temp.tab_index<next1.tab_index)
 					next1=temp;
 				END	       
 			END	 				
 		END
 	END	
 	temp=get_id(0);
 END  
 //si next es igual a 0 es que no se encontro siguiente
 //(puede que la cant de controles sea ==0 o que 
 //actual sea el tab_index mayor)
 If (next1==0)
     next1=first_tab(win);
 END
 
 Return next1;
END

/*
********************************************************************
* FUNCION INTERNA   /pone en foco a una ventana                    *
********************************************************************
*/

PROCESS Set_active_win (Ventana) 
Private
temp;    
tz;  
mapa_temp;      
i;
BEGIN    
 
 If (Active_win==ventana)
 	Return;
 END	
 If (active_win!=0 AND exists(active_win))
 	active_win.event=ui_lost_focus;
 END
 Active_win=ventana;    
 ventana.event=ui_got_focus;
 temp=get_id(TYPE window);
 
 While (temp!=0 AND exists(ventana) )
 		
 		If (temp!=ventana )
 			If (temp.reserved.status==2 AND temp.z<tz AND temp.z<ventana.z)
 				tz = temp.z; 								 				
 				//si esta ventana es la que perdio el foco
 				If (temp.event==ui_lost_focus)
 					refresh(temp);		              
 				END
 				/*se podria bajar la z de la ventanas y no sumar 
 				uno a tz */
 			END 
 		END	   
 		temp=get_id(TYPE window);
 END             
 
 ventana.z=tz-1; 
 If (ventana.image_map!=0)
 //If (map_exists(0,ventana.image_map))
 	refresh(ventana);		      
 END
 
END

/*
********************************************************************
* Funcion interna / RETORNA CANTIDAD DE VENTANAS EN MEMORIA                          *
********************************************************************
*/

PROCESS Cant_win ()
Private
contador=0;
temp;
BEGIN    
	temp=get_id(TYPE window);
	While (temp!=0)
		contador++; 	          
		temp=get_id(TYPE window);
 	END 
 	Return contador;
END  

/*
********************************************************************
*                        PROCESO VENTANA                           *
*  TIPO: CONTAINER                                                 *
********************************************************************
*/

PROCESS window (x,y,String caption,Byte border)

Private
 //Distancia entre x y el mouse
 Word px;
 Word py;     
 Word _width,_height; 
 String _caption;
 Byte _border;
 Byte Esquinas[8]; //indica sobre que esquina esta el cursor 
 i;      
 Byte must_refresh;
 Repeticion; 
BEGIN  
 control_type=ui_container;
 alto=200;
 ancho=200;     
 visible=1; 
 set_active_win(id);   
 visible=0;      //para que todavia clip_control no se dibuje
 _border=border; 
 //si se puede mover
 If (hasvalue (border,1)==1)     
 	win_prop.moveable=1;
 END
 //si se puede cambiar el tamaño	
 If (hasvalue (border,2)==1)
 	win_prop.sizable=1;  	
 END                            
 //si tiene boton cambiar tamaño 
 If (hasvalue (border,8)==1)
 	If (win_prop.state_button==0)
 		win_prop.state_button=clip_control(0);
 	END 	
 END              
 //si tiene boton cerrar 
 If (hasvalue (border,4)==1)
 	If (win_prop.close_button==0)
 		win_prop.close_button=clip_control(1);
 	END 	
 END  
 //si tiene titlebar
 If (hasvalue (border,16)==1)
 	  win_prop.hastitle=1;
 END              
 visible=1;
 Loop   
  If (left!=x OR top!=y )
		left=x;
		top=y;		
  END	
  If (visible==0)    
  	graph=0;
  	Frame;
  Else
  	 	
   	graph=image_map; //asigna imagen como grafico
   	
   	//si la ventana toma el foco
    If (event==ui_got_focus)
    	If (cant_controls(id)!=0)
 			set_focus( first_tab (id)); 
 		Else
 			//setea active control a ninguno
 			set_focus(0);	
 		END
    END                                 
    
    get_event();      //toma events					
    
    If (event==ui_mouse_down)
    	set_active_win(id);    	
    END     	
    
    //si se aprieta tab cuando es Active_win
    If (active_win==id)
	    If (cant_controls(id)!=0 AND key(_tab))
	    	//para que no sea rapida la repeticion de las teclas
	    	If (repeticion==0)
 			set_focus(next_tab(active_control));
 			END
 			repeticion=1;    
 		Else	        
 			repeticion=0;
		END
	END
    
       
    //si se esta cambiando el tamaño
	If (win_prop.sizing>0 )        
		px=mouse.x;
        py=mouse.y;
	  While (mouse.left)	  
	  		get_event();      
            If(px!=mouse.x || py!=mouse.y)
             // Modifica el tama¤o de la ventana seg£n la esquina
             // o el borde
            	Switch(win_prop.sizing)

                        // NW   
                        //esquina superior izq
                        Case 6:
                            ancho+=px-mouse.x;
                            alto+=py-mouse.y;
                            If(ancho>=100)
                                x-=px-mouse.x;
                            Else
                                x-=(px-mouse.x)+(100-ancho);
                                ancho=100;
                                mouse.x=x;
                            END
                            If(alto>=30)
                                y-=py-mouse.y;
                            Else
                                y-=(py-mouse.y)+(30-alto);
                                alto=30;
                                mouse.y=y;
                            END
                        END
                        // N  
                        //borde superior
                        Case 5:
                            alto+=py-mouse.y;
                            If(alto>=30)
                                y-=py-mouse.y;
                            Else
                                y-=(py-mouse.y)+(30-alto);
                                alto=30;
                                mouse.y=y;
                            END
                        END
                        // NE 
                        //esquina superior derecha
                        Case 4:
                            ancho-=px-mouse.x;
                            alto+=py-mouse.y;
                            If(ancho<100)
                                ancho=100;
                                mouse.x=x+ancho;
                            END
                            If(alto>=30)
                                y-=py-mouse.y;
                            Else
                                y-=(py-mouse.y)+(30-alto);
                                alto=30;
                                mouse.y=y;
                            END
                        END
                        // E
                        //borde derecho
                        Case 2:
                            ancho-=px-mouse.x;
                            If(ancho<100)
                                ancho=100;
                                mouse.x=x+ancho;
                            END
                        END
                        // SE
                        //esquina inferior derecha
                        Case 1:
                            ancho-=px-mouse.x;
                            alto-=py-mouse.y;
                            If(ancho<100)
                                ancho=100;
                                mouse.x=x+ancho;
                            END
                            If(alto<30)
                                alto=30;
                                mouse.y=y+alto;
                            END
                        END
                        // S  
                        //borde inferior
                        Case 3:
                            alto-=py-mouse.y;
                            If(alto<30)
                                alto=30;
                                mouse.y=y+alto;
                            END
                        END
                        // SW
                        Case 8:
                            ancho+=px-mouse.x;
                            alto-=py-mouse.y;
                            If(ancho>=100)
                                x-=px-mouse.x;
                            Else
                                x-=(px-mouse.x)+(100-ancho);
                                ancho=100;
                                mouse.x=x;
                            END
                            If(alto<30)
                                alto=30;
                                mouse.y=y+alto;
                            END
                        END
                        // W
                        //borde izq.
                        Case 7:
                            ancho+=px-mouse.x;
                            If(ancho>=100)
                                x-=px-mouse.x;
                            Else
                                x-=(px-mouse.x)+(100-ancho);
                                ancho=100;
                                mouse.x=x;
                            END
                        END
                    END
                   // Actualiza el gráfico con el nuevo tama¤o
                   refresh(id);
                   _height=alto;
                   _width=ancho;
                   event= ui_resize;
               END 
        
		px=mouse.x;
        py=mouse.y;        
        graph=image_map;        
	    Frame;
	  END   //END while 
	  win_prop.sizing=0;   				
	  
	Else	    
		If (win_prop.moviendo==0 AND win_prop.sizable==1) 
			//si esta se quiere cambiar tamaño   			
			//en esquina inferior derecha
			If (mouse.x>=x+ancho-5 AND mouse.y>=y+alto-5 AND on_visible_area(id)==1)								
				If (event==ui_mouse_still_down)
				win_prop.sizing=1;
				END     
				mouse.graph=3;
				esquinas[0]=1;
			Else
				esquinas[0]=0;
			END 
			//en borde derecho     
			If (mouse.x>=x+ancho-5 AND  mouse.y<=y+alto-5 AND mouse.y>=y+5 AND on_visible_area(id)==1)
			    If (event==ui_mouse_still_down)
				win_prop.sizing=2;
				END
				esquinas[1]=1;
			Else
				esquinas[1]=0;
			END
			//en borde inferior     
			If (mouse.y>=y+alto-5  AND mouse.x<=x+ancho-5 AND mouse.x>=x+5 AND on_visible_area(id)==1)
				If (event==ui_mouse_still_down)
				win_prop.sizing=3;
				END       
				esquinas[2]=1;
			Else
				esquinas[2]=0;
			END
			//esquina superior derecha
			If (mouse.y<=y+5  AND mouse.x>=x+ancho-5 AND on_visible_area(id)==1)
				If (event==ui_mouse_still_down)
				win_prop.sizing=4;				
				END       
				esquinas[3]=1;
			Else
				esquinas[3]=0;	
			END 
			//en borde superior
			If (mouse.y<=y+5  AND mouse.x<=x+ancho-5 AND mouse.x>=x+5 AND on_visible_area(id)==1)
				If (event==ui_mouse_still_down)
				win_prop.sizing=5;				
				END   
				esquinas[4]=1;
			Else
				esquinas[4]=0;
			END    
			//esquina superior izquierda
			If (mouse.y<=y+5  AND mouse.x<=x+5 AND on_visible_area(id)==1)
				If (event==ui_mouse_still_down)
				win_prop.sizing=6;				
				END       
				esquinas[5]=1;
			Else
				esquinas[5]=0;
			END
			//en borde izquierdo     
			If (mouse.x<=x+5 AND  mouse.y<=y+alto-5 AND mouse.y>=y+5 AND on_visible_area(id)==1)
			    If (event==ui_mouse_still_down)
			    win_prop.sizing=7;
				px=x+ancho;
				END       
				esquinas[6]=1;
			Else
				esquinas[6]=0;
			END 
			//en esquina inferior izquierda
			If (mouse.x<=x+5 AND mouse.y>=y+alto-5 AND on_visible_area(id)==1)								
				If (event==ui_mouse_still_down)
				win_prop.sizing=8;
				px=x+ancho;
				END       
				esquinas[7]=1;
			Else
				esquinas[7]=0;
			END 		
		END
	END
	
	//define dragarea segun las propiedad border
	If (win_prop.moveable==1) 	     
     If (border<16)
     	dragarea.x=5;
     	dragarea.y=5;
     	dragarea.x1=ancho-5;
     	dragarea.y1=alto-5;
     Else                
      dragarea.x=5;
     	dragarea.y=5;
     	dragarea.x1=ancho-5;
     	dragarea.y1=25;
     END
  END    
	
  //si se esta moviendo la ventana
  If (win_prop.moviendo )
    x=mouse.x-px;
		y=mouse.y-py; 
		//si ya no se presiona el boton del mouse
		If (!mouse.left)
			win_prop.moviendo=0;
		END 
	Else //si no se esta moviendo
	
	  //si se encuentra en drag_area
	  If (mouse.x>=x+dragarea.x AND mouse.y>=y+dragarea.y AND win_prop.sizing==0)
    	If (mouse.x<=x+dragarea.x1 AND mouse.y<= y+dragarea.y1)    		
    		If (event==ui_mouse_still_down AND win_prop.moveable==1)    		
    		//Distancia entre x y el mouse    		
 				px=mouse.x-x;
 				py=mouse.y-y;
 				win_prop.moviendo=1;
    		END
    	END  
      END 
    
	END   
	
	If (win_prop.win_state==0)
		win_prop.normal_x=x;
		win_prop.normal_y=y;
		win_prop.normal_width=ancho;
		win_prop.normal_height=alto;
	END	    	
			
    //comprueba cambio de propiedades que afectan al aspecto grafico
           
    If (_height!=alto OR _width!=ancho )    	    	
    	event=ui_resize;	
    	_height=alto;
    	_width=ancho;
    	must_refresh=1;       	
    END	                             
    
    If (_border!=border)
      visible=0;
    	win_prop.moveable=0;
    	win_prop.sizable=0; 
    	win_prop.hastitle=0;
    	If (exists(win_prop.close_button))
    		signal (win_prop.close_button,s_kill);
    		win_prop.close_button=0;          
    	END
    	If (exists(win_prop.state_button))
    		signal (win_prop.state_button,s_kill);
    		win_prop.state_button=0;          
    	END
   		//si se puede mover
 			If (hasvalue (border,1)==1)     
 				win_prop.moveable=1;
 			END
 			//si se puede cambiar el tamaño	
 			If (hasvalue (border,2)==1)
 				win_prop.sizable=1;  	
 			END                            
 			//si tiene boton cambiar tamaño 
 			If (hasvalue (border,8)==1)
 				If (win_prop.state_button==0)
 					win_prop.state_button=clip_control(0);
 				END 	
 			END              
 			//si tiene boton cerrar 
 			If (hasvalue (border,4)==1)
 				If (win_prop.close_button==0)
 					win_prop.close_button=clip_control(1);
 				END 	
 			END  
 			//si tiene titlebar
 			If (hasvalue (border,16)==1)
			 	  win_prop.hastitle=1;
 			END              
 	 		must_refresh=1;
    	_border=border;
    	visible=1;
    END
    
    If (_caption != caption)
    	_caption=caption;
    	must_refresh=1;
    END
    
    //si se debe dibujar
    If (must_refresh==1)      
   		refresh(id);           		  
    	must_refresh=0;    	    	
    END  
    
    //indica como debe esta el mouse sobre esta ventana
			From i=0 To 8;
				If (i==8) 
					my_mouse=1;
					Break; 
				END
				If (esquinas[i]!=0)
					Switch (i)
						Case 0: My_mouse=3; END	
						Case 1: My_mouse=5; END	
						Case 2: My_mouse=4; END	
						Case 3: My_mouse=8; END	
						Case 4: My_mouse=4; END	
						Case 5: My_mouse=3; END	
						Case 6: My_mouse=5; END	
						Case 7: My_mouse=8; END	
					END 
					Break;
				END
			END 	
    Frame;//refresca ventana
  END //if visible==0
 END
END

/*
*******************************************************************
Funcion interna y de usuario:
		Es un simple alias del proceso Kill_process(), me pareció 
		que podía ser útil para aquellos que vengan de GUI.dll.
		[BlueSteel]
*******************************************************************
*/

PROCESS destroy_window(int id_window)
BEGIN
	kill_process(id_window);
END

#ENDIF
