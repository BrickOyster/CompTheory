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
    #include <string.h>
    #include <stdlib.h>
    #include <math.h>

    #include "cgen.h"
    #include "lambdalib.h"

    extern int yylex(void);
    extern int lineNum;
%}

%union
{
    char* str;
    int intNum;
    double doubleNum;
}

%token KW_integer KW_scalar KW_str KW_bool KW_const KW_comp KW_endcomp KW_of KW_complocalvar KW_void
%token KW_True KW_False
%token KW_if KW_else KW_endif
%token KW_for KW_in KW_endfor KW_while KW_endwhile KW_break KW_continue
%token KW_def KW_enddef KW_main KW_return KW_funcrettype
%token KW_semicolon KW_comma KW_colon

%token <str> KW_IDENTIFIER
%token <str> KW_REAL
%token <str> KW_NUMBER
%token <str> KW_CONSTANT_CHAR
%token <str> KW_CONSTANT_STR

%start out

%type <str> out
%type <str> program
%type <str> code
%type <str> instr
%type <str> return_instr
%type <str> loop_instr

%type <str> main
%type <str> comp_struct
%type <str> compvars
%type <str> functioncall
%type <str> function_statements
%type <str> function_statement
%type <str> function_parameters
%type <str> functioncall_statement
%type <str> functioncall_parameters
%type <str> while_statement
%type <str> for_statement
%type <str> if_statement
%type <str> assign_op
%type <str> declare_constants
%type <str> declare_type
%type <str> vars
%type <str> give_value
%type <str> var
%type <str> arrays
%type <str> type
%type <str> expr

%left KW_dot KW_openpar KW_closepar KW_openbr KW_closebr
%right KW_pow
%left KW_mult KW_div KW_mod KW_add KW_sub
%left KW_less KW_lesseq KW_greater KW_greatereq KW_equal KW_notequal
%right KW_not
%left KW_and KW_or
%right KW_assign KW_addassign KW_subassign KW_multassign KW_divassign KW_modassign KW_cassign

%%



out:
    program
    { printf("#include <stdio.h>\n#include <string.h>\n#include <stdlib.h>\n#include <math.h>\n\n#include \"cgen.h\"\n#include\"lambdalib.h\"\n%s", $1); }
    ;

program:    
    code main                           
    { $$ = template("%s\n%s", $1, $2); }
    ;

code:
    instr
    |return_instr
    |loop_instr
    |code instr                         { $$ = template("%s\n%s", $1, $2); }
    |code return_instr                  { $$ = template("%s\n%s", $1, $2); }
    |code loop_instr                    { $$ = template("%s\n%s", $1, $2); }
    ;

instr:
    assign_op
    |functioncall
    |declare_constants
    |function_statement
    |while_statement
    |for_statement
    |if_statement
    |declare_type
    |comp_struct
    ;

return_instr:
    KW_return expr KW_semicolon         { $$ = template("return %s;\n", $2); }
    |KW_return KW_semicolon             { $$ = template("return ;\n"); }
    ;

loop_instr:
    KW_break KW_semicolon               { $$ = template("break;\n"); }
    |KW_continue KW_semicolon           { $$ = template("continue;\n"); }
    ;

main:
    KW_def KW_main KW_openpar KW_closepar KW_colon code KW_enddef KW_semicolon
    {$$ = template("int main ( ) {\n%s\n}", $6);}
    ;

comp_struct:
    KW_comp KW_IDENTIFIER KW_colon compvars function_statements KW_endcomp KW_semicolon
    { $$ = template("Class %s {\n %s\n%s\n}", $2, $4, $5); }

function_statements:
    %empty                              { $$ = template(""); }
    |function_statements function_statement
    { $$ = template("%s\n%s", $1, $2); }
    ;

compvars:
    declare_constants
    |declare_type
    |compvars declare_type              { $$ = template("%s\n%s", $1, $2); }
    |compvars declare_constants         { $$ = template("%s\n%s", $1, $2); }
    ;

functioncall:
    functioncall_statement KW_semicolon { $$ = template("%s;", $1); }    

functioncall_statement:
    KW_IDENTIFIER KW_openpar functioncall_parameters KW_closepar
    { $$ = template("%s (%s)", $1, $3);}
    ;

functioncall_parameters:
    %empty                              { $$ = template("");}
    |expr                               
    |functioncall_parameters KW_comma expr  
    { $$ = template("%s, %s", $1, $3);}
    ;

function_statement:
    KW_def KW_IDENTIFIER KW_openpar function_parameters KW_closepar KW_funcrettype type KW_colon code KW_enddef KW_semicolon
    { $$ = template("%s %s (%s) {\n%s\n}", $7, $2, $4, $9);}
    |KW_def KW_IDENTIFIER KW_openpar function_parameters KW_closepar KW_colon code KW_enddef KW_semicolon
    { $$ = template("void %s (%s) {\n%s\n}", $2, $4, $7);}
    ;

function_parameters:
    %empty                              { $$ = template(""); }
    |var KW_colon type                  { $$ = template("%s %s", $3, $1);}
    |function_parameters KW_comma var KW_colon type  
    { $$ = template("%s, %s %s", $1, $5, $3);}
    ;

