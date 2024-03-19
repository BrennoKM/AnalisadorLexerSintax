%{
#include <iostream>
#include "__sintax.tab.h"

using namespace std;

%}
%option noyywrap
%option yylineno

delim	[ \t]
brancos {delim}+
digito	[0-9]
letraMa  [A-Z]
letraMi  [a-z]
letras  ({letraMa}|{letraMi})*

classe  {letraMa}([_]?{letras})*
individuo {classe}{digito}+
dado    ({letraMi}+):{letraMi}+
owlClass "Class:"|"CLASS:"|"class:"
owlSubClassOf "SubClassOf:"|"SUBCLASSOF:"|"subclassof:"
owlDisjointClasses "DisjointClasses:"|"DISJOINTCLASSES:"|"disjointclasses"
owlIndividuals "Individuals:"|"INDIVIDUALS:"|"individuals:"
owlEquivalentTo "EquivalentTo:"|"EQUIVALENTTO:"|"equivalentto:"
some    "some"|"SOME"
all     "all"|"ALL"
value   "value"|"VALUE"
min     "min"|"MIN"
max     "max"|"MAX"
exactly "exactly"|"EXACTLY"
that    "that"|"THAT"
not     "not"|"NOT"
and     "and"|"AND"
or      "or"|"OR"
only "only"|"ONLY"
relop (">"|"<"|">="|"<=")
propiedade  "has"{letraMa}{letras}|"is"{letraMa}{letras}"Of"|{letraMi}{letras}*
cardinalidade [0-9]+


%%

{brancos} ; 
{some}    return OPERADOR;
{all}     return OPERADOR;
{value}   return OPERADOR;
{min}     return OPERADOR;
{max}     return OPERADOR;
{exactly} return OPERADOR;
{that}    return OPERADOR;
{not}     return OPERADOR;
{only}    return OPERADOR;
{or}      return OR;
{and}     return AND;


{owlClass} return OWLCLASS;
{owlSubClassOf} return OWLSUBCLASSOF;
{owlDisjointClasses} return OWLDISJOINTCLASSES;
{owlIndividuals} return OWLINDIVIDUALS;
{owlEquivalentTo} return OWLEQUIVALENTTO;
{classe} return CLASSE;
{individuo} return INDIVIDUO;
{dado} return DADO;
{propiedade} return PROPIEDADE;
{cardinalidade} return CARDI;
{relop} return RELOP;

"{" return '{';
"}" return '}';
"[" return '[';
"]" return ']';
"(" return '(';
")" return ')';
"," return ',';
\n ;

%%

