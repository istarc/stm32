#include "CppUTest/TestHarness.h"


TEST_GROUP(FirstTestGroup)
{

};

TEST(FirstTestGroup, FirstTest)
{
   //FAIL("Fail me!\n");
   LONGS_EQUAL(1, 1);
   //FAIL("Fail me!\n\r");
}

