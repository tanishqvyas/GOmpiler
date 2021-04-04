#include <stdio.h>
#include <stdlib.h>
#include "../header.h"

// TEST CONTROL KNOBS
#define TEST_searchSymbol 0
#define TEST_checkDeclared 1

void main()
{
    SymbolTableWrapper* myWrapper = initialize_Wrapper();
    insertSymbolEntry(myWrapper,"santosh",2,2,2,"santy");
    insertSymbolEntry(myWrapper,"tanishq",3,3,3,"tany");
    insertSymbolEntry(myWrapper,"aparna",1,1,1,"appu");
    
    // Print Symbol Table
    printSymbolTable(myWrapper);


    #if TEST_searchSymbol
    SymbolTable* ptr=searchSymbol(myWrapper, 2);
    if(ptr==NULL)
    {
        printf("NOT FOUND\n");
    }
    else
        printf("[%d]\t\t \033[0;36m%s \t\t \033[0;33m%d \t\t \033[0;37m%d\t\t%s\t\t%s\n",ptr->symbolID, ptr->token, ptr->lineNumber, ptr->tokenScope, ptr->type, ptr->value);
    
    #endif
    
    #if TEST_checkDeclared
    printf("%d\n",checkDeclared(myWrapper,"aparna",2));//0
    printf("%d\n",checkDeclared(myWrapper,"aparna",1));//1
    printf("%d\n",checkDeclared(myWrapper,"asesdf",1));//0
    #endif

}



