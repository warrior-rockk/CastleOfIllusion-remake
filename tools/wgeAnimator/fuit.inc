
#IFNDEF FUIT_INC
#DEFINE FUIT_INC 

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
	D E C L A R A C I O N E S
*/

//eventos

#DEFINE UI_IDLE             0
#DEFINE UI_MOUSE_EXIT       7 //retorna a idle
#DEFINE UI_CLICK            1
#DEFINE UI_MOUSE_DOWN       2
#DEFINE UI_MOUSE_UP         3
#DEFINE UI_MOUSE_STILL_DOWN 4
#DEFINE UI_MOUSE_OVER       5
#DEFINE UI_MOUSE_STILL_OVER 6   
#DEFINE UI_RESIZE           8
#DEFINE UI_CHANGE           9 
#DEFINE UI_GOT_FOCUS        10
#DEFINE UI_LOST_FOCUS       11   
#DEFINE UI_KEY_DOWN         12
#DEFINE UI_KEY_PRESS        13
#DEFINE UI_KEY_UP           14

//tipos de control

#DEFINE UI_CONTAINER  1
#DEFINE UI_CONTROL    2
#DEFINE UI_SYSCONTROL 3

//bordes de ventana "low level" ^_^

#DEFINE BDR_NONE     0
#DEFINE BDR_MOVEABLE 1
#DEFINE BDR_SIZABLE  2
#DEFINE BDR_CLOSE    4
#DEFINE BDR_STATE    8   
#DEFINE BDR_TITLE    16

//bordes de ventana simples

#DEFINE BDR_NORMAL BDR_TITLE + BDR_MOVEABLE + BDR_SIZABLE + BDR_CLOSE + BDR_STATE
#DEFINE BDR_FIXED  BDR_TITLE + BDR_MOVEABLE + BDR_CLOSE
#DEFINE BDR_STATIC BDR_TITLE + BDR_CLOSE

//estilos de MessageBox

#DEFINE MB_INFO  1
#DEFINE MB_ALERT 2
#DEFINE MB_YESNO 3

CONST
	fuit_version = 0.7;
END

TYPE Rect
	x;
	y;
	x1;
	y1;
END

GLOBAL 
//Guarda configuracion de el aspecto grafico 
 	Struct skin
 	//propiedades de la skin
 
 		//fichero de imagenes
 		fpg;
 		//propiedades del titlebar
 		//Word ttlbr_x,ttlbr_x2; 
 		Word ttlbr_y;              
 		/*el largo de la barra de titulo esta dado por el ancho de la
 		ventana menos el valor de la siguiente variable*/ 
 		//Word ttlbr_HEIGHT;	      
 		Word ttlbr_caption_x;
 		Word ttlbr_caption_y;		
 		//WORD ttlbr_font;   
 		Word ttlbr_font_color;
 		cursors_fpg;
 		Word W_close_x;  
 		Word W_close_y;
 		Word W_state_x;
 		Word W_state_y;
 	END 
	Active_win; //ID de la ventana con foco
	Active_control;      
 
	//globales de sistema
	p_main;
END

Local 
//propiedades comunes a todos los "objetos"
	Word Left,Top;//posicion x e y de los objetos que se colocan en las ventanas
	Word ALTO,ancho;
	Byte border=1;
	Byte Tab_index=0;//orden de tabulación
	Byte event; 
	Byte ult_event;   
	Int picture; //imagen que se pintara de fondo en el control
	Int fichero;
	Byte fit;
	Int Key_ascii;
	Int selstart;//indica la pasicion en la cadena donde se insertara el caracter 
	String caption; 
	Byte value;
	Byte visible=1;
	Byte enabled=1;  
	container=0;//ID ventana que contiene al objeto 
	Byte My_mouse; //indica como debe estar el cursor en cada ventana  
	Word widthM; 
	Image_map;    //mapa donde se dibujan los objetos    
	Data_map;  //En algunos procesos, el mapa que esta dentro de un area rect. 
	Byte showing_tooltip;
	Byte Multi_line;
	Int font;  
	Byte Control_type; //especifica si es contenedor o control  
	rect DragArea;
	Struct Win_prop 	
		Byte Win_state=0; //Estados de la ventana (0-normal,1-maximizada)	
		close_button=0;   //id boton cerrar
		state_button=0;   //id boton maximizar-normal
		Byte hasTitle=0;
		Byte moviENDo=0,sizing=0; //si se esta moviENDo o cambiando tamaño    
		Byte sizable=0;   //si se puede cambiar de tamaño
		Byte moveable=0;    //si se puede mover
		Word Normal_x=0;     //posicion cuando una ventana esta estado normal
		Word Normal_y=0;
		Word Normal_width=0; 
		Word Normal_height=0; 
	END
	String tooltip_text;
	Byte Tooltip_time; 
	BYTE ret_yes;
