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
    #include "cgen.h"

    extern int yylex(void);
    extern int lineNum;
%}

%token KW_integer KW_scalar KW_str KW_bool KW_const
%token KW_True KW_False
%token KW_not KW_and KW_or KW_of
%token KW_if KW_else KW_endif
%token KW_for KW_in KW_endfor KW_while KW_endwhile KW_break KW_continue
%token KW_def KW_enddef KW_main KW_return KW_comp KW_endcomp

%%

/*--- Data types ---*/
Type: 
    KW_integer      {}
    | KW_scalar     {}
    | KW_str        {}
    | KW_bool       {}
    | KW_const      {}
    ;

Bool:
    KW_True         {}
    | KW_False      {}
    ;

Logical_operators: 
    KW_and          {}
    | KW_or         {}
    | KW_not        {}
    ;  

Conditional:
    KW_if           {}
    | KW_else       {}
    | KW_endif      {}
    ;

Loops:
    KW_for          {}
    | KW_in         {}
    | KW_endfor     {}
    | KW_while      {}
    | KW_endwhile   {}
    | KW_break      {}
    | KW_continue   {}
    ;

Definitions:
    KW_def          {}
    | KW_enddef     {}
    | KW_main       {}
    | KW_return     {}
    | KW_comp       {}
    | KW_endcomp    {}
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
    
    if ( yyparse() == 0 )
        printf("/*--------------Your program is syntactically correct!-------*/\n");
    else
        printf("/*-------------------------Rejected!-------------------------*/\n/* Unrecognized token in line %d: ", lineNum);
}