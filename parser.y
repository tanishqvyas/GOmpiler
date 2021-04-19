%{

    #include<stdio.h>
    #include<stdlib.h>
    #include<string.h>
    #include "symboltable.c"

    extern void yyerror(char* s);  /* prints grammar violation message */
    extern int yylex();
    extern FILE *yyin;
    extern FILE *yyout;
    extern int yylineno;
    //extern YYLTYPE yylloc;
    extern char* yytext;
    extern int functionid;
    int yyscope=0;
    /* 0 implies global yyscope */
    int flag=0;
    int valid=1;
    
    struct quad{
        char op[100];
        char arg1[100];
        char arg2[100];
        char result[100];
    }QUAD[100];
    
    struct stack{
        int items[100];
        int top;
    }stk;

    int labels[100];
    int labelIndex=0;

    struct switches{
        char switchvalue[100];
        int index;
        int cases;
        int hasdefault;
    }switches[100];
    
    int recentswitch=0,test;
    int Index=0,tIndex=0,StNo,Ind,Ind2,Ind3,tInd;
    int tacLines=0;
    char resulttemp[100];
    void AddQuadruple(char op[100],char arg1[100],char arg2[100],char result[100],char lhs[100]);
    void GenerateTemp(char op[100],char arg1[100],char arg2[100],char result[100]);
    void switchCaseGenerate(char arg1[100]);
    void switchFillJumps();
    void repeatUntilGen(char arg1[100]);
    void push(int data);
    int pop();
    void createLabel();
    char doldol[100];
    int paramscount;
    
%}
%locations
%union { char *str;  }
%start program

%token T_PACKAGE T_MAIN T_FUNC T_PRINT T_VAR T_RETURN

%token T_FALLTHROUGH T_DEFAULT T_SWITCH T_CASE T_REPEAT T_UNTIL T_IMPORT T_FMT
%token T_COMMA T_COLON T_PAREN_OPEN T_PAREN_CLOSE T_CURLY_OPEN T_CURLY_CLOSE T_BRACKET_OPEN T_BRACKET_CLOSE T_DOT
%token T_SPLUS T_SMINUS T_SMUL T_SDIV T_SMOD T_SAND T_SOR  T_LSHIFT T_RSHIFT T_PLUS T_MINUS T_DIV T_MUL T_MOD T_WALRUS  T_BAND T_BOR T_BXOR 


%token <str> T_FALSE T_TRUE
%token <str> T_INTEGER
%token <str> T_STRING 
%token T_ASSIGN T_SEMI
%token <str> T_FLOAT64
%token <str> T_IDENTIFIER
%token <str> T_NOTEQ T_COMP T_LTE T_GTE T_AND T_OR T_BNOT T_LT T_GT
%token <str> T_INT T_STR T_BOOL T_FLT64

%type <str> strexpressions number expressions arithmeticExpression relationalExpression logicalExpression relationalOperator
%type <str> L M N T F switchValue type value arrayvalues parameter parameterlist parameters returntype funccall argslist arg args

%%

program                         : T_PACKAGE T_MAIN imports body
                                ;

imports                         : import
                                | import imports
                                ;

import                          : T_IMPORT importname
                                | T_IMPORT T_PAREN_OPEN importnames T_PAREN_CLOSE
                                | T_IMPORT T_PAREN_OPEN importnames 
                                | T_IMPORT importnames T_PAREN_CLOSE 
                                ;

importnames                     : importname
                                | importname importnames
                                ;

importname                      :T_STRING
                                ;

semi                            : T_SEMI
                                | /* EPSILON */
                                ;

body                            :  mainFunctionDefinition
                                |  functionDefinitions mainFunctionDefinition
                                ;


mainFunctionDefinition          : T_FUNC T_MAIN {++functionid;functions[functionid].symbolCount=0;AddQuadruple("func","begin","main","",resulttemp);} T_PAREN_OPEN T_PAREN_CLOSE
                                {
                                    functions[functionid].funcid=functionid;
                                    strcpy(functions[functionid].name,"main");
                                    strcpy(functions[functionid].params,"");
                                    strcpy(functions[functionid].returntype,"");
                                }
                                compoundStatement
                                {
                                    AddQuadruple("func","end","main","",resulttemp);
                                }               
                                ;

