#include <iostream>
#include <memory>

int main(int argc, char const *argv[])
{
    std::unique_ptr<int[]> arrary;
    std::cout << "hello world" << std::endl;

    double d = 1.234;
    int i;
    i = static_cast<double>(d);
    std::cout << "i = " << i << std::endl;
    std::cout << "char b = " << 'b' << std::endl;
    std::cout << "static_cast char b = " << static_cast<int>('b') << std::endl;

    return 0;
}