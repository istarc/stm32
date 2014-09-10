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

Serial console(PA_2,PA_3);

int main(int argc, char* argv[]) {
	return CommandLineTestRunner::RunAllTests(argc, argv);
	//printf("Alo");
}

