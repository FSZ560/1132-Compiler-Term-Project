%{
#include "bridge.tab.h"
#include <stdlib.h>
#include <string.h>
%}

%x CPP_SECTION PYTHON_SECTION BRIDGE_MODE

%%

"<cpp_main>"            { BEGIN(CPP_SECTION); return CPP_START; }
"<python_functions>"    { BEGIN(PYTHON_SECTION); return PY_START; }

<CPP_SECTION>"</cpp_main>"       { BEGIN(INITIAL); return CPP_END; }
<CPP_SECTION>"BRIDGE_CALL"       { BEGIN(BRIDGE_MODE); return BRIDGE_CALL; }
<CPP_SECTION>.|\n                { yylval.str = strdup(yytext); return CPP_CODE; }

<BRIDGE_MODE>"("                 { return LPAREN; }
<BRIDGE_MODE>")"                 { return RPAREN; }
<BRIDGE_MODE>","                 { return COMMA; }
<BRIDGE_MODE>"->"                { return ARROW; }
<BRIDGE_MODE>";"                 { BEGIN(CPP_SECTION); return SEMICOLON; }
<BRIDGE_MODE>[a-zA-Z_][a-zA-Z0-9_]* { yylval.str = strdup(yytext); return IDENTIFIER; }
<BRIDGE_MODE>[0-9]+              { yylval.str = strdup(yytext); return INT_CONST; }
<BRIDGE_MODE>[ \t\r\n]           { /* ignore */ }
<BRIDGE_MODE>\"([^\\\"]|\\.)*\" {
    yylval.str = strdup(yytext + 1);
    yylval.str[strlen(yylval.str) - 1] = '\0';
    return STRING_LITERAL;
}

<PYTHON_SECTION>"</python_functions>" { BEGIN(INITIAL); return PY_END; }
<PYTHON_SECTION>.|\n             { yylval.str = strdup(yytext); return PY_CODE; }

.|\n                             { /* ignore */ }

%%

int yywrap() { return 1; }
