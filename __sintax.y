%{
#include <iostream>
using std::cout;
#define ANSI_COLOR_RED     "\x1b[31m"
#define ANSI_COLOR_RESET   "\x1b[0m"

int cont=0;
int yylex(void);
int yyparse(void);
void yyerror(const char *);
/* variáveis definidas no analisador léxico */
extern int yylineno;    
extern char * yytext;  
%}

%token OWLCLASS OWLSUBCLASSOF OWLDISJOINTCLASSES OWLINDIVIDUALS OWLEQUIVALENTTO CLASSE INDIVIDUO DADO AND OR PROPIEDADE CARDI OPERADOR RELOP 

%%


classe: classe OWLCLASS CLASSE variantes	{cout << "classe Classe: CLASSE\n\n";}
	| OWLCLASS CLASSE variantes 			{cout << "Classe: CLASSE\n\n";}
	| classe OWLCLASS CLASSE error OWLCLASS CLASSE variantes				{cout << ANSI_COLOR_RED << "Erro sintático: erro na classe!!!!!!\n"  << ANSI_COLOR_RESET;}
	| OWLCLASS CLASSE error	OWLCLASS CLASSE	variantes	{cout << ANSI_COLOR_RED << "Erro sintático: erro na classe!!!!!!\n"  << ANSI_COLOR_RESET;}
	;

variantes: OWLEQUIVALENTTO CLASSE AND propiedades 										{cout << "EquivalentTo: CLASSE AND propiedades\n";}
	| OWLEQUIVALENTTO CLASSE AND propiedades variantes 									{cout << "EquivalentTo: CLASSE AND propiedades+\n";}
	| OWLEQUIVALENTTO '{' individuos '}'												{cout << "EquivalentTo: '{' individuos '}'\n";}
	| OWLINDIVIDUALS individuos 														{cout << "Individuals: individuos\n";}
	| OWLINDIVIDUALS error variantes													{cout << ANSI_COLOR_RED << "Individuals: error nos individuos!!!!!!\n"  << ANSI_COLOR_RESET;}
	| OWLSUBCLASSOF classes																{cout << "SubClassOf: classes\n";}
	| OWLSUBCLASSOF classes propiedades 												{cout << "SubClassOf: classes propiedades*\n";}
	| OWLSUBCLASSOF classes propiedades variantes										{cout << "SubClassOf: classes propiedades*+\n";}
	| OWLSUBCLASSOF CLASSE AND propiedades variantes 									{cout << "SubClassOf: CLASSE AND propiedades+\n";}
	| OWLSUBCLASSOF propiedades OWLDISJOINTCLASSES classes OWLINDIVIDUALS individuos 	{cout << "SubClassOf: propriedades DisjointClasses: classes Individuals: individuos\n";}
	| OWLDISJOINTCLASSES classes variantes 												{cout << "DisjointClasses: classes+\n";}
	| OWLDISJOINTCLASSES classes														{cout << "DisjointClasses: classes\n";}
	;

classes: CLASSE
	| CLASSE ','
	| CLASSE ',' classes
	| CLASSE OR classes
	| CLASSE AND classes
	;


individuos: INDIVIDUO ',' individuos
	| INDIVIDUO
	;

propiedades: PROPIEDADE OPERADOR CLASSE 					{cout << "PROPIEDADE OPERADOR CLASSE\n";} 
	| PROPIEDADE OPERADOR CARDI CLASSE 						{cout << "PROPIEDADE OPERADOR CARDI CLASSE\n";} 
	| PROPIEDADE AND CLASSE 								{cout << "PROPIEDADE AND CLASSE\n";} 
	| PROPIEDADE AND CLASSE ',' propiedades 				{cout << "PROPIEDADE AND CLASSE ',' propiedades\n";} 
	| PROPIEDADE OPERADOR CLASSE ',' propiedades 			{cout << "PROPIEDADE OPERADOR CLASSE ',' propiedades\n";} 
	| PROPIEDADE OPERADOR propiedades 						{cout << "PROPIEDADE OPERADOR propiedades\n";} 
	| PROPIEDADE OPERADOR DADO 								{cout << "PROPIEDADE OPERADOR DADO\n";} 
	| PROPIEDADE OPERADOR DADO ',' propiedades 				{cout << "PROPIEDADE OPERADOR DADO ',' propiedades\n";} 
	| PROPIEDADE OPERADOR DADO '[' RELOP CARDI ']' 			{cout << "PROPIEDADE OPERADOR DADO \n";} 
	| PROPIEDADE OPERADOR CARDI DADO  						{cout << "PROPIEDADE OPERADOR CARDI DADO\n";} 
	| PROPIEDADE OPERADOR CARDI DADO '[' RELOP CARDI ']' 	{cout << "PROPIEDADE OPERADOR CARDI DADO [RELOP CARDI]\n";} 
	| PROPIEDADE AND DADO 									{cout << "PROPIEDADE AND DADO\n";} 
	| '(' propiedades ')' 									{cout << "'(' propiedades ')'\n";} 
	| '(' propiedades ')' AND propiedades 					{cout << "'(' propiedades ')' and propiedades\n";} 
	| '(' classes ')' 										{cout << "'(' classes ')'\n";} 
	| '(' classes ')' AND propiedades 						{cout << "'(' classes ')' and propiedades\n";} 
	;

%%

/* definido pelo analisador léxico */
extern FILE * yyin;  

int main(int argc, char ** argv)
{
	/* se foi passado um nome de arquivo */
	if (argc > 1)
	{
		FILE * file;
		file = fopen(argv[1], "r");
		if (!file)
		{
			cout << "Arquivo " << argv[1] << " não encontrado!\n";
			exit(1);
		}
		
		/* entrada ajustada para ler do arquivo */
		yyin = file;
	}

	yyparse();
}

void yyerror(const char * s)
{

	/* mensagem de erro exibe o símbolo que causou erro e o número da linha */
    cout << ANSI_COLOR_RED << "Erro sintático: símbolo \"" << yytext << "\" (linha " << yylineno << ")\n" << ANSI_COLOR_RESET;
}
