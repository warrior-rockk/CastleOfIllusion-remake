
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

#IFNDEF FUIT_CONTROL_INC
#DEFINE FUIT_CONTROL_INC

/*
Dibuja un tooltip en la posicion x,y del mouse
con la infomacion del proceso que se pasa como parametro
*/                                                      
PROCESS Tooltip(proceso)

BEGIN    
 x=mouse.x;
 y=mouse.y+16;             
 z=proceso.z -50;
 If (proceso.tooltip_text=="")
 	Return;
 END     
 alto=text_height(0,proceso.tooltip_text) +4;
 ancho=text_width(0,proceso.tooltip_text)+4;
 
 If (ancho%2!=0)
 	ancho++;
 END      
 If (alto%2!=0)
 	alto++;
 END 
 
 graph=new_map(ancho,alto,16);     
 set_center(0,graph,0,0);
 drawing_map(0,graph);
 drawing_color(map_get_pixel(skin.fpg,16,5,65));
 draw_box(0,0,ancho,alto);  
 drawing_color(rgb(0,0,0));   
 draw_rect(0,0,ancho,alto);
 Set_text_color(map_get_pixel(skin.fpg,16,5,75)); 
 data_map=write_in_map(0,proceso.tooltip_text,0);  
 set_center(0,data_map,0,0);
 map_put(0,graph,data_map,2,2);
 unload_map(0,data_map);
 
 alpha=0;
 
 
 //shadow(id);
 While (exists(proceso))   	    	
 	If (mouse.x!=x OR mouse.y+16!=y)
 		proceso.showing_tooltip=0;
 		unload_map(0,graph);
 		Break;
 	END
 	If (alpha<255)
 		alpha+=20;
  END
 	Frame;
 END
END             

PROCESS Shadow(p_id)
BEGIN
 z=p_id.z+1;
 x=p_id.x+3;
 y=p_id.y+3;
 graph=map_clone(0,p_id.graph);
 drawing_map(0,graph);
 drawing_color(rgb(1,1,1));
 draw_box(0,0,graphic_info(0,graph,g_wide),graphic_info(0,graph,g_height));
 flags=4;
 Loop   
 	If (exists(p_id)==0)
 		Break;
 		unload_map(0,graph);
 	END
 	Frame;
 END
END         

/*
********************************************************************
* FUNCION INTERNA  - Fuerza a un control a dibujarse                                                *
********************************************************************
*/                                         
PROCESS refresh (p_id) 
Private 
 temp;
 mapa_temp;
 mapa_temp2;
 info;
 i;   
 Mapa_foco;
 Word posx,posy;  
 Int x1,x2,y1,y2;
