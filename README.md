# Analisador Léxico e Sintático

Esse projeto tem com objetivo reconhecer a linguavel OWL no modelo Manchester Syntax

## Como preparar o ambiente? 👵
- ### Baixando dependências (opcional caso já as possua instaladas)
      sudo apt update
      sudo apt upgrade
      sudo apt install g++ gdb
      sudo apt install make cmake
      sudo apt install flex libfl-dev
      sudo apt install bison libbison-dev

- ### Agora já podemos executar os comandos para compilar o executavel do projeto!
  **Executar o comando "make" caso conheça o funcionamento dele, caso contrário, podemos executar os comandos um a um**

  1. Gerar o arquivo do analisador léxico com o flex:
   
         flex __lexer.l

  2. Gerar o arquivo do analisador sintático com o bison:
   
	     bison -d __sintax.y -Wcounterexamples 

  3. Compilar tudo em no executavel do projeto:
   
	     g++ lex.yy.c __sintax.tab.c -std=c++17 -o executavel

  4. Limpar arquivos desnecessários (opcional):
   
	     rm lex.yy.c __sintax.tab.c __sintax.tab.h

## Com o executavel em mãos, podemos fazer uso dele da seguinte maneira
	./executavel < arquivo.txt
   > sendo "arquivo.txt" um arquivo de texto que serve pra de entrada

  ### Alguns arquivos de testes já estão definidos no projeto, sendo eles:
    	_owl.txt	
   > Esse arquivo está repleto de erros na sua gramática.
	
	_owl2.txt
   > Esse arquivo é um exemplo do arquivo _owl.txt corrigido

	_owl3.txt
   > Esse é um arquivo pequeno
