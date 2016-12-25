#include<stdio.h>
#include<conio.h>


void main()
{
char pn[10][10],t[10];
int arr[10],bur[10],star[10],finish[10],tat[10],wt[10],i,j,n,temp;
int totwt=0,tottat=0;
clrscr();
printf("\n enter no of processes:");
scanf("%d",&n);
for(i=0;i<n;i++)
{
printf("\n enter the process name,arrival time & burst time:");
scanf("%s%d%d",&pn[i],&arr[i],&bur[i]);
}
for(i=0;i<n;i++)
{
for(j=0;j<n;j++)
{
if(arr[i]<arr[j])
{
temp=arr[i];
arr[i]=arr[j];
arr[j]=temp;
temp=bur[i];
bur[i]=bur[j];
bur[j]=temp;
strcpy(t,pn[i]);
strcpy(pn[i],pn[j]);
strcpy(pn[j],t);
}
}
}
for(i=0;i<n;i++)
{
if(i==0)
star[i]=arr[i];
else
star[i]=finish[i-1];
wt[i]=star[i]-arr[i];
finish[i]=star[i]+bur[i];
tat[i]=finish[i]-arr[i];
}
printf("\n Pname  Arrtime Burstime waittime star TAT finish");
for(i=0;i<n;i++)
{
printf("\n%s\t%3d\t%3d\t%3d\t%3d\t%6d\t%6d",pn[i],arr[i],bur[i],wt[i],star[i],tat[i],finish[i]);
totwt+=wt[i];
tottat+=tat[i];
}
printf("\n average waiting time:%f",(float)totwt/n);
printf("\n average turn around time:%f",(float)tottat/n);
getch();
}

/* output

 enter no of processes:3                                                        
                                                                                
 enter the process name,arrival time & burst time:p1 2 4                        
                                                                                
 enter the process name,arrival time & burst time:p2 3 5                        
                                                                                
 enter the process name,arrival time & burst time:p3 1 6                        
                                                                                
 Pname  Arrtime Burstime waittime start     TAT    finish
p3        1       6       0       1          6       7                          
p1        2       4       5       7          9      11                          
p2        3       5       8      11         13      16                          
 average waiting time:4.333333                                                  
 average turn around time:9.333333                                              
                                                                                
*/
                                                                                
                                                                                
                                                                                
                                                                                
                                                                                
                                                                                
                                                                                
                                                                                
                                                                                
                                                                                
                                                                                
                                                                                
                                                                                
                                                                                
                                                                                
                                                                                
                                                                                
                                                                                
                                                                                
                                                                                
                                                                                
                                                                                
                                                                                
                                                                                
                                                                                
                                                                                
                                                                                
                                                                                
                                                                                
                                                                                
                                                                                
                                                                                
                                                                                