BEGIN
  Switch (p_id.reserved.process_type)  
  	//Section: Refresh_window
  	Case TYPE window: 
  		//descarga ventana anterior
  		If (p_id.image_map!=0)
    	//If (map_exists(0,p_id.image_map))
    		unload_map (0,p_id.image_map);
    		
    	END
    	
    	//creacion del mapa para la ventana
 		p_id.image_map=new_image_map(1,p_id);
 		
 		If (p_id.win_prop.hastitle==1) 	 		
 		   //dibuja titlebar
 		 	If (Active_win==p_id)
 		 	mapa_temp=3;
 		 	Else
 		 	mapa_temp=2;
 		 	END 
 		 	
 		 	From i=0 To p_id.ancho Step 10;
 				map_block_copy(skin.fpg,p_id.image_map,i,0,mapa_temp,30,0,10,
 				graphic_info (skin.fpg,image_map,g_height),0);
 			END
 			//extremos titlebar
 			map_block_copy (skin.fpg,p_id.image_map,0,0,mapa_temp,0,0,30,
 			graphic_info (skin.fpg,image_map,g_height),0);
 			map_block_copy (skin.fpg,p_id.image_map,p_id.ancho-60,0,mapa_temp,40,0,60,
 			graphic_info (skin.fpg,image_map,g_height),0);   
 			
 			//pone el titulo de la ventana                 
 			Set_text_color(map_get_pixel(skin.fpg,16,1,1));
 			mapa_temp=write_in_map(0,p_id.caption,0);
 			map_put(0,p_id.image_map,mapa_temp,skin.ttlbr_caption_x,skin.ttlbr_caption_y); 
 			unload_map(0,mapa_temp);  		
 		END
 			 		
 		//dibuja close_button      

		 //si tiene boton cerrar 
 		If (hasvalue (p_id.border,4)) 	 	 	 	
 			set_center(skin.fpg,26,0,0);
   			map_put(skin.fpg,p_id.image_map,26,p_id.ancho-skin.w_close_x
   			- p_id.win_prop.close_button.ancho,skin.w_close_y);
	 	END              
 		
   		 		//si tiene boton cambiar tamaño 
 		If (hasvalue (p_id.border,8)) 	 	 	 	
 			//dibuja state_button
	   		If (p_id.win_prop.win_state==0)
 	  			mapa_temp=29;
  	 		Else
   				mapa_temp=32;
   			END		
 			set_center(skin.fpg,mapa_temp,0,0);
   			map_put(skin.fpg,p_id.image_map,mapa_temp,p_id.ancho-skin.w_state_x
	   	 	- p_id.win_prop.state_button.ancho,skin.w_state_y);
 		END              
   		   		 	
 		//recorre lista objetos y dibuja en esta ventana
 		  temp=get_id(TYPE group_box);
 		  While(temp!=0)   
 		  	If (temp.visible==1 AND temp.container==p_id)        
 		  	refresh(temp); 		  	
 		  	END
 		  	temp=get_id(TYPE group_box);
 		  END		  
 		  temp=get_id(TYPE label);
 		  While(temp!=0)   
 		  	If (temp.visible==1 AND temp.container==p_id)        
 		  	refresh(temp); 		  	
 		  	END
 		  	temp=get_id(TYPE label);
 		  END
		  temp=get_id(TYPE PicBox);
 		  While(temp!=0)   
 		  	If (temp.visible==1 AND temp.container==p_id)        
 		  	refresh(temp); 		  	
 		  	END
 		  	temp=get_id(TYPE PicBox);
 		  END			  
 		  temp=get_id(TYPE Button);
 		  While(temp!=0)   
 		  	If (temp.visible==1 AND temp.container==p_id)        
 		  	refresh(temp); 		  	
 		  	END
 		  	temp=get_id(TYPE Button);
 		  END		  
 		  temp=get_id(TYPE check_box);
 		  While(temp!=0)   
 		  	If (temp.visible==1 AND temp.container==p_id)        
 		  	refresh(temp); 
 		  	END
 		  	temp=get_id(TYPE check_box);
 		  END
 		  temp=get_id(TYPE option_button);
 		  While(temp!=0)   
 		  	If (temp.visible==1 AND temp.container==p_id)        
 		  	refresh(temp); 
 		  	END
 		  	temp=get_id(TYPE option_button);
 		  END
 		  temp=get_id(TYPE Input_box);
 		  While(temp!=0)   
 		  	If (temp.visible==1 AND temp.container==p_id)        
 		  	refresh(temp); 
 		  	END
 		  	temp=get_id(TYPE Input_box);
 		  END
 		
  	END
  	//Section: Refresh_button
  	Case TYPE button: 
  		//descarga imagen anterior
  		If (p_id.image_map!=0)
    	//If (map_exists(0,p_id.image_map))
    		unload_map (0,p_id.image_map);
    		
    	END
    	
    	Switch (p_id.event)      	
    	Case ui_mouse_over:p_id.image_map=new_image_map(5,p_id); 
    		Set_text_color(map_get_pixel(skin.fpg,16,1,31));    
    		
    	END
    	Case ui_mouse_down, ui_key_down:p_id.image_map=new_image_map(6,p_id); 
    	  Set_text_color(map_get_pixel(skin.fpg,16,1,41));    
    		
    	END
    	Default :
    		If (p_id.enabled==1)
    			p_id.image_map=new_image_map(4,p_id);
    			Set_text_color(map_get_pixel(skin.fpg,16,1,21));            		
    		Else                        
    			p_id.image_map=new_image_map(7,p_id); 
    			Set_text_color(map_get_pixel(skin.fpg,16,1,51));            		
    		END
    	END
    	END    	
    mapa_temp=write_in_map(0,p_id.caption,4);
 		map_put (0,p_id.image_map,mapa_temp,p_id.ancho/2,p_id.alto/2); 
 		unload_map(0,mapa_temp);
 		
 		
 		//prepara mapa del borde (para actualizar foco)
 		ancho=graphic_info (0,p_id.image_map,g_wide);
 		alto=graphic_info (0,p_id.image_map,g_height);
 		mapa_foco=new_map (ancho+4,alto+4,16); 
 		//rellena mapa_foco con el color de fondo
   	drawing_map(0,mapa_foco);
   	drawing_color(map_get_pixel(skin.fpg,1,15,15)); 
   	draw_box(0,0,ancho+4,alto+4);
   	//pega image_map en mapa_foco
   	map_put(0,mapa_foco,p_id.image_map,2,2);
   	set_center(0,mapa_foco,2,2);
   	//descarga image_map
   	unload_map(0,p_id.image_map);
   	//asigna image_map nuevo
   	p_id.image_map=mapa_foco;
   	//si el control tiene el foco
   	If (active_control==p_id)       
   		//dibuja un rectangulo
   		draw_border(37,p_id.image_map);
 		END
 		 		 		
 		//pega la imagen recien creada en el p_id contenedor
 		map_put (0,p_id.container.image_map,p_id.image_map,p_id.Left,p_id.Top);
 		//si el p_id cntenedor es un group_box
 		If (p_id.container.reserved.process_type== TYPE group_box)
 			//actualiza la imagen del p_id_contenedor
 		   map_put (0,p_id.container.container.image_map,
 		   p_id.container.image_map,p_id.container.Left
 		   ,p_id.container.Top);
 		END 
  	END 
  	//Section: Refresh_input
  	Case TYPE Input_box: 
  		//descarga imagen anterior
  		If (p_id.image_map!=0)
    	//If (map_exists(0,p_id.image_map))
    		unload_map (0,p_id.image_map);
    		p_id.image_map=0;
    	END 
    	//descarga imagen anterior
    	If (p_id.data_map!=0)
    	//If (map_exists(0,p_id.data_map))
    		unload_map (0,p_id.data_map);
    		p_id.data_map=0;
    	END 
    	    	
    	           
    	//creamos image_map del tamaño del Input_box
    	p_id.image_map=new_map(p_id.ancho,p_id.alto,16) ;//imagen donde se dibujara 
		set_center(0,p_id.image_map,0,0);//se pone el punto de control en la esquina superior izq.
		
		//Guarda caption de p_id en caption local
    	caption=p_id.caption;	
     //si esta con foco dibujo cursor sobre letras	                      
    If (active_control==p_id)    	
    	If (p_id.SELSTART==0)
 				CAPTION=chr(179)+caption;
 			Else
 				caption= substr(caption,0,p_id.selstart)+chr(179)+substr(caption,p_id.selstart,len(caption)); 
 			END 					                  
 		END
		
		//Creamos Data Map
		//si el largo del texto (mas 10) es mayor al espacio del imputbox
		If (text_width(p_id.font,caption)+ 10 >p_id.ancho)
			//Hacemos data_map del largo del texto  
			 p_id.data_map=new_map (text_width(p_id.font,caption) + 10
			 ,p_id.alto,16);			 
		Else             
			//hacemos datamap del tamaño del input     
			p_id.data_map=new_map (p_id.ancho,p_id.alto,16);			 
		END
		set_center(0,p_id.data_map,0,0);//se pone el punto de control en la esquina superior izq.
		drawing_map(0,p_id.data_map);//asignamos para dibujar sobre el
 	
 		//setea colores 		
    	If (p_id.enabled==1)    		
    		drawing_color(map_get_pixel(skin.fpg,35,15,15));//color de la skin
 				draw_box (0,0,graphic_info(0,p_id.data_map,g_wide),p_id.alto); //pintamos el fondo de color 	 			 				    		
    		Set_text_color(map_get_pixel(skin.fpg,16,1,21));            		
    	Else                        
    		drawing_color(map_get_pixel(skin.fpg,36,15,15));//color de la skin
 				draw_box (0,0,graphic_info(0,p_id.data_map,g_wide),p_id.alto); //pintamos el fondo de color 	
    		Set_text_color(map_get_pixel(skin.fpg,16,1,51));            		
    	END                     
    
 		
    //crea texto en mapa_temp
    mapa_temp=write_in_map(0,caption,4);
    set_center(0,mapa_temp,0,0);
        
    //y lo pega en data_map
 		map_put (0,p_id.data_map,mapa_temp,5,5); 
 		unload_map(0,mapa_temp);  
 		              		
 		
 		//Pone el centro de la imagen de modo que siempre se vea el cursor de edicion
 		If (p_id.selstart>0 AND text_width(p_id.font,substr(caption,0,p_id.selstart))+ 15 > p_id.ancho)
 			set_center(0,p_id.data_map,
 				text_width(p_id.font,substr(caption,0,p_id.selstart)) - 
 				p_id.ancho + 15,0);
 		Else
 			set_center(0,p_id.data_map,0,0);
 		END	
 		//ahora pega data_map en image_map
 		map_put  (0,p_id.image_map,p_id.data_map,0,0); 
 		
 		 		
 		//crea bordes sobre image_map
 		If (p_id.enabled==1)
 			draw_border(35,p_id.image_map);
 		Else                  
 			draw_border(36,p_id.image_map);
 		END
 		
 		//prepara mapa del borde (para actualizar foco)
 		ancho=graphic_info (0,p_id.image_map,g_wide);
 		alto=graphic_info (0,p_id.image_map,g_height);
 		mapa_foco=new_map (ancho+4,alto+4,16); 
 		//rellena mapa_foco con el color de fondo
   	drawing_map(0,mapa_foco);
   	drawing_color(map_get_pixel(skin.fpg,1,15,15)); 
   	draw_box(0,0,ancho+4,alto+4);
   	//pega image_map en mapa_foco
   	map_put(0,mapa_foco,p_id.image_map,2,2);
   	set_center(0,mapa_foco,2,2);
   	//descarga image_map
   	unload_map(0,p_id.image_map);
   	//asigna image_map nuevo
   	p_id.image_map=mapa_foco;
   	//si el control tiene el foco
   	If (active_control==p_id)       
   		//dibuja un rectangulo
   		draw_border(37,p_id.image_map);
 		END
 		 		
 		//pega la imagen recien creada en el p_id contenedor
 		map_put (0,p_id.container.image_map,p_id.image_map,p_id.Left,p_id.Top);
 		//si el p_id cntenedor es un group_box
 		If (p_id.container.reserved.process_type== TYPE group_box)
 			//actualiza la imagen del p_id_contenedor
 		   map_put (0,p_id.container.container.image_map,
 		   p_id.container.image_map,p_id.container.Left
 		   ,p_id.container.Top);
 		END 
  	END  
  	//Section: Refresh_check
  	Case TYPE check_box: 
  	
  		Switch (p_id.event)      	
    	Case ui_mouse_over:
    		If (p_id.value==1)
    			p_id.image_map=13;
    		Else
    			p_id.image_map=12;
    		END     
    		Set_text_color(map_get_pixel(skin.fpg,16,1,31));    
    		set_center(skin.fpg,p_id.image_map,0,0);
    	END
    	Case ui_mouse_down, ui_key_down:
    		If (p_id.value==1)
    			p_id.image_map=11;
    		Else
    			p_id.image_map=10; 
    		END	   
    		Set_text_color(map_get_pixel(skin.fpg,16,1,41));    
    		set_center(skin.fpg,p_id.image_map,0,0);
    	END
    	Default :
    		If (p_id.enabled==0) 
    		 If (p_id.value==1)
    			p_id.image_map=15;  
    		 Else
    		 	p_id.image_map=14;  
    		 END	    
    		 Set_text_color(map_get_pixel(skin.fpg,16,1,51));        
    		 set_center(skin.fpg,p_id.image_map,0,0);
    		Else                        
    		 If (p_id.value==1)
    			p_id.image_map=9;
    		 Else	
    		    p_id.image_map=8;  
    		 END            
    		 Set_text_color(map_get_pixel(skin.fpg,16,1,21));        
    		 set_center(skin.fpg,p_id.image_map,0,0);
    		END
    	END
    	END 
    	
    	//crea las letras
    	mapa_temp=write_in_map(0,p_id.caption,3);              
    	//crea un mapa nuevo
    	info=graphic_info (0, mapa_temp,g_wide);
    	mapa_temp2=new_map (info+p_id.widthm+1,p_id.alto,16);
    	set_center(0,mapa_temp2,0,0);    	
    	 
    	//rellena mapatemp2 con el color de fondo
    	drawing_map(0,mapa_temp2);
    	drawing_color(map_get_pixel(skin.fpg,1,15,15)); 
    	draw_box (0,0,graphic_info(0,mapa_temp2,g_wide),graphic_info(0,mapa_temp2,g_height));
    	
    	//pega en mapatemp2 el dibujo
    	map_put(0,mapa_temp2,p_id.image_map,0,0);
    	 
    	//pega en mapa_temp2 las letras   	
    	
 		map_put(0,mapa_temp2,mapa_temp,p_id.widthm+2,p_id.alto/2); 
 		unload_map(0,mapa_temp);           
 		
 		p_id.image_map=mapa_temp2;
 		
 		//prepara mapa del borde (para actualizar foco)
 		ancho=graphic_info (0,p_id.image_map,g_wide);
 		alto=graphic_info (0,p_id.image_map,g_height);
 		mapa_foco=new_map (ancho+4,alto+4,16); 
 		//rellena mapa_foco con el color de fondo
   	drawing_map(0,mapa_foco);
   	drawing_color(map_get_pixel(skin.fpg,1,15,15)); 
   	draw_box(0,0,ancho+4,alto+4);
   	//pega image_map en mapa_foco
   	map_put(0,mapa_foco,p_id.image_map,2,2);
   	set_center(0,mapa_foco,2,2);
   	//descarga image_map
   	unload_map(0,p_id.image_map);
   	//asigna image_map nuevo
   	p_id.image_map=mapa_foco;
   	//si el control tiene el foco
   	If (active_control==p_id)       
   		//dibuja un rectangulo
   		draw_border(37,p_id.image_map);
 		END
 		
 		//pega la imagen recien creada en la ventana contenedora
 		map_put (0,p_id.container.image_map,p_id.image_map,p_id.Left,p_id.Top);
 		//si el id contenedor es un objeto dentro de una ventana
 		If (p_id.container.reserved.process_type== TYPE group_box)
 			//actualiza la imagen del id_contenedor
 		   map_put (0,p_id.container.container.image_map,
 		   p_id.container.image_map,p_id.container.Left
 		   ,p_id.container.Top);
 		END   
 		//actualiza ancho
 		//p_id.ancho=graphic_info (0, mapa_temp2,G_WIDE);
 		p_id.ancho=graphic_info (0,p_id.image_map,g_wide);
  	END 
  	//Section: Refresh_option
  	Case TYPE option_button:  
  	
  	Switch (p_id.event)      	
    Case ui_mouse_over:
    		If (p_id.value==1)
    			p_id.image_map=23;
    		Else
    			p_id.image_map=22;
    		END     
    		Set_text_color(map_get_pixel(skin.fpg,16,1,31));    
    		set_center(skin.fpg,p_id.image_map,0,0);
    	END
    Case ui_mouse_down, ui_key_down:
    		If (p_id.value==1)
    			p_id.image_map=21;
    		Else
    			p_id.image_map=20; 
    		END	   
    		Set_text_color(map_get_pixel(skin.fpg,16,1,41));    
    		set_center(skin.fpg,p_id.image_map,0,0);
    	END
    Default :
    		If (p_id.enabled==0) 
    		 If (p_id.value==1)
    			p_id.image_map=25;  
    		 Else
    		 	p_id.image_map=24;  
    		 END	    
    		 Set_text_color(map_get_pixel(skin.fpg,16,1,51));        
    		 set_center(skin.fpg,p_id.image_map,0,0);
    		Else                        
    		 If (p_id.value==1)
    			p_id.image_map=19;
    		 Else	
    		    p_id.image_map=18;  
    		 END            
    		 Set_text_color(map_get_pixel(skin.fpg,16,1,21));        
    		 set_center(p_id.file,p_id.image_map,0,0);
    		END
    	END
    END 
    	
    //crea las letras
    mapa_temp=write_in_map(0,p_id.caption,3);              
    //crea un mapa nuevo
    info=graphic_info (0, mapa_temp,g_wide);
    mapa_temp2=new_map (info+p_id.widthm+1,p_id.alto,16);
    set_center(0,mapa_temp2,0,0);
    	
    //rellena mapatemp2 con el color de fondo
    drawing_map(0,mapa_temp2);
    drawing_color(map_get_pixel(skin.fpg,1,15,15)); 
    draw_box (0,0,graphic_info(0,mapa_temp2,g_wide),graphic_info(0,mapa_temp2,g_height));
    	
    //pega en mapatemp2 el dibujo
    map_put(0,mapa_temp2,p_id.image_map,0,0);
    	
    //pega en mapa_temp2 las letras   	
    	
 		map_put(0,mapa_temp2,mapa_temp,p_id.widthm+2,p_id.alto/2); 
 		unload_map(0,mapa_temp);           
 		
 		p_id.image_map=mapa_temp2;
 		
 		//prepara mapa del borde (para actualizar foco)
 		ancho=graphic_info (0,p_id.image_map,g_wide);
 		alto=graphic_info (0,p_id.image_map,g_height);
 		mapa_foco=new_map (ancho+4,alto+4,16); 
 		//rellena mapa_foco con el color de fondo
   	drawing_map(0,mapa_foco);
   	drawing_color(map_get_pixel(skin.fpg,1,15,15)); 
   	draw_box(0,0,ancho+4,alto+4);
   	//pega image_map en mapa_foco
   	map_put(0,mapa_foco,p_id.image_map,2,2);
   	set_center(0,mapa_foco,2,2);
   	//descarga image_map
   	unload_map(0,p_id.image_map);
   	//asigna image_map nuevo
   	p_id.image_map=mapa_foco;
   	//si el control tiene el foco
   	If (active_control==p_id)       
   		//dibuja un rectangulo
   		draw_border(37,p_id.image_map);
 		END
 		 		 		      	
 		//pega la imagen recien creada en la ventana contenedora
 		map_put (0,p_id.container.image_map,p_id.image_map,p_id.Left,p_id.Top);
 		//si el id contenedor es un objeto dentro de una ventana
 		If (p_id.container.reserved.process_type== TYPE group_box)
 			//actualiza la imagen del id_contenedor
 		   map_put (0,p_id.container.container.image_map,
 		   p_id.container.image_map,p_id.container.Left
 		   ,p_id.container.Top);
 		END  
 		//actualiza ancho
 		p_id.ancho=graphic_info (0, p_id.image_map,g_wide);
  	END
  	//Section: Refresh_label
  	Case TYPE Label:
  		//descarga imagen anterior
  		If (p_id.image_map!=0)
    	//If (map_exists(0,p_id.image_map))
    		unload_map (0,p_id.image_map);
    		p_id.image_map=0;
    	END
    	p_id.image_map=new_map(p_id.ancho,p_id.alto,16);
    	set_center(0,p_id.image_map,1,1);           
    	//color_normal
    	Set_text_color(map_get_pixel(skin.fpg,16,1,21));
    	If (p_id.caption!="" AND p_id.multi_line==true)            
    	 posx=0;
    	 posy=0;        
    	 //pega letra por letra en mapa
    	 For (i=0;i<len(p_id.caption);i++)
    	 	
    	 	If (posx+text_width(p_id.font,p_id.caption[i])>p_id.ancho)
    	 		posx=0;
    	 		posy=posy+text_height(p_id.font,p_id.caption[i]);    	 	
    	 	END      	 	
    	 	//se crea la letra en un mapa
    	 	mapa_temp=write_in_map (p_id.font,p_id.caption[i],0);
    	 	//pega la letra en image_map
    	 	map_put (0,p_id.image_map,mapa_temp,posx,posy);
    	 	
    	 	unload_map (0,mapa_temp);       
    	 	//actualiza la posicion de la proxima letra
    	 	posx=posx+text_width(p_id.font,p_id.caption[i]);
    	 END	
    	 Else                                                  
    	 	//escribe todo de una vez
    	 	mapa_temp=write_in_map (p_id.font,p_id.caption,0);
    	 	//pega en image_map
    	 	map_put (0,p_id.image_map,mapa_temp,0,0);
    	 	unload_map(0,mapa_temp);
    	 END  	 
    	 
    	 //pega la imagen recien creada en la ventana contenedora
 		map_put(0,p_id.container.image_map,p_id.image_map,p_id.Left,p_id.Top);
 		//si el id contenedor es un objeto dentro de una ventana
 		If (p_id.container.reserved.process_type== TYPE group_box)
 			//actualiza la imagen del id_contenedor
 		   map_put (0,p_id.container.container.image_map,
 		   p_id.container.image_map,p_id.container.Left
 		   ,p_id.container.Top);
 		END  
    	 
    		
  	END 
  	//Section: Refresh_PicBox
  	Case TYPE PicBox:
  		
		//descarga imagen anterior
  		If (p_id.image_map!=0)
    	//If (map_exists(0,p_id.image_map))
    		unload_map (0,p_id.image_map);
    		p_id.image_map=0;
    	END
    	
		if (p_id.fit)
			p_id.ancho = graphic_info(p_id.fichero,p_id.picture,G_WIDTH);
			p_id.alto = graphic_info(p_id.fichero,p_id.picture,G_HEIGHT);
		end;
		
		p_id.image_map=new_map(p_id.ancho,p_id.alto,16);
    	set_center(0,p_id.image_map,1,1);           
    	
		//CODIGO DEL PICBOX
    	
		Switch (p_id.event)      	
			Case ui_mouse_over:
				drawing_color(map_get_pixel(skin.fpg,16,5,32));
				map_xput(0,p_id.image_map,map_clone(p_id.fichero,p_id.picture),graphic_info(p_id.fichero,p_id.picture,G_WIDTH)/2,graphic_info(p_id.fichero,p_id.picture,G_HEIGHT)/2,0,100,0);
			end;
			Default:
				drawing_color(32);
				map_xput(0,p_id.image_map,map_clone(p_id.fichero,p_id.picture),graphic_info(p_id.fichero,p_id.picture,G_WIDTH)/2,graphic_info(p_id.fichero,p_id.picture,G_HEIGHT)/2,0,100,4);
			end;
		end;
			
		if (p_id.border)
			//draw_border(35,p_id.image_map);
			drawing_map(0,p_id.image_map);
			draw_line(0,0,p_id.ancho-1,0);
			draw_line(0,0,0,p_id.alto-1);
			draw_line(0,p_id.alto-1,p_id.ancho-1,p_id.alto-1);
			draw_line(p_id.ancho-1,p_id.alto-1,p_id.ancho-1,0);
		end;
		//pega la imagen recien creada en la ventana contenedora
 		map_put(0,p_id.container.image_map,p_id.image_map,p_id.Left,p_id.Top);
 		//si el id contenedor es un objeto dentro de una ventana
 		If (p_id.container.reserved.process_type== TYPE group_box)
 			//actualiza la imagen del id_contenedor
 		   map_put (0,p_id.container.container.image_map,
 		   p_id.container.image_map,p_id.container.Left
 		   ,p_id.container.Top);
 		END  
		
    	 
    		
  	END
	//Section: Refresh_group
  	Case TYPE group_box:
  		//descarga imagen anterior
  		If (p_id.image_map!=0)
    	//If (map_exists(0,p_id.image_map))
    		unload_map (0,p_id.image_map);
    		p_id.image_map=0;
    	END
  		p_id.image_map=new_image_map(17,p_id); 
  		//recorre lista objetos y dibuja en esta ventana
 		  temp=get_id(TYPE group_box);
 		  While(temp!=0)   
 		  	If (temp.visible==1 AND temp.container==p_id)        
 		  	refresh(temp);
 		  	END
 		  	temp=get_id(TYPE group_box);
 		  END		
 		  temp=get_id(TYPE Input_box);
 		  While(temp!=0)   
 		  	If (temp.visible==1 AND temp.container==p_id)        
 		  	refresh(temp);
 		  	END
 		  	temp=get_id(TYPE Input_box);
 		  END		
 		  temp=get_id(TYPE label);
 		  While(temp!=0)   
 		  	If (temp.visible==1 AND temp.container==p_id)        
 		  	refresh(temp); 		  	
 		  	END
 		  	temp=get_id(TYPE label);
 		  END
		  temp=get_id(TYPE PicBox);
 		  While(temp!=0)   
 		  	If (temp.visible==1 AND temp.container==p_id)        
 		  	refresh(temp); 		  	
 		  	END
 		  	temp=get_id(TYPE PicBox);
 		  END			  
 		  temp=get_id(TYPE Button);
 		  While(temp!=0)   
 		  	If (temp.visible==1 AND temp.container==p_id)        
 		  	refresh(temp); 
 		  	END
 		  	temp=get_id(TYPE Button);
 		  END		  
 		  temp=get_id(TYPE check_box);
 		  While(temp!=0)   
 		  	If (temp.visible==1 AND temp.container==p_id)        
 		  	refresh(temp); 
 		  	END
 		  	temp=get_id(TYPE check_box);
 		  END  
 		  temp=get_id(TYPE option_button);
 		  While(temp!=0)   
 		  	If (temp.visible==1 AND temp.container==p_id)        
 		  	refresh(temp); 
 		  	END
 		  	temp=get_id(TYPE option_button);
 		  END
  	//pega la imagen recien creada en la ventana contenedora
 	map_put (0,p_id.container.image_map,p_id.image_map,p_id.Left,p_id.Top);
  	END
  END
