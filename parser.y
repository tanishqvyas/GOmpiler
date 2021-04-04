%{

    #include<stdio.h>
    #include<stdlib.h>
    extern void yyerror(char* s);  /* prints grammar violation message */
    extern int yylex();
    extern FILE *yyin;
    extern FILE *yyout;
    extern int yylineno;
    // extern YYLTYPE yylloc;
    extern char* yytext;
    int yyscope=0;
    /* 0 implies global yyscope */
    int flag=0;
    int valid=1;

%}


%start program

%token T_PACKAGE T_MAIN T_FUNC T_PRINT T_VAR T_RETURN
%token T_BOOL T_FLT64
%token T_FALLTHROUGH T_DEFAULT T_SWITCH T_CASE T_REPEAT T_UNTIL T_IMPORT T_FMT
%token T_COMMA T_COLON T_PAREN_OPEN T_PAREN_CLOSE T_CURLY_OPEN T_CURLY_CLOSE T_BRACKET_OPEN T_BRACKET_CLOSE T_DOT
%token T_SPLUS T_SMINUS T_SMUL T_SDIV T_SMOD T_SAND T_SOR T_NOTEQ T_COMP T_LTE T_GTE T_AND T_OR T_LSHIFT T_RSHIFT T_PLUS T_MINUS T_DIV T_MUL T_MOD T_LT T_GT T_WALRUS T_BNOT T_BAND T_BOR T_BXOR 


%token T_FALSE T_TRUE
%token T_INTEGER
%token T_STRING T_ASSIGN T_SEMI
%token T_FLOAT64
%token T_IDENTIFIER
%token T_INT T_STR




%%

program                         :  T_PACKAGE T_MAIN imports body 
                                ;

body                            :  mainFunctionDefinition
                                |  functionDefinition mainFunctionDefinition
                                ;

imports                         : import imports
                                ;

import                          : T_IMPORT T_STRING semi
                                | /* EPSILON */
                                ;

functionDefinition              : T_FUNC T_IDENTIFIER T_PAREN_OPEN parameterlist T_PAREN_CLOSE returntype compoundStatement functionDefinition
                                | /* EPSILON */
                                ;

parameterlist                   : parameters
                                | /* EPSILON */
                                ;

parameters                      : parameter
                                | parameters T_COMMA parameter
                                ;

parameter                       : T_IDENTIFIER type
                                ;

returntype                      : type
                                | /* EPSILON */
                                ;


type                            : T_INT    
                                | T_STR    
                                | T_FLT64
                                | T_BOOL 
                                ;

returnStatement                 : T_RETURN expressions semi
                                ;

mainFunctionDefinition          : T_FUNC T_MAIN T_PAREN_OPEN T_PAREN_CLOSE compoundStatement                 
                                ;

compoundStatement               : T_CURLY_OPEN statements T_CURLY_CLOSE
                                ;

statements                      : statement statements
                                | /*EPSILON */
                                ;

statement                       : compoundStatement
                                | printStatement
                                | switchStatement
                                | repeatUntilStatement
                                | returnStatement
                                | variableDeclaration
                                | arrayDeclaration
                                | variableAssignment
                                | arrayAssignment
                                | /*EPSILON */
                                ;

printStatement                  : T_FMT T_DOT T_PRINT T_PAREN_OPEN T_STRING T_PAREN_CLOSE semi
                                ;

switchStatement                 : T_SWITCH switchValue T_CURLY_OPEN switchCaseStatement T_CURLY_CLOSE
                                ;

switchValue                     : T_IDENTIFIER
                                | T_INTEGER
                                | T_FLOAT64
                                | T_STRING
                                | /* EPSILON */ 
                                ;

switchCaseStatement             : T_CASE caseValues T_COLON statements fallthroughStatement
                                | T_DEFAULT T_COLON statements 
                                ;

fallthroughStatement            : T_FALLTHROUGH
                                | /* EPSILON */
                                ;

caseValues                      : caseValue T_COMMA
                                | caseValue
                                | /* EPSILON */
                                ;

caseValue                       : expressions
                                ;

expressions                     : arithmeticExpression
                                | relationalExpression
                                | logicalExpression
                                ;

arithmeticExpression            : arithmeticExpression T_PLUS T
                                | arithmeticExpression T_MINUS T
                                | T
                                ;

T                               : T T_MUL F
                                | T T_DIV F
                                | T T_MOD F
                                | F
                                ;

F                               : T_PAREN_OPEN expressions T_PAREN_CLOSE
                                | expressions
                                | T_IDENTIFIER
                                | number
                                ;

number                          : T_INTEGER
                                | T_FLOAT64
                                ;

relationalExpression            : expressions relationalOperator expressions
                                | T_STRING relationalOperator T_STRING
                                | T_TRUE
                                | T_FALSE
                                ;

relationalOperator              : T_NOTEQ
                                | T_COMP
                                | T_LTE
                                | T_GTE
                                | T_LT
                                | T_GT
                                ;

logicalExpression               : T_BNOT L
                                | L
                                ;

L                               : L T_AND M
                                | M
                                ;
                       
M                               : M T_OR F
                                | F
                                ;

repeatUntilStatement            : T_REPEAT T_CURLY_OPEN statements T_CURLY_CLOSE T_UNTIL untilCondition
                                | T_REPEAT statement T_UNTIL untilCondition
                                ;

untilCondition                  : expressions
                                ;

variableDeclaration             : T_VAR T_IDENTIFIER type T_ASSIGN strexpressions semi
                                | T_VAR T_IDENTIFIER type semi
                                | T_VAR T_IDENTIFIER T_ASSIGN strexpressions semi
                                | T_IDENTIFIER T_WALRUS strexpressions semi
                                ;

arrayDeclaration                : T_VAR T_IDENTIFIER T_BRACKET_OPEN arraylength T_BRACKET_CLOSE type semi
                                | T_VAR T_IDENTIFIER T_BRACKET_OPEN arraylength T_BRACKET_CLOSE type T_CURLY_OPEN arrayvalues T_CURLY_CLOSE semi
                                | T_IDENTIFIER T_WALRUS T_BRACKET_OPEN arraylength T_BRACKET_CLOSE type T_CURLY_OPEN arrayvalues T_CURLY_CLOSE semi
                                ;

                                
arraylength                     : arithmeticExpression
                                ;

arrayvalues                     : value
                                | arrayvalues T_COMMA value 
                                ;

value          	                : T_INTEGER
                                | T_FLOAT64
                                | T_STRING
                                | T_TRUE
                                | T_FALSE
                                ;

strexpressions                  : T_STRING
                                | expressions
                                ;

variableAssignment              : T_IDENTIFIER T_ASSIGN expressions semi
                                ;

arrayAssignment                 :T_IDENTIFIER T_BRACKET_OPEN arithmeticExpression T_BRACKET_CLOSE T_ASSIGN value semi
                                ;

semi                            : T_SEMI
                                | /* EPSILON */
                                ;

%%

extern void yyerror(char* si)
{
    printf("%s\n",si);
    valid=0;
}


int main(int argc, char * argv[])
{
    yyin=fopen(argv[1],"r");
    printf("LINENO \t TYPE      \tTOKENNAME\n");
    yyparse();
    if(valid==0)
    {
        printf("Syntax was Invalid!\n");
    }
    printSymbolTable();
    fclose(yyin);
    return 0;

}