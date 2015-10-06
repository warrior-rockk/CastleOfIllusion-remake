// ========================================================================
//  Lista Enlaada
//  
//  01/10/15
//
//  Definiciones para lista enlazada
// ========================================================================

//Data Types

//tipo de dato nodo
Type _node
	_node* prevNode = NULL;
	_node* nextNode = NULL;
	int nodeData;
end;


//EJEMPLO

/*
global
	_node* activeMonster = NULL;
	_node* activeObject  = NULL;
end;	

addNode(&activeMonster,1);
removeNode(&activeMonster,1);
addNode(&activeMonster,1);
addNode(&activeMonster,2);
addNode(&activeMonster,3);
removeNode(&activeMonster,1);
removeNode(&activeMonster,3);
addNode(&activeMonster,4);
removeNode(&activeMonster,2);
addNode(&activeMonster,1);
addNode(&activeMonster,2);
removeNode(&activeMonster,1);
removeNode(&activeMonster,4);

listNodes(activeMonster);
listNodes(activeObject);

*/





