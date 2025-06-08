#include "bridge_interface.h"
#include <cstdlib>
#include <string>
#include <memory>

int bridge_call(const std::string& func_name, const std::string& params) {
    std::string cmd = "python3 generated/temp.py " + func_name + " " + params;
    
    FILE* pipe = popen(cmd.c_str(), "r");
    if (!pipe) return -1;
    
    char buffer[128];
    std::string result;
    while (fgets(buffer, sizeof(buffer), pipe)) {
        result += buffer;
    }
    pclose(pipe);
    
    return std::stoi(result);
}