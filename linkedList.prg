// ========================================================================
//  Lista Enlaada
//  
//  01/10/15
//
//  Funciones para una lista enlazada
// ========================================================================

//tipo de dato nodo
Type _node
	_node* prevNode = NULL;
	_node* nextNode = NULL;
	int nodeData;
end;


//Funcion para listar los nodos
function listNodes(_node* nodeObject)
begin
if (nodeObject == NULL)
	say("Lista vacia");
else
	say("Contenido:");
	while (nodeObject != NULL)
		say(nodeObject.nodeData);
		nodeObject = nodeObject.nextNode;	
	end;
	say("FIn Lista");
end;
end;


//Funcion para añadir un nodo (Pila)
function addNode(_node** nodeObject,int nodeData)
private
_node* newNode = NULL;
begin
//creamos el nuevo nodo
newNode = alloc(sizeof(_node));
newNode.nodeData = nodeData;
newNode.prevNode = NULL;
newNode.nextNode = NULL;

//si la lista está vacía
if (*nodeObject == NULL)
	*nodeObject = newNode;
else //si hay algun dato
	(*nodeObject).prevNode = newNode;
	newNode.nextNode = *nodeObject;
	*nodeObject = newNode;
end;
end;

//funcion para quitar un nodo segun su dato
function int removeNode(_node** nodeObject,int nodeData)
private
_node* searchNode;
begin
	searchNode = *nodeObject;
		
	while(searchNode != NULL)
	if (searchNode.nodeData == nodeData)
		//si es el primero
		if (searchNode.prevNode == NULL)
			*nodeObject = searchNode.NextNode;
			if (*nodeObject != NULL)
				(*nodeObject).prevNode = NULL;
			end;
		//si es el ultimo
		elseif (searchNode.nextNode == NULL)
			searchNode.prevNode.nextNode = NULL;
		else	
			searchNode.prevNode.nextNode = searchNode.nextNode;
			searchNode.nextNode.prevNode = searchNode.prevNode;
		end;
		
		free(searchNode);
		say("eliminado nodo");
		return 0;
	else
		searchNode = searchNode.nextNode;
	end;
end;

say("nodo no encontrado");
return -1;

end;