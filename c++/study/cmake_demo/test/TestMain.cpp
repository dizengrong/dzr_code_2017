#define CATCH_CONFIG_MAIN  // This tells Catch to provide a main() - only do this in one cpp file
#include "catch.hpp"

// g++ -std=c++11 -Wall -c TestMain.cpp
// g++ -std=c++11 -Wall -o TestMain TestMain.o TestCase.cpp && TestMain --success


TEST_CASE( "1: All test cases reside in other .cpp files (empty)", "[multi-file:1]" ) {
}

