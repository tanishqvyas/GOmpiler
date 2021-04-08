%{

    #include<stdio.h>
    #include<stdlib.h>
    #include<string.h>
    extern void yyerror(char* s);  /* prints grammar violation message */
    extern int yylex();
    extern FILE *yyin;
    extern FILE *yyout;
    extern int yylineno;
    //extern YYLTYPE yylloc;
    extern char* yytext;
    extern int yyscope;
    /* 0 implies global yyscope */
    int flag=0;
    int valid=1;
    
    struct quad{
        char op[5];
        char arg1[10];
        char arg2[10];
        char result[10];
    }QUAD[100];
    
    struct stack{
        int items[100];
        int top;
    }stk;

    struct switches{
        char switchvalue[100];
        int index;
        int cases;
        int hasdefault;
    }switches[100];
    
    int recentswitch=0,test;
    int Index=0,tIndex=0,StNo,Ind,Ind2,Ind3,tInd;
    char resulttemp[10];
    void AddQuadruple(char op[5],char arg1[10],char arg2[10],char result[10],char lhs[10]);
    void GenerateTemp(char op[5],char arg1[10],char arg2[10],char result[10]);
    void switchCaseGenerate(char arg1[100]);
    void switchFillJumps();
    void repeatUntilGen(char arg1[100]);
    void push(int data);
    int pop();

%}
%locations
%union { char *str; }
%start program

%token T_PACKAGE T_MAIN T_FUNC T_PRINT T_VAR T_RETURN
%token T_BOOL T_FLT64
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
%token T_INT T_STR

%type <str> variableAssignment variableDeclaration strexpressions number expressions arithmeticExpression relationalExpression logicalExpression relationalOperator
%type <str> L M N T F switchValue

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

mainFunctionDefinition          : T_FUNC T_MAIN T_PAREN_OPEN T_PAREN_CLOSE compoundStatement                 
                                ;

functionDefinitions             : functionDefinition
                                | functionDefinitions functionDefinition
                                ;

functionDefinition              : T_FUNC T_IDENTIFIER T_PAREN_OPEN parameterlist T_PAREN_CLOSE returntype compoundStatement
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

compoundStatement               : T_CURLY_OPEN statements T_CURLY_CLOSE
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
                                ;

printStatement                  : T_FMT T_DOT T_PRINT T_PAREN_OPEN T_STRING T_PAREN_CLOSE semi
                                ;

switchStatement                 : T_SWITCH switchValue
                                {
                                    recentswitch++;
                                    switches[recentswitch].index=Index;
                                    sprintf(switches[recentswitch].switchvalue,"%s",$2);
                                }
                                T_CURLY_OPEN switchCaseStatements T_CURLY_CLOSE
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
                                | T_DEFAULT T_COLON statements
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

arithmeticExpression            : arithmeticExpression T_PLUS T
                                {
                                    GenerateTemp("+",$1,$3,$$);
                                }
                                | arithmeticExpression T_MINUS T
                                {
                                    GenerateTemp("-",$1,$3,$$);
                                }
                                | T
                                {
                                    strcpy($$,$1);
                                }
                                ;

T                               : T T_MUL F
                                {
                                    GenerateTemp("*",$1,$3,$$);
                                }
                                | T T_DIV F
                                {
                                    GenerateTemp("/",$1,$3,$$);
                                }
                                | T T_MOD F
                                {
                                    GenerateTemp("%",$1,$3,$$);
                                }
                                | F
                                {
                                    strcpy($$,$1);
                                }
                                ;

F                               : T_PAREN_OPEN arithmeticExpression T_PAREN_CLOSE
                                {
                                    strcpy($$,$2);
                                }
                                | T_IDENTIFIER
                                | number
                                {
                                    strcpy($$,$1);
                                }
                                ;

number                          : T_INTEGER
                                | T_FLOAT64
                                ;

