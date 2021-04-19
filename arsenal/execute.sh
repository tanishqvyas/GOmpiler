#!/bin/sh
yacc -vd parser.y
lex scanner.l
gcc lex.yy.c y.tab.c
