#include<dos.h>
#include<graphics.h>
#include<conio.h>
#include<stdlib.h>
#include<stdio.h>
void pseucol(FILE*fp);
void main()
{
FILE *fp;
char fn[15];
clrscr();
printf("\n\tEnter source image file:");
gets(fn);
fp=fopen(fn,"rb");
if(fp==NULL)
{
printf("\n\tCannot open source.");
getch();
exit(0);
}
pseucol(fp);
getch();
}


void pseucol(FILE *fp)
{
int i;
FILE *fp2;
unsigned char k;
char fn[15];
printf("\n\tEnter the destination file name:");
gets(fn);
fp2=fopen(fn,"wb");
if(fp2==NULL)
{
printf("\n\tCannot open source.");
getch();
exit(0);
}
for(i=0;i<54;i++)
fputc(fgetc(fp),fp2);
if(k>=0  && k<32)
{
fputc(150,fp2);
fputc(75,fp2);
fputc(125,fp2);
}
else if(k>=32 && k<64)
{
fputc(22,fp2);
fputc(35,fp2);
fputc(200,fp2);
}
else if(k>=64 && k<96)
{
fputc(40,fp2);
fputc(200,fp2);
fputc(60,fp2);
}
else if(k>=96 && k<128)
{
fputc(180,fp2);
fputc(45,fp2);
fputc(50,fp2);
}
else if(k>=128 && k<160)
{
fputc(200,fp2);
fputc(180,fp2);
fputc(40,fp2);
}
else if(k>=160 && k<192)
{
fputc(170,fp2);
fputc(33,fp2);
fputc(175,fp2);
}
else if(k>=192 && k<224)
{
fputc(50,fp2);
fputc(165,fp2);
fputc(185,fp2);
}
else
{
fputc(185,fp2);
fputc(175,fp2);
fputc(180,fp2);
}
while(!feof(fp))
fputc(fgetc(fp),fp2);
fcloseall();
printf("\n\tPseudo coloring successful.");
}
