/*
 * Disable coverage testing by removing 
 * (i)   "-lgcov" (Makefile-test, line 70);
 * (ii)  "-fprofile-arcs -ftest-coverage" (Makefile-test, line 143, 152);
 * (iii) "extern "C" void __gcov_flush();" (src-test/test-main.cpp, line 5);
 * (iv)  "__gcov_flush();" (src-test/test-main.cpp, line 14).
 */

#include <stdio.h>
#include "gtest/gtest.h"

extern "C" void __gcov_flush();

int main() {
	int argc = 1;
	char* argv[] = {""};

	printf("--- Test Start ---\n"); // Required for automated testing
	testing::InitGoogleTest(&argc, argv);
	RUN_ALL_TESTS();

	__gcov_flush(); // Required for coverage testing
	printf("--- Test End ---\n"); // Required for automated testing

	return 0;
}