functionDefinitions             : functionDefinition
                                | functionDefinitions functionDefinition
                                ;

functionDefinition              : T_FUNC T_IDENTIFIER {++functionid;functions[functionid].symbolCount=0;AddQuadruple("func","begin",$2,"",resulttemp);} T_PAREN_OPEN parameterlist T_PAREN_CLOSE returntype 
                                {
                                    functions[functionid].funcid=functionid;
                                    strcpy(functions[functionid].name,$2);
                                    strcpy(functions[functionid].params,$5);
                                    strcpy(functions[functionid].returntype,$7);

                                }
                                compoundStatement
                                {
                                    AddQuadruple("func","end",$2,"",resulttemp);
                                }
                                ;

parameterlist                   : parameters
                                { strcpy($$,$1); }
                                | {strcpy($$,"");}
                                ;

parameters                      : parameter
                                {
                                    strcpy($$,$1);
                                }
                                | parameters T_COMMA parameter
                                {
                                    char temp[100];
                                    strcpy(temp,",");
                                    strcat(temp,$3);
                                    strcat($$,temp);
                                }
                                ;

parameter                       : T_IDENTIFIER type
                                {
                                    AddQuadruple("Reparam",$1,"","",resulttemp);
                                    int foundIndex = checkDeclared(yyscope+1,$1);
                                    if(foundIndex == -1)
                                    {
                                        insertSymbolEntry($1, yylineno, @1.first_column, yyscope+1, $2,"",findSize($2));
                                    }
                                    else
                                    {
                                        printf("\033[0;31mError at line number %d\n\033[0;30m \033[0;36m%s\033[0;30m Redeclared in this block.\n\n", yylineno, $1);
                                        valid=0;
                                    }
                                    strcpy($$,$1);
                                    strcat($$," ");
                                    strcat($$,$2);
                                }
                                ;

returntype                      : type {strcpy($$,$1);}
                                | {strcpy($$,"");}
                                ;

type                            : T_INT    
                                | T_STR    
                                | T_FLT64
                                | T_BOOL 
                                ;

returnStatement                 : T_RETURN {strcpy(doldol,"");} expressions semi
                                {
                                    AddQuadruple("return",doldol,"","",resulttemp);
                                }
                                ;

compoundStatement               : T_CURLY_OPEN{++yyscope;} statements {--yyscope;}T_CURLY_CLOSE
                                ;


statements                      : statement statements
                                | /*EPSILON */
                                ;

statement                       : printStatement
                                | returnStatement
                                | variableDeclaration
                                | arrayDeclaration 
                                | variableAssignment
                                | arrayAssignment
                                | switchStatement
                                | repeatUntilStatement
                                | funccall
                                ;

printStatement                  : T_FMT T_DOT T_PRINT T_PAREN_OPEN T_STRING T_PAREN_CLOSE semi
                                ;

switchStatement                 : T_SWITCH switchValue
                                {
                                    recentswitch++;
                                    switches[recentswitch].index=Index;
                                    sprintf(switches[recentswitch].switchvalue,"%s",$2);
                                }
                                T_CURLY_OPEN {++yyscope;} switchCaseStatements {--yyscope;}T_CURLY_CLOSE
                                {
                                    switchFillJumps();
                                }
                                | T_SWITCH T_PAREN_OPEN switchValue T_PAREN_CLOSE
                                {
                                    recentswitch++;
                                    switches[recentswitch].index=Index;
                                    sprintf(switches[recentswitch].switchvalue,"%s",$3);
                                }
                                T_CURLY_OPEN {++yyscope;} switchCaseStatements {--yyscope;}T_CURLY_CLOSE
                                {
                                    switchFillJumps();
                                }
                                ;

switchValue                     : T_IDENTIFIER
                                | T_INTEGER
                                | T_FLOAT64
                                | T_STRING
                                |{strcpy($$,"");}
                                ;

switchCaseStatements            : switchCaseStatement
                                | switchCaseStatements switchCaseStatement
                                ;

