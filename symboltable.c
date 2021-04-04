#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define DEBUG_MODE 0

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
	char paratype[100];
	char value[100];
	char length[100];

} SymbolTable[400];






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
int is_present(int curScope, char *token)
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



int insertIntoSymbolTable(char *token, int lineNumber, int startColumn, int tokenScope)
{
	int isEntered = is_present(token, tokenScope);
	if (isEntered == -1)
	{

		SymbolTable[symbolCount].symbolID = symbolCount;
		SymbolTable[symbolCount].token = token;
		SymbolTable[symbolCount].lineNumber = lineNumber;
		SymbolTable[symbolCount].startColumn = startColumn;
		SymbolTable[symbolCount].tokenScope = tokenScope;

		++symbolCount;
	}
	else
	{
		return -1; 
	}
}


int symbolID;
	char token[100];
	int lineNumber;
	int startColumn;
	int tokenScope;
	char type[100];
	char *paratype[100];
	char value[100];
	char size[100];


int updateVariableEntry(char* token, int tokenScope, char* type, char* value)
{
	int isEntered = is_present(token, tokenScope);
	if(isEntered != -1)
	{
		// do updates here
	}
	else
	{
		return -1; // Unsuccessful update since it does not exist
	}
}


int updateFunctionEntry(char* token, int tokenScope, char* type, char** paratype, )
{
	int isEntered = is_present(token, tokenScope);
	if(isEntered != -1)
	{
		// do updates here
	}
	else
	{
		return -1; // Unsuccessful update since it does not exist
	}
}


int updateArrayEntry(char* token, int tokenScope, char* type, )
{
	int isEntered = is_present(token, tokenScope);
	if(isEntered != -1)
	{
		// do updates here
	}
	else
	{
		return -1; // Unsuccessful update since it does not exist
	}
}


int updateType()
{
	int isEntered = is_present(token, tokenScope);
	if(isEntered != -1)
	{
		// do updates here
	}
	else
	{
		return -1; // Unsuccessful update since it does not exist
	}
}




int updateValue()
{
	
}

int updateLength()
{

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
        printf("[%d] \t\033[0;35m%s\033[0;33m\t\t\t\t%d\t\t%d\033[0;34m\t\t%d\t\t\033[0;36m%s\033[0;32m\t\t%s\033[0;37m\t\t\t%s\033[0;37m\n",SymbolTable[i].symbolID, SymbolTable[i].token, SymbolTable[i].lineNumber, SymbolTable[i].startColumn, SymbolTable[i].tokenScope, SymbolTable[i].type, SymbolTable[i].value,SymbolTable[i].size);
    }
}


---------------------------------------------------
#include <stdio.h>
#include <string.h>
												  struct sym
{
	int sno;
	char token[100];
	int type[100];
	int paratype[100];
	int tn;
	int pn;
	float fvalue;
	int index;
	int scope;
} st[100];
int n = 0, arr[10];
float t[100];
int iter = 0;
int returntype_func(int ct)
{
	return arr[ct - 1];
}
void storereturn(int ct, int returntype)
{
	arr[ct] = returntype;
	return;
}
void insertscope(char *a, int s)
{
	int i;
	for (i = 0; i < n; i++)
	{
		if (!strcmp(a, st[i].token))
		{
			st[i].scope = s;
			break;
		}
	}
}
int returnscope(char *a, int cs)
{
	int i;
	int max = 0;
	for (i = 0; i <= n; i++)
	{
		if (!(strcmp(a, st[i].token)) && cs >= st[i].scope)
		{
			if (st[i].scope >= max)
				max = st[i].scope;
		}
	}
	return max;
}
int lookup(char *a)
{
	int i;
	for (i = 0; i < n; i++)
	{
		if (!strcmp(a, st[i].token))
			return 0;
	}
	return 1;
}
int returntype(char *a, int sct)
{
	int i;
	for (i = 0; i <= n; i++)
	{
		if (!strcmp(a, st[i].token) && st[i].scope == sct)
		{
			return st[i].type[0];
		}
	}
}

int returntypef(char *a)
{
	int i;
	for (i = 0; i < n; i++)
	{
		if (!strcmp(a, st[i].token))
		{
			return st[i].type[1];
		}
	}
}

