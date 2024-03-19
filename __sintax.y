%{
#include <iostream>
using std::cout;
#define RED     "\x1b[31m"
#define RESET   "\x1b[0m"

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
	| classe OWLCLASS CLASSE error OWLCLASS CLASSE variantes				{cout << RED << "Erro sintático: erro na classe!!!!!!\n"  << RESET;}
	| OWLCLASS CLASSE error	OWLCLASS CLASSE	variantes	{cout << RED << "Erro sintático: erro na classe!!!!!!\n"  << RESET;}
	;

variantes: OWLEQUIVALENTTO CLASSE AND propiedades 										{cout << "EquivalentTo: CLASSE AND propiedades\n";}
	| OWLEQUIVALENTTO CLASSE AND propiedades variantes 									{cout << "EquivalentTo: CLASSE AND propiedades+\n";}
	| OWLEQUIVALENTTO '{' individuos '}'												{cout << "EquivalentTo: '{' individuos '}'\n";}
	/* | error CLASSE AND propiedades 														{cout << RED << "Erro sintático: espera-se 'EquivalentTo' ou 'SubClassOf'!!!!!!\n"  << RESET;} */
	/* | OWLEQUIVALENTTO error AND propiedades 											{cout << RED << "Erro sintático: espera-se 'CLASSE' após 'EquivalentTo'!!!!!!\n"  << RESET;} */
	
	| OWLSUBCLASSOF CLASSE															{cout << "SubClassOf: CLASSE\n";}
	/* | OWLSUBCLASSOF CLASSE propiedades									{cout << "SubClassOf: CLASSE propiedades\n";} */
	/* | OWLSUBCLASSOF CLASSE propiedades variantes												{cout << "SubClassOf: CLASSE propiedades+\n";} */
	| OWLSUBCLASSOF classes	propiedades														{cout << "SubClassOf: classes propiedades\n";}
	/* | OWLSUBCLASSOF classes propiedades 												{cout << "SubClassOf: classes propiedades*\n";} */
	/* | OWLSUBCLASSOF classeand propiedades variantes										{cout << "SubClassOf: classes propiedades*+\n";} */
	| OWLSUBCLASSOF classes propiedades variantes 									{cout << "SubClassOf: CLASSE AND propiedades+\n";}
	/* | OWLSUBCLASSOF CLASSE error propiedades variantes									{cout << RED << "\tespera-se 'AND' após a 'CLASSE' !!!!!!\n"  << RESET;} */
	/* | OWLSUBCLASSOF error AND propiedades variantes										{cout << RED << "\tespera-se uma 'CLASSE' após 'SubClassOf' !!!!!!\n"  << RESET;} */
	/* | OWLSUBCLASSOF error error propiedades variantes									{cout << RED << "\tespera-se uma 'CLASSE' após 'SubClassOf' !!!!!!\n"  << RESET;} */
	| OWLSUBCLASSOF propiedades OWLDISJOINTCLASSES classes OWLINDIVIDUALS individuos 	{cout << "SubClassOf: propriedades DisjointClasses: classes Individuals: individuos\n";}
	
	| OWLDISJOINTCLASSES classesFinal variantes 												{cout << "DisjointClasses: classes+\n";}
	| OWLDISJOINTCLASSES classesFinal														{cout << "DisjointClasses: classes\n";}
	/* | OWLDISJOINTCLASSES classes CLASSE												{cout << "DisjointClasses: classes CLASSE\n";} */
	| OWLINDIVIDUALS individuos 														{cout << "Individuals: individuos\n";}
	/* | OWLINDIVIDUALS error variantes													{cout << RED << "Individuals: error nos individuos!!!!!!\n"  << RESET;} */
	;

classesFinal: CLASSE				{cout << "CLASSE \n";}
	| CLASSE ',' classesFinal		{cout << "CLASSE ',' classes\n";}
	| CLASSE OR classesFinal			{cout << "CLASSE 'OR' classes\n";}
	| CLASSE AND classesFinal		{cout << "CLASSE 'AND' classes\n";}
	| CLASSE ',' error 			{cout << RED << "\tespera-se uma 'CLASSE' após uma ',' !!!!!!\n"  << RESET;}
	| CLASSE error 			{cout << RED << "\tespera-se ',' ou 'AND' ou 'OR' após a 'CLASSE' !!!!!!\n"  << RESET;}
	/* | CLASSE 				{cout << "CLASSE\n";} */
	;


classes: CLASSE ','				{cout << "CLASSE ',' \n";}
	| CLASSE ',' classes		{cout << "CLASSE ',' classes\n";}
	| CLASSE OR classes			{cout << "CLASSE 'OR' classes\n";}
	| CLASSE AND classes		{cout << "CLASSE 'AND' classes\n";}
	| CLASSE ',' error 			{cout << RED << "\tespera-se uma 'CLASSE' após uma ',' !!!!!!\n"  << RESET;}
	| CLASSE error 			{cout << RED << "\tespera-se ',' ou 'AND' ou 'OR' após a 'CLASSE' !!!!!!\n"  << RESET;}
	/* | CLASSE 				{cout << "CLASSE\n";} */
	/* | error AND					{cout << RED << "\tespera-se ',' ou 'AND' ou 'OR' após a 'CLASSE' !!!!!!\n"  << RESET;} */
	/* | CLASSE AND error 		{cout << RED << "\tespera-se uma 'CLASSE' !!!!!!\n"  << RESET;} */
	/* | ',' error classes 		{cout << RED << "\tespera-se uma 'CLASSE' !!!!!!\n"  << RESET;} */
	/* | CLASSE error '('		{cout << RED << "\tespera-se uma 'CLASSE' www !!!!!!\n"  << RESET;} */
	/* | error	AND				{cout << RED << "\tespera-se uma 'CLASSE' !!!!!!\n"  << RESET;} */
	/* |  error 		{cout << RED << "\tespera-se ',' ou 'AND' ou 'OR' após a 'CLASSE' !!!!!!\n"  << RESET;} */
	/* | error	AND	{cout << RED << "\tespera-se ',' ou 'AND' ou 'OR' após a 'CLASSE' !!!!!!\n"  << RESET;} */
	;


individuos: INDIVIDUO ',' individuos
	| INDIVIDUO
	/* | INDIVIDUO ','	error individuos {cout << RED << "Erro sintático: espera-se um 'INDIVIDUO' após uma ',' !!!!!!\n"  << RESET;} */
	| error ',' individuos 			{cout << RED << "\tespera-se um 'INDIVIDUO' com cardinalidade!!!!!!\n"  << RESET;}
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
	| '(' classesFinal ')' 										{cout << "'(' classes ')'\n";} 
	| '(' classesFinal ')' AND propiedades 						{cout << "'(' classes ')' and propiedades\n";} 
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
    cout << RED << "Erro sintático: símbolo \"" << yytext << "\" (linha " << yylineno << ")\n" << RESET;
}