END

/*
********************************************************************
* FUNCION INTERNA   /pone en foco a un widget                      *
********************************************************************
*/
PROCESS set_focus(process_id)
Private
temp;    
tz;  
mapa_temp;      
i;         
last_process;
BEGIN    
 
 If (process_id==0)
 	If (active_control!=0 AND exists(active_control))
 		active_control.event=ui_lost_focus; 	
 		last_process=active_control;
 	END
 	active_control=0;
 	If (last_process!=0 AND exists(last_process))
 		refresh(last_process);  
 	END 
 	
 	Return;
 END
 
 
 If (Active_control==process_id OR
 	process_id.control_type!=ui_control)
 	Return;
 END	
 process_id.event=ui_got_focus; 
 If (active_control!=0 AND exists(active_control))
 	active_control.event=ui_lost_focus; 	
 	last_process=active_control;
 END
 Active_control=process_id;   
 If (last_process!=0 AND exists(last_process))
 	refresh(last_process);  
 END 
 refresh(active_control);  
END

/*
*******************************************************************
*                         CONTROL INTERNO                         *
*     Genera las aciones de los botones de control de win.        *
*    1= close_button                                              *
*	 0= State_button                                              *
******************************************************************* 
*/ 
PROCESS Clip_Control(Int boton_tipo) 
BEGIN  
 control_type=ui_syscontrol;	       
 container=father;                        
 //si el boton es cerrar
 If (boton_tipo==1)
 	tooltip_text="Close";
 	ancho=graphic_info(skin.fpg,26,g_wide);
 	alto=graphic_info(skin.fpg,26,g_height);
 	Loop
 	 If (father.visible==1)
 	  	x=father.x+father.ancho-skin.w_close_x-ancho;
 	  	y=father.y+skin.w_close_y;
 	  	get_event();      	
 	  	If (event==ui_mouse_over)
 	  	 set_center(skin.fpg,27,0,0);
 	  	 map_put(skin.fpg,father.image_map,27,
 	  	 father.ancho-skin.w_close_x - ancho,skin.w_close_y);
 	  	END	
 	  	If (event==UI_MOUSE_EXIT )  
 	  	 set_center(skin.fpg,26,0,0);
 	  	 map_put(skin.fpg,father.image_map,26,
 	  	 father.ancho-skin.w_close_x - ancho,skin.w_close_y);
 	  	END     
 	  	If (event==ui_mouse_down )  
 	  	 set_center(skin.fpg,28,0,0);
 	  	 map_put(skin.fpg,father.image_map,28,
 	  	 father.ancho-skin.w_close_x - ancho,skin.w_close_y);
 	  	END 
 	  	If (event==ui_click)
 	  	 kill_process(container);
 	  	 Return;
 	  	END    
 	 END   
 	 //muestra tooltip
 		If (event==ui_mouse_still_over)
 		If (showing_tooltip==0) 
 			If (tooltip_time==30)
 				showing_tooltip=tooltip(id);
 				tooltip_time=0;
 			Else
 				tooltip_time++;
 			END 			
 		END
 		END
 	 Frame;
 	END   
 Else                   
 //si es de win_state
 	ancho=graphic_info(skin.fpg,29,g_wide);
 	alto=graphic_info(skin.fpg,29,g_height);
 	Loop
 	 If (father.visible==1) 
 	 	//si la ventana esta normal
 	   If (father.win_prop.win_state==0)
 	   	tooltip_text="Maximize";
 	  	x=father.x+father.ancho-skin.w_state_x-ancho;
 	  	y=father.y+skin.w_state_y;
 	  	get_event();      	
 	  	If (event==ui_mouse_over)
 	  	 set_center(skin.fpg,30,0,0);
 	  	 map_put(skin.fpg,father.image_map,30,
 	  	 father.ancho-skin.w_state_x - ancho,skin.w_state_y);
 	  	END	
 	  	If (event==UI_MOUSE_EXIT )  
 	  	 set_center(skin.fpg,29,0,0);
 	  	 map_put(skin.fpg,father.image_map,29,
 	  	 father.ancho-skin.w_state_x - ancho,skin.w_state_y);
 	  	END     
 	  	If (event==ui_mouse_down )  
 	  	 set_center(skin.fpg,31,0,0);
 	  	 map_put(skin.fpg,father.image_map,31,
 	  	 father.ancho-skin.w_state_x - ancho,skin.w_state_y);
 	  	END 
 	  	If (event==ui_click)
 	  	 father.x=0;
 	  	 father.y=0;
 	  	 father.ancho=graphic_info(0,Screen,g_wide);
 	  	 father.alto=graphic_info(0,Screen,g_height); 
 	  	 father.win_prop.win_state=1; 	  	 
 	  	END               
 	  //si esta maximizada	      
 	   Else 
 	   	tooltip_text="Restore";
 	    x=father.x+father.ancho-skin.w_state_x-ancho;
 	  	y=father.y+skin.w_state_y;
 	  	get_event();      	
 	  	If (event==ui_mouse_over)
 	  	 set_center(skin.fpg,33,0,0);
 	  	 map_put(skin.fpg,father.image_map,33,
 	  	 father.ancho-skin.w_state_x - ancho,skin.w_state_y);
 	  	END	
 	  	If (event==UI_MOUSE_EXIT )  
 	  	 set_center(skin.fpg,32,0,0);
 	  	 map_put(skin.fpg,father.image_map,32,
 	  	 father.ancho-skin.w_state_x - ancho,skin.w_state_y);
 	  	END     
 	  	If (event==ui_mouse_down )  
 	  	 set_center(skin.fpg,34,0,0);
 	  	 map_put(skin.fpg,father.image_map,34,
 	  	 father.ancho-skin.w_state_x - ancho,skin.w_state_y);
 	  	END 
 	  	If (event==ui_click)    
 	  	 //vuelve al tamaño anterior	
 	  	 father.x=father.win_prop.normal_x;
 	  	 father.y=father.win_prop.normal_y;
 	  	 father.ancho=father.win_prop.normal_width;
 	  	 father.alto=father.win_prop.normal_height;
 	  	 father.win_prop.win_state=0;
 	  	END   
 	   END	                  
 	 END  
 	 //muestra tooltip
 		If (event==ui_mouse_still_over)
 		If (showing_tooltip==0) 
 			If (tooltip_time==30)
 				showing_tooltip=tooltip(id);
 				tooltip_time=0;
 			Else
 				tooltip_time++;
 			END 			
 		END
 		END
 	 Frame;
 	END  	
 END
