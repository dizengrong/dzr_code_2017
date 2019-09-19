#include <iostream>


class Circle
{
    public:
    constexpr Circle (int x, int y, int radius) : _x( x ), _y( y ), _radius( radius ) {}
    constexpr double getArea ()
    {
        return _radius * _radius * 3.1415926;
    }
    private:
        int _x;
        int _y;
        int _radius;
};


int main(int argc, char const *argv[])
{
    Circle c( 0, 0, 10 );
    double area = c.getArea();
    std::cout << "area = " << area << std::endl;
    
    return 0;
}