int returntype2(char *a, int sct)
{
	int i;
	for (i = 0; i < n; i++)
	{
		if (!strcmp(a, st[i].token) && st[i].scope == sct)
		{
			return st[i].type[1];
		}
	}
}

void check_scope_update(char *a, char *b, int sc)
{
	int i, j, k;
	int max = 0;
	for (i = 0; i <= n; i++)
	{
		if (!strcmp(a, st[i].token) && sc >= st[i].scope)
		{
			if (st[i].scope >= max)
				max = st[i].scope;
		}
	}
	for (i = 0; i <= n; i++)
	{
		if (!strcmp(a, st[i].token) && max == st[i].scope)
		{
			float temp = atof(b);
			for (k = 0; k < st[i].tn; k++)
			{
				if (st[i].type[k] == 258)
					st[i].fvalue = (int)temp;
				else
					st[i].fvalue = temp;
			}
		}
	}
}
void storevalue(char *a, char *b, int s_c)
{
	int i;
	for (i = 0; i <= n; i++)
	{
		if (!strcmp(a, st[i].token) && s_c == st[i].scope)
		{
			st[i].fvalue = atof(b);
		}
	}
}

void insert(char *name, int type)
{
	int i;
	if (lookup(name))
	{
		strcpy(st[n].token, name);
		st[n].tn = 1;
		st[n].type[st[n].tn - 1] = type;
		//st[n].addr=addr;
		st[n].sno = n + 1;
		n++;
	}
	else
	{
		for (i = 0; i < n; i++)
		{
			if (!strcmp(name, st[i].token))
			{
				st[i].tn++;
				st[i].type[st[i].tn - 1] = type;
				break;
			}
		}
	}
	return;
}

void insertp(char *name, int type)
{
	int i;
	for (i = 0; i < n; i++)
	{
		if (!strcmp(name, st[i].token))
		{
			st[i].pn++;
			st[i].paratype[st[i].pn - 1] = type;
			break;
		}
	}
}

void insert_index(char *name, int ind)
{
	int i;
	for (i = 0; i < n; i++)
	{
		if (!strcmp(name, st[i].token) && st[i].type[0] == 273)
		{
			st[i].index = atoi(ind);
		}
	}
}

void insert_by_scope(char *name, int type, int s_c)
{
	int i;
	for (i = 0; i < n; i++)
	{
		if (!strcmp(name, st[i].token) && st[i].scope == s_c)
		{
			st[i].tn++;
			st[i].type[st[i].tn - 1] = type;
		}
	}
}

int checkp(char *name, int flist, int c)
{
	int i, j;
	for (i = 0; i < n; i++)
	{
		if (!strcmp(name, st[i].token))
		{
			if (st[i].paratype[c] != flist)
				return 1;
		}
	}
	return 0;
}

void insert_dup(char *name, int type, int s_c)
{
	strcpy(st[n].token, name);
	st[n].tn = 1;
	st[n].type[st[n].tn - 1] = type;
	//st[n].addr=addr;
	st[n].sno = n + 1;
	st[n].scope = s_c;
	n++;
	return;
}

void print()
{
	int i, j;
	printf("\n------------------------------Symbol Table-----------------------------\n");
	printf("-----------------------------------------------------------------------\n");
	printf("\nSNo.\tToken\t\tValue\t\tScope\t\tType\n");
	printf("-----------------------------------------------------------------------\n");
	for (i = 0; i < n; i++)
	{
		if (st[i].type[0] == 258)
			printf("%d\t%s\t\t%d\t\t%d\t", st[i].sno, st[i].token, (int)st[i].fvalue, st[i].scope);
		else
			printf("%d\t%s\t\t%.1f\t\t%d\t", st[i].sno, st[i].token, st[i].fvalue, st[i].scope);
		printf("\t");
		for (j = 0; j < st[i].tn; j++)
		{
			if (st[i].type[j] == 258)
				printf("INT");
			else if (st[i].type[j] == 259)
				printf("FLOAT");
			else if (st[i].type[j] == 271)
				printf("FUNCTION");
			else if (st[i].type[j] == 269)
				printf("ARRAY");
			else if (st[i].type[j] == 260)
				printf("VOID");
			if (st[i].tn > 1 && j < (st[i].tn - 1))
				printf(" - ");
		}
		printf("\n");
	}
	printf("-----------------------------------------------------------------------\n\n");
	return;
}