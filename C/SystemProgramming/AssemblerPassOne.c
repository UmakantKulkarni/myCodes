#include<stdio.h>
#include<string.h>
#include<conio.h>
#include<stdlib.h>
#include<ctype.h>

struct mnemonictab
  {
	char Symbol[8];
	int  address;
	int  size;
  }MT[20];

struct MOTtable
  {
	char Mnemonic[7];
	int  Class;
	char Opcode[3];
  };

struct symboltable
  {
	char Symbol[8];
	int  Address;
	int  Size;
  }ST[20];
struct literaltable
  {
	int  Literal;
	int  Address;
  }LT[10];




static struct MOTtable MOT[28]={{"STOP",1,"00"},{"ADD",1,"01"},{"SUB",1,"02"},
		       {"MULT",1,"03"},{"MOVER",1,"04"},{"MOVEM",1,"05"},
		       {"COMP",1,"06"},{"BC",1,"07"},{"DIV",1,"08"},
		       {"READ",1,"09"},{"PRINT",1,"10"},
		       {"START",3,"01"},{"END",3,"02"},{"ORIGIN",3,"03"},
		       {"EQU",3,"04"},{"LTORG",3,"05"},
		       {"DS",2,"01"},{"DC",2,"02"},
		       {"AREG",4,"01"},{"BREG",4,"02"},{"CREG",4,"03"},
		       {"EQ",5,"01"},{"LT",5,"02"},{"GT",5,"03"},{"LE",5,"04"},
		       {"GE",5,"05"},{"NE",5,"06"},{"ANY",5,"07"}};
int nMOT=28; //Number of entries in MOT
int LC=0;    //Location counter
int iLT=0;   //Index of next entry in Literal Table
int iST=0;   //Index of next entry in Symbol Table
int iIC=0;   //Index of next entry in intermediate code table
int searchST(char symbol[])
   {
      int i;
      for(i=0;i<iST;i++)
		if(strcmp(ST[i].Symbol,symbol)==0)
		     return(i);
      return(-1);
   }

int searchMOT(char symbol[])
   {
      int i;
      for(i=0;i<nMOT;i++)
	 if(strcmp(MOT[i].Mnemonic,symbol)==0)
		return(i);
      return(-1);
   }
int insertST( char symbol[],int address,int size)
    {
       strcpy(ST[iST].Symbol,symbol);
       ST[iST].Address=address;
       ST[iST].Size=size;
       iST++;
       return(iST-1);
    }

void print_mnem(int);
void imperative(); 	
void declaration();	
void directive(); 	
void print_symbol();
void print_literal();	


char s1[8],s2[8],s3[8],label[8];

void DC(); 		//Handle DC
void DS(); 		//Handle DS

int tokencount; 	//total number of words in a statement

void main()
 {
	  char st[10];
	char nextline[80];
	int i,j;
	int lc=0;
	FILE *fp;

	 fp=fopen("asmprog.txt","r");

  j=0;
  while(!feof(fp))
  { 
	  fscanf(fp,"%s",&st);

	  if(!strcmp(st,"START")) 
	  {
		  fscanf(fp,"%d",&lc);
		  LC=lc;
      }
	

     for(i=0;i<28;i++)
	 {
		 if(!(strcmp(st,MOT[i].Mnemonic)))
		 {
			 if(MOT[i].Class==1)
			 { 
			   strcpy(MT[j].Symbol,MOT[i].Mnemonic);
			   MT[j].address=lc;
			   MT[j].size=1;
			   
			   lc++;
			   j++;
			 }
		 }

	 }

  }
  print_mnem(j);

	fp=fopen("asmprog.txt","r");
	while(!feof(fp))
	  {
		//Read a line of assembly program and remove special characters
		i=0;
		nextline[i]=fgetc(fp);
		while(nextline[i]!='\n'&& nextline[i]!=EOF )
		    {
				if(!isalnum(nextline[i]))
					nextline[i]=' ';
				else
					nextline[i]=toupper(nextline[i]);
				i++;
				nextline[i]=fgetc(fp);
		    }
		nextline[i]='\0';

		sscanf(nextline,"%s",s1); //read from the nextline in s1
		if(strcmp(s1,"END")==0)
		      break;
//if the nextline contains a label
		if(searchMOT(s1)==-1)
		     {
			if(searchST(s1)==-1)
				  insertST(s1,LC,0);
			//separate opcode and operands
			tokencount=sscanf(nextline,"%s%s%s%s",label,s1,s2,s3);
			tokencount--;
		     }
		else
			//separate opcode and operands
			tokencount=sscanf(nextline,"%s%s%s",s1,s2,s3);
		if(tokencount==0)//blank line
		      continue;//goto the beginning of the loop
		i=searchMOT(s1);
		if(i==-1)
		  {
			printf("\nWrong Opcode .... %s",s1);
			continue;
		  }
		switch (MOT[i].Class)
		   {
			case 1:	imperative();break;
			case 2: declaration();break;
			case 3: directive();break;
			default: printf("\nWrong opcode ...%s",s1);
				 break;
		   }

	  }

  print_symbol();

  print_literal();

 }

void imperative()
  {
    int index;
    index=searchMOT(s1);

    LC=LC+1;
    if(tokencount>1)
      {
	index=searchMOT(s2);
	if(index != -1)
	   {
	
	   }
	else
	   {   //It is a variable
	       index=searchST(s2);
	       if(index==-1)
		    index=insertST(s2,0,0);
		
	   }
      }
    if(tokencount>2)
      {
	  if(isdigit(*s3))
	     {
		LT[iLT].Literal=atoi(s3);
	    LT[iLT].Address=LC;
		iLT++;
	     }
	  else
	     {
		index=searchST(s3);
		if(index==-1)
		    index=insertST(s3,0,0);
		

	     }

      }

   iIC++;
}

void declaration()
{
   if(strcmp(s1,"DC")==0)
     {
	DC();
	return;
     }
   if(strcmp(s1,"DS")==0)
	DS();
}

void directive()
{
      return;
  
}


void DC()
{
	int index;
	index=searchMOT(s1);
	
	index=searchST(label);
	if(index==-1)
		index=insertST(label,0,0);
	ST[index].Address=LC;
	ST[index].Size=1;
	LC=LC+1;
	iIC++;

}
void DS()
{
	int index;
	index=searchMOT(s1);
	
	index=searchST(label);
	if(index==-1)
		index=insertST(label,0,0);
	ST[index].Address=LC;
	ST[index].Size=atoi(s2);
	LC=LC+atoi(s2);
	iIC++;
}





void print_symbol()
 {
	int i;
	printf("\nsymbol table \n");
	for(i=0;i<iST;i++)
		printf("\n%10s  %3d   %3d",ST[i].Symbol,ST[i].Address
					  ,ST[i].Size);
}

 void print_literal()
  {
	int i;
	printf("\nliteral table\n");
	for(i=0;i<iLT;i++)
		printf("\n%5d\t%5d",LT[i].Literal,LT[i].Address);
  }


void print_mnem(int j)
{
	int i;
	int count=j;
	printf("\nmnemonictab");
	for(i=0;i<count;i++)
		printf("\n%10s  %3d   %3d",MT[i].Symbol,MT[i].address,MT[i].size);

}
