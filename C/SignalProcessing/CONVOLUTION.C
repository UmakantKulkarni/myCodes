#include<conio.h>
#include<stdio.h>
void main()
{
int A[10],B[10],X[20],i,j,a,b,n;
clrscr();
printf("Enter number of elements in A\n");
scanf("%d",&a);
printf("Enter elements in A\n");
for(i=0;i<a;i++)
	scanf("%d",&A[i]);
printf("Enter number of elements in B\n");
scanf("%d",&b);
printf("Enter elements in B\n");
for(i=0;i<b;i++)
	scanf("%d",&B[i]);
n=a+b-1;
for(i=0;i<n;i++)
{
	X[i]=0;
	for(j=0;j<a;j++)
	{
		if(i-j>=0&&i-j<b)
		X[i]+=B[j]*A[i-j];
	}
}
printf("\nThe convolution sequence is\n");
for(i=0;i<n;i++)
	printf("%d\t",X[i]);
getch();
}
