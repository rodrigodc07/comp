%{
#include "trab.tab.h"
#include <ctype.h>
#include <stdlib.h>
#include <stdio.h>
#include <string.h>

char *yytext;
YYSTYPE yylval;
%}

ALFA 		[A-Za-z_]
PLUS            [\+]
MINUS           [\-]
TIMES           [\*]
DIGIT           [0-9]
NUMBER          ({DIGIT}+)
PRINT           "print"
IF              "if"
ELSE            "else"
THEN            "then"
WHILE           "while"
DO              "do"
IDENT		{ALFA}({ALFA}|{DIGIT})*
WS              [ \t]*
ATRIB		        "="
LP              "("
RP              ")"
LC              "{"
RC              "}"
PTV             ";"
VIRG            ","
RET             [\n]

%%
{WS} 		  {
		/* eat up white space */ 
		}
{PLUS} 		{
		return _MAIS; 		
}
{TIMES} 	{
		return _MULT; 
		}
{MINUS} 	{
		return _MENOS; 		
    } 
{ATRIB} 	{		
    return _ATRIB; 		
    }
{LP} 		  {		
    return _ABREPAR; 		
    }
{RP} 		  {
		return _FECHAPAR; 	
    }
{LC} 		  {		
    return _ABRECHA; 		
    }
{RC} 		  {
		return _FECHACHA; 
		}
{PTV} 	  {
		return _PTVIRG;		
    }
{VIRG} 	  {		
    return _VIRG;		
    }
{NUMBER}	{		
    strcpy(yylval.t.symbol, yytext);
		return _N;		
    }
{PRINT} 	{		
    return _PRINT;	
		}
{IF} 		  {
		return _IF;		
    }
{ELSE} 		{
		return _ELSE;		
    }
{THEN} 		{
		return _THEN;		
    }
{WHILE} 	{
		return _WHILE;
		}
{DO} 		  {
		return _DO;
		}
{IDENT} 	{		
    strcpy(yylval.t.symbol, yytext);		
    return _V;
		}
{RET} 		{
		return yytext[0];
		}
