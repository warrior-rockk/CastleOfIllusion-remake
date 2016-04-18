
#IFNDEF FUIT_DIALOGS_INC
#DEFINE FUIT_DIALOGS_INC

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
*******************************************************************
Funcion de usuario:
		Muestra ventana de diálogo con un determinado mensaje y, en
		caso de tener el estilo MB_YESNO, guarda en la variable RET_YES
		si se presionó el botón "Aceptar".
		[BlueSteel]
*******************************************************************
*/

PROCESS MessageBox(int posX,int posY,STRING title, STRING msg, INT style)
PRIVATE
	INT id_window;
	INT id_btnYes, id_btnNo;
	INT id_label;
BEGIN
	signal(father, s_freeze);
	id_window = window(posX, posY, title, BDR_STATIC);
	id_window.alto = 100;
	id_label  = label(id_window, 10, 30, msg);
	id_label.ancho = 180;
	set_active_win(id_window);
	
	IF (style == MB_INFO)
		id_btnYes = button(id_window, 65, 50, "Aceptar");
	END
	
	IF (style == MB_YESNO)
		id_btnYes = button(id_window, 20, 50, "Sí");
		id_btnNo  = button(id_window, 110, 50, "No");
	END
		
	LOOP
	
		IF (style == MB_YESNO)
			IF (id_btnNo.event == UI_CLICK)
				signal(father, s_wakeup);
				destroy_window(id_window);
			END
		END
	
		IF (id_btnYes.event == UI_CLICK)
			signal(father, s_wakeup);
			destroy_window(id_window);
			ret_yes = TRUE;
		END
	  FRAME;
	END
END

#ENDIF 
 