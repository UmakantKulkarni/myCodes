#include<conio.h>
#include<stdio.h>
void main()
{
int A[10],X[30],n,i,j;
clrscr();
printf("Enter number of elements\n");
scanf("%d",&n);
printf("Enter the system to be Autocorrelated\n");
for(i=0;i<n;i++)
{
scanf("%d",&A[i]);
}
printf("The Autocorrelation sequence is \n");
for(i=0;i<n;i++)
{
X[i]=0;
for(j=0;j<n;j++)
{
if(j+i<n)
{
X[i]=X[i]+A[j]*A[j+i];
}
}
printf("%d\t",X[i]);
}
getch();
}