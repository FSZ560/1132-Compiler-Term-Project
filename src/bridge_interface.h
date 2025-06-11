#ifndef BRIDGE_INTERFACE_H
#define BRIDGE_INTERFACE_H
#include <string>


std::string bridge_call(const std::string& func_name, const std::string& params);


std::string bridge_call(const std::string& func_name, int param);


std::string bridge_call(const std::string& func_name, double param);

std::string bridge_call(const std::string& func_name, int param1, int param2);

#endif
