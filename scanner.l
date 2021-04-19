%{
#include<stdio.h>
#include <stdlib.h>
#include "y.tab.h"
extern int yyscope;
extern int yylineno;

#define DEBUG_MODE 1
#define KEYWORD "KEYWORD"
#define OPERATOR "OPERATOR"
#define LITERAL "LITERAL"
#define SEPARATOR "SEPARATOR"
#define IDENTIFIER "IDENTIFIER"


void checkclosed();
void print_token(char* tokenname,char* type,int lineno);

%}

underscore                  [_]
digit                       [0-9]
digits                      {digit}+
letter                      [a-zA-Z]
optionalFraction            (\.{digits})?
optionalExponent            ([Ee][+-]?{digits})?
intNumber                   {digits}
floatNumber                 {digits}{optionalFraction}{optionalExponent}
identifier                  ({letter}|{underscore})({letter}|{digits}|{underscore})*


%%

\n  						{++yylineno; yylloc.first_column = 1; yylloc.last_column = 1;}

 /* IGNORING COMMENTS */
(\/\/.*)[\n] 		{++yylineno;yylloc.first_column = 1; yylloc.last_column = 1;}
\/\*	            {
                        checkclosed();
                    }
\*\/                {
                        printf("\033[0;31mERROR at line number : %d\n \033[0;37m Dangling Comment \033[0;35m\n\n", yylineno);
                    }

 /* SPACE REMOVAL */

\t 						{ yylloc.first_column = yylloc.last_column+1; yylloc.last_column += 4;}
[ ] 					{ yylloc.first_column = yylloc.last_column+1; yylloc.last_column += 1;}
\r                      { yylloc.first_column = yylloc.last_column+1; yylloc.last_column += strlen(yytext);}
\f                      { yylloc.first_column = yylloc.last_column+1; yylloc.last_column += strlen(yytext);}



 /* RESERVED KEYWORDS */
