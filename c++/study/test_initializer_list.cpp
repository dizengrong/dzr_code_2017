#include <iostream>
#include <vector>
#include <string>
#include <map>

using namespace std;


class MyType {
 public:
  // std::initializer_list 专门接收 init 列表。
  // 得以值传递。
  MyType(std::initializer_list<int> init_list) {
    for (int i : init_list) append(i);
  }
  MyType& operator=(std::initializer_list<int> init_list) {
    clear();
    for (int i : init_list) append(i);
  }
};
MyType m{2, 3, 5, 7};


// 初始化列表也可以用在返回类型上的隐式转换。
vector<int> test_function() { 
    return {1, 2, 3}; 
}

int main(int argc, char const *argv[])
{
    // Vector 接收了一个初始化列表。
    vector<string> v{"foo", "bar"};

    // 不考虑细节上的微妙差别，大致上相同。
    // 您可以任选其一。
    vector<string> v2 = {"foo", "bar"};
    for (string s : v2) {
        std::cout << "s = " << s << std::endl;
    }

    // 可以配合 new 一起用。
    auto p = new vector<string>{"foo", "bar"};

    // map 接收了一些 pair, 列表初始化大显神威。
    map<int, string> m = {{1, "one"}, {2, "2"}};
    std::cout << "m[1] = " << m[1] << std::endl;

    // 初始化列表可迭代。
    for (int i : {-1, -2, -3}) {
        std::cout << "i = " << i << std::endl;
    }

    return 0;
}
