// ========================================================================
//  Warcom Game Engine
//  Motor para juegos plataformas 2D
//  31/07/15
//
//  Funciones interface (gui,textos...)
// ========================================================================

//Funcion propia para escribir textos que admite caracteres de retorno de carro para multilinea
function wgeWrite(int fntFile,int x,int y,int align,string text)
private
	int breakPosition;	
	int startChar = 0;
	int posY;
begin
	//Posicion inicial
	posY = y;
	
	//buscamos retornos de carro en la cadena de texto
	while ( (breakPosition = find(text,"\n",startChar)) >= 0 )
		write(fntFile,x,posY,align,substr(text,startChar,breakPosition-startChar));
		startChar = breakPosition + 2;
		posy += text_height(fntGame,text) + dialogTextPadding;
	end;
	
	//escribimos la ultima linea
	write(fntFile,x,posY,align,substr(text,startChar,len(text)));
	
end;

//proceso que crea un cuadro de dialogo vacío
process wgeDialog(int x,int y,int _width,int _height)
begin

file = fpgGame;
width = _width;
height = _height;

//creamos grafico vacio
graph = map_new(width,height,8);
//dibujamos el dialogo
wgeDrawDialog(file,graph,width,height);

loop
	frame;
end;
end;

//Funcion que dibuja el cuadro de dialogo
function wgeDrawDialog(file,graph,int width,int height)
private
	int dialogTileSize 	= 3; 	//tamaño del motivo de las esquinas
	int i;						//Var aux
begin

//tamaño minimo dialogo
if (width < (dialogTileSize * 2)+1)
	width = (dialogTileSize * 2)+1;
end;
if (height < (dialogTileSize * 2)+1)
	height = (dialogTileSize * 2)+1;
end;

//coloreamos el dialogo
map_clear(file,graph,cDialogBackColor);

//dibujamos las esquinas
drawCorner(file,graph,0,0,cDialogColor,0);
drawCorner(file,graph,width-dialogTileSize,0,cDialogColor,B_HMIRROR);
drawCorner(file,graph,0,height-dialogTileSize,cDialogColor,B_VMIRROR);
drawCorner(file,graph,width-dialogTileSize,height-dialogTileSize,cDialogColor,B_HMIRROR | B_VMIRROR);

//dibujamos lineas  marco
drawing_map(file,graph);
drawing_color(cDialogColor);
//linea superior
draw_line(dialogTileSize,0,width-1-dialogTileSize,0);
//linea inferior
draw_line(dialogTileSize,height-1,width-dialogTileSize,height-1);
//lateral izquierda
draw_line(0,dialogTileSize,0,height-1-dialogTileSize);
//lateral derecha
draw_line(width-1,dialogTileSize,width-1,height-1-dialogTileSize);
		
end;

//funcion que dibuja una esquina para un cuadro de dialogo
function drawCorner(file,graph,x,y,_color,flags)
begin
	if (flags == (B_HMIRROR | B_VMIRROR))
		map_put_pixel(file,graph,x+2,y,_color);
		map_put_pixel(file,graph,x+1,y+1,_color);
		map_put_pixel(file,graph,x+2,y+1,_color);
		map_put_pixel(file,graph,x,y+2,_color);
		map_put_pixel(file,graph,x+1,y+2,_color);
		//transparente
		map_put_pixel(file,graph,x+2,y+2,0);
	elseif (flags == B_VMIRROR)
		map_put_pixel(file,graph,x,y,_color);
		map_put_pixel(file,graph,x,y+1,_color);
		map_put_pixel(file,graph,x+1,y+1,_color);
		map_put_pixel(file,graph,x+1,y+2,_color);
		map_put_pixel(file,graph,x+2,y+2,_color);
		//transparente
		map_put_pixel(file,graph,x,y+2,0);
	elseif (flags == B_HMIRROR)
		map_put_pixel(file,graph,x,y,_color);
		map_put_pixel(file,graph,x+1,y,_color);	
		map_put_pixel(file,graph,x+1,y+1,_color);
		map_put_pixel(file,graph,x+2,y+1,_color);
		map_put_pixel(file,graph,x+2,y+2,_color);
		//transparente
		map_put_pixel(file,graph,x+2,y,0);
	else
		map_put_pixel(file,graph,x+1,y,_color);
		map_put_pixel(file,graph,x+2,y,_color);
		map_put_pixel(file,graph,x,y+1,_color);
		map_put_pixel(file,graph,x+1,y+1,_color);
		map_put_pixel(file,graph,x,y+2,_color);
		//transparente
		map_put_pixel(file,graph,x,y,0);
	end;
	
end;

