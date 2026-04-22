%{
#include "parser.tab.h"
#include <string.h>
%}

%option noyywrap yylineno

%%

[ \t\n]+                { }

"suno"                  { return KEYWORD_SUNO; }
"agar"                  { return COND_AGAR; }
"nahi to"               { return COND_NAHI_TO; }
"chalo"                 { return KEYWORD_CHALO; }
"times"                 { return KEYWORD_TIMES; }
"kaam"                  { return KEYWORD_KAAM; }
"wapas"                 { return KEYWORD_WAPAS; }
"number"                { return DATATYPE_NUMBER; }
"shabd"                 { return DATATYPE_SHABD; }

[0-9]+                  { yylval.num = atoi(yytext); return NUMBER; }
\"[^\"]*\"              { yylval.str = strdup(yytext); return STRING; }
[“|”]                   { /* Catch smart quotes and ignore or handle as error */ }

[a-zA-Z_][a-zA-Z0-9_]* { yylval.str = strdup(yytext); return IDENTIFIER; }

[=+<>\-*/]              { return yytext[0]; }
[(){};,\[\]]            { return yytext[0]; }

.                       { printf("Unknown character: %s\n", yytext); }

%%
