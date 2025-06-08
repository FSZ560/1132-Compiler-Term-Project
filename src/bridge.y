%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

extern int yylex();
void yyerror(const char* s);

char* cpp_code = NULL;
char* python_code = NULL;

void append_cpp(const char* code);
void generate_bridge_call(char* func, char* params, char* result);
%}

%union {
    char* str;
}

%token <str> IDENTIFIER CPP_CODE PY_CODE
%token CPP_START CPP_END PY_START PY_END BRIDGE_CALL ARROW LPAREN RPAREN COMMA SEMICOLON
%type <str> param_list

%%

program: sections { 
    // Generate temp.cpp
    FILE* f = fopen("generated/temp.cpp", "w");
    fprintf(f, "#include \"../src/bridge_interface.h\"\n#include <iostream>\n#include <string>\n\n%s", cpp_code);
    fclose(f);
    
    // Generate temp.py
    if (python_code) {
        f = fopen("generated/temp.py", "w");
        fprintf(f, "import sys\n%s\nif __name__ == \"__main__\":\n    result = globals()[sys.argv[1]](*[int(p) for p in sys.argv[2].split(',')])\n    print(result)\n", python_code);
        fclose(f);
    }
}
;

sections: section | sections section ;
section: cpp_section | python_section ;

cpp_section: CPP_START cpp_content CPP_END ;
cpp_content: /* empty */ | cpp_content cpp_element ;
cpp_element: CPP_CODE { append_cpp($1); } | bridge_statement ;

bridge_statement: BRIDGE_CALL LPAREN IDENTIFIER COMMA param_list RPAREN ARROW IDENTIFIER SEMICOLON {
    generate_bridge_call($3, $5, $8);
}
;

param_list: IDENTIFIER { $$ = $1; }
| param_list COMMA IDENTIFIER {
    $$ = (char*)malloc(strlen($1) + strlen($3) + 3);
    sprintf($$, "%s, %s", $1, $3);
}
;

python_section: PY_START python_content PY_END ;
python_content: /* empty */ | python_content PY_CODE {
    if (!python_code) python_code = strdup($2);
    else {
        python_code = (char*)realloc(python_code, strlen(python_code) + strlen($2) + 1);
        strcat(python_code, $2);
    }
}
;

%%

void yyerror(const char* s) { fprintf(stderr, "Error: %s\n", s); }

void append_cpp(const char* code) {
    if (!cpp_code) cpp_code = strdup(code);
    else {
        cpp_code = (char*)realloc(cpp_code, strlen(cpp_code) + strlen(code) + 1);
        strcat(cpp_code, code);
    }
}

void generate_bridge_call(char* func, char* params, char* result) {
    char code[500];
    char param_str[300] = "";
    
    // Parse parameters and build conversion string
    char* param_copy = strdup(params);
    char* token = strtok(param_copy, ",");
    int first = 1;
    
    while (token != NULL) {
        // Trim whitespace
        while (*token == ' ') token++;
        char* end = token + strlen(token) - 1;
        while (end > token && *end == ' ') *end-- = '\0';
        
        if (!first) strcat(param_str, " + \",\" + ");
        strcat(param_str, "std::to_string(");
        strcat(param_str, token);
        strcat(param_str, ")");
        
        first = 0;
        token = strtok(NULL, ",");
    }
    
    sprintf(code, "int %s = bridge_call(\"%s\", %s);\n    ", result, func, param_str);
    append_cpp(code);
    free(param_copy);
}