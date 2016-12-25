//7) Queue using array & LL.

#include<stdio.h>
#define MAX_QUEUE 30
typedef struct node
{
	int data;
	struct node *next;
	
}node;


typedef struct queue_ll
{
	node *front ,*rear;
	
}queue_ll;



typedef struct queue
{
	int data[MAX_QUEUE];
	int front ,rear;
}queue;

void init_ll( queue_ll *q)
{
	q->front=NULL;
	q->rear=NULL;
}
void create_ll( queue_ll *q)
{

	int i,size;
	printf("\nPlease enter total elements in your queue  :");
	scanf("%d",&size);
	printf("\nPlease enter %d elements   :  ",size);
	for(i=0;i<size;i++)
	{
		node *item=(node*)malloc(sizeof(node));
		item->next=NULL;
		scanf("%d",&(item->data));
		if(q->rear==NULL)
		{
			q->front=item;
			q->rear=item;
		}
		else
			q->rear->next=item;
		q->rear=item;
		
	}
	
}
void enqueue_ll(queue_ll *q)
{
	node *item=(node*)malloc (sizeof(node));
	item->next=NULL;
	printf("\nPlease enter the data to be inserted");
	scanf("%d",&item->data);
	q->rear->next=item;
	q->rear=item;
}
node *dequeue_ll(queue_ll *q)
{
	node *current=q->front;
	node *last= q->rear;;
	if(current !=NULL)
	{
		if(q->front==q->rear)
			q->front=q->rear=NULL;
		else
		{
		
			while(current->next!=q->rear)
				current=current->next;
			
			current->next=NULL;
			q->rear=current;
		}
	}
	return last;	
}
	
void print_ll(queue_ll *q)
{
	node *current=q->front;
	while(current!=NULL)
	{
		printf("%d\t",current->data);
		current=current->next;
	}
	
}
int empty_ll(queue_ll *q)
{
	return q->front==NULL;
}
void queue_ll_operations()
{
	int choice;
	queue_ll q;
	init_ll(&q);
		
	do 
	{
		printf("\nWhich of the following operation you want to perform ");
		printf("\n1.Create  a queue  :");
		printf("\n2.Print  a queue  :");
		printf("\n3.Enqueue an element in the queue  :");
		printf("\n4.Dequeue an element from the queue  :");
		printf("\n5.Check for empty  :");
		printf("\n0.Exit  :  ");
		printf("\nPlease  enter your choice  :");
		scanf("%d",&choice);
		switch(choice)
		{
			case 1:
				create_ll(&q);

				break;
			
			case 2:
				print_ll(&q);
				break;
				
			case 3:
				enqueue_ll(&q);
				print_ll(&q);
				break;
				
			case 4:
				dequeue_ll(&q);
				print_ll(&q);
				break;
			case 5:
			
				if(q.front==NULL)
					printf("\nThe Queue is Empty  :  ");
				else 
					printf("\nQueue is  Not Empty  :  ");
				
				break;
				
		}
	}while(choice !=0);
	
	
}

void init(queue *q)
{
	q->front=0;
	q->rear=-1;
}
void create( queue *q)
{

	int i,size;
	printf("\nPlease enter total elements in your queue  :");
	scanf("%d",&size);
	printf("\nPlease enter %d elements   :  ",size);
	for(i=0;i<size;i++)
		scanf("%d",&(q->data[++q->rear]));
	
	
}
void enqueue(queue *q)
{		
	printf("\nPlease enter the element to be inserted  :");
	scanf("%d",&(q->data[++q->rear]));
}
int dequeue(queue *q)
{
	int i,element;
	if(q->rear!=-1)
	{
		element=q->data[0];
		for(i=0;i<q->rear;i++)
			q->data[i]=q->data[i+1];
		q->rear--;
		return element;
	}
	else
		printf("\nQueue is Empty  :");
	
}
	
void print(queue *q)
{
	int i;
	for(i=0;i<=q->rear;i++)
		printf("%d\t",q->data[i]);
	
	
}
int empty(queue *q)
{
	return q->rear==-1;
}
void queue_operations()
{
	int choice;
	queue q;
	init(&q);
	
	do 
	{
		printf("\nWhich of the following operation you want to perform ");
		printf("\n1.Create  a queue  :");
		printf("\n2.Print  a queue  :");
		printf("\n3.Enqueue an element in the queue  :");
		printf("\n4.Dequeue an element from the queue  :");
		printf("\n5.Check for empty  :");
		printf("\n0.Exit  :  ");
		printf("\nPlease  enter your choice  :");
		scanf("%d",&choice);
		switch(choice)
		{
			case 1:
				create(&q);

				break;
			
			case 2:
				print(&q);
				break;
				
			case 3:
				enqueue(&q);
				print(&q);
				break;
				
			case 4:
				dequeue(&q);
				print(&q);
				break;
			case 5:
				if(q.front==q.rear)
					printf("\nThe Queue is Empty  :  ");
				else 
					printf("\nQueue is  Not Empty  :  ");
				
				break;
				
		}
	}while(choice !=0);
	
}

