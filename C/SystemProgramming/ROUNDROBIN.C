#include<stdio.h>
#include<conio.h>

void main()
{
int et[30],ts,n,i,x=0,tot=0;
char pn[10][10];
clrscr();
printf("\n Enter no of processes:");
scanf("%d",&n);
printf("\n Enter time quantum:");
scanf("%d",&ts);
for(i=0;i<n;i++)
{
printf("\n enter process name and estimated time:");
scanf("%s%d",pn[i],&et[i]);
}
printf("The processes are:");
for(i=0;i<n;i++)
printf("\nprocess%d:%s\n",i+1,pn[i]);
for(i=0;i<n;i++)
tot=tot+et[i];
while(x!=tot)
{
for(i=0;i<n;i++)
{
if(et[i]>ts)
{
x=x+ts;
printf("\n %s->%d",pn[i],ts);
et[i]=et[i]-ts;
}
else
if((et[i]<=ts)&&et[i]!=0)
{
x=x+et[i];
printf("\n %s->%d",pn[i],et[i]);
et[i]=0;
}
}
}
printf("\n Total estimated time:%d",x);
getch();
}

 /* output

 enter process name and estimated time:x2 35
                                                                                
 enter process name and estimated time:x3 44                                    
                                                                                
 enter process name and estimated time:x5 29                                    
The processes are:
process1:x1                                                                     
                                                                                
process2:x2                                                                     
                                                                                
process3:x3                                                                     
                                                                                
process4:x5                                                                     
                                                                                
 x1->15                                                                         
 x2->15                                                                         
 x3->15                                                                         
 x5->15                                                                         
 x1->15                                                                         
 x2->15                                                                         
 x3->15                                                                         
 x5->14                                                                         
 x2->5                                                                          
 x3->14                                                                         
 Total estimated time:138                                                       

	 */
                                                                                
                                                                                
                                                                                
                                                                                
                                                                                
                                                                                
                                                                                
                                                                                
                                                                                
                                                                                
                                                                                
                                                                                
                                                                                
                                                                                
                                                                                
                                                                                
                                                                                
                                                                                
                                                                                
                                                                                
                                                                                
                                                                                
                                                                                
                                                                                
                                                                                
                                                                                
