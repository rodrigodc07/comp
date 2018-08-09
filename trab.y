%{
#include <ctype.h>
#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <math.h>
extern int yylex ();
 
#define NADA		9999
#define FRACASSO	9998

char *msg4 = "unknow entity in source program";

typedef enum {
	Variable,
	Constant,
	Temporary,
	Function,
	Procedure
} Entity;

/*
SymbTab: 1as 50 entradas p/ simbolos do fonte
e últimas p/ as temporarias
*/
typedef struct {
  char     asciiOfSource [20];
  Entity   entt;
  int      value;
} SymbTab;

SymbTab symbTab [100];

int	indSymb,  
	indTemp;

int	topTab=0;   // first 50 entries are programmer symbols
int	topTemp=50; // last  50 entries are temporary

int searchSymbTab (char *symb){ 
  int k;
  for (k = 0; k < topTab; k++)
    if (strcmp(symb,symbTab[k].asciiOfSource) == 0)
      return k;
  return topTab;
};

int insertSymbTab (char *symb, Entity whichEntt) {
  
  int existingSym, current, aux;  
  existingSym = searchSymbTab (symb);
  
  if (existingSym < topTab && whichEntt == Constant)
  	return existingSym;
  else if(existingSym < topTab && whichEntt == Variable) {
	char * ptMsg = (char *) malloc (80);
    	strcpy(ptMsg,"Variable already declared with this name: "); 
    	strcat(ptMsg,symb); 
    	yyerror (ptMsg);
    };
    
  current = topTab;
  if (whichEntt == Variable || (whichEntt == Constant)) {
     strcpy(symbTab[current].asciiOfSource,symb);
     symbTab[current].entt = whichEntt;
     }
  else {
    char * ptMsg = (char *) malloc (80);
    strcpy(ptMsg,"Unknown entity type: "); 
    strcat(ptMsg,symb); 
    yyerror (ptMsg);
    };
    
  if (whichEntt == Constant)
     symbTab[current].value = atoi(symb);
  if (whichEntt == Variable) 
     symbTab[current].value = 0;  
  topTab++;
  return current;
};

int returnSymbTab (char *symb, Entity whichEntt) {

  int existingSym, current, aux;  
  existingSym = searchSymbTab (symb);  
  if (existingSym < topTab)
     return existingSym;
  
  current = topTab;
  if (whichEntt == Constant) {
     strcpy(symbTab[current].asciiOfSource,symb);
     symbTab[current].entt = whichEntt;
     symbTab[current].value = atoi(symb);
     }
  else if (whichEntt == Variable) {
     char * ptMsg = (char *) malloc (80);
     strcpy(ptMsg,"Variable not yet declared: "); 
     strcat(ptMsg,symb); 
     yyerror (ptMsg);
     }
  else {
    char * ptMsg = (char *) malloc (80);
    strcpy(ptMsg,"Unknown entity type: "); 
    strcat(ptMsg,symb); 
    yyerror (ptMsg);
    };
    
  topTab++;
  return current;
};

int temp () { 
	char nomeTemporaria[4];
	int retorno;
        sprintf(nomeTemporaria,"t%d",topTemp-50);
	strcpy(symbTab[topTemp].asciiOfSource,nomeTemporaria);
	symbTab[topTemp].entt = Temporary;
        retorno=topTemp;
	topTemp++;
	return (retorno);
};

void printSymbTable () {
	int i, j, inicio, fimTrecho;
	inicio=0;
	j=0;
	fimTrecho = topTab-1;// trecho dos símbolos do programa  
	while (j <= 1) {
  	  for (i=inicio; i <= fimTrecho; i++) { 
            switch (symbTab[i].entt) {
      		case Variable: printf("> Variable: ");break;
      		case Constant: printf("> Numerical Constant: ");break;
      		case Temporary: printf("> Temporary: ");break;
      		case Function: printf("> Function: ");break;
      		case Procedure: printf("> Procedure: ");break;
      		default: yyerror(msg4);break;
    	    };
    	    printf("%s ", symbTab[i].asciiOfSource);
            printf("%d \n", symbTab[i].value);
    	  };// do for
  	  j++;
          inicio = 50;
          fimTrecho=topTemp-1;  // trecho das temporárias
	}; // do while
}; // da function printSymbTable

typedef enum {
	ADD,
	SUB,
	MUL,
	STO,
	PRINT,
	J,
	JF
} Operador;

struct Quadrupla {
	Operador        op;
	int             operando1;
	int             operando2;
	int             operando3;
} quadrupla [ 100 ];

int prox;

void gera (Operador codop,int end1,int end2,int end3){
	quadrupla [prox].op = codop;
	quadrupla [prox].operando1 = end1;
	quadrupla [prox].operando2 = end2;
	quadrupla [prox].operando3 = end3;
	prox++;
};

void remenda (int endQuad, Operador codop,int end1,int end2,int end3){
	quadrupla [endQuad].op = codop;
	quadrupla [endQuad].operando1 = end1;
	quadrupla [endQuad].operando2 = end2;
	quadrupla [endQuad].operando3 = end3;
};

void imprimeQuadrupla(){
  int r; 
  for(r=0;r<prox;r++) 
    printf("%d %d %d %d\n",
            quadrupla[r].op,                
               quadrupla[r].operando1,
                  quadrupla[r].operando2,
                     quadrupla[r].operando3);  
}; //da funcao imprimeQuadrupla

void finaliza () {
  printSymbTable ();
  imprimeQuadrupla ();
  printf("End normal compilation! \n");
  exit(0);
  };

void yyerror(const char *str) {
  printf("error: %s\n",str);
  exit (1);
};

int yywrap() {
  return 1;
};

int main()
{
  printf("\n \n>G6 \n>"); 
  yyparse();
  return 0;
};

%}
%union{
  struct T{
    char symbol[21]; 
    int intval;
  }t;
 }