END

/*
A P I
*/
 	 
PROCESS HasValue(Total,parametro)
Private
	var=16;//valor maximo que puede tomar parametro
	i;
BEGIN    
	For (i=0;i<5;i++)//cuantas veces hay que dividir var en 2 para llegar a 1
		If (total>=var)
			If (var==parametro)
				Return 1;
			END
			total=total-var;			
		END	
		var=var/2;
	END
	Return 0;
END

/*
*******************************************************************
Funcion interna y de usuario:
		Es importante no matar lo procesos creados con esta 
	libreria de la manera corriente (signal (id,s_kill)),
	debido a que hay procesos que llaman a otros y estos quedarian
	ocupando memoria.
		La forma correcta es hacerlo con esta funcion:
	               KILL_PROCESS(Int PROCESO)
*******************************************************************
*/

PROCESS Kill_PROCESS (proceso)
Private
	temp;
BEGIN 
	If (proceso==active_control)
		active_control=0;
	END   
	If (proceso==active_win)
		set_active_win(get_top_win(active_win));
	END              
	If (proceso.image_map!=0)
	//If (map_exists(0,proceso.image_map))
		unload_map(0,proceso.image_map);
	END
	If (proceso.graph!=0)
	//If (map_exists(0,proceso.graph))
		unload_map(0,proceso.graph);
	END
	If (proceso.data_map!=0)
	//If (map_exists(0,proceso.data_map))
		unload_map(0,proceso.data_map);
	END
	temp=get_id(0);
	While (temp!=0)
		
		If (temp.container==proceso)			
			If (temp.control_type==ui_container)
				kill_process(temp);
			Else 
				signal(temp,s_kill/*_tree*/);			
			END
		END  
		temp=get_id(0);	  
	END
	If (proceso.container!=0)
		refresh(proceso.container);
	END                             	
	signal(proceso,s_kill/*_tree*/);	
END

/*      
********************************************************************
* Inicia configuracion predeterminada de la UI                     *
* obligatorio antes de crear cualquier proceso de UI               *
* Ademas llama al proceso que controla cursor del mouse                           *
********************************************************************
*/

PROCESS fuit_init(STRING skin_fpg, STRING cursors_fpg) 
BEGIN
   /*
   inicio propiedades de la skin
   */
  
 	//fichero de imagenes
 	skin.fpg=load_fpg(skin_fpg);
 	//propiedades del titlebar 	
 	/*skin.ttlbr_x=20;
 	skin.ttlbr_x2=50;*/
 	skin.ttlbr_y=5;	
 	//skin.ttlbr_height=10;	 	  
 	
 	skin.ttlbr_caption_x=25;
 	skin.ttlbr_caption_y=8;		
 	
 	skin.cursors_fpg=load_fpg(cursors_fpg);
 	skin.W_close_x=4;
 	skin.W_close_y=4;
 	skin.W_state_x=19;
 	skin.W_state_y=4;
    /*
    llama a un proceso que controla los cursores del raton
    */    
  p_main=FUIT_control();         
END          

/*
Termina el uso de la ui 
Libera memoria utilizada por FUIT
*/