int main()
{
	
	int choice;
	do
	{
		printf("\nWhich of the Following Queue You Want to Implement  : ");
		printf("\n1.Queue Using Array  :");
		printf("\n2.Queue Using Linked List  :");
		printf("\n0.Exit  :");
		printf("\nPlease Enter Your Choice  ");
		scanf("%d",&choice);
		switch(choice)
		{
			case 1:
				queue_operations();
				break;
			case 2:
				queue_ll_operations();
				break;
				
		}
		
	}while(choice!=0);
	
	getch();
	return 0;
}



/*


				OUTPUT
				
E:\Programming\c\se-entc>gcc 7-queue.c

E:\Programming\c\se-entc>a

Which of the Following Queue You Want to Implement  :
1.Queue Using Array  :
2.Queue Using Linked List  :
0.Exit  :
Please Enter Your Choice  1

Which of the following operation you want to perform
1.Create  a queue  :
2.Print  a queue  :
3.Enqueue an element in the queue  :
4.Dequeue an element from the queue  :
5.Check for empty  :
0.Exit  :
Please  enter your choice  :1

Please enter total elements in your queue  :5

Please enter 5 elements   :  1 2 3 4 5

Which of the following operation you want to perform
1.Create  a queue  :
2.Print  a queue  :
3.Enqueue an element in the queue  :
4.Dequeue an element from the queue  :
5.Check for empty  :
0.Exit  :
Please  enter your choice  :2
1       2       3       4       5
Which of the following operation you want to perform
1.Create  a queue  :
2.Print  a queue  :
3.Enqueue an element in the queue  :
4.Dequeue an element from the queue  :
5.Check for empty  :
0.Exit  :
Please  enter your choice  :3

Please enter the element to be inserted  :6
1       2       3       4       5       6
Which of the following operation you want to perform
1.Create  a queue  :
2.Print  a queue  :
3.Enqueue an element in the queue  :
4.Dequeue an element from the queue  :
5.Check for empty  :
0.Exit  :
Please  enter your choice  :4
2       3       4       5       6
Which of the following operation you want to perform
1.Create  a queue  :
2.Print  a queue  :
3.Enqueue an element in the queue  :
4.Dequeue an element from the queue  :
5.Check for empty  :
0.Exit  :
Please  enter your choice  :5
Queue is  Not Empty  :

Which of the following operation you want to perform
1.Create  a queue  :
2.Print  a queue  :
3.Enqueue an element in the queue  :
4.Dequeue an element from the queue  :
5.Check for empty  :
0.Exit  :
Please  enter your choice  :0

Which of the Following Queue You Want to Implement  :
1.Queue Using Array  :
2.Queue Using Linked List  :
0.Exit  :
Please Enter Your Choice  2

Which of the following operation you want to perform
1.Create  a queue  :
2.Print  a queue  :
3.Enqueue an element in the queue  :
4.Dequeue an element from the queue  :
5.Check for empty  :
0.Exit  :
Please  enter your choice  :1

Please enter total elements in your queue  :5

Please enter 5 elements   :  1 2 3 4 5

Which of the following operation you want to perform
1.Create  a queue  :
2.Print  a queue  :
3.Enqueue an element in the queue  :
4.Dequeue an element from the queue  :
5.Check for empty  :
0.Exit  :
Please  enter your choice  :2
1       2       3       4       5
Which of the following operation you want to perform
1.Create  a queue  :
2.Print  a queue  :
3.Enqueue an element in the queue  :
4.Dequeue an element from the queue  :
5.Check for empty  :
0.Exit  :
Please  enter your choice  :3

Please enter the data to be inserted 6
1       2       3       4       5       6
Which of the following operation you want to perform
1.Create  a queue  :
2.Print  a queue  :
3.Enqueue an element in the queue  :
4.Dequeue an element from the queue  :
5.Check for empty  :
0.Exit  :
Please  enter your choice  : 4
1       2       3       4       5
Which of the following operation you want to perform
1.Create  a queue  :
2.Print  a queue  :
3.Enqueue an element in the queue  :
4.Dequeue an element from the queue  :
5.Check for empty  :
0.Exit  :
Please  enter your choice  :5
Queue is  Not Empty  :

Which of the following operation you want to perform
1.Create  a queue  :
2.Print  a queue  :
3.Enqueue an element in the queue  :
4.Dequeue an element from the queue  :
5.Check for empty  :
0.Exit  :
Please  enter your choice  :0


Which of the Following Queue You Want to Implement  :
1.Queue Using Array  :
2.Queue Using Linked List  :
0.Exit  :
Please Enter Your Choice  0


E:\Programming\c\se-entc>
*/