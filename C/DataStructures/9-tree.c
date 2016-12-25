//9) Operations on Binary search tree: Create, search, recursive traversals.

#include <stdio.h>
#include <conio.h>
typedef struct node
{
	int data;
       struct  node *left,*right;
}node;

node *create(int );
void insert(node *, node *);
void PreOrderPrint(node *);
void PostOrderPrint(node *);
void InOrderPrint(node *);
void freeNode(node *branch);
void search(node *branch,int key,int *found);
int main()
{
	int operation,size,found,key;
	node *root=NULL;
	//clrscr();
	do
		{
		printf("\nWhich of The Following operation You Want to preform  :  ");
		printf("\n1.Create A binary Search Tree   :  ");
		printf("\n2.Print A Binary tree using Recursive Preorder : ");
		printf("\n3.Print A Binary tree using Recursive Postorder : ");
		printf("\n4.Print A Binary tree using Recursive Inorder : ");
		printf("\n5.Search a element in binary tree : ");
		printf("\n0.Exit   : ");
		printf("\nPlease Enter Your Choice   : ");
		scanf("%d",&operation);
	switch(operation)
	{
		case 1:
			printf("\nPlease Enter Size of your Tree  :   ");
			scanf("%d",&size);
			freeNode(root);
			printf("\nPlease Enter %d elements  :   ",size);
			
			root=create(size);
		break;

	case 2:
		PreOrderPrint(root);
		break;
	case 3:
		PostOrderPrint(root);
		break;
	case 4:
		InOrderPrint(root);
		break;
	case 5:
		found=0;
		printf("\nPlease Enter the key to be searched  :  ");
		scanf("%d",&key);
		search(root,key,&found);
		if(found==1)
			printf("The Elemnet is Found:  ");
		else
			printf("The Elemnet is Not found  :  ");

	}
	}while(operation!=0);
	getch();
	return 0;
}

void search(node * branch,int key,int *found)
{
	if(branch!=NULL)
	{
		if(branch->data==key)
		{
			printf("\nThe given element found ");
			*found=1;
		}
		else if(branch->data >key)
			search(branch->left,key,found);
		else
			search(branch->right,key,found);
	}
		
}
node *create(int size)
{
	node *root =NULL;
	int i;
	for( i=0;i<size;i++)
	{
		node *item=(node*) malloc(sizeof(node));
		scanf("%d",&(item->data));
		item->left=NULL;
		item->right=NULL;
		if(root==NULL)
			root=item;
		else
			insert(root, item);

		
	}
	return root;
}

void insert(node *branch, node *element)
{
	if(branch->data >= element->data)
	{
		if(branch->left == NULL)
			branch->left = element;
		else
			insert(branch->left, element);
	}
	else
	{
		if(branch->right == NULL)
			branch->right = element;
		else
			insert(branch->right, element);
	}
}

void PreOrderPrint(node *branch)
{
	if (branch!=NULL)
	{
		printf("%d\t", branch->data);
		PreOrderPrint(branch->left);
		PreOrderPrint(branch->right);
	}
}

void PostOrderPrint(node *branch)
{
	if(branch!=NULL)
	{
		PostOrderPrint(branch->left);
		PostOrderPrint(branch->right);
		printf("%d\t", branch->data);
	}
}

void InOrderPrint(node *branch)
{

	if(branch!=NULL)
	{
		InOrderPrint(branch->left);
		printf("%d\t", branch->data);
		InOrderPrint(branch->right);
	}

}
// this function is optinal and for those who want to do extra
void freeNode(node *branch)
{
	if(branch!=NULL)
	{
		freeNode(branch->left);
		freeNode(branch->right);
		free (branch);
	}
}




