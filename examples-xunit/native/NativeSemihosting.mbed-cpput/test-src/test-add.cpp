#include "CppUTest/TestHarness.h"
#include "dadd.h"

TEST_GROUP(ThirdTestGroup)
{

};

TEST(ThirdTestGroup, TestDAdd)
{
   LONGS_EQUAL(dadd(0,0), 0);
   LONGS_EQUAL(dadd(0,1), 1);
   LONGS_EQUAL(dadd(1,0), 1);
   LONGS_EQUAL(dadd(1,1), 2);
}