END

/*
********************************************************************
*                          PROCESO BOTON                           *
* TIPO: CONTROL                                                    *
********************************************************************
*/                      
     
PROCESS Button(container,Word Left,Word Top,String caption)
Private
Word _height,_width;
String _caption;
Word A_left,A_top; 
Byte must_refresh;    
Byte _border;
Byte _visible,_enabled;
BEGIN 
 control_type=ui_control; 
 must_refresh=1;
 file=skin.fpg;	                                
 ancho=70;
 alto=20; 
 visible=1;
 enabled=1; 
 x=container.x+Left;
 y=container.y+Top;
 tab_index=cant_controls(container);
 Loop     
 	//actualiza  x e y segun la pos de la ventana container      
 	x=container.x+Left;
 	y=container.y+Top;   
 	z=container.z; 	    
 	
 	If (enabled==1 AND visible==1 AND container.visible==1)
 		get_event();   
 	Else
 		event=ui_idle;
 	END
 	
 	//muestra tooltip
 	If (event==ui_mouse_still_over)
 		If (showing_tooltip==0) 
 			If (tooltip_time==30)
 				showing_tooltip=tooltip(id);
 				tooltip_time=0;
 			Else
 				tooltip_time++;
 			END 			
 		END
 	END
 	
 	
 	If (event==ui_mouse_over   OR _border!=border OR
 	 event==ui_key_down OR event== ui_key_up
 	OR event==ui_mouse_down OR  event==UI_MOUSE_EXIT) 	
 	 	_border=border;
 		must_refresh=1;                 
 	END              
 	 	
 	//comprueba cambio de propiedades que afectan al aspecto grafico
    If (_height!=alto OR _width!=ancho OR _caption != caption OR
    	A_left!=Left OR A_top !=Top OR _visible!=visible OR
    	_enabled!=enabled
    	/*OR event==ui_got_focus OR event==ui_lost_focus*/)
    	    	            
   		_enabled=enabled;
   		_visible=visible;
    	_caption=caption;
    	_height=alto;
    	_width=ancho;
    	refresh(container);
    	A_left=Left;
    	A_top=Top;
    END
    
    
 	
 	If (must_refresh==1 AND visible==1 AND container.visible==1)
 		
 		refresh(id); 		
 		
 		must_refresh=0;
 	END           
 	
 	Frame;
 END	
