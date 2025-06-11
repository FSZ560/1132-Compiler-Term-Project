<cpp_main>
#include <iostream>
using namespace std;

int main() {
    int x = 500;
    int y = 60;
    
    BRIDGE_CALL(add_numbers, x, y) -> result;
    cout << result << endl;

    x = 1000, y = 5000;
    BRIDGE_CALL(add_numbers, x, y) -> result2;
    cout << result2 << endl;
    
    return 0;
}
</cpp_main>

<python_functions>
def add_numbers(x, y):
    return x * y
</python_functions>