package					                {if (DEBUG_MODE) print_token(yytext,KEYWORD, yylineno); yylval.str= strdup(yytext); yylloc.first_column = yylloc.last_column+1; yylloc.last_column += strlen(yytext); return T_PACKAGE;}
main					                {if (DEBUG_MODE) print_token(yytext,KEYWORD, yylineno); yylval.str= strdup(yytext); yylloc.first_column = yylloc.last_column+1; yylloc.last_column += strlen(yytext); return T_MAIN;}
func					                {if (DEBUG_MODE) print_token(yytext,KEYWORD, yylineno); yylval.str= strdup(yytext); yylloc.first_column = yylloc.last_column+1; yylloc.last_column += strlen(yytext); return T_FUNC;}
Println                 	            {if (DEBUG_MODE) print_token(yytext,KEYWORD, yylineno); yylval.str= strdup(yytext); yylloc.first_column = yylloc.last_column+1; yylloc.last_column += strlen(yytext); return T_PRINT;}
fmt                      	            {if (DEBUG_MODE) print_token(yytext,KEYWORD, yylineno); yylval.str= strdup(yytext); yylloc.first_column = yylloc.last_column+1; yylloc.last_column += strlen(yytext); return T_FMT;}
var						                {if (DEBUG_MODE) print_token(yytext,KEYWORD, yylineno); yylval.str= strdup(yytext); yylloc.first_column = yylloc.last_column+1; yylloc.last_column += strlen(yytext); return T_VAR;}
int						                {if (DEBUG_MODE) print_token(yytext,KEYWORD, yylineno); yylval.str= strdup(yytext); yylloc.first_column = yylloc.last_column+1; yylloc.last_column += strlen(yytext); return T_INT;}
string					                {if (DEBUG_MODE) print_token(yytext,KEYWORD, yylineno); yylval.str= strdup(yytext); yylloc.first_column = yylloc.last_column+1; yylloc.last_column += strlen(yytext); return T_STR;}
float64                                 {if (DEBUG_MODE) print_token(yytext,KEYWORD, yylineno); yylval.str= strdup(yytext); yylloc.first_column = yylloc.last_column+1; yylloc.last_column += strlen(yytext); return T_FLT64;}                                            
bool                                    {if (DEBUG_MODE) print_token(yytext,KEYWORD, yylineno); yylval.str= strdup(yytext); yylloc.first_column = yylloc.last_column+1; yylloc.last_column += strlen(yytext); return T_BOOL;}
fallthrough                             {if (DEBUG_MODE) print_token(yytext,KEYWORD, yylineno); yylval.str= strdup(yytext); yylloc.first_column = yylloc.last_column+1; yylloc.last_column += strlen(yytext); return T_FALLTHROUGH;}
default                                 {if (DEBUG_MODE) print_token(yytext,KEYWORD, yylineno); yylval.str= strdup(yytext); yylloc.first_column = yylloc.last_column+1; yylloc.last_column += strlen(yytext); return T_DEFAULT;}
switch                                  {if (DEBUG_MODE) print_token(yytext,KEYWORD, yylineno); yylval.str= strdup(yytext); yylloc.first_column = yylloc.last_column+1; yylloc.last_column += strlen(yytext); return T_SWITCH;}
case                                    {if (DEBUG_MODE) print_token(yytext,KEYWORD, yylineno); yylval.str= strdup(yytext); yylloc.first_column = yylloc.last_column+1; yylloc.last_column += strlen(yytext); return T_CASE;}
repeat                                  {if (DEBUG_MODE) print_token(yytext,KEYWORD, yylineno); yylval.str= strdup(yytext); yylloc.first_column = yylloc.last_column+1; yylloc.last_column += strlen(yytext); return T_REPEAT;}
until                                   {if (DEBUG_MODE) print_token(yytext,KEYWORD, yylineno); yylval.str= strdup(yytext); yylloc.first_column = yylloc.last_column+1; yylloc.last_column += strlen(yytext); return T_UNTIL;}
import                                  {if (DEBUG_MODE) print_token(yytext,KEYWORD, yylineno); yylval.str= strdup(yytext); yylloc.first_column = yylloc.last_column+1; yylloc.last_column += strlen(yytext); return T_IMPORT;}
return                                  {if (DEBUG_MODE) print_token(yytext,KEYWORD, yylineno); yylval.str= strdup(yytext); yylloc.first_column = yylloc.last_column+1; yylloc.last_column += strlen(yytext); return T_RETURN;}


 /* OPERATORS */
