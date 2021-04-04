#!/bin/bash

# -d is used in order to generate y.tab.h file and -v tag is used to generate output file
yacc -dv parser.y
lex scanner.l
gcc y.tab.c lex.yy.c
