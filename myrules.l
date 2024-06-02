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
    #include "cgen.h"
    #include  "myparser.tab.h"

    int lineNum  = 1;
%}

%x COMMENT 

DIGIT                   [0-9]
CHAR                    [a-zA-Z]
SYMBOL                  [-+*/:_$%!#@&~^()]
IDENTIFIER              [a-zA-Z][0-9a-zA-Z_]*
NUMBER                  [+-]?{DIGIT}+
DECIMAL                 ([+-]?"."{NUMBER})|([+-]?{NUMBER}("."{NUMBER}?)?)
REAL                    {DECIMAL}([eE][+-]?{NUMBER})?
BOOLEAN                 ("True"|"False")
ESC_CHAR                ("\\n"|"\\t"|"\\r"|"\\\\"|"\\\"")
NONPRINT                [^"\\"^"\'"^"\""^"\n"]
CONSTANT_CHAR           ("\'")({ESC_CHAR}|{NONPRINT})("\'")
CONSTANT_STR            ("\"")({ESC_CHAR}|{NONPRINT})*("\"")
ARITHMETIC_OPERATOR     ([+*/%]|"**"|"-")
RELATIONAL_OPERATOR     ("=="|"!="|"<"|"<="|">"|">=")
LOGIC_OPERATOR          ("and"|"or"|"not")
ASSIGNMENT_OPERATOR     (=|"+="|"-="|"*="|"/="|"%="|":=")
PROSIMO_OPERATOR        ("+"|"-")
DELIMITER               (";"|"("|")"|","|"["|"]"|":"|".")

%%

integer                 { yylval = strdup(yytext); return KW_integer; }
scalar                  { yylval = strdup(yytext); return KW_scalar; }
str                     { yylval = strdup(yytext); return KW_str; }
bool                    { yylval = strdup(yytext); return KW_bool; }
True                    { yylval = strdup(yytext); return KW_True; }
False                   { yylval = strdup(yytext); return KW_False; }
const                   { yylval = strdup(yytext); return KW_const; }
if                      { yylval = strdup(yytext); return KW_if; }
else                    { yylval = strdup(yytext); return KW_else; }
endif                   { yylval = strdup(yytext); return KW_endif; }
for                     { yylval = strdup(yytext); return KW_for; }
in                      { yylval = strdup(yytext); return KW_in; }
endfor                  { yylval = strdup(yytext); return KW_endfor; }
while                   { yylval = strdup(yytext); return KW_while; }
endwhile                { yylval = strdup(yytext); return KW_endwhile; }
break                   { yylval = strdup(yytext); return KW_break; }
continue                { yylval = strdup(yytext); return KW_continue; }
not                     { yylval = strdup(yytext); return KW_not; }
and                     { yylval = strdup(yytext); return KW_and; }
or                      { yylval = strdup(yytext); return KW_or; }
def                     { yylval = strdup(yytext); return KW_def; }
enddef                  { yylval = strdup(yytext); return KW_enddef; }
main                    { yylval = strdup(yytext); return KW_main; }
return                  { yylval = strdup(yytext); return KW_return; }
comp                    { yylval = strdup(yytext); return KW_comp; }
endcomp                 { yylval = strdup(yytext); return KW_endcomp; }
of                      { yylval = strdup(yytext); return KW_of; }

{DIGIT}                 { yylval = strdup(yytext); return KW_DIGIT; }
{CHAR}                  { yylval = strdup(yytext); return KW_CHAR; }
{BOOLEAN}               { yylval = strdup(yytext); return KW_BOOLEAN; }
{LOGIC_OPERATOR}        { yylval = strdup(yytext); return KW_LOGIC_OPERATOR; }
{IDENTIFIER}            { yylval = strdup(yytext); return KW_IDENTIFIER; }
{REAL}                  { yylval = strdup(yytext); return KW_REAL; }
{ESC_CHAR}              { yylval = strdup(yytext); return KW_ESC_CHAR; }
{CONSTANT_CHAR}         { yylval = strdup(yytext); return KW_CONSTANT_CHAR; }
{CONSTANT_STR}          { yylval = strdup(yytext); return KW_CONSTANT_STR; }
{ARITHMETIC_OPERATOR}   { yylval = strdup(yytext); return KW_ARITHMETIC_OPERATOR; }
{RELATIONAL_OPERATOR}   { yylval = strdup(yytext); return KW_RELATIONAL_OPERATOR; }
{ASSIGNMENT_OPERATOR}   { yylval = strdup(yytext); return KW_ASSIGNMENT_OPERATOR; }
{PROSIMO_OPERATOR}      { yylval = strdup(yytext); return KW_PROSIMO_OPERATOR; }
{DELIMITER}             { yylval = strdup(yytext); return KW_DELIMITER; }

[ \r\t]+                /* Eat up whitespace */

"--"[^\n]*		        { printf("%sLine %02d: line comment: %s %s\n",KYEL, lineNum, yytext, KNRM); ; } /* Eat line comments */
"-*"                    { BEGIN(COMMENT); printf("%sMultiline Comment started at line: %02d %s\n", KYEL, lineNum, KNRM); ; }

<COMMENT>[^*\n]*        /* eat anything that's not a '*' */
<COMMENT>"*"+[^*\-\n]*  /* eat up '*'s not followed by '-'s */
<COMMENT>\n             ++lineNum;
<COMMENT>"*"+"-"        { BEGIN(INITIAL); printf("%sMultiline Comment ended at line: %02d %s\n", KYEL, lineNum, KNRM); ; }

<<EOF>>			            return EOF;

\n					    ++lineNum;
.                       { printf("%sLine %02d: Error. Unrecognized literal     := %s %s\n", KRED, lineNum, yytext, KNRM); ; }

%%
// int main( int argc, char **argv )
// {
//     ++argv, --argc; /* skip over program name */
//     if ( argc > 0 )
//         yyin = fopen( argv[0], "r" );
//     else
//         yyin = stdin;
//     yylex();
// }