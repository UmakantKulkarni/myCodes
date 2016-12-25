//6) Implementation of stack using arrays & LL.
#include<stdio.h>
#define MAX_STACK 30
typedef struct node
{
	int data;
	struct node *next;

}node;
struct stack
{
	int data[MAX_STACK];
	int top;
};

/* stack operations using Array */
void init(struct stack *);
int empty(struct stack *);
int full(struct stack *);
void push(struct stack *, int );
int pop(struct stack *);
int top(struct stack * );
void create(struct stack *);
void print(struct stack *);


//stack functions  using linked list
node *create_ll();
//as we are traverssing from top it
//will definately print in reverse order
void print_ll(node *);
node * push_ll(node *);
node *pop_ll(node *);
node *top_ll(node *);
int empty_ll(node *);
void stack_ll();
void stack();


int main()
{
	int choice;
	do
	{
		printf("\nWhich Type of stack you want to implement  :");
		printf("\n1.stack using Array  :");
		printf("\n2.stack using Linked list  :");
		printf("\n0.exit ");
		printf("\nPlease enter your choice");
		scanf("%d",&choice);
		switch(choice)
		{
			case 1:
				stack();
				break;
			case 2:
				stack_ll();
				break;
		}
	}while(choice!=0);
	getch();
	return 0;
}



/* stack operations using Array */
void init(struct stack *s)
{
	s->top=-1 ;
}
int empty(struct stack *s)
{
	return s->top< 0;
}

int full(struct stack *s)
{
	return s->top == MAX_STACK;
}

void push(struct stack *s, int data)
{
	s->data[++s->top] = data;
}
int pop(struct stack *s)
{
	return s->data[(s->top)--];
}

int top(struct stack * s)
{
	return s->data[s->top ];
}
void create(struct stack *s)
{
	int i,data,size;
	printf("\n Pleasse enter Total  elements  :   ");
	scanf("%d",&size);

	printf("\n Pleasse enter %d elements  :   ",size);
	for(i=0;i<size;i++)
	{
		scanf("%d",&s->data[++s->top]);

	}
}
void print(struct stack *s)
{
	int i;
	for(i=0;i<=s->top;i++)
		printf("%d\t",s->data[i]);

}
node *create_ll()
{
	node *top=NULL;
	int i,size;
	printf("\nPlease Enetr total elements of the stack  :  ");
	scanf("%d",&size);
		printf("\n Please enter %d elements  :   ",size);
	for(i=0;i<size;i++)
	{
		node *item=(node*)malloc(sizeof(node));
		item->next=NULL;
		scanf("%d",&(item->data));
		item->next=top;
		top=item;
	}
	return top;
}
//as we are traverssing from top it
//will definately print in reverse order
void print_ll(node *top)
{
	node *current=top;
	while(current!=NULL)
	{
		printf("%d\t",current->data);
		current=current->next;
	}
}
node * push_ll(node *top)
{
	node *item=(node*)malloc(sizeof(node));
	item->next=NULL;
	printf("\n Please Enter the data to be inserted   :    ");
	scanf("%d",&(item->data));
	item->next=top;
	top=item;
	return top;
}
node *pop_ll(node *top)
{
	node *element=top;
	top=top->next;
	free(element);
	return top;

}

node *top_ll(node *top)
{
	return top;
}
int empty_ll(node *top)
{
	return top==NULL;

}
void stack_ll()
{
	node *top;
	int choice;
	do
	{
		printf("\n1.Which of the following operation you want to perform  :  ");
		printf("\n 1.create a stack   :  ");
		printf("\n2.print the stack elements  :   "  );
		printf("\n3.push the element into the stack  :  ");
		printf("\n4.Pop the element from the stack ");
		printf("\n5.Check for empty or not  : " );
		printf("\n0.Exit  :");
		printf("\n Please enter your choice  :  ");
		scanf("%d",&choice);
		switch(choice)
		{
			case 1:
				top=create_ll();
				break;
			case 2:
				print_ll(top);
				break;
			case 3:
				top=push_ll(top);
				break;
			case 4:
				top=pop_ll(top);
				break;
			case 5:
				if(top==NULL)
					printf("\n Yes the stack is empty  "  );
				else
					printf("\nno the stack is not empty  ");
				break;
		}
	}while(choice !=0);

}

void stack()
{

	int choice,element;
	struct stack s;
	init(&s);
	do
	{
		printf("\n1.Which of the following operation you want to perform  :  ");
		printf("\n 1.create a stack   :  ");
		printf("\n2.print the stack elements  :   "  );
		printf("\n3.push the element into the stack  :  ");
		printf("\n4.Pop the element from the stack ");
		printf("\n5.Check for empty or not  : " );
		printf("\n0.Exit  :");
		printf("\n Please enter your choice  :  ");
		scanf("%d",&choice);
		switch(choice)
		{
			case 1:
				create(&s);              //
				break;
			case 2:
				print(&s);
				break;
			case 3:
				printf("\nPlease enter  The element   to be pushed ");
				scanf("%d",&element);
				push(&s,element);
				break;
			case 4:
				pop(&s);
				break;
			case 5:
				if(empty(&s)==1)
					printf("\n Yes the stack is empty  "  );
				else
					printf("\nno the stack is not empty  ");
				break;
		}
	}while(choice !=0);
	
}



