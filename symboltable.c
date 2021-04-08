#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define DEBUG_MODE 1

extern int yylineno;

int symbolCount = 0;

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
	int length;

} SymbolTable[400];

char* DetermineType(char* value)
{
	char* curType;

	if(strcmp(value, "true")==0 || strcmp(value, "false")==0)
	{
		curType = "bool";
	}
	else
	{
		char* isStr = strchr(value, '"');
		if(isStr != NULL)
		{
			curType = "string";
		}
		else
		{
			isStr = strchr(value, '.');
			if(isStr != NULL)
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




int checkDeclared( int curScope, char *token)
{

    for(int i =0; i<symbolCount; ++i)
    {
        if((strcmp(SymbolTable[i].token, token)==0 )  && (SymbolTable[i].tokenScope ==curScope))
        {
            return i;
        }
    }
    return -1;
}


// A function to chek if the identifier has been already been added
// to the symbol table or not
// The scope of the prviously added var must be less than equal to the current token
int searchSymbol(int curScope,char *token)
{
	for (int i = 0; i < symbolCount; ++i)
	{
		if (strcmp(token, SymbolTable[i].token) == 0)
		{
			if (curScope >= SymbolTable[i].tokenScope)
			{
				return i;
			}
			else
			{
				return -1;
			}
		}
		else
		{
			return -1;
		}
	}
}




void insertSymbolEntry(char* token, int lineNumber, int startColumn, int tokenScope, char* type, char* value, int length)
{
    
    int foundIndex = checkDeclared(tokenScope,token);

    if (foundIndex == -1)
    {
        SymbolTable[symbolCount].symbolID = symbolCount;
        strcpy(SymbolTable[symbolCount].token, token);
        SymbolTable[symbolCount].lineNumber = lineNumber;
        SymbolTable[symbolCount].startColumn = startColumn;
        SymbolTable[symbolCount].tokenScope = tokenScope;
        strcpy(SymbolTable[symbolCount].type, type);
        strcpy(SymbolTable[symbolCount].value, value);
    	SymbolTable[symbolCount].length = length;
        if (DEBUG_MODE)
            printf("\033[0;32mAdded a new Entry to Symbol Table.\033[0;37m\n");
        ++symbolCount;
    }
    
    else
    {
        
        strcpy(SymbolTable[foundIndex].value,value);
        if (DEBUG_MODE)
            printf("\033[0;32mIdenitifier exists. Symbol Table updated.\033[0;37m\n");
        return;
    }
}




void updateSymbolEntry(char* token, int lineNumber, int startColumn, int tokenScope, char* type, char* value)
{
    
    int foundIndex = searchSymbol(tokenScope, token);

    if (foundIndex == -1)
    {
        SymbolTable[symbolCount].symbolID = symbolCount;
        strcpy(SymbolTable[symbolCount].token, token);
        SymbolTable[symbolCount].lineNumber = lineNumber;
        SymbolTable[symbolCount].startColumn = startColumn;
        SymbolTable[symbolCount].tokenScope = tokenScope;
        strcpy(SymbolTable[symbolCount].type, type);
        strcpy(SymbolTable[symbolCount].value, value);
        if (DEBUG_MODE)
            printf("\033[0;32mAdded a new Entry to Symbol Table.\033[0;37m\n");
        ++symbolCount;
    }
    
    else
    {
        
        strcpy(SymbolTable[foundIndex].value,value);
        if (DEBUG_MODE)
            printf("\033[0;32mIdenitifier exists. Symbol Table updated.\033[0;37m\n");
        return;
    }
}

void printSymbolTable()
{
    if(symbolCount==0)
    {
        printf("Symbol Table is empty\n");
        return;
    }
    
    printf("\n\n__________________________________________________________________________________________________________________________________________________________\n");
    printf("\t\t\t\t\t\t\t \033[0;31mSYMBOL TABLE\033[0;37m\n");
    printf("___________________________________________________________________________________________________________________________________________________________\n");
    printf("\nToken ID \033[0;35mToken\033[0;33m\t\t\t\tLineNumber\tStart Column\033[0;34m\tTokenScope\t\033[0;36mType\033[0;32m\t\tValue\033[0;37m\t\t\tLength\033[0;37m\n");
    printf("------------------------------------------------------------------------------------------------------------------------------------------------------------\n");
    
    for(int i =0; i<symbolCount; ++i)
    {
        printf("[%d] \t\033[0;35m%s\033[0;33m\t\t\t\t%d\t\t%d\033[0;34m\t\t%d\t\t\033[0;36m%s\033[0;32m\t\t%s\033[0;37m\t\t\t%d\033[0;37m\n",SymbolTable[i].symbolID, SymbolTable[i].token, SymbolTable[i].lineNumber, SymbolTable[i].startColumn, SymbolTable[i].tokenScope, SymbolTable[i].type, SymbolTable[i].value,SymbolTable[i].length);
    }
}

