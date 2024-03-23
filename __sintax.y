%{
#include <iostream>
#include <unordered_map>
using std::cout;
#define RED     "\x1b[31m"
#define RESET   "\x1b[0m"

int cont=0;
int contAbreParen, contFechaParen, contAbreCol, contFechaCol, contAbreChave, contFechaChave;
int numError, tipoClasse, numLocal;
std::unordered_map<int, std::string> mapaClasse, mapaError, mapaLocal;
int yylex(void);
int yyparse(void);
void yyerror(const char *);
/* variáveis definidas no analisador léxico */
extern int yylineno;    
extern char * yytext;  

void resetAbreFecha(){
  contAbreParen = 0;
  contFechaParen = 0;
  contAbreCol = 0;
  contFechaCol = 0;
  contAbreChave = 0; 
  contFechaChave = 0;
}

%}

%token OWLCLASS OWLSUBCLASSOF OWLDISJOINTCLASSES OWLINDIVIDUALS OWLEQUIVALENTTO CLASSE INDIVIDUO DADO AND OR PROPIEDADE CARDI OPERADOR RELOP 


%%

exp: exp owlclass classe tipos    
  | owlclass classe tipos               
  | exp owlclass classe error tipos
  | owlclass classe error tipos
  | exp owlclass error classe tipos
  | owlclass error classe tipos
  | exp error owlclass classe tipos
  | error owlclass classe tipos
  ;

tipos: owlsubclassof corpo      {tipoClasse = 1;}          
  | owlequivalentto corpo       {tipoClasse = 2;}             
  | disvinduals                 {tipoClasse = 3;}          
  ;

corpo: classeand                           
  | classeand propiedades                 
  | classeand disvinduals                 
  | propiedades                           
  | classeand propiedades disvinduals     
  | propiedades disvinduals               
  | disvinduals                           
  | individuos
  | individuos disvinduals                   
  ;

disvinduals: owlindividuals individuos
  | disvinduals owlindividuals individuos
  | owldisjointclasses classes
  ;

classes: classe
  | classes orand classe
  | classes virgula classe
  | abreParen classes fechaParen
  ;

individuos: indivi              
  | individuos virgula indivi
  | abreChave individuos fechaChave
  ;

propiedades: abreParen propiedades fechaParen           
  /* | abreParen classes fechaParen                         */
  | propiedades orand abreParen propiedades fechaParen                              
  | propiedades orand abreParen classes fechaParen         
  | propiedades virgula prop operand propcomp     
  | propiedades virgula prop operand abreParen classes fechaParen                
  | prop operand propcomp                     
  | prop operand abreParen classes fechaParen     
  | prop operand abreParen propiedades fechaParen  
  ;

operand: orand
  | oper                   
  ;

orand: or  
  | and                 
  ;

propcomp: classe                              
  | dado                                      
  | dado abreCol relop cardi fechaCol         
  | cardi classe                              
  | cardi dado                                
  | cardi dado abreCol relop cardi fechaCol  
  ;

classeand: classe                      
  | classe and                         
  | classe virgula                 
  ;

owlclass:
  {numError = 1;} OWLCLASS                 {cout << "\n\nOWLCLASS ";}
  {resetAbreFecha();}
  ;

classe:
  {numError = 2;} CLASSE                   {cout << "CLASSE ";}
  ;

owlsubclassof:
  {numError = 3;} OWLSUBCLASSOF            {cout << "\nOWLSUBCLASSOF \n";}
  {numLocal = 1;}
  ;

owlequivalentto:
  {numError = 4;} OWLEQUIVALENTTO          {cout << "\nOWLEQUIVALENTTO \n";}
  {numLocal = 2;}
  ;

owldisjointclasses:
  {numError = 4;} OWLDISJOINTCLASSES       {cout << "\nOWLDISJOINTCLASSES \n";}
  {numLocal = 3;}
  ;

owlindividuals:
  {numError = 5;} OWLINDIVIDUALS           {cout << "\nOWLINDIVIDUALS \n";}
  {numLocal = 4;}
  ;

indivi:
  {numError = 7;} INDIVIDUO                {cout << "INDIVIDUO ";}
  ;

dado:
  {numError = 8;} DADO                     {cout << "DADO ";}
  ;

cardi:
  {numError = 9;} CARDI                    {cout << "CARDI ";}
  ;

relop:
  {numError = 10;} RELOP                   {cout << "RELOP ";}
  ;

oper:
  {numError = 11;} OPERADOR                {cout << "OPERADOR ";}
  ;

