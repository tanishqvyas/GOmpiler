#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define DEBUG_MODE 1

extern int yylineno;
int functionid=0;


struct functions
{
    int funcid;
    char name[100];
    char returntype[100];
    char params[100];
    int symbolCount;
}functions[100];

struct SymbolTable
{
    int symbolID;
    char token[100];
    int lineNumber;
    int startColumn;
    int tokenScope;
    char type[100];
    //char paratype[100];
    char value[100];
    char length[100];

} SymbolTable[100][400];

char* findSize(char type[100])
{
    
    if(strcmp(type,"int") == 0)
    {
        return "4";
    }
    else if(strcmp(type,"float64") == 0)
    {
        return "8";
    }
    else if(strcmp(type,"string") == 0)
    {
        return "";
    }
    else if(strcmp(type,"bool") == 0)
    {
        return "1";
    }
    else
    {
        return "";
    }
}


char *DetermineType(char *value)
{

    char *curType;

    if(strchr(value, '+') || strchr(value, '*') || strchr(value, '/') || strchr(value, '%') || strchr(value, '-') || strchr(value, '=') || strchr(value, '>') || strchr(value, '<'))
    {
        strcpy(curType, "expr");
        return curType;
    }

    if (strcmp(value, "true") == 0 || strcmp(value, "false") == 0)
    {
        curType = "bool";
    }
    else
    {
        char *isStr = strchr(value, '"');
        if (isStr != NULL)
        {
            curType = "string";
        }
        else
        {
            isStr = strchr(value, '.');
            if (isStr != NULL)
            {
                curType = "float64";
            }
            else
            {
                curType = "int";
            }
        }
    }

    return curType;
}

int checkDeclared(int curScope, char *token)
{

    for (int i = 0; i < functions[functionid].symbolCount; ++i)
    {
        if ((strcmp(SymbolTable[functionid][i].token, token) == 0) && (SymbolTable[functionid][i].tokenScope == curScope))
        {
            return i;
        }
    }
    return -1;
}

// A function to chek if the identifier has been already been added
// to the symbol table or not
// The scope of the prviously added var must be less than equal to the current token
int searchSymbol(int curScope, char *token)
{
    for (int i = 0; i < functions[functionid].symbolCount; ++i)
    {
        if ((strcmp(SymbolTable[functionid][i].token, token) == 0) && (SymbolTable[functionid][i].tokenScope <= curScope))
        {
            return i;
        }
    }
    return -1;
}

void insertSymbolEntry(char *token, int lineNumber, int startColumn, int tokenScope, char *type, char *value, char* length)
{

      int foundIndex = checkDeclared(tokenScope, token);

    // if (foundIndex == -1)
    // {

        SymbolTable[functionid][functions[functionid].symbolCount].symbolID = functions[functionid].symbolCount;
        strcpy(SymbolTable[functionid][functions[functionid].symbolCount].token, token);
        SymbolTable[functionid][functions[functionid].symbolCount].lineNumber = lineNumber;
        SymbolTable[functionid][functions[functionid].symbolCount].startColumn = startColumn;
        SymbolTable[functionid][functions[functionid].symbolCount].tokenScope = tokenScope;
        strcpy(SymbolTable[functionid][functions[functionid].symbolCount].type, type);
        strcpy(SymbolTable[functionid][functions[functionid].symbolCount].value, value);
        strcpy(SymbolTable[functionid][functions[functionid].symbolCount].length, length);
        if (DEBUG_MODE)
            printf("\033[0;32mAdded a new Entry to Symbol Table.\033[0;37m\n");
        ++functions[functionid].symbolCount;
    // }

    //else
    //{

    //    strcpy(SymbolTable[foundIndex].value, value);
    //    if (DEBUG_MODE)
            // printf("\033[0;32mIdenitifier exists. Symbol Table updated. %s\033[0;37m\n", value);
        // return;
    //}
}

void updateSymbolEntry(char *token, int lineNumber, int startColumn, int tokenScope, char *type, char *value)
{

    int foundIndex = searchSymbol(tokenScope, token);

    //if (foundIndex == -1)
    //{
    //    SymbolTable[symbolCount].symbolID = symbolCount;
    //    strcpy(SymbolTable[symbolCount].token, token);
    //    SymbolTable[symbolCount].lineNumber = lineNumber;
    //    SymbolTable[symbolCount].startColumn = startColumn;
    //    SymbolTable[symbolCount].tokenScope = tokenScope;
    //    strcpy(SymbolTable[symbolCount].type, type);
    //    strcpy(SymbolTable[symbolCount].value, value);
    //    if (DEBUG_MODE)
    //        printf("\033[0;32mAdded a new Entry to Symbol Table.\033[0;37m\n");
    //    ++symbolCount;
    //}

    //else
    //{
        strcpy(SymbolTable[functionid][foundIndex].value, value);
        strcpy(SymbolTable[functionid][foundIndex].type, type);
        strcpy(SymbolTable[functionid][foundIndex].length, findSize(type));
        if (DEBUG_MODE)
            printf("\033[0;32mIdenitifier exists. Symbol Table updated.%s\033[0;37m\n", value);
        return;
    //}
}


int checkArrayValType(char* arrayValues, char* type)
{
    char *token = strtok(arrayValues, ",");

    while(token != NULL)
    {
        if(strcmp(type, DetermineType(token)) != 0)
        {
            return 0;
        }

        token = strtok(NULL, ",");

    }

    return 1;
}


int searchFunction(char *token)
{
    for (int i = 1; i <=functionid; ++i)
    {
        if (strcmp(functions[i].name, token) == 0)
        {
            return i;
        }
    }
    return -1;
}


void printSymbolTable()
{
    for(int j=1;j<=functionid;++j)
    {
        printf("\nFunction Name \t\033[0;35mReturn Type\033[0;33m\t\tParameters\tSymbolCount\033[0;37m\n");
        printf("\n%s\t\033[0;35m%s\033[0;33m\t\t\t\t%s\t\t%d\033[0;37m\t\n",functions[j].name,functions[j].returntype,functions[j].params,functions[j].symbolCount);
        if (functions[j].symbolCount == 0)
        {
            printf("\nSymbol Table for %s is empty\n",functions[j].name);
            return;
        }
        printf("\n\n_______________________________________________________________________________________________________________________________________\n");
        printf("\t\t\t\t\t\t\t \033[0;31mSYMBOL TABLE for %s function\033[0;37m \n",functions[j].name);
        printf("_______________________________________________________________________________________________________________________________________\n");
        printf("\nToken ID \033[0;35mToken\033[0;33m\t\t\t\tLineNumber\tStart Column\033[0;34m\tTokenScope\t\033[0;36mType\033[0;32m\t\tValue\033[0;37m\t\tLength\033[0;37m\n");
        printf("---------------------------------------------------------------------------------------------------------------------------------------\n");

        for (int i = 0; i < functions[j].symbolCount; ++i)
        {
            printf("[%d] \t\033[0;35m%s\033[0;33m\t\t\t\t%d\t\t%d\033[0;34m\t\t%d\t\t\033[0;36m%s\033[0;32m\t\t%s\033[0;37m\t\t%s\033[0;37m\n", SymbolTable[j][i].symbolID, SymbolTable[j][i].token, SymbolTable[j][i].lineNumber, SymbolTable[j][i].startColumn, SymbolTable[j][i].tokenScope, SymbolTable[j][i].type, SymbolTable[j][i].value, SymbolTable[j][i].length);
        }
    }
}
