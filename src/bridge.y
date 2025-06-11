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

%token <str> IDENTIFIER INT_CONST CPP_CODE PY_CODE
%token CPP_START CPP_END PY_START PY_END BRIDGE_CALL ARROW LPAREN RPAREN COMMA SEMICOLON
%token <str> STRING_LITERAL
%type <str> param_list param_item

%%

program: sections { 
    // Generate temp.cpp
    FILE* f = fopen("generated/temp.cpp", "w");
    fprintf(f, "#include \"../src/bridge_interface.h\"\n#include <iostream>\n#include <string>\n\n%s", cpp_code);
    fclose(f);
    
    // Generate temp.py
    if (python_code) {
        f = fopen("generated/temp.py", "w");
        fprintf(f, "import sys\nimport ast\n%s\n", python_code);
        fprintf(f,
                "def parse_param(p):\n"
                "    try:\n"
                "        return int(p)\n"
                "    except ValueError:\n"
                "        try:\n"
                "            return ast.literal_eval(p)\n"
                "        except:\n"
                "            return p\n"
                "if __name__ == \"__main__\":\n"
        	"    try:\n"
       		"        result = globals()[sys.argv[1]](*[parse_param(p) for p in sys.argv[2].split(',')])\n"
       		"        print(result)\n"
        	"    except:\n"
        	"        pass\n");
                
                
                
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

param_list: param_item { $$ = $1; }
| param_list COMMA param_item {
    $$ = (char*)malloc(strlen($1) + strlen($3) + 3);
    sprintf($$, "%s, %s", $1, $3);
}
;

param_item: IDENTIFIER { $$ = $1; }
          | INT_CONST  { $$ = $1; }
          | STRING_LITERAL { 
              char* wrapped = (char*) malloc(strlen($1) + 3);
              sprintf(wrapped, "\\\"%s\\\"", $1); 
              $$ = wrapped;
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
    
    int is_string_literal = (token[0] == '\\' && token[1] == '"' &&
                            token[strlen(token)-1] == '"' && token[strlen(token)-2] == '\\');
    
    if (is_string_literal) {

        char* clean_str = (char*)malloc(strlen(token) + 1);
        strcpy(clean_str, token + 2); 
        clean_str[strlen(clean_str) - 2] = '\0';  
        strcat(param_str, "\"");
        strcat(param_str, clean_str);
        strcat(param_str, "\"");
        free(clean_str);
    } else {

        int is_digit = 1;
        for (char* p = token; *p; ++p) {
            if (*p < '0' || *p > '9') {
                is_digit = 0;
                break;
            }
        }
        
        if (is_digit) {

            strcat(param_str, "\"");
            strcat(param_str, token);
            strcat(param_str, "\"");
        } else {
            if (strstr(token, "message") != NULL || strstr(token, "str") != NULL) {
                strcat(param_str, token);
            } else {
                strcat(param_str, "std::to_string(");
                strcat(param_str, token);
                strcat(param_str, ")");
            }
        }
    }
    
    first = 0;
    token = strtok(NULL, ",");
}
    
    sprintf(code, "std::string %s = bridge_call(\"%s\",%s);\n    ", result, func, param_str);
    append_cpp(code);
    free(param_copy);
}
