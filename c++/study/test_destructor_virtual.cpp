// 这段程序演示了为什么析构函数必须为虚函数
#include<iostream>
using namespace std;
class ClxBase{
public:
    ClxBase() {};
    virtual ~ClxBase() {cout << "Output from the destructor of class ClxBase!" << endl;};

    void DoSomething() { cout << "Do something in class ClxBase!" << endl; };
};

class ClxDerived : public ClxBase{
public:
    ClxDerived() {};
    virtual ~ClxDerived() { cout << "Output from the destructor of class ClxDerived!" << endl; };

    void DoSomething() { cout << "Do something in class ClxDerived!" << endl; };
};

int   main(){  
	ClxBase *p =  new ClxDerived();
	p->DoSomething();
	delete p;
	return 0;
}