%token _ATRIB _EOF _ABREPAR _FECHAPAR _PTVIRG
%token _MAIS _MENOS _MULT _DIVID _PRINT
%token _IF _ELSE _THEN _WHILE _DO
%token _VIRG _ABRECHA _FECHACHA
%token _ERRO
%token _N _V
%type<t> E T F _N _V M N V
%%

/* 
regras da gramatica e acoes semanticas
*/

P    : D _ABRECHA C _FECHACHA      
     |  /* empty */ {finaliza (); }   
     ;
D    : D V _PTVIRG 
     | V _PTVIRG          
     ;
V    : V _VIRG _V {
		insertSymbTab($1.symbol, Variable); }
     | _INT _V {	
		insertSymbTab($1.symbol, Variable); }  		
B    : _ABRECHA  C _FECHACHA
     | S     
C    : C _PTVIRG S
     | S
S    : _IF _ABREPAR E _FECHAPAR _THEN M B _ELSE M B {
                                                     remenda($6.intval,JF,$3.intval,$9.intval+1,NADA);
					             remenda($9.intval,J,prox,NADA,NADA); }                                                     													 
     | _IF _ABREPAR E _FECHAPAR _THEN M B           {
                                                     remenda($6.intval,JF,$3.intval,prox,NADA); }
     | _WHILE N _ABREPAR E _FECHAPAR _DO M B        {
					             gera(J, $2.intval, NADA, NADA); 
						     remenda($6.intval, JF, E.intval, prox, NADA); }
     | _V _ATRIB E {
                   $1.intval = returnSymbTab($1.symbol, Variable);
		   gera(STO,$3.intval,$1.intval,NADA);
	           printf("\n"); }
     | _PRINT _ABREPAR E _FECHAPAR {                                      
                                    gera(PRINT, $3.intval, NADA, NADA);
				    printf("\n"); }
M    : /* empty */ {
                    $$.intval = prox;
                    prox++; }
N    : /* empty */ {
                    $$.intval = prox; }					
L    : L _VIRG E 
     | E	      
E    : E _MAIS T {
                  $$.intval = temp(); 
		  gera (ADD,$1.intval,$3.intval,$$.intval); }
     | E _MENOS T{    
                  $$.intval = temp(); 
		  gera (SUB,$1.intval,$3.intval,$$.intval); }
     | T	 {	
                  $$.intval = $1.intval; }
T    : T _MULT F {	
                  $$.intval = temp(); 
		  gera (MUL,$1.intval,$3.intval,$$.intval); }	
      | F	 {	
                  $$.intval = $1.intval; }
F    : _V {
           $$.intval=returnSymbTab($1.symbol, Variable); }
     | _N {
           $$.intval=returnSymbTab($1.symbol, Constant); } 
     ;
%%

void atendeReclamacao () {
  int aux;
  aux = 0; // trying avoid compilation error in bison
  }
