#include "mbed.h"
#include "CppUTest/CommandLineTestRunner.h"

int main() {
	int argc = 2;
	char* argv[] = {"", "-v"};
	printf("Hello World\n");
	
	//MemoryLeakWarningPlugin::turnOffNewDeleteOverloads(); // Uncomment to disable memory leaks detection
	CommandLineTestRunner::RunAllTests(argc, argv);
	fflush(stdout);

	while(1);
}
