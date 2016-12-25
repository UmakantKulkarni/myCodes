#include<stdio.h>
#include<conio.h>

void main()
{
int j,mark;
char subj[10],remark,x;
clrscr();

FILE *fp;
fp=fopen("DATABASE","w");
fprintf(fp,"%s","SrNo.  Subject   Marks      Remark");
for(j=1;j<6;j++)
{
printf("\nEnter Name & Marks of subject %d",j);
scanf("%s%d",subj,&mark);
if(mark<40)
fprintf(fp,"\n%d         %s    	   %d         %s ",j,subj,mark,"Fail");
else
fprintf(fp,"\n%d         %s    	   %d         %s ",j,subj,mark,"Pass");
}
fclose(fp);
printf("\n\n");

fp=fopen("DATABASE","r");
while(!feof(fp))
{
fscanf(fp,"%c",&x);
printf("%c",x);
}
fclose(fp);
getch();
}

OUTPUT:-

Enter Name & Marks of subject 1A                                                
38                                                                              
                                                                                
Enter Name & Marks of subject 2B                                                
87                                                                              
                                                                                
Enter Name & Marks of subject 3C                                                
35                                                                              
                                                                                
Enter Name & Marks of subject 4D                                                
67                                                                              
                                                                                
Enter Name & Marks of subject 5E                                                
77                                                                              
                                                                                
                                                                                
SrNo.  Subject   Marks      Remark                                              
1         A        38         Fail                                              
2         B        87         Pass                                              
3         C        35         Fail                                              
4         D        67         Pass                                              
5         E        77         Pass                                              
                                                                                
                                                                                
