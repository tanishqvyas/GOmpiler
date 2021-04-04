

body                            :  mainFunctionDefinition
                                |  functionDefinition mainFunctionDefinition
                                ;

mainFunctionDefinition          : T_FUNC T_MAIN T_PAREN_OPEN T_PAREN_CLOSE compoundStatement                 
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
