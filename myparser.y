%{
    #define KNRM        "\x1B[0m"
    #define KRED        "\x1B[31m"
    #define KGRN        "\x1B[32m"
    #define KYEL        "\x1B[33m"
    #define KBLU        "\x1B[34m"
    #define KMAG        "\x1B[35m"
    #define KCYN        "\x1B[36m"
    #define KWHT        "\x1B[37m"
    
    #include <stdio.h>
    #include <math.h>
    #include "cgen.h"

    extern int yylex(void);
    extern int lineNum;
%}

%union
{
    char* str;
    int intNum;
    double doubleNum;
}

%token KW_integer KW_scalar KW_str KW_bool KW_const KW_comp KW_endcomp KW_of
%token KW_True KW_False
%token KW_if KW_else KW_endif
%token KW_for KW_in KW_endfor KW_while KW_endwhile KW_break KW_continue
%token KW_def KW_enddef KW_main KW_return

%token <intNum> KW_DIGIT
%token KW_CHAR
%token <str> KW_IDENTIFIER
%token <doubleNum> KW_REAL
%token <intNum> KW_NUMBER
%token KW_ESC_CHAR
%token <str> KW_CONSTANT_CHAR
%token <str> KW_CONSTANT_STR

%start code

%type <str> code
%type <str> instr

%type <str> function_statement
%type <str> function_parameters
%type <str> while_statement
%type <str> for_statement
%type <str> if_statement
%type <str> assign_op
%type <str> declare_type
%type <str> vars
%type <str> give_value
%type <str> var
%type <str> arrays
%type <str> type
%type <str> expr

%left '.' '(' ')' '[' ']'
%right "**"
%left '*' '/' '%' '+' '-'
%left '<' "<=" '>' ">=" "==" "!="
%right "not"
%left "and" "or"
%right '=' "+=" "-=" "*=" "/=" "%=" ":="

%%

code:  
    instr                           { $$ = template("%s\n", $1); }
    | code instr                    { $$ = template("%s\n%s", $1, $2); }
    ;

instr:
    assign_op
    |function_statement
    |while_statement
    |for_statement
    |if_statement
    |declare_type
    ;

function_statement:
    KW_def KW_IDENTIFIER '(' function_parameters ')' "->" type ':' code KW_enddef
    {$$ = template("%s %s (%s) {\n%s\n}", $7, $2, $4, $9);}

function_parameters:
    KW_IDENTIFIER ':' type          { $$ = template("%s %s", $3, $1);}
    | function_parameters ',' KW_IDENTIFIER ':' type
    { $$ = template("%s, %s %s", $1, $5, $3);}
    ;

while_statement:
    KW_while '(' expr ')' ':' code KW_endwhile ';'
    {$$ = template("while(%s){\n%s\n}",$3, $6);}
    ;

for_statement:
    KW_for KW_IDENTIFIER KW_in '[' KW_NUMBER ':' KW_NUMBER ':' KW_NUMBER ']' ':' code KW_endfor ';'
    {$$ = template("for (int %s = %s; %s < %s; %s += %s) {\n%s\n}\n", $2, $5, $2, $7, $2, $9, $12);}
    ;

if_statement:
    KW_if '(' expr ')' ':' code KW_endif ';'
    {$$ = template("if (%s) {\n%s\n}\n", $3, $6);} 
    |KW_if '(' expr ')' ':' code KW_else ':' code KW_endif 
    {$$ = template("if (%s) {\n%s\n} else {\n%s\n}\n", $3, $6, $9);} 
    ;

assign_op:
    var '=' expr                    { $$ = template("%s = %s;", $1, $3); }
    |var "+=" expr                  { $$ = template("%s += %s;", $1, $3); }
    |var "-=" expr                  { $$ = template("%s -= %s;", $1, $3); }
    |var "*=" expr                  { $$ = template("%s *= %s;", $1, $3); }
    |var "/=" expr                  { $$ = template("%s /= %s;", $1, $3); }
    |var "%=" expr                  { $$ = template("%s \%= %s;", $1, $3); }
    |var ":=" expr                  { $$ = template("%s = %s;", $1, $3); }
    ;

declare_type:
    vars ':' type                   { $$ = template("%s %s;", $3, $1); ; }
    ;

vars:
    give_value
    |var
    |vars ',' give_value            { $$ = template("%s , %s", $1, $3); }
    |vars ',' var                   { $$ = template("%s , %s", $1, $3); }
    ;

give_value:
    var '=' expr                    { $$ = template("%s = %s", $1, $3); }
    |var ":=" expr                  { $$ = template("%s = %s", $1, $3); }
    ;

var:
    KW_IDENTIFIER                   { $$ = template("%s", $1); }
    |KW_IDENTIFIER arrays           { $$ = template("%s%s", $1, $2); }
    ;
    
arrays:
    '[' expr ']'                    { $$ = template("[%s]", $2);}
    |arrays '[' expr ']'            { $$ = template("%s[%s]"), $1, $3;}
    ;

type: 
    KW_integer                      { $$ = template("int"); }
    | KW_scalar                     { $$ = template("double"); }
    | KW_str                        { $$ = template("string"); }
    | KW_bool                       { $$ = template("int"); }
    ;

expr:
    KW_REAL                         { $$ = template("%s",$1); }
    |KW_NUMBER                      { $$ = template("%s",$1); }
    |KW_CONSTANT_STR                { $$ = template("%s",$1); }
    |var                            { $$ = template("%s",$1); }
    |KW_True                        { $$ = template("1"); }
    |KW_False		                { $$ = template("0"); }
    |'(' expr ')'                   { $$ = template("(%s)",$2); }
    | expr "**" expr                { $$ = template("%s ** %s", $1, $3); }
    | expr '*' expr                 { $$ = template("%s * %s", $1, $3); }
    | expr '/' expr                 { $$ = template("%s / %s", $1, $3); }
    | expr '%' expr                 { $$ = template("%s \% %s", $1, $3); }
    | expr '+' expr                 { $$ = template("%s + %s", $1, $3); }
    | expr '-' expr                 { $$ = template("%s - %s", $1, $3); }
    | expr '<' expr                 { $$ = template("%s < %s", $1, $3); }
    | expr "<=" expr                { $$ = template("%s <= %s", $1, $3); }
    | expr '>' expr                 { $$ = template("%s > %s", $1, $3); }
    | expr ">=" expr                { $$ = template("%s >= %s", $1, $3); }
    | expr "==" expr                { $$ = template("%s == %s", $1, $3); }
    | expr "!=" expr                { $$ = template("%s != %s", $1, $3); }
    | expr "not" expr               { $$ = template("! %s", $3); }
    | expr "and" expr               { $$ = template("%s && %s", $1, $3); }
    | expr "or" expr                { $$ = template("%s || %s", $1, $3); }
    ;

%%
int main( int argc, char **argv )
{
    extern FILE *yyin;
    ++argv, --argc; /* skip over program name */
    if ( argc > 0 )
        yyin = fopen( argv[0], "r" );
    else
        yyin = stdin;
    
    if ( yyparse() == 1 )
        printf("/*-Rejected!-*/\n/* Unrecognized token in line %d: ", lineNum);
}