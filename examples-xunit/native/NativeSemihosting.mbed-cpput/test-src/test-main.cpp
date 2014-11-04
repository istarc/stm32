/* Private define ------------------------------------------------------------*/
/* Private macro -------------------------------------------------------------*/
/* Private variables ---------------------------------------------------------*/
/* Private function prototypes -----------------------------------------------*/
/* Private functions ---------------------------------------------------------*/

/**
  * @brief  Main program
  * @param  None
  * @retval None
  */
//#include "mbed.h"
#include <stdio.h>
#include "CppUTest/CommandLineTestRunner.h"

extern "C" void __gcov_flush();

int main() {
	int argc = 3;
	char* argv[] = {"", "-v", "-c"};
	printf("Hello World\n");
	
	//MemoryLeakWarningPlugin::turnOffNewDeleteOverloads(); // Uncomment to disable memory leaks detection
	CommandLineTestRunner::RunAllTests(argc, argv);
	__gcov_flush();

	return 0;
}