/*

E:\Vikas\DevEnv\Programming\Educational\Pune\c\se-entc>gcc 6-stack.c

E:\Programming\c\se-entc>a.exe

Which Type of stack you want to implement  :
1.stack using Array  :
2.stack using Linked list  :
0.exit
Please enter your choice1

1.Which of the following operation you want to perform  :
 1.create a stack   :
2.print the stack elements  :
3.push the element into the stack  :
4.Pop the element from the stack
5.Check for empty or not  :
0.Exit  :
 Please enter your choice  :  1

 Pleasse enter Total  elements  :   6

 Pleasse enter 6 elements  :   1 2 3 4 5 6

1.Which of the following operation you want to perform  :
 1.create a stack   :
2.print the stack elements  :
3.push the element into the stack  :
4.Pop the element from the stack
5.Check for empty or not  :
0.Exit  :
 Please enter your choice  :  2
1       2       3       4       5       6
1.Which of the following operation you want to perform  :
 1.create a stack   :
2.print the stack elements  :
3.push the element into the stack  :
4.Pop the element from the stack
5.Check for empty or not  :
0.Exit  :
 Please enter your choice  :  3

Please enter  The element   to be pushed 7

1.Which of the following operation you want to perform  :
 1.create a stack   :
2.print the stack elements  :
3.push the element into the stack  :
4.Pop the element from the stack
5.Check for empty or not  :
0.Exit  :
 Please enter your choice  :  2
1       2       3       4       5       6       7
1.Which of the following operation you want to perform  :
 1.create a stack   :
2.print the stack elements  :
3.push the element into the stack  :
4.Pop the element from the stack
5.Check for empty or not  :
0.Exit  :
 Please enter your choice  :  4

1.Which of the following operation you want to perform  :
 1.create a stack   :
2.print the stack elements  :
3.push the element into the stack  :
4.Pop the element from the stack
5.Check for empty or not  :
0.Exit  :
 Please enter your choice  :  2
1       2       3       4       5       6
1.Which of the following operation you want to perform  :
 1.create a stack   :
2.print the stack elements  :
3.push the element into the stack  :
4.Pop the element from the stack
5.Check for empty or not  :
0.Exit  :
 Please enter your choice  :  5

no the stack is not empty
1.Which of the following operation you want to perform  :
 1.create a stack   :
2.print the stack elements  :
3.push the element into the stack  :
4.Pop the element from the stack
5.Check for empty or not  :
0.Exit  :
 Please enter your choice  :  0

Which Type of stack you want to implement  :
1.stack using Array  :
2.stack using Linked list  :
0.exit
Please enter your choice 2

1.Which of the following operation you want to perform  :
 1.create a stack   :
2.print the stack elements  :
3.push the element into the stack  :
4.Pop the element from the stack
5.Check for empty or not  :
0.Exit  :
 Please enter your choice  :  1

Please Enetr total elements of the stack  :  5

 Please enter 5 elements  :   1 2 3 4 5

1.Which of the following operation you want to perform  :
 1.create a stack   :
2.print the stack elements  :
3.push the element into the stack  :
4.Pop the element from the stack
5.Check for empty or not  :
0.Exit  :
 Please enter your choice  :  2
5       4       3       2       1
1.Which of the following operation you want to perform  :
 1.create a stack   :
2.print the stack elements  :
3.push the element into the stack  :
4.Pop the element from the stack
5.Check for empty or not  :
0.Exit  :
 Please enter your choice  :  3

 Please Enter the data to be inserted   :    6

1.Which of the following operation you want to perform  :
 1.create a stack   :
2.print the stack elements  :
3.push the element into the stack  :
4.Pop the element from the stack
5.Check for empty or not  :
0.Exit  :
 Please enter your choice  :  2
6       5       4       3       2       1
1.Which of the following operation you want to perform  :
 1.create a stack   :
2.print the stack elements  :
3.push the element into the stack  :
4.Pop the element from the stack
5.Check for empty or not  :
0.Exit  :
 Please enter your choice  :  4

1.Which of the following operation you want to perform  :
 1.create a stack   :
2.print the stack elements  :
3.push the element into the stack  :
4.Pop the element from the stack
5.Check for empty or not  :
0.Exit  :
 Please enter your choice  :  2
5       4       3       2       1
1.Which of the following operation you want to perform  :
 1.create a stack   :
2.print the stack elements  :
3.push the element into the stack  :
4.Pop the element from the stack
5.Check for empty or not  :
0.Exit  :
 Please enter your choice  :  5

no the stack is not empty
1.Which of the following operation you want to perform  :
 1.create a stack   :
2.print the stack elements  :
3.push the element into the stack  :
4.Pop the element from the stack
5.Check for empty or not  :
0.Exit  :
 Please enter your choice  :  0

Which Type of stack you want to implement  :
1.stack using Array  :
2.stack using Linked list  :
0.exit
Please enter your choice0

E:\Vikas\DevEnv\Programming\Educational\Pune\c\se-entc>



*/
*/