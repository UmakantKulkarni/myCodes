//5) Implementation of singly linked list- Create, Insert, Delete, Search.
#include <stdio.h>
#include <malloc.h>

struct node
{
    int data;
    struct node *next;
};
struct node *InsertionatStart(struct node*,struct node*);
struct node *read(int);
void print(struct node*);
struct node *InsertionatEnd(struct node*,struct node*);
struct node *InsertionBetween(struct node*,struct node *,int);
struct node *InsertionatStart(struct node*,struct node*);
struct node *DeletetheElement(struct node*,int);
int elementsearch(struct node*,int );

int main()
{
    int size,num,operation,position,position1,element;
	struct node *item,*item1,*item2,*item3,*item4;
    struct node *head = NULL;
	clrscr();
	do
	
	{
		operation=PrintMenu();
		switch(operation)
		{
			
			case 1:
				/* read linked list */
				printf("Please enter size of linked list:\n");
				scanf("%d", &size);

				printf("Please enter %d elements in the list\n",size);
				head = read(size);
				break;
			case 2:
				print(head);
				break;
			case 3:
				printf("please enter the number to be inserted");
				item2= (struct node *) malloc(sizeof(struct node));
				scanf("%d", &(item2->data));
				head=InsertionatStart(head,item2);
				print(head);
				break;
				
			case 4:
				printf("please enter the number to be inserted");
				item = (struct node *) malloc(sizeof(struct node));
				scanf("%d", &(item->data));
				printf(" at what position you want to insert the element");
				scanf("%d",&position);
   
				head=InsertionBetween(head,item,position);
				print(head);
				printf("\n");
				break; 
			case 5:
				printf("please enter the number to be inserted");
				item3 = (struct node *) malloc(sizeof(struct node));
				scanf("%d", &(item3->data));
				head=InsertionatEnd(head,item3);
				print(head);
			
				printf("\n");
				break;
			case 6:
				printf("please enter the  Position of number to be deleted:");
				scanf("%d", &position1);
				head=DeletetheElement(head,position1);
				print(head);
				break;
			case 7:
				printf("please enter the number to be searched:");
				scanf("%d", &element);
				position=elementsearch(head,element);
				if(position==0)
					printf("element not found");
				else
					printf("element not found at position  :%d",position);
				break;

	}
		printf("\n");
	}while(operation != 8);
	getch();
	return 0;
}

int PrintMenu()
{
		int operation=0;
		printf("\nWhich  operation do you want to perform on linked list:");
		printf("\n1)Create a new linked list:");
		printf("\n2)Print the linked list:");
		printf("\n3)Insert the element at start of linked list:");	
		printf("\n4)Insert the element in between of linked list:");
		printf("\n5)Insert the element at end of linked list:");
		printf("\n6)Delete the element from linked list:");
		printf("\n7)Search the element in linked list:");
		printf("\n8)Exit:");
		printf("\nEnter your choice:");
		scanf("%d", &operation);
		return operation;
	
}
/* create a new linked list of size and read elements from user input */
struct node *read(int size)
{
    int i;
    /* to store head of the linked list, initialize with NULL */
    struct node *head = NULL;

    /* following pointers are used to construct linked list */
    struct node *last = head;


    for(i = 0; i < size; i++)
    {
        struct node *item = (struct node *) malloc(sizeof(struct node));
   
        scanf("%d", &(item->data));
        /* important do not forget to mark end of the list */
        item->next = NULL;

        if(head == NULL)
        {
            head = item;
        }
        else
        {
            last->next = item;
        }

        last = item;
    }

   
   

    return head;
}

/* Function to print a linked list */
void print(struct node *head)
{
    struct node *current =head;
    while(current)
    {
        printf("%d\t", current->data);
        current = current->next;
    }
}


struct node *InsertionatEnd(struct node *head,struct node*item)
{
		struct node *current=head;
		struct node *last;
	
		if(head!=NULL)
		{
			while((current->next)!=NULL)
			{
				last=current;
				current=current->next;
			}
			current->next=item;
		}
		else
		{
			head=item;
		}
	
		item->next=NULL;
		return(head);
}

struct node *InsertionBetween(struct node *head,struct node *item,int position)
{
	int i;
		struct node *before=head;
	