"+="					                {if (DEBUG_MODE) print_token(yytext,OPERATOR, yylineno); yylloc.first_column = yylloc.last_column+1; yylloc.last_column += strlen(yytext); yylval.str= strdup(yytext); return T_SPLUS;}
"-="					                {if (DEBUG_MODE) print_token(yytext,OPERATOR, yylineno); yylloc.first_column = yylloc.last_column+1; yylloc.last_column += strlen(yytext); yylval.str= strdup(yytext); return T_SMINUS;}
"*="					                {if (DEBUG_MODE) print_token(yytext,OPERATOR, yylineno); yylloc.first_column = yylloc.last_column+1; yylloc.last_column += strlen(yytext); yylval.str= strdup(yytext); return T_SMUL;}
"/="					                {if (DEBUG_MODE) print_token(yytext,OPERATOR, yylineno); yylloc.first_column = yylloc.last_column+1; yylloc.last_column += strlen(yytext); yylval.str= strdup(yytext); return T_SDIV;}
"%="					                {if (DEBUG_MODE) print_token(yytext,OPERATOR, yylineno); yylloc.first_column = yylloc.last_column+1; yylloc.last_column += strlen(yytext); yylval.str= strdup(yytext); return T_SMOD;}
"&="					                {if (DEBUG_MODE) print_token(yytext,OPERATOR, yylineno); yylloc.first_column = yylloc.last_column+1; yylloc.last_column += strlen(yytext); yylval.str= strdup(yytext); return T_SAND;}
"^="					                {if (DEBUG_MODE) print_token(yytext,OPERATOR, yylineno); yylloc.first_column = yylloc.last_column+1; yylloc.last_column += strlen(yytext); yylval.str= strdup(yytext); return T_SOR;}
"|="					                {if (DEBUG_MODE) print_token(yytext,OPERATOR, yylineno); yylloc.first_column = yylloc.last_column+1; yylloc.last_column += strlen(yytext); yylval.str= strdup(yytext); return T_SOR;}
"!="				                    {if (DEBUG_MODE) print_token(yytext,OPERATOR, yylineno); yylloc.first_column = yylloc.last_column+1; yylloc.last_column += strlen(yytext); yylval.str= strdup(yytext); return T_NOTEQ;}
"=="				                    {if (DEBUG_MODE) print_token(yytext,OPERATOR, yylineno); yylloc.first_column = yylloc.last_column+1; yylloc.last_column += strlen(yytext); yylval.str= strdup(yytext); return T_COMP;}
"<="				                    {if (DEBUG_MODE) print_token(yytext,OPERATOR, yylineno); yylloc.first_column = yylloc.last_column+1; yylloc.last_column += strlen(yytext); yylval.str= strdup(yytext); return T_LTE;}
">="				                    {if (DEBUG_MODE) print_token(yytext,OPERATOR, yylineno); yylloc.first_column = yylloc.last_column+1; yylloc.last_column += strlen(yytext); yylval.str= strdup(yytext); return T_GTE;}
"&&"				                    {if (DEBUG_MODE) print_token(yytext,OPERATOR, yylineno); yylloc.first_column = yylloc.last_column+1; yylloc.last_column += strlen(yytext); yylval.str= strdup(yytext); return T_AND;}
"||"				                    {if (DEBUG_MODE) print_token(yytext,OPERATOR, yylineno); yylloc.first_column = yylloc.last_column+1; yylloc.last_column += strlen(yytext); yylval.str= strdup(yytext); return T_OR;}
"<<"					                {if (DEBUG_MODE) print_token(yytext,OPERATOR, yylineno); yylloc.first_column = yylloc.last_column+1; yylloc.last_column += strlen(yytext); yylval.str= strdup(yytext); return T_LSHIFT;}
">>"					                {if (DEBUG_MODE) print_token(yytext,OPERATOR, yylineno); yylloc.first_column = yylloc.last_column+1; yylloc.last_column += strlen(yytext); yylval.str= strdup(yytext); return T_RSHIFT;}
"+"                                     {if (DEBUG_MODE) print_token(yytext,OPERATOR, yylineno); yylloc.first_column = yylloc.last_column+1; yylloc.last_column += strlen(yytext); yylval.str= strdup(yytext); return T_PLUS;}
"-"                                     {if (DEBUG_MODE) print_token(yytext,OPERATOR, yylineno); yylloc.first_column = yylloc.last_column+1; yylloc.last_column += strlen(yytext); yylval.str= strdup(yytext); return T_MINUS;}
"/"                                     {if (DEBUG_MODE) print_token(yytext,OPERATOR, yylineno); yylloc.first_column = yylloc.last_column+1; yylloc.last_column += strlen(yytext); yylval.str= strdup(yytext); return T_DIV;}
"*"                                     {if (DEBUG_MODE) print_token(yytext,OPERATOR, yylineno); yylloc.first_column = yylloc.last_column+1; yylloc.last_column += strlen(yytext); yylval.str= strdup(yytext); return T_MUL;}
"%"					                    {if (DEBUG_MODE) print_token(yytext,OPERATOR, yylineno); yylloc.first_column = yylloc.last_column+1; yylloc.last_column += strlen(yytext); yylval.str= strdup(yytext); return T_MOD;}
"<"					                    {if (DEBUG_MODE) print_token(yytext,OPERATOR, yylineno); yylloc.first_column = yylloc.last_column+1; yylloc.last_column += strlen(yytext); yylval.str= strdup(yytext); return T_LT;}
">"					                    {if (DEBUG_MODE) print_token(yytext,OPERATOR, yylineno); yylloc.first_column = yylloc.last_column+1; yylloc.last_column += strlen(yytext); yylval.str= strdup(yytext); return T_GT;}
"="					                    {if (DEBUG_MODE) print_token(yytext,OPERATOR, yylineno); yylloc.first_column = yylloc.last_column+1; yylloc.last_column += strlen(yytext); yylval.str= strdup(yytext); return T_ASSIGN;}
":="                                    {if (DEBUG_MODE) print_token(yytext,OPERATOR, yylineno); yylloc.first_column = yylloc.last_column+1; yylloc.last_column += strlen(yytext); yylval.str= strdup(yytext); return T_WALRUS;}
"!"					                    {if (DEBUG_MODE) print_token(yytext,OPERATOR, yylineno); yylloc.first_column = yylloc.last_column+1; yylloc.last_column += strlen(yytext); yylval.str= strdup(yytext); return T_BNOT;}
"&"					                    {if (DEBUG_MODE) print_token(yytext,OPERATOR, yylineno); yylloc.first_column = yylloc.last_column+1; yylloc.last_column += strlen(yytext); yylval.str= strdup(yytext); return T_BAND;}
"|"					                    {if (DEBUG_MODE) print_token(yytext,OPERATOR, yylineno); yylloc.first_column = yylloc.last_column+1; yylloc.last_column += strlen(yytext); yylval.str= strdup(yytext); return T_BOR;}
"^"					                    {if (DEBUG_MODE) print_token(yytext,OPERATOR, yylineno); yylloc.first_column = yylloc.last_column+1; yylloc.last_column += strlen(yytext); yylval.str= strdup(yytext); return T_BXOR;}


 /* SEPARATORS */

