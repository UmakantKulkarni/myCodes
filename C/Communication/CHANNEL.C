#include<stdio.h>
#include<conio.h>
#include<math.h>

void idchannel();
void symchannel();
void asymchannel();

void main()
{
  int choice;

  //clrscr();

  while(1)
  {
   printf("\n    MENU");
   printf("\n1.ideal channel");
   printf("\n2.symmetric channel");
   printf("\n3.assymetric channel");
   printf("\n4.exit");
   printf("\nenter choice");
   scanf("%d",&choice);

    switch(choice)
    {
     case 1: idchannel();
	     break;
     case 2: symchannel();
	     break;
     case 3: asymchannel();
	     break;
     case 4: exit();
	     break;

    }
  }

 }

 void idchannel()
 {
  float px0,px1,py1,py0;
  float pcyx[2][2];   //conditional prob
  float pyx[2][2]; //joint prob
  float pcxy[2][2]; //equivocational prob
  float hx,hy,hxy,hyx,HXY; //entropies
  int i,j;

  printf("\nenter px0:");
  scanf("%f",&px0);

  px1=1-px0;
  py0=px0;
  py1=px1;

  pcyx[0][0]=1;
  pcyx[0][1]=0;
  pcyx[1][0]=0;
  pcyx[1][1]=1;
  printf("\n the transiton matrix is:");
  printf("\n");
  for(i=0;i<2;i++)
  {
    for(j=0;j<2;j++)
    printf(" %f ",pcyx[i][j]);

    printf("\n");
  }

  pyx[0][0]=pcyx[0][0]*px0;
  pyx[0][1]=pcyx[0][1]*px1;
  pyx[1][0]=pcyx[1][0]*px0;
  pyx[1][1]=pcyx[1][1]*px1;
  printf("\n the joint prob matrix is:");
  printf("\n");
  for(i=0;i<2;i++)
  {
    for(j=0;j<2;j++)
    printf(" %f ",pyx[i][j]);

    printf("\n");
  }

  pcxy[0][0]=pyx[0][0]/py0;
  pcxy[0][1]=pyx[0][1]/py0;
  pcxy[1][0]=pyx[1][0]/py1;
  pcxy[1][1]=pyx[1][1]/py1;
  printf("\n the equivocational prob matrix is:");
  printf("\n");
  for(i=0;i<2;i++)
  {
    for(j=0;j<2;j++)
    printf(" %f ",pcxy[i][j]);

    printf("\n");
  }

  hx=-(px0*log10(px0)+px1*log10(px1))/0.301;
  hy=hx;

  hxy=0;
  for(i=0;i<2;i++)
   for(j=0;j<2;j++)
     if(pcxy[i][j])
     hxy=hxy - pyx[i][j]*log10(pcxy[i][j])/0.301;

  hyx=0;
  for(i=0;i<2;i++)
   for(j=0;j<2;j++)
     if(pcyx[i][j])
     hyx=hyx - pyx[i][j]*log10(pcyx[i][j])/0.301;

  HXY=0;
  for(i=0;i<2;i++)
   for(j=0;j<2;j++)
     if(pyx[i][j])
     HXY=HXY - pyx[i][j]*log10(pyx[i][j])/0.301;


  printf("\nentropy hx is:%f",hx);
  printf("\nentropy hy is:%f",hy);
  printf("\nentropy h(xy) is:%f",HXY);
  printf("\nentropy h(x|y) is:%f",hxy);
  printf("\nentropy h(y|x) is:%f",hyx);



 }

 void symchannel()
 {
 }

 void asymchannel()
 {
 }
