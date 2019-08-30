#include "TestClass.h"

TestClass::TestClass(): m_data(0) {}


int TestClass::add(int a){
	m_data = m_data + a;
	return m_data;
}