		if(position==1)
		{
			item->next=head;
			head=item;
		}
		else 
		{
		
			for(i=1;i<position-1;i++)
			{	
				before=before->next;
			}
			if(before!=NULL)
			{
				item->next=before->next;
				before->next=item;
				
			}
		}

	return head;
	
	
}
struct node *InsertionatStart(struct node *head,struct node*item)
{
		item->next=head;
		head=item;
		return(head);
}

struct node *DeletetheElement(struct node *head,int position)
{
	int i;
	struct node *current=head;
	struct node *before=head;
	struct node *after=head;
		for(i=1;i<position-1;i++)
		{	
			before=before->next;
		}
		for(i=0;i<position;i++)
		{	
			after=after->next;
		} 
	before->next=after;
	
	return(head);
	
}
int elementsearch(struct node*head,int item)
{
	int PositionofElement=1;
	struct node *current=head;
	while(current)
	{
		
		if((current->data)==item)
		{
			return PositionofElement;
		}
		current=current->next;
		PositionofElement++;
		
	}
	return 0;
	
}

/*


E:\Vikas\Programming\DevEnv\Educational\Engineering\Pune\c\se-entc>gcc 5-sll.c


E:\Vikas\Programming\DevEnv\Educational\Engineering\Pune\c\se-entc>rename a.exe 5-sll.exe

E:\Vikas\Programming\DevEnv\Educational\Engineering\Pune\c\se-entc> 5-sll.exe

Which  operation do you want to perform on linked list:
1)Create a new linked list:
2)Print the linked list:
3)Insert the element at start of linked list:
4)Insert the element in between of linked list:
5)Insert the element at end of linked list:
6)Delete the element from linked list:
7)Search the element in linked list:
8)Exit:
Enter your choice:1
Please enter size of linked list:
6
Please enter 6 elements in the list
1 2 3 4 5 6


Which  operation do you want to perform on linked list:
1)Create a new linked list:
2)Print the linked list:
3)Insert the element at start of linked list:
4)Insert the element in between of linked list:
5)Insert the element at end of linked list:
6)Delete the element from linked list:
7)Search the element in linked list:
8)Exit:
Enter your choice:2
1       2       3       4       5       6

Which  operation do you want to perform on linked list:
1)Create a new linked list:
2)Print the linked list:
3)Insert the element at start of linked list:
4)Insert the element in between of linked list:
5)Insert the element at end of linked list:
6)Delete the element from linked list:
7)Search the element in linked list:
8)Exit:
Enter your choice:3
please enter the number to be inserted0
0       1       2       3       4       5       6

Which  operation do you want to perform on linked list:
1)Create a new linked list:
2)Print the linked list:
3)Insert the element at start of linked list:
4)Insert the element in between of linked list:
5)Insert the element at end of linked list:
6)Delete the element from linked list:
7)Search the element in linked list:
8)Exit:
Enter your choice:4
please enter the number to be inserted 7
 at what position you want to insert the element 4
0       1       2       7       3       4       5       6


Which  operation do you want to perform on linked list:
1)Create a new linked list:
2)Print the linked list:
3)Insert the element at start of linked list:
4)Insert the element in between of linked list:
5)Insert the element at end of linked list:
6)Delete the element from linked list:
7)Search the element in linked list:
8)Exit:
Enter your choice:6
please enter the  Position of number to be deleted: 4
0       1       2       3       4       5       6

Which  operation do you want to perform on linked list:
1)Create a new linked list:
2)Print the linked list:
3)Insert the element at start of linked list:
4)Insert the element in between of linked list:
5)Insert the element at end of linked list:
6)Delete the element from linked list:
7)Search the element in linked list:
8)Exit:
Enter your choice: 7
please enter the number to be searched: 5
element not found at position  :6

Which  operation do you want to perform on linked list:
1)Create a new linked list:
2)Print the linked list:
3)Insert the element at start of linked list:
4)Insert the element in between of linked list:
5)Insert the element at end of linked list:
6)Delete the element from linked list:
7)Search the element in linked list:
8)Exit:
Enter your choice:8

E:\Vikas\Programming\DevEnv\Educational\Engineering\Pune\c\se-entc>

*/