switchCaseStatement             :T_CASE
                                {
                                    push(Index);
                                    createLabel();
                                } 
                                expressions T_COLON
                                {
                                    switchCaseGenerate($3);
                                }
                                statements
                                {
                                    push(Index);
                                    AddQuadruple("GOTO","","","-1",resulttemp);
                                } 
                                fallthroughStatement
                                | T_DEFAULT {push(Index);createLabel();}T_COLON statements
                                {
                                    switches[recentswitch].hasdefault=1;
                                    push(Index);
                                    AddQuadruple("GOTO","","","-1",resulttemp);
                                } 
                                ;

fallthroughStatement            : T_FALLTHROUGH
                                | /* EPSILON */
                                ;

expressions                     : arithmeticExpression
                                {
                                    strcpy($$,$1);
                                }
                                | relationalExpression
                                {
                                    strcpy($$,$1);
                                }
                                | logicalExpression
                                {
                                    strcpy($$,$1);
                                }
                                ;

arithmeticExpression            : arithmeticExpression {strcat(doldol,"+");}T_PLUS T
                                {
                                    GenerateTemp("+",$1,$4,$$);
                                }
                                | arithmeticExpression {strcat(doldol,"-");} T_MINUS T
                                {
                                    GenerateTemp("-",$1,$4,$$);
                                }
                                | T
                                {
                                    strcpy($$,$1);
                                }
                                ;

T                               : T {strcat(doldol,"*");} T_MUL F
                                {
                                    GenerateTemp("*",$1,$4,$$);
                                }
                                | T {strcat(doldol,"/");} T_DIV F
                                {
                                    GenerateTemp("/",$1,$4,$$);
                                }
                                | T  {strcat(doldol,"%");} T_MOD F
                                {
                                    GenerateTemp("%",$1,$4,$$);
                                }
                                | F
                                {
                                    strcpy($$,$1);
                                }
                                ;

F                               : T_PAREN_OPEN {strcat(doldol,"(");} arithmeticExpression {strcat(doldol,")");}T_PAREN_CLOSE
                                {
                                    strcpy($$,$3);
                                }
                                | T_IDENTIFIER
                                {
                                    int foundIndex = searchSymbol(yyscope, $1);
                                    if(foundIndex == -1)
                                    {
                                        printf("\033[0;31mError at line number %d\n\033[0;30m ReferenceError : assignment to undeclared variable \033[0;35m%s\033[0;30m\n\n", yylineno, $1);
                                        valid=0;
                                    }
                                    else
                                    {
                                        strcat(doldol,$1);
                                    }
                                }
                                | T_IDENTIFIER T_BRACKET_OPEN{strcat(doldol,$1);strcat(doldol,"[");} arithmeticExpression {strcat(doldol,"]");} T_BRACKET_CLOSE
                                {
                                    
                                    int foundIndex = searchSymbol(yyscope, $1);
                                    if(foundIndex == -1)
                                    {
                                        printf("\033[0;31mError at line number %d\n\033[0;30m ReferenceError : assignment to undeclared variable \033[0;35m%s\033[0;30m\n\n", yylineno, $1);
                                        valid=0;
                                    }
                                    else
                                    {
                                        GenerateTemp("*",findSize(SymbolTable[functionid][foundIndex].type),$4,resulttemp);
                                        GenerateTemp("=[]",$1,resulttemp,$$);
                                    }
                                }
                                | number
                                {
                                    strcat(doldol,$1);
                                    strcpy($$,$1);
                                }
                                ;

number                          : T_INTEGER
                                | T_FLOAT64
                                ;

relationalExpression            : arithmeticExpression relationalOperator {strcat(doldol,$2);} arithmeticExpression
                                {
                                    GenerateTemp($2,$1,$4,$$);
                                }
                                | T_STRING {strcat(doldol,$1);} relationalOperator {strcat(doldol,$3);} T_STRING
                                {
                                    strcat(doldol,$5);
                                    GenerateTemp($3,$1,$5,$$);
                                }
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

logicalExpression               : T_BNOT {strcat(doldol,$1);} L
                                {
                                    GenerateTemp("!",$3,"",$$);
                                }
                                | L
                                {
                                    strcpy($$,$1);
                                }
                                ;

