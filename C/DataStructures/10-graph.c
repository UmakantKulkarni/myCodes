//10) Implementation of Graph using adjacency Matrix.
#include<stdio.h>
#define MAX_NODES 50
#define MAX_QUEUE_ELEMENTS 50
#define MAX_STACK_ELEMENTS 50

typedef struct GraphNode
{
	int data;
	int  visited;

}GraphNode;
typedef struct Queue
{
	int top,data[MAX_QUEUE_ELEMENTS];
	
}Queue;

typedef struct Stack
{
		int top,data[MAX_STACK_ELEMENTS];

}Stack;
typedef struct Graph
{
	int count;
	GraphNode *vertices;
	int adjacency[MAX_NODES][MAX_NODES];
	
}Graph;
//Queueue Functions
void Init_Queue(Queue *);
void enqueue(Queue *,int);
int  dequeue(Queue *);
int empty(Queue *);


//stack functions
int  pop(Stack *);
int peek(Stack *);
int  Isempty(Stack *);
void push(Stack *,int );
void Init_Stack(Stack *);

//Graph Functions

void DFS(Graph *);
void InitGraph(Graph *);
void create(Graph *);
int getAdjUnvisitedVertex(Graph *,int );
void BFS(Graph *);
void represent(Graph*);

int main()
{
	Graph graph;
	int choice;
	InitGraph(&graph);
	//clrscr();
	do 
	{
		printf("\nWhich of the following operation you want to perform  :  ");
		printf("\n1.Create A graph   :   ");
		printf("\n2.Represent a graph  : ");
		printf("\n3.Perform Depth first search ");
		printf("\n4.Perform Breadth first search ");
		printf("\n0.Exit ");
		printf("\nPlease Enter Your choice   :  ");
		scanf("%d",&choice);
		switch(choice)
		{
			case 1:
				create(&graph);
			break;
			
			case 2:represent(&graph);
			break;
			case 3:
				DFS(&graph);
			break;
			case 4:
				BFS(&graph);

			break;
		}

	}while(choice !=0);
	getch();
	return 0;
}
void Init_Queue(Queue *q)
{
	q->top = -1;
}
void enqueue(Queue *q,int element)
{
	q->data[++q->top] = element;
}

int  dequeue(Queue *q)
{
	q->top--;
	return q->data[0];
}
int empty(Queue *q)
{
	return q->top < 0;	
}

int  pop(Stack *s)
{
	return s->data[s->top--];
}
int peek(Stack *s)
{
	return s->data[s->top];
}


int  Isempty(Stack *s)
{
	return s->top < 0;
}

void push(Stack *s,int element)
{
	s->data[++s->top] = element;
}

void Init_Stack(Stack *s)
{
	s->top = -1;
}


void DFS(Graph *graph)
{
	int i;
	if(graph->vertices && graph->count > 0)
	{
		Stack stack;
		Init_Stack(&stack);
		for(i = 0; i < graph->count; i++)
		{
			graph->vertices[i].visited = 0;
		}

		printf("%d\t",graph->vertices[0].data);
		graph->vertices[0].visited= 1;
		push(&stack,0);

		while(!Isempty(&stack))
		{
			int vertex = peek(&stack);
			int child = getAdjUnvisitedVertex(graph,vertex);

			if(child != -1)
			{
				graph->vertices[child].visited = 1;
				printf("%d\t",graph->vertices[child].data);
				push(&stack,child);
			}
			else
			{
				pop(&stack);
			}
			
		}
	printf("\n");

	}
}

void InitGraph(Graph *graph)
{
	graph->count = 0;
	graph->vertices = NULL;
}


void create(Graph *graph)
{
	int i,j;
	printf("\nPlease Enter number of vertices: " );
	scanf("%d",&graph->count);
	graph->vertices = (GraphNode*)malloc(sizeof(GraphNode)*graph->count);
	
	printf("\nPlease enter %d vertices: ",graph->count);
	for( i = 0; i < graph->count; i++)
	{
		scanf("%d",&graph->vertices[i].data);
		graph->vertices[i].visited=0;
	}
	printf("\nPlease enter %d by %d adjacency matrix  ",graph->count,graph->count);
	for(i = 0; i < graph->count; i++)
	{
		for( j = 0; j < graph->count; j++)
		{
			scanf("%d",&graph->adjacency[i][j]);
		}
	}

}

int getAdjUnvisitedVertex(Graph *graph,int v)
{
	int j;
	for(j = 0; j < graph->count; j++)
	{
		if(graph->adjacency[v][j] == 1 && !graph->vertices[j].visited)
			return j;
	}

    return -1;
}  


void BFS(Graph *graph)
{
	int i,child;
	if(graph->vertices && graph->count > 0)
	{
		Queue queue;
		Init_Queue(&queue);
		for(i = 0; i < graph->count; i++)
			graph->vertices[i].visited = 0;
		
		printf("%d\t",graph->vertices[0].data);
		graph->vertices[0].visited= 1;
		enqueue(&queue,0);
		while(!empty(&queue))
		{
			int vertex = dequeue(&queue);
			while((child = getAdjUnvisitedVertex(graph,vertex)) != -1)
			{
				graph->vertices[child].visited = 1;
				printf("%d\t",graph->vertices[child].data);
				enqueue(&queue,child);
			}
			
		}
		printf("\n");
	}
}
void represent(Graph *graph)
{
	int i,j;
	printf("\n The graph has %d vertices  And Adjacency Matrix is :\n",graph->count);
	
	for(i=0;i<graph->count;i++)
	{
		for(j=0;j<graph->count;j++)
		{
			printf("%d\t",graph->adjacency[i][j]);
		}
		printf("\n");
	}
}



/*
						OUTPUT

E:\Vikas\DevEnv\Programming\Educational\Pune\c\se-entc>					

E:\Vikas\DevEnv\Programming\Educational\Pune\c\se-entc>10-graph.exe

Which of the following operation you want to perform  :
1.Create A graph   :
2.Represent a graph  :
3.Perform Depth first search
4.Perform Breadth first search
0.Exit
Please Enter Your choice   :  1

Please Enter number of vertices: 5

Please enter 5 vertices: 1 2 3 4 6

Please enter 5 by 5 adjacency matrix
1 1 1 1 1
1 1 1 1 1
1 1 1 1 1
1 1 1 1 1
1 1 1 1 1

Which of the following operation you want to perform  :
1.Create A graph   :
2.Represent a graph  :
3.Perform Depth first search
4.Perform Breadth first search
0.Exit
Please Enter Your choice   :  2

 The graph has 5 vertices  And Adjacency Matrix is
1       1       1       1       1
1       1       1       1       1
1       1       1       1       1
1       1       1       1       1
1       1       1       1       1

Which of the following operation you want to perform  :
1.Create A graph   :
2.Represent a graph  :
3.Perform Depth first search
4.Perform Breadth first search
0.Exit
Please Enter Your choice   :  3
1       2       3       4       6

Which of the following operation you want to perform  :
1.Create A graph   :
2.Represent a graph  :
3.Perform Depth first search
4.Perform Breadth first search
0.Exit
Please Enter Your choice   :  4
1       2       3       4       6

Which of the following operation you want to perform  :
1.Create A graph   :
2.Represent a graph  :
3.Perform Depth first search
4.Perform Breadth first search
0.Exit
Please Enter Your choice   :  0

E:\Vikas\DevEnv\Programming\Educational\Pune\c\se-entc>					
						
						
*/