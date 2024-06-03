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
ESC_CHAR                ("\\n"|"\\t"|"\\r"|"\\\\"|"\\\"")
NONPRINT                [^"\\"^"\'"^"\""^"\n"]
CONSTANT_CHAR           ("\'")({ESC_CHAR}|{NONPRINT})("\'")
CONSTANT_STR            ("\"")({ESC_CHAR}|{NONPRINT})*("\"")

%%

integer                 { yylval.str = strdup(yytext); return KW_integer; }
scalar                  { yylval.str = strdup(yytext); return KW_scalar; }
str                     { yylval.str = strdup(yytext); return KW_str; }
bool                    { yylval.str = strdup(yytext); return KW_bool; }
True                    { yylval.str = strdup(yytext); return KW_True; }
False                   { yylval.str = strdup(yytext); return KW_False; }
const                   { yylval.str = strdup(yytext); return KW_const; }
if                      { yylval.str = strdup(yytext); return KW_if; }
else                    { yylval.str = strdup(yytext); return KW_else; }
endif                   { yylval.str = strdup(yytext); return KW_endif; }
for                     { yylval.str = strdup(yytext); return KW_for; }
in                      { yylval.str = strdup(yytext); return KW_in; }
endfor                  { yylval.str = strdup(yytext); return KW_endfor; }
while                   { yylval.str = strdup(yytext); return KW_while; }
endwhile                { yylval.str = strdup(yytext); return KW_endwhile; }
break                   { yylval.str = strdup(yytext); return KW_break; }
continue                { yylval.str = strdup(yytext); return KW_continue; }
def                     { yylval.str = strdup(yytext); return KW_def; }
enddef                  { yylval.str = strdup(yytext); return KW_enddef; }
main                    { yylval.str = strdup(yytext); return KW_main; }
return                  { yylval.str = strdup(yytext); return KW_return; }
comp                    { yylval.str = strdup(yytext); return KW_comp; }
endcomp                 { yylval.str = strdup(yytext); return KW_endcomp; }
of                      { yylval.str = strdup(yytext); return KW_of; }

"."                     { return ".";}
"("                     { return "(";}
")"                     { return ")";}
"["                     { return "[";}
"]"                     { return "]";}
"**"                    { return "**";}
"*"                     { return "*";}
"/"                     { return "/";}
"%"                     { return "%";}
"+"                     { return "+";}
"-"                     { return "-";}
"<"                     { return "<";}
"<="                    { return "<=";}
">"                     { return ">";}
">="                    { return ">=";}
"=="                    { return "==";}
"!="                    { return "!=";}
"not"                   { return "not"; }
"and"                   { return "and"; }
"or"                    { return "or"; }
"="                     { return "=";}
"+="                    { return "+=";}
"-="                    { return "-=";}
"*="                    { return "*=";}
"/="                    { return "/=";}
"%="                    { return "%=";}
":="                    { return ":=";}

";"                     { return ";";}
","                     { return ",";}
":"                     { return ":";}

{DIGIT}                 { yylval.str = strdup(yytext); return KW_DIGIT; }
{CHAR}                  { yylval.str = strdup(yytext); return KW_CHAR; }
{IDENTIFIER}            { yylval.str = strdup(yytext); return KW_IDENTIFIER; }
{NUMBER}                { yylval.str = strdup(yytext); return KW_NUMBER; }
{REAL}                  { yylval.str = strdup(yytext); return KW_REAL; }
{ESC_CHAR}              { yylval.str = strdup(yytext); return KW_ESC_CHAR; }
{CONSTANT_CHAR}         { yylval.str = strdup(yytext); return KW_CONSTANT_CHAR; }
{CONSTANT_STR}          { yylval.str = strdup(yytext); return KW_CONSTANT_STR; }

[ \r\t]+                /* Eat up whitespace */

"--"[^\n]*		        /* Eat line comments */
"-*"                    { BEGIN(COMMENT); ; }

<COMMENT>[^*\n]*        /* eat anything that's not a '*' */
<COMMENT>"*"+[^*\-\n]*  /* eat up '*'s not followed by '-'s */
<COMMENT>\n             ++lineNum;
<COMMENT>"*"+"-"        { BEGIN(INITIAL); ; }

<<EOF>>			        return EOF;

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