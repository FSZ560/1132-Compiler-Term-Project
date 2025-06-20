<cpp_main>
#include <iostream>
using namespace std;

int main() {
    cout << "=== Bridge Interpreter Advanced Example ===" << endl;
    
    int base = 5;
    int exponent = 3;
    
    cout << "Computing " << base << " raised to the power of " << exponent << endl;
    
    BRIDGE_CALL(power_function, base, exponent) -> power_result;
    
    cout << "Power result: " << power_result << endl;
    
    int number = 17;
    
    BRIDGE_CALL(is_prime, number) -> prime_check;
    
    if (std::stoi(prime_check) == 1) {
        cout << number << " is a prime number!" << endl;
    } else {
        cout << number << " is not a prime number." << endl;
    }
    
    BRIDGE_CALL(fibonacci, 10) -> fib_result;
    
    cout << "10th Fibonacci number: " << fib_result << endl;
    
    string message = "hello world";
    BRIDGE_CALL(shout, message) -> shouted_message;
    cout << "Shouted message: " << shouted_message << endl;
    return 0;
}
</cpp_main>

<python_functions>
def power_function(base, exponent):
    result = base ** exponent
    return result

def is_prime(n):
    if n < 2:
        return 0
    for i in range(2, int(n**0.5) + 1):
        if n % i == 0:
            return 0
    return 1

def fibonacci(n):
    if n <= 1:
        return n
    a, b = 0, 1
    for _ in range(2, n + 1):
        a, b = b, a + b
    return b
def shout(text):
    return text.upper() + "!!!"
</python_functions>
