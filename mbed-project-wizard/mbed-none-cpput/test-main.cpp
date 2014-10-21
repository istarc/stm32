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
#include "mbed.h"
#include "CppUTest/CommandLineTestRunner.h"

int main() {
	int argc = 3;
	char* argv[] = {"", "-v", "-c"};
	printf("Hello World\n");
	CommandLineTestRunner::RunAllTests(argc, argv);
	fflush(stdout);

	while(1);
}
