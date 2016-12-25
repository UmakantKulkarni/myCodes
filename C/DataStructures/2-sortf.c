//2) Sorting Methods-Bubble, Selection & Insertion.

#include "stdio.h"
void ReadArray(int [],int);
void PrintArray(int [], int );
void BubbleSort(int [], int );
void InsertionSort(int [], int );
void SelectionSort(int [], int );
void CopyArray(int [],int[] ,int );
int main()
{
	int size, arr[30],array1[30],array2[30],array3[30], opt;
	clrscr();
	printf("Enter the size of the array\n");
	scanf("%d", &size);
	printf("Enter %d elements of the array\n", size);
	ReadArray(arr, size);
	/*make 3 new copies so that we cn use seperate for each 
		sorting function
	*/
	CopyArray(arr,array1,size);
	CopyArray(arr,array2,size);
	CopyArray(arr,array3,size);
	
		do
		{
			printf("\nWHICH OF THE FOLLOWING SORTING YOU WANT TO PERFORM\n");
			printf("\n1)Bubble Sort");
			printf("\n2)Selection Sort");
			printf("\n3)Insertion sort");
			printf("\n4)Exit");
			printf("\nEnter Your Choice : ");
			scanf("%d",&opt);
			switch(opt)
			{  
				case 1: 
					BubbleSort(arr,size);
					break;
				case 2:
					SelectionSort(array1, size);
					break;
				case 3:
					InsertionSort(array3, size);
					break;
			}
		}while(opt!=4);
		getch();  
		return 0;
}

void ReadArray(int *arr, int size)
{
	int i = 0;
	while(i < size)
	{
		scanf("%d", &(arr[i]));
		i++;
	}
}
void PrintArray(int *arr, int size)
{
	int i = 0;
	while(i < size)
	{
		printf("%d\t", (arr[i]));
		i++;
	}
	printf("\n");
}

void BubbleSort(int *arr, int size)
{
	int i, j; 
	for(i = 0 ; i < size ; i++)
	{
		for(j = 0; j < size - 1; j++) 
		{
			if(arr[j] > arr[j + 1])
			{
				int temp = arr[j];
				arr[j] = arr[j + 1];
				arr[j + 1] = temp;
			}
		}
		//call print array to show  each  itearation (pass in bubble sort )
		//you can exclude this below 2 steps
		PrintArray(arr,size);
		printf("\n");
	}
}

void InsertionSort(int *arr, int size)
{
	int  i, j; /*iterators */
	for(i = 1; i < size ; i++) 
	{
		int element = arr[i]; 
		for(j = i - 1; arr[j] > element && j >= 0; j--) 
		{
			arr[j + 1] = arr[j];
		}
		arr[j + 1] = element;
		PrintArray(arr,size);
		printf("\n");
	}
}
void SelectionSort(int *arr, int size)
{
	int  i, j; /*iterators */
	for(i = 0; i < size ; i++) 
	{
		int temp; 
		int minimum_index = i;
		for(j = i + 1; j < size; j++) 
		{
			if(arr[j] < arr[minimum_index])
				minimum_index = j;
		}
		temp = arr[i];
		arr[i] = arr[minimum_index];
		arr[minimum_index] = temp;
		PrintArray(arr,size);
		printf("\n");
	}
}
void CopyArray(int array1[],int array2[],int size)
{
	int i=0;
	while(i<size)
	{
		array2[i]=array1[i++];
	}
}
							/*OUTPUT*/
							
/*


E:\Vikas\Programming\DevEnv\Educational\Engineering\Pune\c\se-entc>gcc 2-sortf.c

E:\Programming\c\se-entc>rename a.exe 2-sotrf.exe

E:\Programming\c\se-entc>2-sotrf.exe

Enter the size of the array
6
Enter 6 elements of the array
6 5 4 3  2 1

WHICH OF THE FOLLOWING SORTING YOU WANT TO PERFORM

1)Bubble Sort
2)Selection Sort
3)Insertion sort
4)Exit
Enter Your Choice : 1
5       4       3       2       1       6

4       3       2       1       5       6

3       2       1       4       5       6

2       1       3       4       5       6

1       2       3       4       5       6

1       2       3       4       5       6


WHICH OF THE FOLLOWING SORTING YOU WANT TO PERFORM

1)Bubble Sort
2)Selection Sort
3)Insertion sort
4)Exit
Enter Your Choice : 2
1       5       4       3       2       6

1       2       4       3       5       6

1       2       3       4       5       6

1       2       3       4       5       6

1       2       3       4       5       6

1       2       3       4       5       6


WHICH OF THE FOLLOWING SORTING YOU WANT TO PERFORM

1)Bubble Sort
2)Selection Sort
3)Insertion sort
4)Exit
Enter Your Choice : 3
5       6       4       3       2       1

4       5       6       3       2       1

3       4       5       6       2       1

2       3       4       5       6       1

1       2       3       4       5       6


WHICH OF THE FOLLOWING SORTING YOU WANT TO PERFORM

1)Bubble Sort
2)Selection Sort
3)Insertion sort
4)Exit
Enter Your Choice : 4

E:\Vikas\Programming\DevEnv\Educational\Engineering\Pune\c\se-entc>


*/							
							
						
