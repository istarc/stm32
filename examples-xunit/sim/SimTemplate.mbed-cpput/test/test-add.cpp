#include "CppUTest/TestHarness.h"
#include "add.h"

TEST_GROUP(SecondTestGroup)
{

};

TEST(SecondTestGroup, TestAdd)
{
   LONGS_EQUAL(add(0,0), 0);
   LONGS_EQUAL(add(0,1), 1);
   LONGS_EQUAL(add(1,0), 1);
   LONGS_EQUAL(add(1,1), 2);
}