L                               : L T_AND {strcat(doldol,$2);} M
                                {
                                    GenerateTemp("AND",$1,$4,$$);
                                }
                                | M
                                {
                                    strcpy($$,$1);
                                }
                                ;
                       
M                               : M T_OR {strcat(doldol,$2);} N
                                {
                                    GenerateTemp("OR",$1,$4,$$);
                                }
                                | N
                                {
                                    strcpy($$,$1);
                                }
                                ;

N                               : T_PAREN_OPEN relationalExpression T_PAREN_CLOSE
                                {
                                    strcpy($$,$2);
                                    strcat(doldol,")");
                                }
                                ;


repeatUntilStatement            : T_REPEAT T_CURLY_OPEN { ++yyscope;push(Index);createLabel();} statements {--yyscope;}T_CURLY_CLOSE T_UNTIL expressions semi
                                {
                                    repeatUntilGen($8);
                                }
                                | T_REPEAT {++yyscope;push(Index);createLabel(); } statement {--yyscope;}T_UNTIL expressions semi
                                {
                                    repeatUntilGen($6);
                                }
                                ;

variableDeclaration             : T_VAR T_IDENTIFIER type T_ASSIGN {strcpy(doldol,"");} strexpressions semi
                                {
                                    AddQuadruple("=",$6,"",$2,resulttemp);

                                    int foundIndex = checkDeclared(yyscope,$2);
                                    if(foundIndex == -1)
                                    {
                                        char* curType = DetermineType(doldol);
                                        if(strcmp(curType, $3) == 0 || strcmp(curType,"expr")==0)
                                        {
                                            insertSymbolEntry($2 , yylineno, @2.first_column, yyscope, $3, doldol,findSize($3));   
                                        }
                                        else if(strcmp($3,"float64")==0 && strcmp(curType,"int")==0)
                                        {
                                            insertSymbolEntry($2 , yylineno, @2.first_column, yyscope, "float", doldol,findSize("float"));
                                        } 
                                        else
                                        {
                                            printf("\033[0;31mError at line number %d\n\033[0;30m Cannot use %s (type untyped %s) as type %s in assignment\n\n", yylineno, doldol, curType, $3);
                                            valid=0;
                                        }
                                    }

                                    else
                                    {
                                        printf("\033[0;31mError at line number %d\n\033[0;30m \033[0;36m%s\033[0;30m Redeclared in this block.\n\n", yylineno, $2);
                                        valid=0;
                                    }
                                }
                                | T_VAR T_IDENTIFIER type semi
                                {
                                    int foundIndex = checkDeclared(yyscope,$2);
                                    if(foundIndex == -1)
                                    {
                                        insertSymbolEntry($2 , yylineno, @2.first_column, yyscope, $3, "",findSize($3));   
                                    }

                                    else
                                    {
                                        printf("\033[0;31mError at line number %d\n\033[0;30m \033[0;36m%s\033[0;30m Redeclared in this block.\n\n", yylineno, $2);
                                        valid=0;
                                    }
                                }
                                | T_VAR T_IDENTIFIER T_ASSIGN {strcpy(doldol,"");} strexpressions semi
                                {
                                    AddQuadruple("=",$5,"",$2,resulttemp);

                                    int foundIndex = checkDeclared(yyscope, $2);
                           
                                    if(foundIndex == -1)
                                    {
                                        char* curType = DetermineType(doldol);
                                        if(strcmp(curType,"expr")==0)
                                        {
                                           strcpy( curType,"expr");
                                        }
                                        insertSymbolEntry($2 , yylineno, @2.first_column, yyscope, curType, doldol, findSize(curType));
                                           
                                    }
                                    else
                                    {
                                        printf("\033[0;31mError at line number %d\n\033[0;30m \033[0;36m%s\033[0;30m Redeclared in this block.\n\n", yylineno, $2);
                                        valid=0;
                                    }
                                }
                                | T_IDENTIFIER T_WALRUS {strcpy(doldol,"");} strexpressions semi
                                {
                                    AddQuadruple("=",$4,"",$1,resulttemp);

                                    int foundIndex = checkDeclared(yyscope, $1);
                           
                                    if(foundIndex == -1)
                                    {
                                        char* curType = DetermineType(doldol);
                                        if(strcmp(curType,"expr")==0)
                                        {
                                           strcpy( curType,"expr");
                                        }
                                        insertSymbolEntry($1 , yylineno, @1.first_column, yyscope, curType, doldol, findSize(curType));
                                    }
                                    else
                                    {
                                        printf("\033[0;31mError at line number %d\n\033[0;30m \033[0;36m%s\033[0;30m Redeclared in this block.\n\n", yylineno, $1);
                                        valid=0;
                                    }
                                }
                                ;