//funcion que escribe las opciones de un menu en la posicion correcta de un cuadro de dialogo
function wgeWriteDialogOptions(wgeDialog idDialog,string textOptions,int selected);
private
	//posicion del texto
	int textPosY;
	int textPosX;
	
	char delimiterChar = ";"; 	//caracter delimitador
	string textOption;			//texto actual
	int startChar = 0;			//comienzo texto
	int endChar  = 0;			//fin cadena
	int optionNum = 1;			//numero de opcion
begin
	//limpiamos textos
	delete_text(all_text);
	//redibujamos dialogo
	wgeDrawDialog(idDialog.file,idDialog.graph,idDialog.width,idDialog.height);
	
	//establecemos posicion inicial
	textPosX = idDialog.x - (idDialog.width>>1) + dialogTextMarginX;
	textPosY = idDialog.y - (idDialog.height>>1) + dialogTextMarginY;
	
	//mientras queden opciones en el string
	while(endChar >= 0) 
		//establecemos caracter inicio y fin
		startChar = find(textOptions,delimiterChar,endChar);
		endChar   = find(textOptions,delimiterChar,startChar+1);
		//obtenemos la cadena de la opcion
		textOption = substr(textOptions,startChar+1,endChar-(startChar+1));
		
		//escribimos la cadena
		write(fntGame,textPosX,textPosY,ALIGN_CENTER_LEFT,textOption);
		
		//pintamos el cursor si esta la opcion seleccionada
		if (optionNum == selected)
			map_put(fpgGame,idDialog.graph,12,dialogCursorMarginX,dialogTextMarginY+((optionNum-1)*(text_height(fntGame,textOption)+dialogMenuPadding)));
		end;
		
		//incrementamos la posicion Y del texto		
		textPosY += text_height(fntGame,textOption)+dialogMenuPadding;
		//incrementamos el numero de opcion
		optionNum++;

	end;

end;

//funcion que escribe los valores de seleccion de una opcion de menu
function wgeWriteDialogValues(wgeDialog idDialog,string textValues,int selected,int value);
private
	//posicion del texto
	int textPosY;
	int textPosX;
	
	char delimiterChar = ";"; 	//caracter delimitador
	string textValue;			//texto actual
	int startChar = 0;			//comienzo texto
	int endChar  = 0;			//fin cadena
	int valueNum = 0;			//numero de valor
begin
	
	//establecemos posicion inicial
	textPosX = idDialog.x + (idDialog.width>>1) - text_width(fntGame,"00");
	textPosY = idDialog.y - (idDialog.height>>1) + dialogTextMarginY;
	
	textPosY += (text_height(fntGame,textValues)+dialogMenuPadding)*(selected-1);
	
	//mientras queden opciones en el string
	while(endChar >= 0) 
		//establecemos caracter inicio y fin
		startChar = find(textValues,delimiterChar,endChar);
		endChar   = find(textValues,delimiterChar,startChar+1);
		//extraemos la cadena
		textValue = substr(textValues,startChar+1,endChar-(startChar+1));
		
		//escribimos el valor seleccionado de la opcion actual
		if (valueNum == value)
			write(fntGame,textPosX,textPosY,ALIGN_CENTER_RIGHT,textValue);
		end;
		
		//incrementamos el numero de opcion
		valueNum++;

	end;
end;

//funcion que escribe un valor numerico con maximo y minimo
function wgeWriteDialogVariable(wgeDialog idDialog,int minValue,int MaxValue,int value,int numOption)
private
	//posicion del texto
	int textPosY;
	int textPosX;
	
begin

	//establecemos posicion inicial
	textPosX = idDialog.x + (idDialog.width>>1) - dialogTextMarginX;
	textPosY = idDialog.y - (idDialog.height>>1) + dialogTextMarginY;
	//establecemos posicion relativa
	textPosY += (text_height(fntGame,value)+dialogMenuPadding)*(numOption-1);
	
	//escribimos el valor
	write(fntGame,textPosX,textPosY,ALIGN_CENTER_RIGHT,value);
	
	//pintamos flechas que indican los limites
	if (value > minValue)
		map_xput(fpgGame,idDialog.graph,12,idDialog.width-dialogTextMarginX-dialogCursorMarginX-text_width(fntGame,"00"),((text_height(fntGame,value)+dialogMenuPadding)*(numOption-1))+dialogTextMarginY,0,100,B_HMIRROR);
		
	end;
	if (value < maxValue)
		map_put(fpgGame,idDialog.graph,12,idDialog.width-dialogTextMarginX+dialogCursorMarginX,((text_height(fntGame,value)+dialogMenuPadding)*(numOption-1))+dialogTextMarginY);
	end;
	
end;