/*
							OUTPUT
							
							

E:\Programming\c\se-entc>a

Which of The Following operation You Want to preform  :
1.Create A binary Search Tree   :
2.Print A Binary tree using Recursive Preorder :
3.Print A Binary tree using Recursive Postorder :
4.Print A Binary tree using Recursive Inorder :
5.Search a element in binary tree :
0.Exit   :
Please Enter Your Choice   : 1

Please Enter Size of your Tree  :   7

Please Enter 7 elements  :   5 1 2 3 7 8 9

Which of The Following operation You Want to preform  :
1.Create A binary Search Tree   :
2.Print A Binary tree using Recursive Preorder :
3.Print A Binary tree using Recursive Postorder :
4.Print A Binary tree using Recursive Inorder :
5.Search a element in binary tree :
0.Exit   :
Please Enter Your Choice   : 2
5       1       2       3       7       8       9
Which of The Following operation You Want to preform  :
1.Create A binary Search Tree   :
2.Print A Binary tree using Recursive Preorder :
3.Print A Binary tree using Recursive Postorder :
4.Print A Binary tree using Recursive Inorder :
5.Search a element in binary tree :
0.Exit   :
Please Enter Your Choice   : 3
3       2       1       9       8       7       5
Which of The Following operation You Want to preform  :
1.Create A binary Search Tree   :
2.Print A Binary tree using Recursive Preorder :
3.Print A Binary tree using Recursive Postorder :
4.Print A Binary tree using Recursive Inorder :
5.Search a element in binary tree :
0.Exit   :
Please Enter Your Choice   : 4
1       2       3       5       7       8       9
Which of The Following operation You Want to preform  :
1.Create A binary Search Tree   :
2.Print A Binary tree using Recursive Preorder :
3.Print A Binary tree using Recursive Postorder :
4.Print A Binary tree using Recursive Inorder :
5.Search a element in binary tree :
0.Exit   :
Please Enter Your Choice   : 5

Please Enter the key to be searched  :
The given element found The Elemnet is Found:
Which of The Following operation You Want to preform  :
1.Create A binary Search Tree   :
2.Print A Binary tree using Recursive Preorder :
3.Print A Binary tree using Recursive Postorder :
4.Print A Binary tree using Recursive Inorder :
5.Search a element in binary tree :
0.Exit   :
Please Enter Your Choice   : 5^C
E:\Programming\c\se-entc>gcc 9-tree.c
9-tree.c:172:3: warning: no newline at end of file

E:\Vikas\Programming\DevEnv\c\Educational\Pune\se-entc>a


Which of The Following operation You Want to preform  :
1.Create A binary Search Tree   :
2.Print A Binary tree using Recursive Preorder :
3.Print A Binary tree using Recursive Postorder :
4.Print A Binary tree using Recursive Inorder :
5.Search a element in binary tree :
0.Exit   :
Please Enter Your Choice   : 1

Please Enter Size of your Tree  :   7

Please Enter 7 elements  :   5 1 2 3 7 8 9

Which of The Following operation You Want to preform  :
1.Create A binary Search Tree   :
2.Print A Binary tree using Recursive Preorder :
3.Print A Binary tree using Recursive Postorder :
4.Print A Binary tree using Recursive Inorder :
5.Search a element in binary tree :
0.Exit   :
Please Enter Your Choice   : 2
5       1       2       3       7       8       9
Which of The Following operation You Want to preform  :
1.Create A binary Search Tree   :
2.Print A Binary tree using Recursive Preorder :
3.Print A Binary tree using Recursive Postorder :
4.Print A Binary tree using Recursive Inorder :
5.Search a element in binary tree :
0.Exit   :
Please Enter Your Choice   : 3
3       2       1       9       8       7       5
Which of The Following operation You Want to preform  :
1.Create A binary Search Tree   :
2.Print A Binary tree using Recursive Preorder :
3.Print A Binary tree using Recursive Postorder :
4.Print A Binary tree using Recursive Inorder :
5.Search a element in binary tree :
0.Exit   :
Please Enter Your Choice   : 4
1       2       3       5       7       8       9
Which of The Following operation You Want to preform  :
1.Create A binary Search Tree   :
2.Print A Binary tree using Recursive Preorder :
3.Print A Binary tree using Recursive Postorder :
4.Print A Binary tree using Recursive Inorder :
5.Search a element in binary tree :
0.Exit   :
Please Enter Your Choice   : 5

Please Enter the key to be searched  :  7

The given element found The Elemnet is Found:

Which of The Following operation You Want to preform  :
1.Create A binary Search Tree   :
2.Print A Binary tree using Recursive Preorder :
3.Print A Binary tree using Recursive Postorder :
4.Print A Binary tree using Recursive Inorder :
5.Search a element in binary tree :
0.Exit   :
Please Enter Your Choice   : 5

Please Enter the key to be searched  :  0
The Elemnet is Not found  :
Which of The Following operation You Want to preform  :
1.Create A binary Search Tree   :
2.Print A Binary tree using Recursive Preorder :
3.Print A Binary tree using Recursive Postorder :
4.Print A Binary tree using Recursive Inorder :
5.Search a element in binary tree :
0.Exit   :
Please Enter Your Choice   : 0

E:\Vikas\Programming\c\se-entc>

*/