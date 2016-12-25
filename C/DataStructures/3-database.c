//3) Data base Management using array of structure.

#include<stdio.h>
#include<string.h>
#include<conio.h>
#define MAX 50

typedef struct record
{
	char name[MAX];
	int rollnum,marks;

}record;
void create(record [],int );
void PrintRecords(record [],int );
void AddRecord(record [],int );
int DeleteRecord(record [],int );
void ModifyRecord( record [],int );
int search(record [],int ,int );
void SortRecords(record [],int );
void SortRec(record [],int );

 int  main()
{  
	record  file[10];
	int total=0,i,operation,position,rollno;
	//clrscr();
    do{

	   printf("\n1)create a Record File :");
	   printf("\n2)Insert a Record  in File :");
	   printf("\n3)delete a Record  from File :");
	   printf("\n4)Search a Record  in File :");
	   printf("\n5)Print a Record   File :");
	   printf("\n6)Sort a Record   File According to name:");
	   printf("\n7)Sort a Record   File According to Roll Number:");
	   printf("\n8)Modify a Record in   File :");
	   printf("\n9)Exit");
       printf("\nEnter Your Choice:");
       scanf("%d",&operation);
       switch(operation)
		{
		case 1: 	
			printf("\nEnter No. of Records you want to create:");
			scanf("%d",&total);
			create(file,total);
			break;
		case 2:
			AddRecord(file,total);
			total++;
			break;
		case 3:
			total=total-DeleteRecord(file,total);
			PrintRecords(file,total);
			break;
		case 4:
			printf("\nPlease Enter Rollno of Record to Be searcheds:");
			scanf("%d",&rollno);
			position=search(file,total,rollno);
			if(position==-1)
				printf("No such Record in File ");
			else
				printf("Record Found At position %d",position);
			break;
		case 5:
			PrintRecords(file,total);
			break;
		case 6:
			SortRecords(file,total);
			PrintRecords(file,total);
			break;

		case 7:
			SortRec(file,total);
			PrintRecords(file,total);
			break;
		case 8:
			ModifyRecord(file,total);
			PrintRecords(file,total);
			break;
		}
	 }while(operation!=9);
	getch();	
	return 0;
  }

void create(record file[],int total)
{
	int i;
	for (i=0;i<total;i++)
	{
		printf("\nPlease Enter Name,Roll number and Marks of Student %d :",i+1);
		scanf("%s%d%d",&file[i].name,&file[i].rollnum,&file[i].marks);
	}

}
void PrintRecords(record file[],int total)
{
	int i;
	for (i=0;i<total;i++)
	{
		printf("\nThe Name,Roll number and Marks of Student %d   :",i+1);
		printf("%s   %d    %d",file[i].name,file[i].rollnum,file[i].marks);
	}
}
void AddRecord(record file[],int total)
{
	printf("\nPlease Enter Name,Roll number and Marks of New Record :");
	scanf("%s%d%d",&file[total].name,&file[total].rollnum,&file[total].marks);
}

int DeleteRecord(record file[],int total)
{
	int i,rollno,position;
	printf("\nPlease Enter Roll number of Record to be Deleted:");
	scanf("%d",&rollno);
	position=search(file,total,rollno);
	if(position == -1)
	{
		printf("\n No such record in the file  :  ");
		return 0;
	}
	for(i=position;i<total;i++)
		file[i]=file[i+1];
	
	return 1;
	
}
void ModifyRecord(record file[],int total)
{
	int i,rollno,position;
	printf("\nPlease Enter Roll number of Record to be Modified:");
	scanf("%d",&rollno);
	position=search(file,total,rollno);
	printf("\nPlease Enter Name,Roll number and Marks of  Record to be modified:");
	scanf("%s%d%d",&file[position].name,&file[position].rollnum,&file[position].marks);

	
}
int search(record file[],int total,int rollno)
{
	int i;
	for (i=0;i<total;i++)
	{
		if(file[i].rollnum==rollno)
		{
			return i;
		}
	}
	return -1;
}
void SortRecords(record file[],int total)
{
	int i,j;
	record temp;
	for(i=0;i<total;i++)
	{
		for(j=i+1;j<total;j++)
		{
			if(strcmp(file[i].name,file[j].name)>0)
			{
				temp=file[i];
				file[i]=file[j];
				file[j]=temp;
			}
		}
	}
	
}

void SortRec( record file[],int total)
{
	int i,j;
	record temp;
	for(i=0;i<total;i++)
	{
		for(j=i+1;j<total;j++)
		{
			if(file[i].rollnum>file[j].rollnum)
			{
				temp=file[i];
				file[i]=file[j];
				file[j]=temp;
			}
		}
	}
}


