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
extern "C" {
#include <stdlib.h>
#include <stdio.h>
}
#include "CppUTest/CommandLineTestRunner.h"

extern "C" void __gcov_flush();

int main() {
	int argc = 0;
	char* argv[] = {""};
	printf("Executing Unit Tests ...\n");
	CommandLineTestRunner::RunAllTests(argc, argv);
	__gcov_flush();
	return 0;
}
