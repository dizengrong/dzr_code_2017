#include <stdio.h>
#include <string.h>
#include <iostream>
using namespace std;

int  a=4;

int  &f(int  x)

{    a=a+x;

      return  a;

}

int main(void)

{    int   t=5;

     cout<<f(t)<<endl; // a = 9

    f(t)=20;             //a = 20

    cout<<f(t)<<endl;     //t = 5,a = 20  a = 25

    t=f(t);                //a = 30 t = 30

    cout<<f(t)<<endl;      //a = 60 t = 30
    cout << t << endl;

    char ori[]="hello中文";  
    char *copy=new char[10];  
    strcpy(copy, ori);
    copy[0] = 'i';
    bool is_same = ori == copy;

    cout << ori << endl;
    cout << copy << endl;
    cout << is_same << endl;
}