/*
			OUTPUT
			
E:\Vikas\Programming\DevEnv\Educational\Pune\c\se-entc>GCC 3-DATABASE.C

E:\Vikas\Programming\DevEnv\Educational\Pune\c\se-entc>a

1)create a Record File :
2)Insert a Record  in File :
3)delete a Record  from File :
4)Search a Record  in File :
5)Print a Record   File :
6)Sort a Record   File According to name:
7)Sort a Record   File According to Roll Number:
8)Modify a Record in   File :
9)Exit
Enter Your Choice:1

Enter No. of Records you want to create:3

Please Enter Name,Roll number and Marks of Student 1 :vikas 143 100

Please Enter Name,Roll number and Marks of Student 2 :sneha 144 90

Please Enter Name,Roll number and Marks of Student 3 :arunav 420 38

1)create a Record File :
2)Insert a Record  in File :
3)delete a Record  from File :
4)Search a Record  in File :
5)Print a Record   File :
6)Sort a Record   File According to name:
7)Sort a Record   File According to Roll Number:
8)Modify a Record in   File :
9)Exit
Enter Your Choice:3

Please Enter Roll number of Record to be Deleted:123

 No such record in the file  :
The Name,Roll number and Marks of Student 1   :vikas   143    100
The Name,Roll number and Marks of Student 2   :sneha   144    90
The Name,Roll number and Marks of Student 3   :arunav   420    38
1)create a Record File :
2)Insert a Record  in File :
3)delete a Record  from File :
4)Search a Record  in File :
5)Print a Record   File :
6)Sort a Record   File According to name:
7)Sort a Record   File According to Roll Number:
8)Modify a Record in   File :
9)Exit
Enter Your Choice:2

Please Enter Name,Roll number and Marks of New Record :ayesha 123 43

1)create a Record File :
2)Insert a Record  in File :
3)delete a Record  from File :
4)Search a Record  in File :
5)Print a Record   File :
6)Sort a Record   File According to name:
7)Sort a Record   File According to Roll Number:
8)Modify a Record in   File :
9)Exit
Enter Your Choice:5

The Name,Roll number and Marks of Student 1   :vikas   143    100
The Name,Roll number and Marks of Student 2   :sneha   144    90
The Name,Roll number and Marks of Student 3   :arunav   420    38
The Name,Roll number and Marks of Student 4   :ayesha   123    43
1)create a Record File :
2)Insert a Record  in File :
3)delete a Record  from File :
4)Search a Record  in File :
5)Print a Record   File :
6)Sort a Record   File According to name:
7)Sort a Record   File According to Roll Number:
8)Modify a Record in   File :
9)Exit
Enter Your Choice:3

Please Enter Roll number of Record to be Deleted:123

The Name,Roll number and Marks of Student 1   :vikas   143    100
The Name,Roll number and Marks of Student 2   :sneha   144    90
The Name,Roll number and Marks of Student 3   :arunav   420    38
1)create a Record File :
2)Insert a Record  in File :
3)delete a Record  from File :
4)Search a Record  in File :
5)Print a Record   File :
6)Sort a Record   File According to name:
7)Sort a Record   File According to Roll Number:
8)Modify a Record in   File :
9)Exit
Enter Your Choice:6

The Name,Roll number and Marks of Student 1   :arunav   420    38
The Name,Roll number and Marks of Student 2   :sneha   144    90
The Name,Roll number and Marks of Student 3   :vikas   143    100
1)create a Record File :
2)Insert a Record  in File :
3)delete a Record  from File :
4)Search a Record  in File :
5)Print a Record   File :
6)Sort a Record   File According to name:
7)Sort a Record   File According to Roll Number:
8)Modify a Record in   File :
9)Exit
Enter Your Choice:7

The Name,Roll number and Marks of Student 1   :vikas   143    100
The Name,Roll number and Marks of Student 2   :sneha   144    90
The Name,Roll number and Marks of Student 3   :arunav   420    38
1)create a Record File :
2)Insert a Record  in File :
3)delete a Record  from File :
4)Search a Record  in File :
5)Print a Record   File :
6)Sort a Record   File According to name:
7)Sort a Record   File According to Roll Number:
8)Modify a Record in   File :
9)Exit
Enter Your Choice:8

Please Enter Roll number of Record to be Modified:420

Please Enter Name,Roll number and Marks of  Record to be modified:
shruti 420 34

The Name,Roll number and Marks of Student 1   :vikas   143    100
The Name,Roll number and Marks of Student 2   :sneha   144    90
The Name,Roll number and Marks of Student 3   :shruti   420    34
1)create a Record File :
2)Insert a Record  in File :
3)delete a Record  from File :
4)Search a Record  in File :
5)Print a Record   File :
6)Sort a Record   File According to name:
7)Sort a Record   File According to Roll Number:
8)Modify a Record in   File :
9)Exit
Enter Your Choice:4

Please Enter Rollno of Record to Be searcheds:143
Record Found At position 0
1)create a Record File :
2)Insert a Record  in File :
3)delete a Record  from File :
4)Search a Record  in File :
5)Print a Record   File :
6)Sort a Record   File According to name:
7)Sort a Record   File According to Roll Number:
8)Modify a Record in   File :
9)Exit
Enter Your Choice:9

E:\Vikas\DevEnv\Programming\Educational\Pune\c\se-entc>

*/
