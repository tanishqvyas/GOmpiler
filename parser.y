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

program                         :  body YYACCEPT
                                ;

body                            : T_PACKAGE T_MAIN imports mainFunctionDefinition
                                ;

imports                         : import imports
                                ;

import                          : T_IMPORT T_STRING semi
                                | /* EPSILON */
                                ;

mainFunctionDefinition          : T_FUNC T_MAIN T_PAREN_OPEN T_PAREN_CLOSE  T_CURLY_OPEN statements T_CURLY_CLOSE                  
                                ;

statements                      : statement statements
                                | statement statements
                                | statement statements
                                | statement statements
                                | /*EPSILON */
                                ;

statement                       : printStatement
                                | switchStatement
                                | repeatUntilStatement
                                | returnStatement
                                | declareStatement
                                | /*EPSILON */
                                ;

printStatement                  : T_FMT T_DOT T_PRINT T_PAREN_OPEN T_STRING T_PAREN_CLOSE semi
                                ;

switchStatement                 : T_SWITCH  switchValue T_CURLY_OPEN switchCaseStatement T_CURLY_CLOSE
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


repeatUntilStatement            : T_REPEAT T_CURLY_OPEN statements T_CURLY_CLOSE T_UNTIL untilCondition
                                | T_REPEAT statement T_UNTIL untilCondition
                                ;

untilCondition                  : T_TRUE
                                | T_FALSE
                                | T_IDENTIFIER
                                | T_PAREN_OPEN expressionWithoutStr T_PAREN_CLOSE
                                ;

expressionWithoutStr            : T_FALSE
                                | T_TRUE
                                | T_IDENTIFIER
                                | T_INTEGER
                                | T_FLOAT64
                                | expressionGrammar
                                ;

expression                      : T_FALSE
                                | T_TRUE
                                | T_IDENTIFIER
                                | T_INTEGER
                                | T_FLOAT64
                                | T_STRING
                                | expressionGrammar
                                ;

expressionGrammar               // TODO


declareStatement                : T_VAR T_IDENTIFIER type T_ASSIGN expression semi
                                | T_VAR T_IDENTIFIER type semi
                                | T_VAR T_IDENTIFIER T_ASSIGN expression semi
                                | T_IDENTIFIER T_WALRUS expression semi
                                ;

initializationStatement         : T_IDENTIFIER T_ASSIGN expression semi
                                ;


arithmeticOperator              : T_XOR
                                | T_DIV
                                | T_MOD
                                | T_MUL
                                | T_ADD
                                | T_MINUS
                                ;

relationalOperator              : T_LT 
                                | T_GT 
                                | T_COMP 
                                | T_NOTEQ 
                                | T_LTE 
                                | T_GTE 
                                | T_PLUS 
                                | T_MINUS 
                                | T_DIV 
                                | T_MUL
                                | T_MOD 
                                ;


returnStatement                 : T_RETURN returnValues
                                ;

returnValues                    : T_TRUE
                                | T_FALSE
                                | T_IDENTIFIER
                                | T_STRING
                                | T_FLOAT64
                                | T_INTEGER
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