arrayDeclaration                : T_VAR T_IDENTIFIER T_BRACKET_OPEN {strcpy(doldol,"");} arraylength T_BRACKET_CLOSE type T_CURLY_OPEN arrayvalues T_CURLY_CLOSE semi
                                {
                                    char arrayvalues[100];
                                    strcpy(arrayvalues,"{");
                                    strcat(arrayvalues,$9);
                                    strcat(arrayvalues,"}");
                                    AddQuadruple("=",arrayvalues,"",$2,resulttemp);

                                    int foundIndex = checkDeclared(yyscope, $2);
                                    if(foundIndex != -1)
                                    {
                                        printf("\033[0;31mError at line number %d\n\033[0;30m \033[0;36m%s\033[0;30m Redeclared in this block.\n\n", yylineno, $2);
                                        valid=0;
                                    }

                                    else
                                    {
                                        char temp[100];
                                        strcpy(temp,$9);
                                        int istypeOK = checkArrayValType(temp,$7);
                                        if(istypeOK)
                                        {
                                            char size[100];
                                            sprintf(size, "%d", atoi(doldol)*atoi(findSize($7)));
                                            insertSymbolEntry($2 , yylineno, @2.first_column, yyscope, $7, $9,size);  
                                        }
                                        else 
                                        {
                                            printf("\033[0;31mError at line number %d\n\033[0;30m \033[0;36m%s\033[0;30m array value(s) do not match array type.\n\n", yylineno, $9);
                                            valid=0;
                                        }
                                    }
                                }
                                | T_IDENTIFIER T_WALRUS T_BRACKET_OPEN {strcpy(doldol,"");} arraylength T_BRACKET_CLOSE type T_CURLY_OPEN arrayvalues T_CURLY_CLOSE semi
                                {
                                    char temp[100];
                                    strcpy(temp,$9);
                                    char arrayvalues[100];
                                    strcpy(arrayvalues,"{");
                                    strcat(arrayvalues,$9);
                                    strcat(arrayvalues,"}");
                                    AddQuadruple("=",arrayvalues,"",$1,resulttemp);

                                    int foundIndex = checkDeclared(yyscope, $1);
                                    if(foundIndex != -1)
                                    {
                                        printf("\033[0;31mError at line number %d\n\033[0;30m \033[0;36m%s\033[0;30m Redeclared in this block.\n\n", yylineno, $1);
                                        valid=0;
                                    }

                                    else
                                    {
                                        
                                        int istypeOK = checkArrayValType(temp,$7);
                                        
                                        if(istypeOK)
                                        {
                                            char size[100];
                                            sprintf(size, "%d", atoi(doldol)*atoi(findSize($7)));
                                            insertSymbolEntry($1 , yylineno, @1.first_column, yyscope, $7, $9,size);  
                                        }
                                        else 
                                        {
                                            printf("\033[0;31mError at line number %d\n\033[0;30m \033[0;36m%s\033[0;30m array value(s) do not match array type.\n\n", yylineno, $9);
                                            valid=0;
                                        }
                                    }

                                }
                                ;
 
arraylength                     : arithmeticExpression
                                ;

arrayvalues                     : value
                                {
                                    strcpy($$,$1);
                                }
                                | arrayvalues T_COMMA value
                                {
                                    char temp[100];
                                    strcpy(temp,",");
                                    strcat(temp,$3);
                                    strcat($$,temp);
                                } 
                                ;

value          	                : T_INTEGER
                                | T_FLOAT64
                                | T_STRING
                                | T_TRUE
                                | T_FALSE
                                ;