relationalExpression            : arithmeticExpression relationalOperator arithmeticExpression
                                {
                                    GenerateTemp($2,$1,$3,$$);
                                }
                                | T_STRING relationalOperator T_STRING
                                {
                                    GenerateTemp($2,$1,$3,$$);
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

logicalExpression               : T_BNOT L
                                {
                                    GenerateTemp("!",$2,"",$$);
                                }
                                | L
                                {
                                    strcpy($$,$1);
                                }
                                ;

L                               : L T_AND M
                                {
                                    GenerateTemp("AND",$1,$3,$$);
                                }
                                | M
                                {
                                    strcpy($$,$1);
                                }
                                ;
                       
M                               : M T_OR N
                                {
                                    GenerateTemp("OR",$1,$3,$$);
                                }
                                | N
                                {
                                    strcpy($$,$1);
                                }
                                ;

N                               : T_PAREN_OPEN relationalExpression T_PAREN_CLOSE
                                {
                                    strcpy($$,$2);
                                }
                                ;


repeatUntilStatement            : T_REPEAT T_CURLY_OPEN {push(Index);} statements T_CURLY_CLOSE T_UNTIL expressions semi
                                {
                                    repeatUntilGen($7);
                                }
                                | T_REPEAT {push(Index);} statement T_UNTIL expressions semi
                                {
                                    repeatUntilGen($5);
                                }
                                ;

variableDeclaration             : T_VAR T_IDENTIFIER type T_ASSIGN strexpressions semi
                                {
                                    AddQuadruple("=",$5,"",$2,$$);
                                }
                                | T_VAR T_IDENTIFIER type semi
                                {
                                    strcpy($$,"");
                                }
                                | T_VAR T_IDENTIFIER T_ASSIGN strexpressions semi
                                {
                                    AddQuadruple("=",$4,"",$2,$$);
                                }
                                | T_IDENTIFIER T_WALRUS strexpressions semi
                                {
                                    AddQuadruple(":=",$3,"",$1,$$);
                                }
                                ;

arrayDeclaration                : T_VAR T_IDENTIFIER T_BRACKET_OPEN arraylength T_BRACKET_CLOSE type T_CURLY_OPEN arrayvalues T_CURLY_CLOSE semi
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
                                {
                                    strcpy($$,$1);
                                }
                                | expressions
                                {
                                    strcpy($$,$1);
                                }
                                ;

variableAssignment              : T_IDENTIFIER T_ASSIGN strexpressions semi
                                {
                                    AddQuadruple("=",$3,"",$1,$$);
                                }
                                ;

arrayAssignment                 :T_IDENTIFIER T_BRACKET_OPEN arithmeticExpression T_BRACKET_CLOSE T_ASSIGN strexpressions semi
                                ;
%%

extern void yyerror(char* si)
{
    printf("%s\n",si);
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

void AddQuadruple(char op[5],char arg1[10],char arg2[10],char result[10],char lhs[10]){
	strcpy(QUAD[Index].op,op);
	strcpy(QUAD[Index].arg1,arg1);
	strcpy(QUAD[Index].arg2,arg2);
	strcpy(QUAD[Index].result,result);
	strcpy(lhs,QUAD[Index++].result);
}

void GenerateTemp(char op[5],char arg1[10],char arg2[10],char result[10]){
	strcpy(QUAD[Index].op,op);
	strcpy(QUAD[Index].arg1,arg1);
	strcpy(QUAD[Index].arg2,arg2);
	sprintf(QUAD[Index].result,"t%d",tIndex++);
	strcpy(result,QUAD[Index++].result);
}

void switchCaseGenerate(char arg1[10])
{
    switches[recentswitch].cases+=1;
    int temp=Index;
    test=pop();
    if (test!=Index)
    {
        Index=test;
    }
    if(strcmp(switches[recentswitch].switchvalue,"")==0)
    {
        push(Index);
        AddQuadruple("==",arg1,"FALSE","-1",resulttemp);
    }
    else
    {
        char result[100];
        GenerateTemp("==",switches[recentswitch].switchvalue,arg1,result);
        push(Index);
        AddQuadruple("==",result,"FALSE","-1",resulttemp);
    } 
    Index=temp;
}

void switchFillJumps(){
    int FailoverIndex=Index;
    if(switches[recentswitch].hasdefault==1)
    {
        FailoverIndex=pop();
        sprintf(QUAD[FailoverIndex].result,"%d",Index);
    }
    for(int i=0; i<switches[recentswitch].cases;++i)
    {
        Ind=pop();
        sprintf(QUAD[Ind].result,"%d",Index);
        Ind=pop();
        sprintf(QUAD[Ind].result,"%d",FailoverIndex);
        FailoverIndex=Ind;
    }
    --recentswitch;
}

void repeatUntilGen(char arg1[10])
{
    push(Index);
    AddQuadruple("==",arg1,"TRUE","-1",resulttemp);

    push(Index);
    AddQuadruple("GOTO","","","-1",resulttemp);
    
    Ind=pop();
    Ind2=pop();
    Ind3=pop();
    sprintf(QUAD[Ind].result,"%d",Ind3);
    sprintf(QUAD[Ind2].result,"%d",Index);
}

int main(int argc, char * argv[])
{
    yyin=fopen(argv[1],"r");
    yylloc.first_line=yylloc.last_line=1;
    yylloc.first_column=yylloc.last_column=0;
    printf("LINENO \t TYPE      \tTOKENNAME\n");
    yyparse();
    printf("\n\n\t\t -------------------------------------""\n\t\t \033[0;33mPos\033[0;36m Operator\033[0;35m \tArg1 \tArg2\033[0;32m \tResult\033[0;37m" "\n\t\t -------------------------------------");

    for(int i=0;i<Index;i++){
        printf("\n\t\t \033[0;33m%d\033[0;36m\t %s\033[0;35m\t %s\t %s \033[0;32m\t%s\033[0;37m",i,QUAD[i].op,QUAD[i].arg1,QUAD[i].arg2,QUAD[i].result);
    }
    printf("\n");
    if(valid==0)
    {
        printf("Syntax was Invalid!\n");
    }

    fclose(yyin);
    return 0;

}