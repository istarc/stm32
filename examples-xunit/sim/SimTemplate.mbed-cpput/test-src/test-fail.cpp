#include "CppUTest/TestHarness.h"


TEST_GROUP(FirstTestGroup)
{

};

TEST(FirstTestGroup, FirstTest)
{
   FAIL("Fail me!\n");
}

