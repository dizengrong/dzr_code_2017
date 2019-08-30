#define CATCH_CONFIG_MAIN  // This tells Catch to provide a main() - only do this in one cpp file
#include "catch.hpp"

// g++ -std=c++11 -Wall -I$(CATCH_SINGLE_INCLUDE) -c TestMain.cpp
// g++ -std=c++11 -Wall -I$(CATCH_SINGLE_INCLUDE) -o TestMain TestMain.o TestCase.cpp && TestMain --success


TEST_CASE( "1: All test cases reside in other .cpp files (empty)", "[multi-file:1]" ) {
}

