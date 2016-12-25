#include<stdio.h>
#include<conio.h>
void main()
{
int i,j,a1[10],b[10],m,n,a2[10],c[20];
clrscr();
printf("\nEnter the size of 1st sequence :");
scanf("%d",&m);
printf("Enter the Elements\n");
for (i=0;i<m;i++)
{
printf("\nEnter the %d element :",i+1);
scanf("%d",&a1[i]);
}
printf("\nEnter the size of 2nd sequence :");
scanf("%d",&n);
printf("Enter the elements\n");
for (i=0;i<n;i++)
{
printf("\nEnter the %d element :",i+1);
scanf("%d",&a2[i]);
}
printf("\nEntered signal is\n");
for(i=0;i<m;i++)
{
printf("%d ",a1[i]);
}
printf("\nEntered signal is\n");
for(i=0;i<m;i++)
{
printf("%d ",a2[i]);
}
for(i=0;i<n;i++)
{
b[i]=a2[n-1-i];
}
printf("\n\n The crosscorrelation is\n\n");
for(i=0;i<(m+n-1);i++)
{
c[i]=0;
for(j=0;j<n;j++)
{
if((i-j)>=0 && (i-j)<n)
c[i]+=a1[j]*b[i-j];
}
printf("%d \t",c[i]);
}
getch();
}

OUTPUT:-
Enter the size of 1st sequence :3
Enter the Elements                                                              
										
Enter the 1 element :9                                                          
										
Enter the 2 element :8                                                          

Enter the 3 element :7                                                          
										
Enter the size of 2nd sequence :2                                               
Enter the elements                                                              
										
Enter the 1 element :5                                                          
										
Enter the 2 element :6                                                          
										
Entered signal is                                                               
9 8 7                                                                           
Entered signal is                                                               
5 6 6                                                                           
										
 The crosscorrelation is                                                        
										
54      93      40      0                                                       
