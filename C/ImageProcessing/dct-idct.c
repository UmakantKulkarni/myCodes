#include<stdio.h>
#include<conio.h>
#include<math.h>
#include<stdlib.h>
#include<dos.h>
#include<graphics.h>
struct header
{
char ftype[2];
unsigned long fsize,res,offset;
}head;
struct information
{
unsigned long size,width,height;
}info;
void main()
{
FILE*fp;
int ch,i,j,m,n,x,y,img[4][4]={0},n1=4;
char*filename;
float k1,k2,dct[4][4]={0},idct[4][4]={0};
flushall();
clrscr();
printf("\n Enter file path");
gets(filename);
fp=fopen(filename,"rb");
if(fp==NULL)
{
printf("\n unable to open file...");
getch();
exit(0);
}
fread(&head,sizeof(head),1,fp);
fread(&info,sizeof(info),1,fp);
fseek(fp,head.offset,0);
for(x=0;x<n1;x++)
for(y=0;y<n1;y++)
{
ch=getc(fp);
img[x][y]=ch;
dct[x][y]=0;
idct[x][y]=0;
}
for(m=0;m<n1;m++)
for(n=0;n<n1;n++)
{
for(x=0;x<n1;x++)
{
for(y=0;y<n1;y++)
{
if(m==0)
k1=sqrt(1/(float)n1);
else
k1=sqrt(2/(float)n1);
if(n==0)
k2=sqrt(1/(float)n1);
else
k2=sqrt(2/(float)n1);
dct[m][n]=(dct[m][n])+(k1*k2*img[x][y]*cos((2*x+1)*3.14159*m/(2*n1))*
cos((2*y+1)*3.14159*n/(2*n1)));
idct[x][y]=(idct[x][y])+(k1*k2*dct[x][y]*cos((2*x+1)*3.14159*m/(2*n1))*
cos((2*y+1)*3.14159*n/(2*n1)));
}
}
}
printf("\n\n ***** Program for finding DCT/IDCT coefficients of an image *****");
printf("\n\n The Image Coefficients are\n\n ");
for(i=0;i<n1;i++)
{
for(j=0;j<n1;j++)
printf("%d ",img[i][j]);
printf("\n ");
}
printf("\n\n The DCT coefficients\n\n  ");
for(i=0;i<n1;i++)
{
for(j=0;j<n1;j++)
printf("%f  ",dct[i][j]);
printf("\n\n ");
}
printf("\n\n The IDCT coefficients\n\n  ");
for(i=0;i<n1;i++)
{
for(j=0;j<n1;j++)
printf("%f  ",idct[i][j]);
printf("\n\n ");
}
getch();
}
