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
   > Esse arquivo é um exemplo do arquivo _owl.txt corrigido.

	_owl3.txt
   > Esse é um arquivo pequeno que eu recomendo para fazer testes rápidos do projeto.
	
 	_owl4.txt
   > A mesma coisa do anterior

	_owl5.txt
   > Esse é referente ao ultimo arquivo disponibilizado da gramática do Manchester Syntax, sendo o exemplo mais complexo dentre todos.

## Leve explicação da gramática desenvolvida
- As variáveis não-terminais sempre deviram em um ou mais não-terminais, exceto aos casos especiais, dos quais os não-terminais derivam unicamente um token terminal.
	> Ahnnn?
	
	Exemplo: a várivel "orand" deriva em "or" ou "and", sendo que "or" deriva o token "OR" e and deriva o token "AND".
	
	orand: or  
	    | and                 
	    ;
	
	or: OR
	;
	
	and: AND
	;
	
	Por quê? Isso deixa a gramática visualmente mais extensa, mas em troca, permite que cada token possa ser tratado de uma forma diferente de forma eficiente.

- Outra peculiaridade é que a leitura é feita da direita pra esquerda.
	> Ahnnnnnnnnnnn???????
	
	Exemplo: ao invés de usar 'indivi virgula individuos' foi escolhido a forma descrita abaixo.
	
	individuos: indivi              
	  | individuos virgula indivi
	  ;
	
	Por quê? Isso deixa a gramática confusa, mas em troca, permite que os tokens lidos sejam impresso no terminal na ordem em que são lidos.
## Exemplos de entrada
----------------------------------------------------------------------------------------------------------------
![image](https://github.com/BrennoKM/AnalisadorLexerSintax/assets/99992197/46915f3f-879c-43d5-b4a8-5a473d65b743)

Saida: ![image](https://github.com/BrennoKM/AnalisadorLexerSintax/assets/99992197/dc12b728-e9c3-49cf-9232-dcaca7511521)
----------------------------------------------------------------------------------------------------------------
### Exemplo com problema na gramática
![image](https://github.com/BrennoKM/AnalisadorLexerSintax/assets/99992197/91e3a819-03d5-450f-9cf4-f0764d22e5f4)

Saida: ![image](https://github.com/BrennoKM/AnalisadorLexerSintax/assets/99992197/5e2e517b-468f-47a6-aa44-b34a7889f30b)
----------------------------------------------------------------------------------------------------------------