PROCESS fuit_quit()     
Private
	temp;
BEGIN
	temp=get_id(0);
	While (temp!=0)
		If (temp.control_type!=0)
			kill_process(temp);
		END           
		temp=get_id(0);
	END
	signal(p_main,s_kill);
	mouse.graph=0;
	unload_fpg(skin.fpg);
 	unload_fpg(skin.cursors_fpg);
END    

/* 
********************************************************************
* FUNCION INTERNA                                                  *
* Este proceso toma el event y lo asigna al proceso padre         *
********************************************************************	
*/
PROCESS get_event()
Private
temp;
BEGIN

 //recorre lista de ventanas
 temp=get_id(TYPE window);
 While (temp!=0)
 		
 		If (temp!=father)
 			//si alguna esta ejecutando algunas de estas acciones
 			If (temp.win_prop.moviENDo==1 OR temp.win_prop.sizing==1) 
 				//evita que reciva event
 				father.event=ui_idle;
 				Return;
 			END
 		END	   
 		temp=get_id(TYPE window);
 END 
 	
 //si se encuentra el mouse dentro del area visible del objeto	 	
 If (on_visible_area(father)==1)
	 //si se aprieta un boton
	 If (mouse.left OR mouse.right)   
	 	//si el ya se tenia presionado
	 	If (father.ult_event==ui_mouse_down OR father.ult_event==ui_mouse_still_down)
	 		//entonces se mantiene presionado
	 		father.event=ui_mouse_still_down;	
	 	Else    
	 		//se prosiona recien ahora
	 		father.event=ui_mouse_down;	
	 	END 	 	
	 Else//	si no se presina boton
	 	//si el event anterior fue mouse_down
	 	If (father.ult_event==ui_mouse_down OR father.ult_event==ui_mouse_still_down)
	 		father.event=ui_mouse_up;
	 	Else                                   
	 		//si se levanto el mouse
	 		If (father.ult_event==ui_mouse_up)
	 	    	father.event=ui_click;
	 		Else       
	 			If ( father.ult_event==ui_click)
	 				father.event=ui_mouse_over;
	 			END
	 			//si no se presino nada ni hubo click
	 	   		If (father.ult_event==ui_mouse_still_over OR father.ult_event==ui_mouse_over)
	 	    		father.event=ui_mouse_still_over;
	 	    	Else
	 	    		father.event=ui_mouse_over;
	 	    	END	 	
	 		END 
	 	END 	 	  
	 END  
	 
 Else          
 	//si esta fuera del objeto
 	
 	If (father.ult_event!=ui_idle OR father.ult_event!=UI_MOUSE_EXIT)      
 		//y antes se estaba apretando dentro
 		father.event=UI_MOUSE_EXIT;
 	Else                                 
 		//si no nada :P
 		father.event=ui_idle;
 	END
 END   
 
 //si el control tiene el foco
 If (ACTIVE_CONTROL==father)
 	//si se presiona una tecla  (no soporta teclas scan_code)
 	If (ascii!=0 AND scan_code!=_tab)
 		father.event=ui_key_down;
 	Else
 		If (father.ult_event==ui_key_down)
 			father.event=ui_key_up;
 		Else                   
 			If (father.ult_event==ui_key_up)
 				father.event=ui_key_press;
 			END
 		END	
 	END 	
 	
 END
 
 //si se ha hecho click sobre el control 
 If (father.ult_event==ui_click AND father!=active_control)
 	set_focus(father);
 END
 
 If (father.event==father.ult_event)
 	//si no es uno de esos event que deben permanecer activos
 	If (father.event!=ui_mouse_still_over AND father.event!=ui_mouse_still_down)
 		father.event=ui_idle; 	
 	END 
 Else                   
 	father.ult_event=father.event;
 END
  
END

INCLUDE "src/f_window.inc";
INCLUDE "src/f_draw.inc";
INCLUDE "src/f_control.inc";
INCLUDE "src/f_mouse.inc";
INCLUDE "src/f_dialogs.inc";

#ENDIF