while_statement:
    KW_while KW_openpar expr KW_closepar KW_colon code KW_endwhile KW_semicolon
    {$$ = template("while(%s){\n%s\n}",$3, $6);}
    ;

for_statement:
    KW_for KW_IDENTIFIER KW_in KW_openbr expr KW_colon expr KW_colon expr KW_closebr KW_colon code KW_endfor KW_semicolon
    {$$ = template("for (int %s = %s; %s < %s; %s += %s) {\n%s\n}\n", $2, $5, $2, $7, $2, $9, $12);}
    |KW_for KW_IDENTIFIER KW_in KW_openbr expr KW_colon expr KW_closebr KW_colon code KW_endfor KW_semicolon
    {$$ = template("for (int %s = %s; %s < %s; %s ++) {\n%s\n}\n", $2, $5, $2, $7, $2, $10);}
    ;

if_statement:
    KW_if KW_openpar expr KW_closepar KW_colon code KW_endif KW_semicolon
    {$$ = template("if (%s) {\n%s\n}\n", $3, $6);} 
    |KW_if KW_openpar expr KW_closepar KW_colon code KW_else KW_colon code KW_endif KW_semicolon
    {$$ = template("if (%s) {\n%s\n} else {\n%s\n}\n", $3, $6, $9);} 
    ;

assign_op:
    var KW_assign expr KW_semicolon     { $$ = template("%s = %s;", $1, $3); }
    |var KW_addassign expr KW_semicolon { $$ = template("%s += %s;", $1, $3); }
    |var KW_subassign expr KW_semicolon { $$ = template("%s -= %s;", $1, $3); }
    |var KW_multassign expr KW_semicolon{ $$ = template("%s *= %s;", $1, $3); }
    |var KW_divassign expr KW_semicolon { $$ = template("%s /= %s;", $1, $3); }
    |var KW_modassign expr KW_semicolon { $$ = template("%s \%= %s;", $1, $3); }
    ;

declare_constants:
    KW_const declare_type               { $$ = template("const %s;", $2); }
    ;

declare_type:
    vars KW_colon type KW_semicolon     { $$ = template("%s %s;", $3, $1); }
    ;

vars:
    give_value
    |var
    |give_value KW_comma vars           { $$ = template("%s, %s", $1, $3); }
    |var KW_comma vars                  { $$ = template("%s, %s", $1, $3); }
    ;

give_value:
    var KW_assign expr                  { $$ = template("%s = %s", $1, $3); }
    ;

var:
    KW_IDENTIFIER                       { $$ = template("%s", $1); }
    |KW_IDENTIFIER arrays               { $$ = template("%s%s", $1, $2); }
    ;
    
arrays:
    KW_openbr expr KW_closebr           { $$ = template("[%s]", $2);}
    |arrays KW_openbr expr KW_closebr   { $$ = template("%s[%s]"), $1, $3;}
    |KW_openbr KW_closebr               { $$ = template("[]");}
    |arrays KW_openbr KW_closebr        { $$ = template("%s[]"), $1;}
    ;

type: 
    KW_integer                          { $$ = template("int"); }
    | KW_scalar                         { $$ = template("double"); }
    | KW_str                            { $$ = template("string"); }
    | KW_bool                           { $$ = template("int"); }
    | KW_void                           { $$ = template("void"); }
    ;

expr:
    KW_REAL                             
    |KW_NUMBER                          
    |KW_CONSTANT_STR                    
    |KW_CONSTANT_CHAR                   
    |var                                
    |functioncall_statement
    |KW_True                            { $$ = template("1"); }
    |KW_False		                    { $$ = template("0"); }
    |KW_openpar expr KW_closepar        { $$ = template("(%s)",$2); }
    |expr KW_pow expr                   { $$ = template("pow(%s, %s)", $1, $3); }
    |KW_add expr                        { $$ = template("+%s",$2); }
    |KW_sub expr                        { $$ = template("-%s",$2); }
    |expr KW_mult expr                  { $$ = template("%s * %s", $1, $3); }
    |expr KW_div expr                   { $$ = template("%s / %s", $1, $3); }
    |expr KW_mod expr                   { $$ = template("%s \% %s", $1, $3); }
    |expr KW_add expr                   { $$ = template("%s + %s", $1, $3); }
    |expr KW_sub expr                   { $$ = template("%s - %s", $1, $3); }
    |expr KW_less expr                  { $$ = template("%s < %s", $1, $3); }
    |expr KW_lesseq expr                { $$ = template("%s <= %s", $1, $3); }
    |expr KW_greater expr               { $$ = template("%s > %s", $1, $3); }
    |expr KW_greatereq expr             { $$ = template("%s >= %s", $1, $3); }
    |expr KW_equal expr                 { $$ = template("%s == %s", $1, $3); }
    |expr KW_notequal expr              { $$ = template("%s != %s", $1, $3); }
    |KW_not expr                        { $$ = template("! %s", $2); }
    |expr KW_and expr                   { $$ = template("%s && %s", $1, $3); }
    |expr KW_or expr                    { $$ = template("%s || %s", $1, $3); }
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
        printf("/*-Rejected!-*/\n/* Unrecognized token in line %d: %s\n", lineNum, yylval.str);
}