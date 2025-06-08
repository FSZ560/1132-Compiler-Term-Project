#include <iostream>
#include <cstdlib>

extern int yyparse();
extern FILE* yyin;

int main(int argc, char* argv[]) {
    if (argc != 2) {
        std::cerr << "Usage: " << argv[0] << " <file.cy>" << std::endl;
        return 1;
    }
    
    yyin = fopen(argv[1], "r");
    if (!yyin) {
        std::cerr << "Cannot open file: " << argv[1] << std::endl;
        return 1;
    }
    
    if (yyparse() != 0) {
        std::cerr << "Parse failed" << std::endl;
        return 1;
    }
    fclose(yyin);
    
    // Compile and run
    system("g++ -o generated/temp_program generated/temp.cpp src/bridge_interface.cpp -I src/");
    system("./generated/temp_program");
    
    return 0;
}