strexpressions                  : T_STRING
                                {
                                    strcat(doldol,$1);
                                    strcpy($$,$1);
                                }
                                | expressions
                                {
                                    strcpy($$,$1);
                                }
                                | funccall
                                {
                                    strcpy($$,$1);
                                }
                                ;

variableAssignment              : T_IDENTIFIER T_ASSIGN {strcpy(doldol,"");} strexpressions semi
                                {
                                    AddQuadruple("=",$4,"",$1,resulttemp);

                                    int foundIndex = searchSymbol(yyscope, $1);
                           
                                    if(foundIndex == -1)
                                    {
                                        printf("\033[0;31mError at line number %d\n\033[0;30m ReferenceError : assignment to undeclared variable \033[0;35m%s\033[0;30m\n\n", yylineno, $1);
                                        valid=0;
                                    }
                                    else
                                    {
                                        char* curType = DetermineType(doldol);

                                        if(strcmp(SymbolTable[functionid][foundIndex].type, curType) == 0 || strcmp(curType,"expr")==0 || strcmp(SymbolTable[functionid][foundIndex].type,"float64")==0 && strcmp(curType,"int")==0)
                                        {
                                            updateSymbolEntry($1, yylineno, @1.first_column, yyscope, SymbolTable[functionid][foundIndex].type, doldol);
                                        }
                                        else if(strcmp(SymbolTable[functionid][foundIndex].type,"expr")==0)
                                        {
                                            updateSymbolEntry($1, yylineno, @1.first_column, yyscope, curType, doldol);
                                        }
                                        else
                                        {
                                            printf("\033[0;31mError at line number %d\n\033[0;30m Cannot use %s (type untyped %s) as type %s in assignment\n\n", yylineno, doldol, curType, SymbolTable[functionid][foundIndex].type);
                                            valid=0;
                                        }
                                    }
                                }
                                ;

arrayAssignment                 : T_IDENTIFIER T_BRACKET_OPEN arithmeticExpression T_BRACKET_CLOSE T_ASSIGN {strcpy(doldol,"");} strexpressions semi
                                {
                                    int foundIndex = searchSymbol(yyscope, $1);
                                    if(foundIndex == -1)
                                    {
                                        printf("\033[0;31mError at line number %d\n\033[0;30m ReferenceError : assignment to undeclared variable \033[0;35m%s\033[0;30m\n\n", yylineno, $1);
                                        valid=0;
                                    }
                                    else
                                    {
                                        
                                        GenerateTemp("*",findSize(SymbolTable[functionid][foundIndex].type),$3,resulttemp);
                                        AddQuadruple("[]=",resulttemp,doldol,$1,resulttemp);
                   
                                        char* curType =  DetermineType($7);

                                        if(strcmp(curType, SymbolTable[functionid][foundIndex].type) != 0)
                                        {
                                            printf("\033[0;31mError at line number %d\n\033[0;30m Type Mismatch \033[0;35m%s\033[0;30m\n\n", yylineno, $1);   
                                            valid=0;
                                        }
                                    }
                                }
                                ;

funccall                        : T_IDENTIFIER {paramscount=0;} T_PAREN_OPEN argslist T_PAREN_CLOSE
                                {

                                    int foundIndex = searchFunction($1);
                                    strcpy(doldol,$1);
                                    if(foundIndex == -1)
                                    {
                                        printf("\033[0;31mError at line number %d\n\033[0;30m ReferenceError : access to undefined function \033[0;35m%s\033[0;30m\n\n", yylineno, $1);
                                        valid=0;
                                    }
                                    
                                    char temp[100];
                                    sprintf(temp,"%d",paramscount);
                                    GenerateTemp("call",$1,temp,resulttemp);
                                    
                                    strcpy($$,resulttemp);
                                    
                                    strcat(doldol,"(");
                                    strcat(doldol,$4);
                                    strcat(doldol,")");
                                }
                                ;

argslist                        : args
                                { 
                                    strcpy($$,$1);
                                }
                                | {strcpy($$,"");}
                                ;

