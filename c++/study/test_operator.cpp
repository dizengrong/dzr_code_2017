#include <iostream>
using namespace std;
class CAverage
{
public:
    double operator()(int a1, int a2, int a3)
    {  //重载()运算符
        return (double)(a1 + a2 + a3) / 3;
    }

    double operator()(int a1, int a2, int a3, int a4)
    {  //重载()运算符
        return (double)(a1 + a2 + a3) / 3;
    }
};
int main(int argc,char *argv[])
{
    cout << argv[1] << endl;
    CAverage average;  //能够求三个整数平均数的函数对象
    cout << average(3, 2, 3) << endl;  //等价于 cout << average.operator(3, 2, 3);
    #ifdef __cplusplus
    cout<<"C++";
    #else
    cout<<"c";
    #endif
    return 0;
}
