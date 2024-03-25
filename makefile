
# Compiladores
CC=g++
LEX=flex
BISON=bison

# Dependências
all: executavel

flex: __lexer.l
	$(LEX) __lexer.l

bison: __sintax.y
	$(BISON) -d __sintax.y -Wcounterexamples 

executavel: bison flex
	$(CC) lex.yy.c __sintax.tab.c -std=c++17 -o executavel
	rm lex.yy.c __sintax.tab.c __sintax.tab.h