args                            : arg
                                {
                                    strcpy($$,$1);
                                }
                                | args T_COMMA arg
                                {
                                    char temp[100];
                                    strcpy(temp,",");
                                    strcat(temp,$3);
                                    strcat($$,temp);
                                }
                                ;

arg                             : T_IDENTIFIER
                                {
                                    ++paramscount;
                                    AddQuadruple("param",$1,"","",resulttemp);
                                    int foundIndex = searchSymbol(yyscope,$1);
                                    if(foundIndex == -1)
                                    {
                                        printf("\033[0;31mError at line number %d\n\033[0;30m ReferenceError : access to undeclared variable \033[0;35m%s\033[0;30m\n\n", yylineno, $1);
                                        valid=0;
                                    }
                                    strcpy($$,$1);
                                }
                                | value
                                {
                                    ++paramscount;
                                    AddQuadruple("param",$1,"","",resulttemp);
                                    strcpy($$,$1);
                                }
                                ;

%%

extern void yyerror(char* si)
{
    printf("%s at line number %d\n",si,yylineno);
    valid=0;
}

void push(int data)
{ 
	stk.top++;

	if(stk.top==100)
    {
		printf("\n Stack overflow\n");
		exit(0);
	}

	stk.items[stk.top]=data;
}

int pop()
{
	int data;

	if(stk.top==-1)
    {
		printf("\n Stack underflow\n");
		exit(0);
	}

	data=stk.items[stk.top--];
	return data;
}


void createLabel()
{
    labels[labelIndex]=Index;
    strcpy(QUAD[Index].op,"label");
	strcpy(QUAD[Index].arg1,"");
	strcpy(QUAD[Index].arg2,"");
	sprintf(QUAD[Index++].result,"L%d",labelIndex++);
}

void AddQuadruple(char op[100],char arg1[100],char arg2[100],char result[100],char lhs[100]){
	strcpy(QUAD[Index].op,op);
	strcpy(QUAD[Index].arg1,arg1);
	strcpy(QUAD[Index].arg2,arg2);
	strcpy(QUAD[Index].result,result);
	strcpy(lhs,QUAD[Index++].result);
}

void GenerateTemp(char op[100],char arg1[100],char arg2[100],char result[100]){
	strcpy(QUAD[Index].op,op);
	strcpy(QUAD[Index].arg1,arg1);
	strcpy(QUAD[Index].arg2,arg2);
	sprintf(QUAD[Index].result,"t%d",tIndex++);
	strcpy(result,QUAD[Index++].result);
}

void switchCaseGenerate(char arg1[100])
{
    switches[recentswitch].cases+=1;
    if(strcmp(switches[recentswitch].switchvalue,"")==0)
    {
        push(Index);
        AddQuadruple("if",arg1,"TRUE","-1",resulttemp);
    }
    else
    {
        char result[100];
        GenerateTemp("==",switches[recentswitch].switchvalue,arg1,result);
        push(Index);
        AddQuadruple("if",result,"TRUE","-1",resulttemp);
    }
    push(Index);
    AddQuadruple("GOTO","","","-1",resulttemp);
    push(Index);
    createLabel();
}

void switchFillJumps(){
    int afterstmts,label,iffail,ifpass,caselabel;
    int FailoverIndex=Index;
    createLabel();
    if(switches[recentswitch].hasdefault==1)
    {
        FailoverIndex=pop();
        strcpy(QUAD[FailoverIndex].result,QUAD[Index-1].result);
        FailoverIndex=pop();
    }
    for(int i=0; i<switches[recentswitch].cases;++i)
    {
        afterstmts=pop();
        label=pop();
        iffail=pop();
        ifpass=pop();
        caselabel=pop();

        strcpy(QUAD[afterstmts].result,QUAD[Index-1].result);
        strcpy(QUAD[iffail].result,QUAD[FailoverIndex].result);
        strcpy(QUAD[ifpass].result,QUAD[label].result);
        FailoverIndex=caselabel;
    }
    strcpy(switches[recentswitch].switchvalue,"");
    switches[recentswitch].index=0;
    switches[recentswitch].cases=0;
    switches[recentswitch].hasdefault=0;
    --recentswitch;

}

