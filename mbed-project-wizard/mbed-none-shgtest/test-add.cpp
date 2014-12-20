#include "gtest/gtest.h"
#include "dadd.h"

TEST(ThirdTestGroup, TestDAdd)
{
   EXPECT_EQ(dadd(0,0), 0);
   EXPECT_EQ(dadd(0,1), 1);
   EXPECT_EQ(dadd(1,0), 1);
   EXPECT_EQ(dadd(1,1), 2);
}

