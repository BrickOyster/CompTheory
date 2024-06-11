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
    
    #include "cgen.h"
    #include  "myparser.tab.h"

    int lineNum  = 1;
    char macro_regex[100];
    char macro_name[100];
    
    typedef struct Macro {
        char *name;
        char *regex;
    } Macro;

    Macro macros[100];
    int macro_count = 0;
    char* comps[100];
    int comp_count = 0;

    void add_comp(const char *name){
        comps[comp_count] = strdup(name);
        comp_count++;
    }

    int is_comp(const char *name) {
        for (int i = 0; i < comp_count; i++) {
            if (strcmp(comps[i], name) == 0) {
                return 1;
            }
        }
        return 0;
    }

    void add_macro(const char *name, const char *regex) {
        macros[macro_count].name = strdup(name);
        macros[macro_count].regex = strdup(regex);
        macro_count++;
    }

    char* get_macro_regex(const char *name) {
        for (int i = 0; i < macro_count; i++) {
            if (strcmp(macros[i].name, name) == 0) {
                return macros[i].regex;
            }
        }
        return NULL;
    }
%}

%x COMMENT 
%x MACRO
%x COMP

DIGIT                   [0-9]
CHAR                    [a-zA-Z]
SYMBOL                  [-+*/:_$%!#@&~^()]
IDENTIFIER              [a-zA-Z][0-9a-zA-Z_]*
NUMBER                  {DIGIT}+
DECIMAL                 ("."{NUMBER})|({NUMBER}("."{NUMBER}))
REAL                    {DECIMAL}([eE][+-]?{NUMBER})?
ESC_CHAR                ("\\n"|"\\t"|"\\r"|"\\\\"|"\\\"")
NONPRINT                [^"\\"^"\'"^"\""^"\n"]
CONSTANT_CHAR           ("\'")({ESC_CHAR}|{NONPRINT})("\'")
CONSTANT_STR            ("\"")({ESC_CHAR}|{NONPRINT})*("\"")

%%

"-*"                    {BEGIN(COMMENT); ; }

<COMMENT>[^*\n]*        /* eat anything that's not a '*' */
<COMMENT>"*"+[^*\-\n]*  /* eat up '*'s not followed by '-'s */
<COMMENT>\n             ++lineNum;
<COMMENT>"*"+"-"        { BEGIN(INITIAL); }

"@defmacro"             { BEGIN(MACRO); }

<MACRO>{IDENTIFIER}     { strcpy(macro_name, yytext); yymore(); }
<MACRO>"="|[ \r\t]+     { /* Ignore the '=' character or whitespaces */ }
<MACRO>[^\n ^IDENTIFIER]+ {
    strcpy(macro_regex, yytext);
    add_macro(macro_name, macro_regex);
    BEGIN(INITIAL);
}

comp                    { BEGIN(COMP); yylval.str = strdup(yytext); return KW_comp; }

<COMP>#                 { /* Skip #.(not valid in c) */ }
<COMP>{IDENTIFIER}      { add_comp(yytext); BEGIN(INITIAL); yylval.str = strdup(yytext); return KW_IDENTIFIER; }

integer|int             { yylval.str = strdup(yytext); return KW_integer; }
scalar                  { yylval.str = strdup(yytext); return KW_scalar; }
str                     { yylval.str = strdup(yytext); return KW_str; }
boolean|bool            { yylval.str = strdup(yytext); return KW_bool; }
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
endcomp                 { yylval.str = strdup(yytext); return KW_endcomp; }
of                      { yylval.str = strdup(yytext); return KW_of; }
void                    { yylval.str = strdup(yytext); return KW_void; }

"."                     { yylval.str = strdup(yytext); return KW_dot; }
"("                     { yylval.str = strdup(yytext); return KW_openpar; }
")"                     { yylval.str = strdup(yytext); return KW_closepar; }
"["                     { yylval.str = strdup(yytext); return KW_openbr; }
"]"                     { yylval.str = strdup(yytext); return KW_closebr; }

"**"                    { yylval.str = strdup(yytext); return KW_pow; }
"*"                     { yylval.str = strdup(yytext); return KW_mult; }
"/"                     { yylval.str = strdup(yytext); return KW_div; }
"%"                     { yylval.str = strdup(yytext); return KW_mod; }
"+"                     { yylval.str = strdup(yytext); return KW_add; }
"-"                     { yylval.str = strdup(yytext); return KW_sub; }

"<"                     { yylval.str = strdup(yytext); return KW_less; }
"<="                    { yylval.str = strdup(yytext); return KW_lesseq; }
">"                     { yylval.str = strdup(yytext); return KW_greater; }
">="                    { yylval.str = strdup(yytext); return KW_greatereq; }
"=="                    { yylval.str = strdup(yytext); return KW_equal; }
"!="                    { yylval.str = strdup(yytext); return KW_notequal; }

"not"                   { yylval.str = strdup(yytext); return KW_not; }
"and"                   { yylval.str = strdup(yytext); return KW_and; }
"or"                    { yylval.str = strdup(yytext); return KW_or; }

"="                     { yylval.str = strdup(yytext); return KW_assign; }
"+="                    { yylval.str = strdup(yytext); return KW_addassign; }
"-="                    { yylval.str = strdup(yytext); return KW_subassign; }
"*="                    { yylval.str = strdup(yytext); return KW_multassign; }
"/="                    { yylval.str = strdup(yytext); return KW_divassign; }
"%="                    { yylval.str = strdup(yytext); return KW_modassign; }
":="                    { yylval.str = strdup(yytext); return KW_cassign; }

";"                     { yylval.str = strdup(yytext); return KW_semicolon; }
","                     { yylval.str = strdup(yytext); return KW_comma; }
":"                     { yylval.str = strdup(yytext); return KW_colon; }

#                       { yylval.str = strdup(yytext); return KW_hash; }
"->"                    { yylval.str = strdup(yytext); return KW_funcrettype; }

{IDENTIFIER}            { 
    char *regex = get_macro_regex(yytext);
    if(regex) { yylval.str = strdup(regex); return KW_IDENTIFIER; }
    else if(is_comp(yytext)){ yylval.str = strdup(yytext); return KW_udclass; }
    else { yylval.str = strdup(yytext); return KW_IDENTIFIER; }
}

{NUMBER}                { yylval.str = strdup(yytext); return KW_NUMBER; }
{REAL}                  { yylval.str = strdup(yytext); return KW_REAL; }
{CONSTANT_CHAR}         { yylval.str = strdup(yytext); return KW_CONSTANT_CHAR; }
{CONSTANT_STR}          { yylval.str = strdup(yytext); return KW_CONSTANT_STR; }

[ \r\t]+                /* Eat up whitespace */


"--"[^\n]*		        /* Eat line comments */

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