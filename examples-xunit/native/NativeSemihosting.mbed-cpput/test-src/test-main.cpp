/*
 * Disable coverage testing by removing 
 * (i)   "-lgcov" (Makefile-test, line 70);
 * (ii)  "-fprofile-arcs -ftest-coverage" (Makefile-test, line 143, 152);
 * (iii) "extern "C" void __gcov_flush();" (src-test/test-main.cpp, line 5);
 * (iv)  "__gcov_flush();" (src-test/test-main.cpp, line 14).
 */

//#include "mbed.h"
#include <stdio.h>
#include "CppUTest/CommandLineTestRunner.h"

extern "C" void __gcov_flush();

int main() {
	int argc = 2;
	char* argv[] = {"", "-v"};

	printf("--- Test Start ---\n"); // Required for automated testing
	//MemoryLeakWarningPlugin::turnOffNewDeleteOverloads(); // Disables memory leaks detection
	CommandLineTestRunner::RunAllTests(argc, argv); // Run All Tests
	__gcov_flush(); // Required for coverage testing
	printf("--- Test End ---\n"); // Required for automated testing

	return 0;
}
