#include "gtest/gtest.h"
#include "add.h"

TEST(SecondTestGroup, TestAdd)
{
   EXPECT_EQ(add(0,0), 0);
   EXPECT_EQ(add(0,1), 1);
   EXPECT_EQ(add(1,0), 1);
   EXPECT_EQ(add(1,1), 2);
}