END
/*
********************************************************************
*                          PROCESO CHECK_BOX                       *
* TIPO: CONTROL.                                                   *
********************************************************************
*/                      
PROCESS Check_box(container,Word Left,Word Top,String caption)
Private
 //mapa_temp,mapa_temp2;
 //info; 
 String _caption;
 A_left,A_top;
 _visible,_enabled;
 //widthm; 
 _value;     
 Byte must_refresh;
BEGIN  
 control_type=ui_control;  
 must_refresh=1; 	
 file=skin.fpg;	                                
 //tomamos alto y ancho
 alto=graphic_info (skin.fpg,8,g_height);
 If (alto%2!=0)
 	alto++;
 END      
 
 widthm=graphic_info (skin.fpg,8,g_wide);
 
 visible=1;
 enabled=1; 
 tab_index=cant_controls(container);
 //must_refresh=1;
 Loop
 	//actualiza  x e y segun la pos de la ventana container      
 	x=container.x+Left;
 	y=container.y+Top;   
 	z=container.z;
 	
 	If (enabled==1 AND visible==1 AND container.visible==1)
 		get_event();   
 	Else
 		event=ui_idle;
 	END    
 	
 	//muestra tooltip
 	If (event==ui_mouse_still_over)
 		If (showing_tooltip==0) 
 			If (tooltip_time==30)
 				showing_tooltip=tooltip(id);
 				tooltip_time=0;
 			Else
 				tooltip_time++;
 			END 			
 		END
 	END
 	
 	If (ult_event==ui_click OR ult_event==ui_key_press)
 		If (value==1)
 			value=0 ; 		
 		Else     
 			value=1 ; 		
 		END
 	END   
 	
 	//comprueba cambio de propiedades que afectan al aspecto grafico
    If (_caption != caption OR 	A_left!=Left OR A_top !=Top 
    OR _visible!=visible OR	_enabled!=enabled  
    /*OR event==ui_got_focus OR event==ui_lost_focus */)    	    	            
    	
   		_enabled=enabled;
   		_visible=visible;
    	_caption=caption;    	
    	refresh(container);
    	A_left=Left;
    	A_top=Top;    	
    END                 
                          
    If (value!=_value)
    	_value=value;    	
    	event=ui_change;
    END
 	
 	//refresca si se producen cambios en los events
 	If (event==ui_mouse_over OR event==ui_change  
 	OR event==ui_key_down 
 	OR  event==UI_MOUSE_EXIT OR event==ui_mouse_down) 		
 		must_refresh=1;                 
 	END              
 	
 	If (must_refresh==1 AND visible==1 AND container.visible==1)
 		    	
    	 refresh(id);
 		
 		must_refresh=0;
 	END  
 	        	
 	Frame;
 END	