","			            {if (DEBUG_MODE) print_token(yytext,SEPARATOR, yylineno); yylloc.first_column = yylloc.last_column+1; yylloc.last_column += strlen(yytext); yylval.str= strdup(yytext); return T_COMMA;}
";"					    {if (DEBUG_MODE) print_token(yytext,SEPARATOR, yylineno); yylloc.first_column = yylloc.last_column+1; yylloc.last_column += strlen(yytext); yylval.str= strdup(yytext); return T_SEMI;}
":"                     {if (DEBUG_MODE) print_token(yytext,SEPARATOR, yylineno); yylloc.first_column = yylloc.last_column+1; yylloc.last_column += strlen(yytext); yylval.str= strdup(yytext); return T_COLON;}
"("					    {if (DEBUG_MODE) print_token(yytext,SEPARATOR, yylineno); yylloc.first_column = yylloc.last_column+1; yylloc.last_column += strlen(yytext); yylval.str= strdup(yytext); return T_PAREN_OPEN;}
")"					    {if (DEBUG_MODE) print_token(yytext,SEPARATOR, yylineno); yylloc.first_column = yylloc.last_column+1; yylloc.last_column += strlen(yytext); yylval.str= strdup(yytext); return T_PAREN_CLOSE;}
"{"					    {if (DEBUG_MODE) print_token(yytext,SEPARATOR, yylineno); yylloc.first_column = yylloc.last_column+1; yylloc.last_column += strlen(yytext); yylval.str= strdup(yytext); return T_CURLY_OPEN;}
"}"					    {if (DEBUG_MODE) print_token(yytext,SEPARATOR, yylineno); yylloc.first_column = yylloc.last_column+1; yylloc.last_column += strlen(yytext); yylval.str= strdup(yytext); return T_CURLY_CLOSE;}
"["					    {if (DEBUG_MODE) print_token(yytext,SEPARATOR, yylineno); yylloc.first_column = yylloc.last_column+1; yylloc.last_column += strlen(yytext); yylval.str= strdup(yytext); return T_BRACKET_OPEN;}
"]"					    {if (DEBUG_MODE) print_token(yytext,SEPARATOR, yylineno); yylloc.first_column = yylloc.last_column+1; yylloc.last_column += strlen(yytext); yylval.str= strdup(yytext); return T_BRACKET_CLOSE;}
"."					    {if (DEBUG_MODE) print_token(yytext,SEPARATOR, yylineno); yylloc.first_column = yylloc.last_column+1; yylloc.last_column += strlen(yytext); yylval.str= strdup(yytext); return T_DOT;}



 /* LITERALS */
