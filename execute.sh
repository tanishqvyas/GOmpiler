#!/bin/sh
yacc -vd parser.y -Wnone
lex scanner.l
gcc lex.yy.c y.tab.c
./a.out testcases/test_tac.go