or:
  {numError = 12;} OR                      {cout << "OR ";}
  ;

and:
  {numError = 13;} AND                     {cout << "\nAND ";}
  ;

prop:
  {numError = 14;} PROPIEDADE              {cout << "PROPIEDADE ";}
  ;

abreCol:
  {numError = 15;} '['                     {cout << "'[' ";}
  {contAbreCol++;}
  ;

fechaCol:
  {numError = 16;} ']'                     {cout << "']' ";}
  {contFechaCol++;}
  ;

abreChave:
  {numError = 17;} '{'                     {cout << "'{' ";}
  {contAbreChave++;}
  ;

fechaChave:
  {numError = 18;} '}'                     {cout << "'}' ";}
  {contFechaChave++;}
  ;

abreParen:
  {numError = 19;} '('                     {cout << "'(' ";}
  {contAbreParen++;}
  ;

fechaParen:
  {numError = 20;} ')'                     {cout << "')' ";}
  {contFechaParen++;}
  ;

virgula:
  {numError = 21;} ','                     {cout << "',' \n";}
  ;

%%

/* definido pelo analisador léxico */
extern FILE * yyin;  



void verificaFechaAbre(int numError, char* token){
  if(15 <= numError && numError <= 20){
    cout << RED << "\t\tVerifique se está abrindo e fechando '{' '}' corretamente\n" << RESET;
    cout << RED << "\t\tVerifique se está abrindo e fechando '(' ')' corretamente\n" << RESET;
    cout << RED << "\t\tVerifique se está abrindo e fechando '[' ']' corretamente\n" << RESET;
  } else {
    if(contAbreChave != contFechaChave || token[0] == '{' || token[0] == '}'){
      cout << RED << "\t\tVerifique se está abrindo e fechando '{' '}' corretamente\n" << RESET;
    }
    if(contAbreParen != contFechaParen || token[0] == '(' || token[0] == ')'){
      cout << RED << "\t\tVerifique se está abrindo e fechando '(' ')' corretamente\n" << RESET;
    }
    if(contAbreCol != contFechaCol || token[0] == '[' || token[0] == ']'){
      cout << RED << "\t\tVerifique se está abrindo e fechando '[' ']' corretamente\n" << RESET;
    }
  }
}

int main(int argc, char ** argv)
{
  mapaClasse[1] = "Primitiva";
  mapaClasse[2] = "Definida";
  mapaClasse[3] = "Normal";

  mapaLocal[1] = "SubClassOf";
  mapaLocal[2] = "EquivalentTo";
  mapaLocal[3] = "DisjointClasses";
  mapaLocal[4] = "Individuals";

  mapaError[1]  = "Esperava-se OWLCLASS";
  mapaError[2]  = "Esperava-se CLASSE";
  mapaError[3]  = "Esperava-se OWLSUBCLASSOF";
  mapaError[4]  = "Esperava-se OWLEQUIVALENTTO";
  mapaError[5]  = "Esperava-se OWLDISJOINTCLASSES";
  mapaError[6]  = "Esperava-se OWLINDIVIDUALS";
  mapaError[7]  = "Esperava-se INDIVIDUO";
  mapaError[8]  = "Esperava-se DADO";
  mapaError[9]  = "Esperava-se CARDINALIDADE";
  mapaError[10] = "Esperava-se RELOP";
  mapaError[11] = "Esperava-se OPERADOR";
  mapaError[12] = "Esperava-se OR";
  mapaError[13] = "Esperava-se AND";
  mapaError[14] = "Esperava-se PROPIEDADE";
  mapaError[15] = "Esperava-se '['";
  mapaError[16] = "Esperava-se ']'";
  mapaError[17] = "Esperava-se '{'";
  mapaError[18] = "Esperava-se '}'";
  mapaError[19] = "Esperava-se '('";
  mapaError[20] = "Esperava-se ')'";
  mapaError[21] = "Esperava-se ','";
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
    cout << RED << "\nErro sintático: símbolo \"" << yytext << "\" (linha " << yylineno << ")\n" << RESET;
    cout << RED << "\tnumError:\t" << numError << "\n" << RESET;
    cout << RED << "\tMensagem:\t"<< mapaError[numError] << "\n"<< RESET;
    verificaFechaAbre(numError, yytext);
    cout << RED << "\tTipo da Classe:\t"<< mapaClasse[tipoClasse] << "\n"<< RESET;
    cout << RED << "\tLocal do erro:\t"<< mapaLocal[numLocal] << RESET;
}