false                   {if (DEBUG_MODE) print_token(yytext,LITERAL, yylineno); yylloc.first_column = yylloc.last_column+1; yylloc.last_column += strlen(yytext); yylval.str= strdup(yytext); return T_FALSE;}
true                    {if (DEBUG_MODE) print_token(yytext,LITERAL, yylineno); yylloc.first_column = yylloc.last_column+1; yylloc.last_column += strlen(yytext); yylval.str= strdup(yytext); return T_TRUE;}
{intNumber}                   {if (DEBUG_MODE) print_token(yytext,LITERAL, yylineno); yylloc.first_column = yylloc.last_column+1; yylloc.last_column += strlen(yytext); yylval.str= strdup(yytext); return T_INTEGER;}
\"([^"\n])*(\n)([^"])*\" {if (DEBUG_MODE) print_token(yytext,LITERAL, yylineno); printf("\033[0;31mERROR at line number : %d\n \033[0;37m Invalid String : \033[0;35m%s\033[0;37m\n Strings cannot contain newlines. \n\n", yylineno, yytext);
                        int found=-1;
                        int first = -1;
                        for(int i =0;i<strlen(yytext);++i)
                        {
                            if(yytext[i]==10)
                            {
                                found =i;
                                if (first==-1)
                                    first = i;
                                ++yylineno;
                            }
                        }
                        yytext[first]='\0';
                        yylloc.first_column = yylloc.last_column+1; yylloc.last_column += strlen(yytext); yylval.str= strdup(yytext); return T_STRING;
                        }
\"[^"]*\"				{if (DEBUG_MODE) print_token(yytext,LITERAL, yylineno); yylloc.first_column = yylloc.last_column+1; yylloc.last_column += strlen(yytext); yylval.str= strdup(yytext); return T_STRING;}
{floatNumber}                 {if (DEBUG_MODE) print_token(yytext,LITERAL, yylineno); yylloc.first_column = yylloc.last_column+1; yylloc.last_column += strlen(yytext); yylval.str= strdup(yytext); return T_FLOAT64;}




{identifier}			{
                            if (DEBUG_MODE) print_token(yytext, IDENTIFIER, yylineno);
                            int identifierLength = strlen(yytext);
                            yylval.str=strdup(yytext); 
                            yylloc.first_column = yylloc.last_column; 
                            yylloc.last_column += strlen(yytext);
                            return T_IDENTIFIER;
                        }


 /* For any other token print error */
.                       {   
                            printf("\033[0;31m");
                            printf("ERROR");
                            printf("\033[0m");
                            printf(" : Unexpected character \033[0;35m%s\033[0m at \033[0;33mline number %d\033[0m, could not classify as any token.\n\n", yytext ,yylineno);
                        }



%%
int yywrap(){
    return 1;
}

void print_token(char* tokenname, char* type, int lineno)
{
    printf("\033[0;33m %d\t \033[0;36m[%s]\t\033[0;35m%s\t \033[0;37m\n", lineno, type, tokenname);
}

void checkclosed()
{
	char c, c1;
loop:
	while ((c = input()) != '*' && c != 0)
    {
        if(c==10)
        {
            ++yylineno;
            yylloc.first_column = 1; yylloc.last_column = 1;
        }
    }
	if ((c1 = input()) != '/' && c != 0)
	{
        if(c1==10)
        {
            ++yylineno;
            yylloc.first_column = 1; yylloc.last_column = 1;
        }
		unput(c1);
        goto loop;
	}
    else if(c==0)
    {
        printf("\033[0;31mERROR at line number : %d\n \033[0;37m Unclosed Comment \033[0;35m\n\n", yylineno);
    }
    else
        return;
}