END
/*
********************************************************************
*                          PROCESO OPTION_BUTTON                   *
* TIPO: CONTROL.                                                   *
********************************************************************
*/                      
PROCESS Option_Button(container,Word Left,Word Top,String caption)
Private
 //mapa_temp,mapa_temp2;
 temp;
 //info; 
 String _caption;
 A_left,A_top;
 _visible,_enabled;
 //widthm; 
 _value; 
 Byte must_refresh;
BEGIN    
 control_type=ui_control;
 must_refresh=1; 	
 file=skin.fpg;	                                
 //tomamos alto y ancho
 alto=graphic_info (skin.fpg,18,g_height);
 
 If (alto%2!=0)
 	alto++;
 END      
 
 widthm=graphic_info (skin.fpg,18,g_wide);
 
 visible=1;
 enabled=1;
 tab_index=cant_controls(container); 
 //must_refresh=1;
 Loop
 	//actualiza  x e y segun la pos de la ventana container      
 	x=container.x+Left;
 	y=container.y+Top;   
 	z=container.z; 	
 	
 	If (enabled==1 AND visible==1 AND container.visible==1)
 		get_event();   
 	Else
 		event=ui_idle;
 	END
 	
 	//muestra tooltip
 	If (event==ui_mouse_still_over)
 		If (showing_tooltip==0) 
 			If (tooltip_time==30)
 				showing_tooltip=tooltip(id);
 				tooltip_time=0;
 			Else
 				tooltip_time++;
 			END 			
 		END
 	END    
 	
 	If (ult_event==ui_click OR ult_event==ui_key_press) 		
 		 temp=get_id(TYPE option_button);
    	 While (temp!=0)                 
    		If (temp.container==container)  
    		 temp.value=0;
    		END
    		temp=get_id(TYPE option_button);
    	 END          
    	 value=1 ; 		
 	END   
 	
 	//comprueba cambio de propiedades que afectan al aspecto grafico
    If (_caption != caption OR 	A_left!=Left OR A_top !=Top 
    OR event==ui_key_down  
    OR _visible!=visible OR	_enabled!=enabled
    /*OR event==ui_got_focus OR event==ui_lost_focus*/ )
    	
   		_enabled=enabled;
   		_visible=visible;
    	_caption=caption;    	
    	refresh(container);
    	A_left=Left;
    	A_top=Top;
    	
    END  
    If ( value!=_value)
    	_value=value;        	
    	event=ui_change;
    END
 	
 	//refresca si se producen cambios en los events
 	If (event==ui_mouse_over OR event==ui_mouse_down
 	OR event==ui_change OR  event==UI_MOUSE_EXIT)
 	must_refresh=1;                 
 	END              
 	
 	If (must_refresh==1 AND visible==1 AND container.visible==1)
 		    	
    	refresh(id);
 		
 		must_refresh=0;
 	END    
 	      
 	
 	Frame;
 END	
