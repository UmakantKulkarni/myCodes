//1)Searching methods-Linear & Binary

#include<stdio.h>

//Prototypes of Functions Used In this programm.
int  LinearSearch(int [],int ,int );
int  BinarySearch(int [],int ,int );
void SortArray(int [], int );

int main()
{

		int a[30],size,key,i,op,index;
		clrscr();
		// To know the total Number of elements from user
		printf("\nEnter no of elements :");
		scanf("%d",&size);
		// To take the input elements from user
		// as this are more than 1 loop is used
		printf("\nPlease Enter array elements :");
		for(i=0;i<size;i++)
		{
			scanf("%d",&a[i]);
		}
	do
	  {
	    printf("\n1)Linear   2)Binary  0)Quit");
	    //Accept the user's choice for operation to be perfromed.
		printf("\nEnter your choice : ");
	    scanf("%d",&op);
	    switch(op)
		{
			case 1:
				//accept the key from user (the element to be searched).
				printf("Please enter the element to be searched");
				scanf("%d",&key);
				//store the index of variable in the list in varaible index
				index =LinearSearch(a,key,size);
				if(index==-1)
					printf("Element not found In The given Sequence");
				else
					printf("Element found at Index: %d", index);	

				break;
			case 2:
				//Before performing Binary search we have to sort the 
				//sequence (i.e Arrange in any order say ascending
				SortArray(a,size);
				
				//accept the key from user (the element to be searched).
				printf("Please enter the element to be searched");
				scanf("%d",&key);
				//store the index of variable in the list in varaible index
				index=BinarySearch(a,key,size);
				if(index==-1)
					printf("Element not found In the Given Sequence :");
				else
					printf("After Sorting  given list Element found at Index: %d",index);

				break;

	    }
	// continue this loop till user dont prss 0 (i.e-ask for exit)	
	} while(op!=0);
	getch();
	return 0;
}
int  LinearSearch(int Array[],int key,int size)
{
	int i;//iterator
	for(i=0;i<size;i++)
	{
		// see if key matches the array's element
		if(Array[i]==key)
		{
		// condition satisfiedd means satisfied the condition 
		//immidiately return its index.
			return i;
		}
	}
	//whole array has been checked as loop is completed 
	//and key is not found so return -1.(a code assumed for not found).
	return -1;
}
int  BinarySearch(int Array[],int key,int size)
{
	int i,mid,left=1,right=size;
	do
	{
		// mark the middle index 
		mid=(left+right)/2;
		if(Array[mid]==key)
		{
			// if array element at index= mid matches with key
			// search terminates with sucess.
			return mid;
		}
		else if(Array[mid]>key)
		{
			// move right pivot to mid-1.
			right=mid-1;
		}
		else 
		{
		// move left pivot to mid+1.
			left=mid+1;
		}
	//left <=right means left and right pointers did'nt crossed each othr
		
	}while(left <= right);
	
	//whole array has been checked as loop is completed 
	//and key is not found so return -1.(a code word rd assumed for not found).
	return -1;
}
//arrary by default are passed by refrence so no need to
//give any return type for sort function
void SortArray(int arr[], int size)
{
	int i, j;
	//For this sorting I am using bubble sort Algorithm.
	for(i = 1 ; i < size ; i++)
	{
		for(j = 0; j < size - i; j++) 
		{
			if(arr[j] > arr[j + 1])
			{
				int temp = arr[j];
				arr[j] = arr[j + 1];
				arr[j + 1] = temp;
			}
		}
	}
}



						/*  OUTPUT*/
						
/*
E:\Vikas\Programming\DevEnv\Educational\c\se-entc>gcc 1-search.c

E:\Vikas\Programming\DevEnv\Educational\c\se-entc>1-search.exe

Enter no of elements :6

Please Enter array elements :1 2 3 4 5 6

1)Linear   2)Binary  0)Quit
Enter your choice : 1
Please enter the element to be searched  0
Element not found In The given Sequence
1)Linear   2)Binary  0)Quit
Enter your choice : 1
Please enter the element to be searched 4
Element found at Index: 3
1)Linear   2)Binary  0)Quit
Enter your choice : 2

Please enter the element to be searched 0
Element not found In the Given Sequence :
1)Linear   2)Binary  0)Quit
Enter your choice : 2

Please enter the element to be searched 3
Element not found In the Given Sequence :
1)Linear   2)Binary  0)Quit
Enter your choice : 0

E:\Vikas\Programming\DevEnv\Educational\Engineering\c\se-entc>

*/					





