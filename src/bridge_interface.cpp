#include "bridge_interface.h"
#include <cstdlib>
#include <sstream>

std::string bridge_call(const std::string& func_name, const std::string& params) {

    std::string command = "python3 generated/temp.py " + func_name + " \"" + params + "\"";
    FILE* pipe = popen(command.c_str(), "r");
    if (!pipe) return "Error";
    
    char buffer[128];
    std::string result = "";
    while (fgets(buffer, sizeof(buffer), pipe) != NULL) {
        result += buffer;
    }
    pclose(pipe);

    if (!result.empty() && result.back() == '\n') {
        result.pop_back();
    }
    
    return result;
}

std::string bridge_call(const std::string& func_name, int param) {
    return bridge_call(func_name, std::to_string(param));
}

std::string bridge_call(const std::string& func_name, double param) {
    return bridge_call(func_name, std::to_string(param));
}

std::string bridge_call(const std::string& func_name, int param1, int param2) {
    std::string params = std::to_string(param1) + "," + std::to_string(param2);
    return bridge_call(func_name, params);
}