void repeatUntilGen(char arg1[100])
{
    push(Index);
    AddQuadruple("if",arg1,"TRUE","-1",resulttemp);

    
    push(Index);
    AddQuadruple("GOTO","","","-1",resulttemp);
    createLabel(); //out of loop label

    Ind=pop();  //goto
    Ind2=pop(); //IF
    Ind3=pop(); //repeat Label
    strcpy(QUAD[Ind].result,QUAD[Index -1].result);
    strcpy(QUAD[Ind2].result,QUAD[Ind3].result);
}




int main(int argc, char * argv[])
{
    yyin=fopen(argv[1],"r");
    yylloc.first_line=yylloc.last_line=1;
    yylloc.first_column=yylloc.last_column=0;
    printf("LINENO \t TYPE      \tTOKENNAME\n");
    int accepted=yyparse();
    if(accepted==0 && valid!=0){

        printSymbolTable();

        printf("\n\n\t\t -------------------------------------""\n\t\t \033[0;33mPos\033[0;36m Operator\033[0;35m \tArg1 \tArg2\033[0;32m \tResult\033[0;30m" "\n\t\t -------------------------------------");

        FILE *out=fopen("quad.txt","w");
        for(int i=0;i<Index;i++){
            printf("\n\t\t \033[0;33m%d\033[0;36m\t %s\033[0;35m\t %s\t %s \033[0;32m\t%s\033[0;30m",i,QUAD[i].op,QUAD[i].arg1,QUAD[i].arg2,QUAD[i].result);
            fprintf(out, "%s %s %s %s\n",QUAD[i].op, QUAD[i].arg1, QUAD[i].arg2, QUAD[i].result);
        }

        fclose(out);
        printf("\n");

        for(int i=0;i<Index;i++){
            if(strcmp(QUAD[i].op,"label")==0){
                printf("\n\t\t %s:",QUAD[i].result);
            }
            else if(strcmp(QUAD[i].op,"if")==0){
                printf("\n\t\t %s %s == %s GOTO %s",QUAD[i].op,QUAD[i].arg1,QUAD[i].arg2,QUAD[i].result);
            }
            else if(strcmp(QUAD[i].op,"GOTO")==0){
                printf("\n\t\t %s %s",QUAD[i].op, QUAD[i].result);
            }
            else if(strcmp(QUAD[i].op,"=")==0 || strcmp(QUAD[i].op,":=")==0){
                printf("\n\t\t %s %s %s",QUAD[i].result, QUAD[i].op,QUAD[i].arg1 );
            }
            else if(strcmp(QUAD[i].op,"[]=")==0){
                printf("\n\t\t %s[%s] = %s",QUAD[i].result,QUAD[i].arg1,QUAD[i].arg2);
            }
            else if(strcmp(QUAD[i].op,"=[]")==0){
                printf("\n\t\t %s = %s[%s]",QUAD[i].result,QUAD[i].arg1,QUAD[i].arg2);
            }
            else if(strcmp(QUAD[i].op,"func")==0){
                printf("\n\t\t %s %s %s",QUAD[i].op,QUAD[i].arg1,QUAD[i].arg2);
            }
            else if(strcmp(QUAD[i].op,"Reparam")==0 || strcmp(QUAD[i].op,"param")==0 ){
                printf("\n\t\t %s %s",QUAD[i].op,QUAD[i].arg1);
            }
            else if(strcmp(QUAD[i].op,"call")==0 || strcmp(QUAD[i].op,"param")==0 ){
                printf("\n\t\t %s = %s %s , %s",QUAD[i].result,QUAD[i].op,QUAD[i].arg1,QUAD[i].arg2);
            }
            else if(strcmp(QUAD[i].op,"return")==0 ){
                printf("\n\t\t %s %s",QUAD[i].op,QUAD[i].arg1);
            }
            else{
            printf("\n\t\t %s = %s %s %s",QUAD[i].result,QUAD[i].arg1,QUAD[i].op,QUAD[i].arg2);
            }
        }
        printf("\n");
	    
        
    }

    else
    {
        printf("\n\n\033[0;31mSyntax is Invalid, Cannot generate Three Address Code.\033[0;30m\n\n");

    }
    fclose(yyin);
    return 0;

}