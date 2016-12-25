#include<stdio.h>
#include<conio.h>
#include<stdlib.h>
#include<string.h>
#include<io.h>


int count[20];
void wordcount();

void main()
{
  int linenum;
  char label[20],mne[10],opr[10],mname[10];
  FILE *f1,*f2;
  void wordcount(void);
  clrscr();
  wordcount();
  printf("\noutput\n");
  f1=fopen("minput.txt","r");
  linenum=1;
  while(!feof(f1))
  {

  if(count[linenum]==1)
   fscanf(f1,"%s\n",mne);
  if(count[linenum]==2)
  fscanf(f1,"%s%s\n",mne,opr);
   if(count[linenum]==3)
   {
    fscanf(f1,"%s%s%s\n",label,mne,opr);
    if(strcmp(label,"MACRO")==0)
    {
    printf("\n macro name=%s\n",mne);
    printf("\n macro arguments=%s\n",opr);
    strcpy(mname,mne);
    f2=fopen("MACRODEF.txt","w");
    linenum+=1;
    printf("maco definition follows\n\n");
    while(strcmp(mne,"MEND")!=0)
    {

     fscanf(f1,"%s %s \n",mne,opr);
     fprintf(f2,"%s %s \n",mne,opr);
     printf("%s %s \n",mne,opr);
     linenum+=1;
     if(count[linenum]==1)
      fscanf(f1,"%s\n",mne);
      }
     }
   }

   linenum+=1;
  }
      fclose(f1);
      fclose(f2);
      getch();
}

void wordcount()
{
      FILE *f3;
      char c;
      int word=0,i=1,j=0,cnt;
      printf("\n wordcount");
      f3=fopen("minput.txt","r");
      c=getc(f3);
      while(c!=EOF)
      {

      if(c==' ')
      word+=1;
      if(c=='\n')
      {
      word+=1;
      count[i]=word;
      printf("\n line no %d",j+1);
      printf("no of words %d\n",word);
      i+=1;
      word=0;
      j++;
      }
      c=getc(f3);
      }
      fclose(f3);
}