END  
/*
*******************************************************************
*						Proceso Label                             *
* TIPO: CONTROL.                                                *
*******************************************************************
*/
PROCESS Label (container,Word Left,Word Top,String Caption)
Private
Word _height,_width;
Word A_left,A_top;  
Byte must_refresh;
//temp;
Byte _visible;  
String _caption;  
_multi_line;
BEGIN   
 Multi_line=true;
 control_type=ui_control;
 file=skin.fpg;	                                
 visible=1;
 ancho=100;
 alto=100;        
 _caption=caption;
 must_refresh=1; 
 tab_index=cant_controls(container);
 Loop
  x=container.x+Left;
  y=container.y+Top;   
  z=container.z;
  //comprueba cambio de propiedades que afectan al aspecto grafico
    If (_height!=alto OR _width!=ancho OR A_left!=Left 
    OR A_top !=Top OR _visible!=visible OR _caption!=caption
    OR _multi_line!=multi_line)
    	_caption=caption;   		
   		_visible=visible;
    	_height=alto;
    	_width=ancho;
    	refresh(container);
    	//must_refresh=1;
    	A_left=Left;
    	A_top=Top; 
    	_multi_line=multi_line;
    END   
    
  If (must_refresh==1 AND container.visible==1 AND visible==1)  
  
  	refresh(id);
  	
  	must_refresh=0;
  END	
  Frame;
 END 
END  

/*
*******************************************************************
*						Proceso PicBox                            *
* TIPO: CONTROL.                                                  *
*******************************************************************
*/
PROCESS PicBox (container,Word Left,Word Top,fichero,picture)
Private
Word _height,_width;
Word A_left,A_top;  
Byte must_refresh;
//temp;
Byte _visible;  
Byte _fit;
Byte _border;
String _caption;  
BEGIN   
 control_type=ui_control;
 file=skin.fpg;	                                
 visible=1;
 ancho=100;
 alto=100;        
 border=0;
 must_refresh=1; 
 tab_index=cant_controls(container);
 Loop
  x=container.x+Left;
  y=container.y+Top;   
  z=container.z;
  
  If (enabled==1 AND visible==1 AND container.visible==1)
 		get_event();   
 	Else
 		event=ui_idle;
 	END;
	
  //comprueba cambio de propiedades que afectan al aspecto grafico
    If (_height!=alto OR _width!=ancho OR A_left!=Left 
    OR A_top !=Top OR _visible!=visible OR _caption!=caption
	OR _fit!=fit OR _border!=border 
    )
    	_visible=visible;
    	_fit = fit;
		_border= border;
		_height=alto;
    	_width=ancho;
    	refresh(container);
    	//must_refresh=1;
    	A_left=Left;
    	A_top=Top; 
    END   
  
  
  	If (event==ui_mouse_over OR event==ui_mouse_down
 	OR event==UI_MOUSE_EXIT)
 	must_refresh=1;                 
 	END
  
  If (must_refresh==1 AND container.visible==1 AND visible==1)  
  
  	refresh(id);
  	
  	must_refresh=0;
  END	
  Frame;
 END 
