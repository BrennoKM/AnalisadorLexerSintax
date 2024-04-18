%{
#include <iostream>
#include <unordered_map>
#include <cstring>
#include <vector>

using std::cout;
#define RED     "\x1b[31m"
#define RESET   "\x1b[0m"

int cont=0;
int contAbreParen, contFechaParen, contAbreCol, contFechaCol, contAbreChave, contFechaChave;
int numError, tipoClasse, numLocal;

bool flagClasse, flagEquivalent, flagSubClass, flagDisjoint, flagIndividuals, flagOnly, flagSome, flagInteger, flagFloat, flagDado;
char * classeAtual;
char * classetext;

char* ultimaPropiedade;
int palavrasFechamento = 0;
std::unordered_map<std::string, std::vector<std::string>> propiedadesFechamento;
std::vector<std::string> dataProps, objProps;
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

%token OWLCLASS OWLSUBCLASSOF OWLDISJOINTCLASSES OWLINDIVIDUALS OWLEQUIVALENTTO CLASSE INDIVIDUO DADO AND OR PROPIEDADE CARDI CARDIF OPERADOR RELOP INVERSE


%%

exp: exp owlclass classe tipos    
  | owlclass classe tipos
  | exp error tipos   
  | error tipos
  ;

tipos: owlsubclassof corpo      {tipoClasse = 1;}        
  | owlequivalentto corpo       {tipoClasse = 2;} 
  | disvinduals                 {tipoClasse = 3;}
  | owlequivalentto corpo 
  owlsubclassof corpo           {tipoClasse = 4;}
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

classeand: classe                      
  | classe and
  | classe or classes                       
  | classe virgula                 
  ;

classes: classe
  | classes orand classe
  | classes virgula classe
  | abreParen classes fechaParen
  ;  

disvinduals: owlindividuals individuos
  | disvinduals owlindividuals individuos
  | owldisjointclasses classes
  ;

individuos: indivi              
  | individuos virgula indivi
  | abreChave individuos fechaChave
  ;

propiedades: abreParen propiedades fechaParen                         
  | propiedades orand abreParen propiedades fechaParen                      
  | propiedades orand abreParen classes fechaParen
  | propiedades orand prop operand propcomp                
  | propiedades virgula prop operand propcomp                         
  | propiedades virgula prop operand abreParen classes fechaParen          
  | prop operand propcomp                                                                                        
  | prop operand abreParen classes fechaParen                         
  | propiedades orand prop operand abreParen classes fechaParen                         
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

owlclass:
  {numError = 1;} OWLCLASS                 {cout << "\n\nOWLCLASS ";}
  {
    resetAbreFecha(); 
    flagClasse = true;
    flagEquivalent = false;
    flagSubClass = false;
    flagDisjoint = false;
    flagIndividuals = false;
    flagOnly = false;
    flagSome = false;
    flagDado = false;
    palavrasFechamento = 0;
    propiedadesFechamento.clear();
  }
  
  ;

classe:
  {numError = 2;} CLASSE                   {cout << "CLASSE ";}
  {
    if(flagClasse == true){
      classeAtual = new char[strlen(yytext) + 1];
      strcpy(classeAtual, yytext);
      flagClasse = false;
    }
    if(flagDisjoint == true){
      if(strcmp(classeAtual, yytext) == 0){
        cout << RED << "\nErro semântico: classe não pode ser disjoint de si propria" << " (linha " << yylineno << ")\n" << RESET;
      }
    }
    if((flagSubClass == true || flagEquivalent == true) && flagSome == true){
      if (propiedadesFechamento.find(ultimaPropiedade) != propiedadesFechamento.end()) {
          std::string texto(yytext);
          propiedadesFechamento[ultimaPropiedade].push_back(texto);
      } else {
          std::vector<std::string> novoVetor;
          std::string texto(yytext);
          novoVetor.push_back(texto);
          propiedadesFechamento[ultimaPropiedade] = novoVetor;
      }
      std::string prop(ultimaPropiedade);
      std::string linha = " (linha " + std::to_string(yylineno) + ")";
      prop += linha;
      objProps.push_back(prop);
      flagSome = false;
    }
    if(flagOnly == true){
      bool teste = false;
      if(propiedadesFechamento[ultimaPropiedade].size() == 0){
        cout << RED << "\nErro semântico: o axioma de fechamento possui propiedades não declaradas '" << ultimaPropiedade << "' (linha " << yylineno << ")\n" << RESET;
      } else {
        for (auto& it : propiedadesFechamento) {
          if(strcmp(it.first.c_str(), ultimaPropiedade) == 0){
            for(auto& e : it.second){
              if(strcmp(e.c_str(), yytext) == 0){
                teste = true;
                break;
              }
            }
          }
        }
        if(teste == false){
          cout << RED << "\nErro semântico: o axioma de fechamento possui classes não declaradas '" << yytext << "' para a propiedade '" << ultimaPropiedade <<"' (linha " << yylineno << ")\n" << RESET;
        }
      }
    }
  }
  ;

owlsubclassof:
  {numError = 3;} OWLSUBCLASSOF            {cout << "\nOWLSUBCLASSOF \n";}
  {
    numLocal = 1;
    flagSubClass = true;
    flagOnly = false;
    palavrasFechamento = 0;
    propiedadesFechamento.clear();
  
    if(flagDisjoint == true){
      cout << RED << "\nErro semântico: SubClasse está após o disjoint" << " (linha " << yylineno << ")\n" << RESET;
    }
    if(flagIndividuals == true){
      cout << RED << "\nErro semântico: SubClasse está após o individuals" << " (linha " << yylineno << ")\n" << RESET;
    }
  }
  ;

owlequivalentto:
  {numError = 4;} OWLEQUIVALENTTO          {cout << "\nOWLEQUIVALENTTO \n";}
  {
    numLocal = 2;
    flagEquivalent = true;
    if(flagSubClass == true){
      cout << RED << "\nErro semântico: Equivalent está após a SubClass" << " (linha " << yylineno << ")\n" << RESET;
    }
  }
  ;

owldisjointclasses:
  {numError = 4;} OWLDISJOINTCLASSES       {cout << "\nOWLDISJOINTCLASSES \n";}
  {
    numLocal = 3; 
    flagDisjoint = true;
    flagOnly = false;
    if(flagIndividuals == true){
      cout << RED << "\nErro semântico: Disjoint está após o Individuals" << " (linha " << yylineno << ")\n" << RESET;
    }
    if(flagEquivalent == false && flagSubClass == false){
      cout << RED << "\nErro semântico: a Classe deve possuir pelo menos o corpo EquivalentTo ou SubClassOf" << " (linha " << yylineno << ")\n" << RESET;
    }
  }
  ;

owlindividuals:
  {numError = 5;} OWLINDIVIDUALS           {cout << "\nOWLINDIVIDUALS \n";}
  {
    numLocal = 4;
    flagIndividuals = true;
    flagOnly = false;
    if(flagEquivalent == false && flagSubClass == false){
      cout << RED << "\nErro semântico: a Classe deve possuir pelo menos o corpo EquivalentTo ou SubClassOf" << " (linha " << yylineno << ")\n" << RESET;
    }
  }
  ;

indivi:
  {numError = 7;} INDIVIDUO                {cout << "INDIVIDUO ";}
  ;

dado:
  {numError = 8;} DADO                     {cout << "DADO ";}
  {
    std::string integer= "xsd:integer";
    std::string floatnum= "xsd:float";
    if(strcmp(integer.c_str(), yytext) == 0){
      flagInteger = true;
    }
    if(strcmp(floatnum.c_str(), yytext) == 0){
      flagFloat = true;
    }
    flagDado = true;
    std::string prop(ultimaPropiedade);
    std::string linha = " (linha " + std::to_string(yylineno) + ")";
    prop += linha;
    dataProps.push_back(prop);
  }
  ;

cardi:
  {numError = 9;} CARDI                    {cout << "CARDI ";}
  {
    if(flagInteger == true){
      flagInteger = false;
    } else {
      if(flagDado == true){
        if(flagFloat == false){
            cout << RED << "\nErro semântico: o tipo de dado deveria ser xsd:integer" << " (linha " << yylineno << ")\n" << RESET;
        } else {
          cout << RED << "\nErro semântico: o dado '" << yytext << "' deve ser do tipo xsd:float" << " (linha " << yylineno << ")\n" << RESET;
          flagFloat = false;
        }
      }
    }
  }
  | {numError = 9;} CARDIF                    {cout << "CARDIF ";}
  {
    if(flagFloat == true){
      flagFloat = false;
    } else {
      if(flagDado == true){
        if(flagInteger == false){
          cout << RED << "\nErro semântico: o tipo de dado deveria ser xsd:float" << " (linha " << yylineno << ")\n" << RESET;
        } else {
        cout << RED << "\nErro semântico: o dado '" << yytext << "' deve ser do tipo xsd:integer" << " (linha " << yylineno << ")\n" << RESET;
          flagInteger = false;
        }
      }
    }
  }
  ;

relop:
  {numError = 10;} RELOP                   {cout << "RELOP ";}
  ;

oper:
  {numError = 11;} OPERADOR                {cout << "OPERADOR ";}
  {if(strcmp("some", yytext) == 0){
    flagSome = true;
  }
  if(strcmp("only", yytext) == 0){
    flagOnly = true;
  }
  }
  ;

or:
  {numError = 12;} OR                      {cout << "OR ";}
  ;

and:
  {numError = 13;} AND                     {cout << "\nAND ";}
  ;

prop:
  {numError = 14;} PROPIEDADE              {cout << "PROPIEDADE ";}
  {
    ultimaPropiedade = new char[strlen(yytext) + 1];
    strcpy(ultimaPropiedade, yytext);}
  | {numError = 22;} INVERSE {numError = 14;} PROPIEDADE              {cout << "INVERSE PROPIEDADE ";}
  {
    ultimaPropiedade = new char[strlen(yytext) + 1];
    strcpy(ultimaPropiedade, yytext);}
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
  mapaClasse[4] = "Dupla";

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
  mapaError[22] = "Esperava-se 'INVERSE'";
  
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

  int i = 0;
  cout << "\nData Propertys encontradas:\n";
  for(auto& e : dataProps){
    cout << "\t" << e << "\n";
    i++;
  }
  cout << "\n\tContagem total: " << i << "\n";
  i = 0;
  cout << "\nObject Propertys encontradas:\n";
  for(auto& e : objProps){
    cout << "\t" << e << "\n";
    i++;
  }
  cout << "\n\tContagem total: " << i << "\n";
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
