#include<string.h>
#include<graphics.h>
#include<stdlib.h>
#include<stdio.h>
#include<BMP.H>


typedef struct bmp_head
 {
  unsigned short int type;
  unsigned long int size;
  unsigned long int reserved;
  unsigned long int dataoffset;
 }bm;

 typedef struct bmp_info_header
 {

  unsigned long int size;
  unsigned long int width;
  unsigned long int height;
  unsigned short int planes;
  unsigned short int bitcount;
  unsigned long int compression;
  unsigned long int image_size;
  unsigned long int xpells;
  unsigned long int ypells;
  unsigned long int colours_use;
  unsigned long int colours_imp;
  }bmi;

 typedef struct rgbquad
 {
  char r,g,b,reserved;
 }rgb;

 void main()
 {
 bm bm1;
 bmi bmi1;
 FILE *fp;
 int x,y,i,j,ans,arr2[256];
 float arr3[256],gr;
 float gray=0;
 int a[256],e[256],m=0;
 float b[256];
 unsigned char c;
 int gdriver=DETECT,gmode,errorcode;
 struct palettetype pal;

  initgraph(&gdriver,&gmode,"c:/TC/bgi");
  errorcode=graphresult();
  if(errorcode!=grOk)
  {
   printf("\ngraphics error");
   printf("\nPress any key to hault");
   getch();
   exit(1);
  }

  else
  {
   if((fp=fopen("C:\\Images\\golf.bmp","rb"))==NULL)
      printf("\nUnable to open file");
   else
   {
      fread(&bm1,sizeof(bm1),1,fp);
      printf("\nBMP FILE HEADER");
      printf("\n1.type:%d\n2.size:%ld\n3.reserved:%ld\n4.offset:%ld",bm1.type,bm1.size,bm1.reserved,bm1.dataoffset);

      printf("\n\n");
      fread(&bmi1,sizeof(bmi1),1,fp);
      printf("\nBMP INFO HEADER");
      printf("\n1.size:%ld\n2.width:%ld\n3.height:%ld\n4.planes:%d\n5.bitcount:%d\n6.compression:%ld\n7.imagesize:%ld\n8.xpells:%ld\n9.ypells:%ld\n10.colours_use:%ld\n11.colours_imp:%ld\n",bmi1.size,bmi1.width,bmi1.height,bmi1.planes,bmi1.bitcount,bmi1.compression,bmi1.image_size,bmi1.xpells,bmi1.ypells,bmi1.colours_use,bmi1.colours_imp);
      SaveScreen("C:\\histone.bmp");
      getch();
      fclose(fp);
   }
  }
      cleardevice();
      printf("\n INPUT IMAGE");
      fp=fopen("C:\\Images\\golf.bmp","rb");
      getpalette(&pal);

      for(i=0;i<pal.size;i++)
      {	setrgbpalette(pal.colors[i],i*4,i*4,i*4);      }
      for(i=0;i<256;i++)
       {
	e[i]=0;
	a[i]=0;
	b[i]=0;
	arr2[i]=0;
       }

      fseek(fp,bm1.dataoffset,SEEK_SET);
      for(y=bmi1.width;y>0;y--)
	{
	for(x=0;x<bmi1.height;x++)
	{
	 c=fgetc(fp);
	 putpixel(x+100,y+100,c/16);
	 a[c]=a[c]+1;
	 }
	}

	 printf("\n Press 1 to continue:\t");
	 scanf("\n%d",&ans);
	 SaveScreen("C:\\histtwo.bmp");
	 if (ans==1)
	 clrscr();
	for(i=0;i<255;i++)
	{	 line(50+(2*i),350-(a[i]/10),50+(2*i),350);	}

	 outtextxy(250,450,"HISTOGRAM");
	for(i=0;i<256;i++)
	{
	gr=0;
	for(j=0;j<=i;j++)
	{	gr=gr+a[j];	}
	gray=(gr/(bmi1.width*bmi1.height));
	gray=gray*255;
	b[i]=gray;

      }
	 printf("\n PRESS 1 to get the equalised IMAGE:\t");
	 scanf("%d",&ans);
	 SaveScreen("C:\\histthree.bmp");
	 if (ans==1)
       clrscr();

  fseek(fp,bm1.dataoffset,SEEK_SET);
      for(y=bmi1.width;y>0;y--)
	{
	for(x=0;x<bmi1.height;x++)
	{
	 c=fgetc(fp);
	 m=b[c] ;
	 putpixel(x+100,y+100,b[c]/16);
	 e[m]=e[m]+1;

	 }
	}

	printf("\n Enter 1 to plot equalised histogram:\t");
	scanf("%d",&ans);
	SaveScreen("C:\\histfour.bmp");
	if(ans==1)
	clrscr();
	for(j=0;j<256;j++)
	 {
	 line((2*j)+30,350-(e[j]/16),(2*j)+30,350);
	 }
	 outtextxy(250,450,"EQUALISED HISTGRAM");
	 SaveScreen("C:\\histfive.bmp");
	getch();
	fclose(fp);
	closegraph();
}