END
        
/*
*******************************************************************
*						Proceso Group_box                         *
* TIPO: CONTAINER.                                                *
*******************************************************************
*/
PROCESS Group_Box (container,Word Left,Word Top)
Private
Word _height,_width;
Word A_left,A_top;  
Byte must_refresh;
//temp;
Byte _visible,_enabled;
Byte _border;
BEGIN  
 control_type=ui_container;
 file=skin.fpg;	                                
 visible=1;
 ancho=100;
 alto=100;  
 must_refresh=1;   
 
 Loop
  x=container.x+Left;
  y=container.y+Top;  
  z=container.z;
  //comprueba cambio de propiedades que afectan al aspecto grafico
    If (_height!=alto OR _width!=ancho OR A_left!=Left 
    OR A_top !=Top OR _visible!=visible OR _enabled!=enabled
     OR _border!=border )
   		_enabled=enabled;  
   		_border=border;
   		_visible=visible;
    	_height=alto;
    	_width=ancho;
    	refresh(container);
    	A_left=Left;
    	A_top=Top;
    END
  If (must_refresh==1 AND container.visible==1 AND visible==1)  
  
  	refresh(id);
  	
  	must_refresh=0;
  END	
  Frame;
 END 
END  
/*
********************************************************************
*                          PROCESO Textbox                         *
* TIPO: CONTROL  
FALTA HACER PROPIEDAD MULTILINE!!!! (muahaha)                                                 *
********************************************************************
*/                      
     
PROCESS Input_box (container,Word Left,Word Top,String caption)
Private
Word _height,_width;
String _caption;
Word A_left,A_top;
Byte must_refresh;
Byte _visible,_enabled;
Byte _selstart;    
Byte Apretado;//contador de repeticion de las teclas
BEGIN 
 control_type=ui_control; 
 must_refresh=1;
 file=skin.fpg;	                                
 ancho=100;
 alto=20; 
 visible=1;
 enabled=1; 
 x=container.x+Left;
 y=container.y+Top;
 tab_index=cant_controls(container);
 Loop     
 	//actualiza  x e y segun la pos de la ventana container      
 	x=container.x+Left;
 	y=container.y+Top;   
 	z=container.z;
 	
 	If (enabled==1 AND visible==1 AND container.visible==1)
 		get_event();   
 	Else
 		event=ui_idle;
 	END
 	
 	//muestra tooltip
 	If (event==ui_mouse_still_over)
 		If (showing_tooltip==0) 
 			If (tooltip_time==30)
 				showing_tooltip=tooltip(id);
 				tooltip_time=0;
 			Else
 				tooltip_time++;
 			END 			
 		END
 	END
 		
 	//ok, si el mouse esta encima de la caja de texto
 	If (event!=ui_idle)
 		If (on_visible_area(id))
 		my_mouse=7;
 		Else
 		my_mouse=1;
 		END
 		
 	Else        		
 		my_mouse=1;		
 	END  
 	
 	If (event==ui_got_focus ) //si acaba de tomar foco
 		If (caption!="")
 			selstart=len(caption);//pone cursor en final de texto
 		END
 	END
 	
//Section: Me quede ACA
 	//si el control tiene el foco
 	If (active_control==id)
 		
 		//si se aprieta un tecla
 		If (event==ui_key_down)  			                 
 			key_ascii=ascii;  //se guarda cual fue 
 			//apretado=1;
 		END	
 		If (apretado==0)
 			If (scan_code!=0)
 				apretado++;       				
 			END
 			Switch (scan_code)
 				Case _left: 
 					If (selstart>0)
 						selstart--;    
 					END
 					//key_ascii=0;
 				END
 				Case _right: 
 					If (selstart<len(caption))
 						selstart++;    
 					END
 					//key_ascii=0;
 				END  
 				Case _home:
 					selstart=0;
 					//key_ascii=0;
 				END    
 				Case _END:   
 					selstart=len(caption);
 					//key_ascii=0;
 				END
 				Case _backspace: 
 					If (SELSTART>0)
 						If (selstart>1) 					
 							caption= substr(caption,0,selstart-1)+substr(caption,selstart,len(caption)); 
 						Else
 							caption=substr(caption,1,len(caption));
 						END	
 					END			
 					If (selstart>0)
 						selstart--;    
 					END 					
 					key_ascii=0;
 				END     
 				Case _del:   
 					If (selstart>0) 					
 						caption=substr (caption,0,selstart) + substr(caption,selstart+1,len(caption));;
 					Else
 						caption=substr(caption,1,len(caption));	
 					END
 					key_ascii=0;
 				END
 			END
 		Else
 			If (apretado<10 AND scan_code!=0)
 				apretado++;
 			Else
 				apretado=0;	
 			END	
 		END                             
 		//si se solto
 		If (event==ui_key_up)           
 			
 			//agrega a caption  la letra nueva en la pocision del cursor
 			If (key_ascii!=0) 
 				If (SELSTART==0)
 					CAPTION=chr(key_ascii)+caption;
 				Else
 					caption= substr(caption,0,selstart)+chr(key_ascii)+substr(caption,selstart,len(caption)); 
 				END 				
 			END
 			//se suma 1 a selstart (posicion del cursor)
 			If (key_ascii!=0)
 				selstart++;    
 			END  
 			key_ascii=0;
 			//must_refresh=1;       //y refresca
 		END
 	END
 	 	
 	//comprueba cambio de propiedades que afectan al aspecto grafico
    If (_height!=alto OR _width!=ancho OR 
    	A_left!=Left OR A_top !=Top OR _visible!=visible OR
    	_enabled!=enabled )     	    	            
   		_enabled=enabled;
   		_visible=visible;
    	_caption=caption;
    	_height=alto;
    	_width=ancho;
    	refresh(container);
    	A_left=Left;
    	A_top=Top;
    END
    
    If (caption!=_caption OR _selstart!=selstart)
    	_selstart=selstart;
    	_caption=caption;
    	must_refresh=1;
    END
    
 	
 	If (must_refresh==1 AND visible==1 AND container.visible==1)
 		
 		refresh(id); 		
 		
 		must_refresh=0;
 	END
 	
 	
 	Frame;
 END	
END

#ENDIF
