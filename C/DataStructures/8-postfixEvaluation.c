//8) Evaluation of postfix expression (input will be postfix expression)

#include<stdio.h>
#include<ctype.h>
#include<string.h>
#define MAX_STACK 50
#define MAX_EXPR 50
/* definition of stack */
struct stack
{
	int data[MAX_STACK];
	int length;
};

/* declaration of stack functions */

void init(struct stack *);
int  empty(struct stack *);
int  full(struct stack *);
int  pop(struct stack *);
void push(struct stack *,int );
int  top(struct stack *); //value of the top element


/* evaluation functions */
void EvaluatePostfix(char postfix[]);
int  Evaluate(char op,int op1,int op2);

int main()
{


	char PostfixString[MAX_EXPR];
	printf("\n Please Enter The Input Postfix string   :  ");
	fflush(stdin);
	fgets(PostfixString, MAX_EXPR, stdin);
	EvaluatePostfix(PostfixString);
	
	
	return 0;
}

/* precedence of an operator */
int precedence(char op)
{
	switch(op)
	{
		case '(' :
			return 0;
		case '+' :
		case '-' :
			return 1;
		case '*' :
		case '/' :
		case '%' :
			return 2;
		default :
			/* invalid operand */
			return -1;
	}
	
}
int isOperator(char token)
{
	/* use precedence function - we know all operators have 0 or higher precedence */
	return precedence(token) >= 0;	
}


void EvaluatePostfix(char postfix[])
{
	int number = 0;
	int read_number = 0;
	char *pPost = postfix;
	struct stack s;	
	init(&s);
		
	for(pPost = postfix; *pPost != '\0'; pPost++)
	{
		char token = *pPost;
		
		if(isdigit(token))
		{
			if(!read_number)
			{
				read_number = 1;
				number = 0;
			}
			
			number = number * 10 + ( token - '0');
		}
		else 
		{
			if(read_number)
			{
				read_number = 0;
				push(&s, number);
			}
			
			if(isalpha(token))
			{
				printf("\nEnter the value of %c : ", token);
				scanf("%d", &number);
				push(&s,number);
				printf("\n");
			}
			else if(isOperator(token) && s.length >= 2)
			{
				number = Evaluate(token, pop(&s), pop(&s));					
				push(&s, number);
			}
		}
	}
	
	if(read_number)
	{
		read_number = 0;
		push(&s, number);
	}
	
	if(s.length >= 1)
		printf("\nvalue of expression = %d\n", pop(&s));

}

int Evaluate(char op, int op1, int op2)
{
	switch(op)
	{
		case '+':
			return op1 + op2;
		case '-':
			return op1 - op2;
		case '*':
			return op1 * op2;
		case '/':
			return op1 / op2;
		case '%':
			return op1 % op2;
		
	}
}

/* stack operations */
void init(struct stack *s)
{
	s->length = 0;
}
int empty(struct stack *s)
{
	return s->length == 0;
}

int full(struct stack *s)
{
	return s->length == MAX_STACK;
}

void push(struct stack *s, int x)
{
	s->data[s->length++] = x;
}

int pop(struct stack *s)
{
	return s->data[--(s->length)];
}

int top(struct stack * s)
{
	return s->data[s->length - 1];
}


/*                        OUTPUT



E:\Programming\c\se-entc>gcc 8-postfixEvaluation.c

E:\Programming\c\se-entc>a

 Please Enter The Input Postfix string   :  ab*c+d-

Enter the value of a : 2


Enter the value of b : 3


Enter the value of c : 4


Enter the value of d : 5


value of expression = 5

E:\Programming\c\se-entc>

*/
